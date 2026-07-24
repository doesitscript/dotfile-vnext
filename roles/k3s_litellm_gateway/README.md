# k3s_litellm_gateway

Deploys the LiteLLM proxy on K3s using the official `litellm-helm` chart. Secrets are sourced from Ansible vault at apply time and written to Kubernetes Secrets; the chart references them with `os.environ/<VAR>` in `proxy_config`.

## Vault sources

| Vault file | Variables |
|------------|-----------|
| `vault/shared.vault.yml` | `vault_shared_openai_api_key`, `vault_shared_anthropic_api_key`, `vault_hf_token`, `vault_k3s_litellm_gateway_master_key`, Langfuse and Minio shared keys |
| `vault/network.vault.yml` | `vault_network_postgres_*` (same credentials as `/srv/stacks/network/.env`) |

Set a real OpenAI key before using the migration/provider routes:

```bash
ansible-vault edit vault/shared.vault.yml
# vault_shared_openai_api_key: "sk-..."
# vault_shared_anthropic_api_key: "sk-ant-..."   # optional; enables Claude COMPLEX/REASONING tiers
```

### Continue open-weight lanes (local only — not OpenRouter / Mercury)

Catalog weights under `inventory/group_vars/model_catalog/manifest.yml`, download
to `\\HOM-LAB-HVH-01\public\models\huggingface\`, serve on secondary vLLM, then
set api_bases so LiteLLM appends mature `model_list` rows:

```yaml
# inventory/host_vars/hom-lab-ctl-k3s-02.yaml (after secondary runtimes exist)
k3s_litellm_gateway_autocomplete_1_5b_api_base: "http://vllm-autocomplete-1.5b....:8000/v1"
k3s_litellm_gateway_autocomplete_7b_api_base: "http://vllm-autocomplete-7b....:8000/v1"
k3s_litellm_gateway_diffusiongemma_api_base: "http://vllm-diffusiongemma....:8000/v1"
k3s_litellm_gateway_diffucoder_api_base: "http://diffucoder-openai-wrapper....:8000/v1"
```

Lane aliases: `code-fast`, `code-autocomplete-1.5b`/`7b`, `diffusiongemma-nextedit`
(replaces Mercury), `diffucoder`, `continue-edit`. DiffuCoder needs an
OpenAI-compatible wrapper (`diffusion_generate` is not chat-native).

## Complexity auto-router (`smart-router`)

Requires LiteLLM **>= v1.94.x** (`auto_router/complexity_router`). The role keeps
`image_tag: main-latest` by default so the gateway can pick up that surface.

Clients call:

```text
model: smart-router
```

Tier map (local-first; Ollama retired — code-review aliases vllm-primary):

| Tier | Without cloud keys | With OpenAI | With Anthropic |
| --- | --- | --- | --- |
| SIMPLE | `code-review` (vLLM) | `code-review` (vLLM) | `code-review` (vLLM) |
| MEDIUM | Ornith | Ornith | Ornith |
| COMPLEX | Ornith | `gpt-4o` | `claude-sonnet` |
| REASONING | Ornith | `gpt-4o` | `claude-sonnet` |

This is **pre-request complexity classification**, not post-response confidence
handoff. Keyword rules for ansible/k3s/netbox escalate to COMPLEX/REASONING.

Disable with `k3s_litellm_gateway_complexity_router_enabled: false`.

## Message trim pre-call hook (local 32k safety net)

When `k3s_litellm_gateway_trim_messages_enabled` is true (default), the role:

1. Renders `templates/custom_callbacks.py.j2` into ConfigMap `litellm-callback-files`
2. Mounts it at `/etc/litellm/custom_callbacks.py` on the LiteLLM pod
   (beside `config.yaml` so LiteLLM can import `custom_callbacks` — not `/app/`)
3. Sets `litellm_settings.callbacks: custom_callbacks.proxy_handler_instance`
4. After Helm apply, restarts the LiteLLM Deployment so the ConfigMap `subPath`
   remounts the callback file, then waits up to **600s** for rollout (memory-pressure
   on k3s-02 can delay scheduling)

### Error that drove these custom values

Cursor Agent → LiteLLM → Ornith (`hosted_vllm` / Qwen on `vllm-primary`) failed with:

```text
litellm.ContextWindowExceededError / Hosted_vllmException (HTTP 400)
This model's maximum context length is 32768 tokens. However, you requested
0 output tokens and your prompt contains at least 32769 input tokens
(parameter=input_tokens, value=32769).
Received Model Group=deepreinforce-ai/Ornith-1.0-35B-GGUF
Available Model Group Fallbacks=None
```

What we learned from live evidence (not inference alone):

1. **Wrong model name was a separate issue** — Cursor briefly used `hosted_vllm`
   (provider prefix). Published aliases are `deepreinforce-ai/Ornith-1.0-35B-GGUF`
   / `smart-router`. Fixing the name did not fix overflow.
2. **Ornith was selected correctly** when the 32769 error appeared — the chat
   payload was simply over the **32k** vLLM window.
3. **No useful local context fallback** — without OpenAI/Anthropic keys,
   `context_window_fallbacks` is empty; `code-review` shares the same 32k backend.
4. **A naive trim to ~30000 was not enough** — pod logs showed the pre-call hook
   reporting `before≈60k after≈29993 budget=30000` and vLLM still rejecting with
   **32769**. LiteLLM’s counter undercounted vs Qwen/vLLM, and Agent **`tools`**
   schemas inflate the real prompt after message trim. Cursor also sends
   **`max_tokens: 0`**, which matches the “0 output tokens” wording in the error.

That sequence is why this role pins the server-tuned drivers below instead of
stock LiteLLM defaults. Diagnostic note:
`docs/diagnostics/litellm-context-window--k3s--diagnostics.md`.

### Mid-stream “Internal Server Error” (second failure mode)

After the overflow fix landed, Cursor Agent replies on Ornith sometimes **stopped
mid-sentence** and Cursor reported **Internal Server Error**. Live evidence:

- LiteLLM/vLLM often still returned **HTTP 200** (not a gateway crash).
- Hook logs showed Agent payloads with `tools_est≈26360`, message budget ≈`4104`,
  and **`requested_out=256`** from rewriting Cursor’s `max_tokens: 0` to a tiny floor.
- A 256-token completion cap truncates Agent streams (`finish_reason=length`);
  Cursor can surface that poorly as Internal Server Error.

Fix: prefer **4096** completion tokens, but **adaptively lower** that when tools
leave little room under 32768, while always reserving `min_message_tokens`.

### Server-tuned trim drivers

These are **custom homelab values**, not LiteLLM stock defaults. They exist so
Cursor Agent + Ornith on this cluster’s **32k** `vllm-primary` (Qwen AWQ) can
accept fat prompts instead of returning the `ContextWindowExceededError` above,
and so Agent streams are not cut at 256 tokens.

| Driver | Role variable / behavior | Homelab value | Driven by |
| --- | --- | --- | --- |
| Enable hook | `k3s_litellm_gateway_trim_messages_enabled` | `true` | No cloud overflow path when OpenAI key unset |
| Input budget | `k3s_litellm_gateway_trim_messages_max_input_tokens` | **24000** | 30000 still overflowed after tools/template |
| Safety margin | `k3s_litellm_gateway_trim_messages_safety_tokens` | **2048** | LiteLLM `after≈29993` vs vLLM `32769` disagreement |
| Preferred completion | `k3s_litellm_gateway_trim_messages_min_completion_tokens` | **4096** (adaptive) | Mid-stream cutoff + Cursor Internal Server Error when floor was 256 |
| Min messages | `k3s_litellm_gateway_trim_messages_min_message_tokens` | **2048** | Keep chat text when tools schemas are huge |
| Tools subtract | estimate from request `tools` JSON | dynamic | Agent tool schemas after message trim |
| Multimodal hard-cut | `k3s_litellm_gateway_trim_messages_chars_per_token` | **2.5** | Cursor `content` arrays under-trimmed by `trim_messages` alone |
| Deploy remount | `present.yml` rollout restart after ConfigMap | always when enabled | `subPath` mounts do not refresh in place |

Override any of the role variables in inventory if the cluster’s context window
or Cursor payload shape changes. Redeploy LiteLLM after changing them.

### Hook behavior

The pre-call hook runs before each chat completion (`acompletion` / `completion`):

- Token counting uses the served vLLM model id
  (`hosted_vllm/{{ k3s_litellm_gateway_primary_vllm_model }}`), not the client
  alias (e.g. Ornith). Alias-based counting under-trims vs Qwen/vLLM.
- Flattens multimodal `content` to strings before trim (avoids LiteLLM list/str concat errors).
- Completion = min(preferred, 32768 − safety − tools_est − min_messages); messages
  budget = remaining under that window and `max_input_tokens`.
- Uses `litellm.utils.trim_messages`, then a hard character cut across messages.
- Logs:
  - `litellm trim_messages hook: ... before=N after=M budget=... tools_est=... tool_count_total=...`
  - When `tools` is present: `tools_breakdown` with grouped totals
    (`cursor_builtin_tokens`, `mcp_context7_tokens`, `mcp_ansible_tokens`,
    `mcp_other_tokens`, `unknown_tokens`) plus one `tool=<name> tokens=...`
    line per schema (sorted largest first). Use this to measure which tools
    dominate the ~26k Agent tax on the 32k local window.

### Operator notes

| Topic | Detail |
| --- | --- |
| Mount path | `/etc/litellm/custom_callbacks.py` — LiteLLM loads callbacks next to config |
| ConfigMap refresh | `subPath` mounts do **not** update in place; role always `rollout restart` after apply |
| Rollout wait | `kubectl rollout status ... --timeout=600s` for memory-pressure delays |
| Disable | `k3s_litellm_gateway_trim_messages_enabled: false` and redeploy |

Verify with an oversized `/v1/chat/completions` to Ornith: expect HTTP 200 and a
`trim_messages hook` log line, not `ContextWindowExceededError`.

## Kubernetes secrets

| Secret | Keys |
|--------|------|
| `litellm-env-secret` | `PROXY_MASTER_KEY`, `OPENAI_API_KEY` (when set), `ANTHROPIC_API_KEY` (when set), `LANGFUSE_*` |
| `litellm-external-postgres` | `username`, `password` |

Helm `environmentSecrets` mounts `litellm-env-secret` into the pod; `proxy_config` uses `os.environ/OPENAI_API_KEY` and `os.environ/PROXY_MASTER_KEY`.

External PostgreSQL uses `k3s_litellm_gateway_db_endpoint` plus
`k3s_litellm_gateway_db_port` when rendering the database URL and status output.

## Model routes vs model catalog

`k3s_litellm_gateway_model_list` is the LiteLLM gateway route list. It defines
client-facing aliases such as `deepreinforce-ai/Ornith-1.0-35B-GGUF`, `experiment`, and the preserved
migration rows.

For the current slice:

- `deepreinforce-ai/Ornith-1.0-35B-GGUF` is the first real local coding lane
  (`model_info.trim_messages: true` — safety net enabled).
- `deepreinforce-ai/Ornith-1.0-35B-GGUF-no-trim` is the same `vllm-primary`
  weights with `model_info.trim_messages: false` (callback is opt-in; this
  alias is left untouched). Oversized prompts fail at vLLM (32k).
- The global LiteLLM callback only mutates requests when the resolved route’s
  `model_info.trim_messages` is true — currently only
  `deepreinforce-ai/Ornith-1.0-35B-GGUF` (not `smart-router`, `-no-trim`, or
  other aliases).
- `experiment` remains visible as a smoke alias, but it currently shares the
  same `vllm-primary` backend as `deepreinforce-ai/Ornith-1.0-35B-GGUF` until a second runtime exists.
- `gpt-4o-mini` and `default` stay present as migration rows while local-lane
  verification is still maturing.

The durable Hugging Face/storage catalog is separate:
`inventory/group_vars/model_catalog/manifest.yml`. That manifest tracks
candidate/downloaded/served model weights and their storage path on the
`HOM-LAB-HVH-01` public SMB share.

Do not duplicate the full catalog into this role. When a catalog row becomes a
served runtime, add or update the corresponding LiteLLM route here and keep the
route's `model_info.model_lane` aligned with its `model_name`.

## Langfuse trace metadata

The gateway supplies route-level metadata through LiteLLM `model_info`, including
`model_lane`, `routing_policy`, and `project`.

Per-request metadata such as `agent_role` and `context_class` is owned by the
IDE/agent client profile. Those values must be sent with the completion request
metadata, not hardcoded globally in the gateway, because planner, coder, tester,
reviewer, documenter, and steward traffic can share the same gateway.

## Playbook

```bash
ansible-playbook playbooks/deploy_litellm_gateway.yaml
```

Requires the shared fuzlang external data-plane declared in
`inventory/group_vars/all/fuzlang_external_services.yml` so external
PostgreSQL and the vault-aligned `.env` exist.

## Lifecycle

- `k3s_litellm_gateway_state: present` — deploy
- `k3s_litellm_gateway_state: absent` — remove Helm release and namespace
