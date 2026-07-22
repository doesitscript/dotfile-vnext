# k3s_litellm_gateway

Deploys the LiteLLM proxy on K3s using the official `litellm-helm` chart. Secrets are sourced from Ansible vault at apply time and written to Kubernetes Secrets; the chart references them with `os.environ/<VAR>` in `proxy_config`.

## Vault sources

| Vault file | Variables |
|------------|-----------|
| `vault/shared.vault.yml` | `vault_shared_openai_api_key`, `vault_k3s_litellm_gateway_master_key`, Langfuse and Minio shared keys |
| `vault/network.vault.yml` | `vault_network_postgres_*` (same credentials as `/srv/stacks/network/.env`) |

Set a real OpenAI key before using the migration/provider routes:

```bash
ansible-vault edit vault/shared.vault.yml
# vault_shared_openai_api_key: "sk-..."
# vault_shared_anthropic_api_key: "sk-ant-..."   # optional; enables Claude COMPLEX/REASONING tiers
```

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

### Hook behavior

The pre-call hook runs before each chat completion (`acompletion` / `completion`):

- Token counting uses the served vLLM model id
  (`hosted_vllm/{{ k3s_litellm_gateway_primary_vllm_model }}`), not the client
  alias (e.g. Ornith). Alias-based counting under-trims vs Qwen/vLLM.
- Budget defaults to `k3s_litellm_gateway_trim_messages_max_input_tokens` (**24000**),
  minus estimated `tools` JSON tokens, requested `max_tokens` (rewritten from 0
  to 256), and a safety margin for chat-template / tokenizer skew.
- Uses `litellm.utils.trim_messages`, then a hard character cut across messages
  (including multimodal `content` parts) so Cursor Agent payloads cannot slip past.
- Logs: `litellm trim_messages hook: ... before=N after=M budget=... tools_est=...`

This is the local safety net when OpenAI context-window fallbacks are empty.
Without the hook, Cursor/agent prompts one token over 32k return
`ContextWindowExceededError`.

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

- `deepreinforce-ai/Ornith-1.0-35B-GGUF` is the first real local coding lane.
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
