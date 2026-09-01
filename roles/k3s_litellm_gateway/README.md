# k3s_litellm_gateway

Deploys the LiteLLM proxy on K3s using the official `litellm-helm` chart. Secrets are sourced from Ansible vault at apply time and written to Kubernetes Secrets; the chart references them with `os.environ/<VAR>` in `proxy_config`.

## Vault sources

| Vault file | Variables |
|------------|-----------|
| `vault/shared.vault.yml` | `vault_shared_openai_api_key`, `vault_shared_anthropic_api_key`, `vault_hf_token`, `vault_shared_openrouter_api_key` (research/catalog; not LiteLLM route wiring by default), `vault_k3s_litellm_gateway_master_key`, Langfuse and Minio shared keys |
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

Lane client IDs (structured `model_name` values): see **Client model ID syntax**
above. Short catalog lanes: `code-fast`, `continue-autocomplete`, `diffusiongemma-nextedit`,
`diffucoder`, `continue-edit`/`continue-apply`, `open-webui-chat`, `architect`,
`open-webui-general`, `prompt-assist`, `kilo-main`, `kilo-fast` (Open WebUI / Kilo via desktop Ollama when the
matching `k3s_litellm_gateway_*_chat_api_base` is set).

## Client model ID syntax

LiteLLM `model_list[].model_name` values use structured client IDs defined in
`defaults/main/model_client_ids.yml`:

```text
<model-slug>@<host-slug>~<friendly-lane>
```

| Segment | Meaning |
| --- | --- |
| `model-slug` | Backend weight id (`:` and `/` → `-`) |
| `@` | Separates model from host |
| `host-slug` | Homelab surface (`desktop`, `hvh01`, `k3s02-vllm`, `openai`, `anthropic`, `litellm`) |
| `~` | Separates host from purpose lane |
| `friendly-lane` | Invented client purpose name (`code-fast`, `kilo-main`, `smart-router`, …) |

Entry kinds (also in `model_info.client_model_id_kind` when set):

- **FRIENDLY ALIAS** — one backend `model` + `api_base` (most routes).
- **MODEL GROUP** — router entry; fans out to other client `model_name` targets.
  Example: `complexity-router@litellm~smart-router` (LiteLLM complexity auto-router).

`model_info.model_lane` keeps the short catalog-friendly slug for tracing
(`code-fast`, `deepreinforce-ai/Ornith-1.0-35B-GGUF`, …) even when the client
`model_name` uses the structured form.

### Examples

| Client `model_name` | Kind | Backend |
| --- | --- | --- |
| `ornith-35b@k3s02-vllm~coder-primary` | FRIENDLY ALIAS | vLLM Ornith on k3s-02 |
| `qwen2.5-coder-1.5b@hvh01~code-fast` | FRIENDLY ALIAS | Ollama on HVH-01 |
| `devstral-24b@desktop~kilo-main` | FRIENDLY ALIAS | Desktop Ollama |
| `complexity-router@litellm~smart-router` | MODEL GROUP | Tier router |

## Complexity auto-router (`complexity-router@litellm~smart-router`)

Requires LiteLLM **>= v1.94.x** (`auto_router/complexity_router`). The role keeps
`image_tag: main-latest` by default so the gateway can pick up that surface.

Clients call:

```text
model: complexity-router@litellm~smart-router
```

Tier map (local-first; Ollama retired — SIMPLE tier aliases vllm-primary review lane):

| Tier | Without cloud keys | With OpenAI | With Anthropic |
| --- | --- | --- | --- |
| SIMPLE | `ornith-35b@k3s02-vllm~code-review` | same | same |
| MEDIUM | `ornith-35b@k3s02-vllm~coder-primary` | same | same |
| COMPLEX | `ornith-35b@k3s02-vllm~coder-primary` | `gpt-4o@openai~cloud-chat` | `claude-sonnet-4@anthropic~cloud-escalation` |
| REASONING | `ornith-35b@k3s02-vllm~coder-primary` | `gpt-4o@openai~cloud-chat` | `claude-sonnet-4@anthropic~cloud-escalation` |

This is **pre-request complexity classification**, not post-response confidence
handoff. Keyword rules for ansible/k3s/netbox escalate to COMPLEX/REASONING.

Disable with `k3s_litellm_gateway_complexity_router_enabled: false`.

## AI Request Inspector (observe-only callback)

When `k3s_litellm_gateway_request_inspector_enabled` is true (default), the role:

1. Renders `templates/custom_callbacks.py.j2` into ConfigMap `litellm-callback-files`
2. Mounts it at `/etc/litellm/custom_callbacks.py` on the LiteLLM pod
   (beside `config.yaml` so LiteLLM can import `custom_callbacks` — not `/app/`)
3. Sets `litellm_settings.callbacks: custom_callbacks.proxy_handler_instance`
4. After Helm apply, restarts the LiteLLM Deployment only when the callback
   ConfigMap or LiteLLM env/database secrets changed, or when the deployment is
   still unhealthy after converge; otherwise it verifies rollout status without
   forcing a restart

The inspector **does not trim or rewrite messages**. It emits one JSON line per
phase:

```text
litellm request_inspector {"model":{...},"context":{...},"largest_tools":[...],"warnings":[...],"finish_reason":...}
```

| Driver | Role variable | Default |
| --- | --- | --- |
| Enable | `k3s_litellm_gateway_request_inspector_enabled` | `true` |
| Max window | `k3s_litellm_gateway_request_inspector_max_window` | `32768` |
| Safety field | `k3s_litellm_gateway_request_inspector_safety_tokens` | `2048` |
| Tools warn % | `k3s_litellm_gateway_request_inspector_warn_tools_pct` | `0.75` |
| Conversation warn % | `k3s_litellm_gateway_request_inspector_warn_conversation_pct` | `0.05` |
| Dump on warn | `k3s_litellm_gateway_request_inspector_dump_tools_on_warn` | `true` |

### Archived trim_messages mutate path

The former pre-call **mutate** safety net (`trim_messages` + hard-cut, gated by
`model_info.trim_messages`) is archived at:

`roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`

That archive README documents the old `*_trim_messages_*` Ansible vars and how
to revive mutate in an emergency. Historical overflow / mid-stream evidence that
drove those drivers remains in
`docs/diagnostics/litellm-context-window--k3s--diagnostics.md`.

### Operator notes

| Topic | Detail |
| --- | --- |
| Mount path | `/etc/litellm/custom_callbacks.py` — LiteLLM loads callbacks next to config |
| ConfigMap refresh | `subPath` mounts do **not** update in place; role always `rollout restart` after apply |
| Rollout wait | `kubectl rollout status ... --timeout=600s` |
| Disable | `k3s_litellm_gateway_request_inspector_enabled: false` and redeploy |
| Verify | Agent call → pod logs contain `litellm request_inspector` JSON |

## Kubernetes secrets

| Secret | Keys |
|--------|------|
| `litellm-env-secret` | `PROXY_MASTER_KEY`, `OPENAI_API_KEY` (when set), `ANTHROPIC_API_KEY` (when set), `LANGFUSE_*` |
| `litellm-external-postgres` | `username`, `password` |

Helm `environmentSecrets` mounts `litellm-env-secret` into the pod; `proxy_config` uses `os.environ/OPENAI_API_KEY` and `os.environ/PROXY_MASTER_KEY`.

External PostgreSQL uses `k3s_litellm_gateway_db_endpoint` plus
`k3s_litellm_gateway_db_port` when rendering the database URL and status output.

## Model routes vs model catalog

`k3s_litellm_gateway_model_list` is the LiteLLM gateway route list. Client-facing
`model_name` values use the structured syntax in `defaults/model_client_ids.yml`
(`<model-slug>@<host-slug>~<friendly-lane>`).

For the current slice:

- `ornith-35b@k3s02-vllm~coder-primary` is the primary local coding lane (Ornith on vLLM).
  The live LiteLLM callback is the **Request Inspector** (observe-only).
- `ornith-35b@k3s02-vllm~coder-no-trim` is a historical alias from the
  trim era; both aliases now pass through unmutated. Oversized prompts fail at
  vLLM (32k). Archived mutate path:
  `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`.
- `ornith-35b@k3s02-vllm~experiment` remains visible as a smoke alias, but it currently shares the
  same `vllm-primary` backend as coder-primary until a second runtime exists.
- `gpt-4o-mini@openai~cloud-fast` and `ornith-35b@k3s02-vllm~default` stay present as migration rows while local-lane
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

Requires the shared Langfuse platform external data-plane declared in
`inventory/group_vars/all/langfuse_platform_external_services.yml` so external
PostgreSQL and the vault-aligned `.env` exist.

## Lifecycle

- `k3s_litellm_gateway_state: present` — deploy
- `k3s_litellm_gateway_state: absent` — remove Helm release and namespace
