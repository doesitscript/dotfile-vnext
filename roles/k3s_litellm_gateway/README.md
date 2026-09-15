# k3s_litellm_gateway

Deploys the LiteLLM proxy on K3s using the official `litellm-helm` chart. Secrets are sourced from Ansible vault at apply time and written to Kubernetes Secrets; the chart references them with `os.environ/<VAR>` in `proxy_config`.

## Vault sources

| Vault file | Variables |
|------------|-----------|
| `vault/shared.vault.yml` | `vault_shared_openai_api_key`, `vault_shared_anthropic_api_key`, `vault_shared_gemini_api_key`, `vault_shared_azure_ai_api_key` (prep), `vault_hf_token`, `vault_shared_openrouter_api_key` (research/catalog; not LiteLLM route wiring by default), `vault_k3s_litellm_gateway_master_key`, Langfuse and Minio shared keys |
| `vault/network.vault.yml` | `vault_network_postgres_*` (same credentials as `/srv/stacks/network/.env`) |

Set a real OpenAI key before using the migration/provider routes:

```bash
ansible-vault edit vault/shared.vault.yml
# vault_shared_openai_api_key: "sk-..."
# vault_shared_anthropic_api_key: "sk-ant-..."   # optional; enables Claude COMPLEX/REASONING tiers
# vault_shared_gemini_api_key: "AIza..."         # optional; enables Gemini free-tier routes (see below)
```

### Google Gemini cloud lanes (free tier)

When `vault_shared_gemini_api_key` is set, the role appends five routes from
`defaults/main/gemini_model_routes.yml` and injects `GEMINI_API_KEY` into
`litellm-env-secret`.

**Operator runbook:** [docs/reference/models/gemini-litellm-lanes.md](../../docs/reference/models/gemini-litellm-lanes.md)

| Client `model_name` | Backend | Highlight |
| --- | --- | --- |
| `gemini-2.5-flash-long-context` | `gemini/gemini-2.5-flash` | **1M ctx** — primary long-context lane |
| `gemini-2.5-pro` | `gemini/gemini-2.5-pro` | Hard reasoning — **not** max-context |
| `gemini-2.5-flash` | `gemini/gemini-2.5-flash` | Daily fast lane / tools |
| `gemini-2.5-flash-lite` | `gemini/gemini-2.5-flash-lite` | Bulk / Langfuse evals |
| `gemini-embedding-001` | `gemini/gemini-embedding-001` | Text embeddings |

Tip: use **long-context** for volume; use **deep-reasoning** for quality on hard
problems — both may share Flash/Pro backends but client IDs preserve intent in traces.

### Continue open-weight lanes (local only — not OpenRouter / Mercury)

Catalog weights under `inventory/group_vars/model_catalog/manifest.yml`, download
to `\\HOM-LAB-HVH-01\public\models\huggingface\`, serve on secondary vLLM, then
set api_bases so LiteLLM appends mature `model_list` rows:

```yaml
# inventory/host_vars/hom-lab-ctl-k3s-02.yaml (after secondary runtimes exist)
k3s_litellm_gateway_local_backends:
  fim_1_5b:
    api_base: "http://vllm-fim-1.5b....:8000/v1"
  fim_7b:
    api_base: "http://vllm-fim-7b....:8000/v1"
k3s_litellm_gateway_diffusiongemma_api_base: "http://vllm-diffusiongemma....:8000/v1"
k3s_litellm_gateway_diffucoder_api_base: "http://diffucoder-openai-wrapper....:8000/v1"
```

Lane client IDs are plain logical model slugs. Runtime and host placement are
kept in the structured backend registry and rendered `model_info`.

### Kilo lanes — operator notes (2026-09-01)

| Client ID | Backend | Kilo code agent |
| --- | --- | --- |
| `qwen3-coder-30b-a3b` | 5090 vLLM Qwen3-Coder AWQ | **Current primary**; card sampling defaults on route (`temp=0.7`, `top_p=0.8`, `top_k=20`, `repetition_penalty=1.05`); tool acceptance pending |
| `qwen2.5-coder-14b` | Ollama on `dev-workstation-win` | Implement/edit lane |
| `ministral-3-8b` | Ollama on `dev-workstation-win` | Interim fallback |
| `qwen2.5-coder-1.5b-base-q8_0` | Ollama on `HOM-LAB-HVH-01` | Autocomplete lane |

Do not invest in fixing 14B tool parsing. Restore 32B or upgrade to Qwen3-Coder /
Qwen 3.6 27B on vLLM. See HRL investigation note and
`docs/brainstorming_designs/2026-09-01--homelab-routing-layer-flint-openwrt/re-evaluate-models-and_distribution.partially-implemented.md`.

Operator `kilo.jsonc` must set `limit` and `tool_call` per model — not managed by Ansible.

## Client model IDs

LiteLLM `model_list[].model_name` values use stable logical IDs defined in
`defaults/main/model_client_ids.yml`:

```text
<model-slug>
```

| Segment | Meaning |
| --- | --- |
| `model-slug` | Stable logical model/lane ID. Runtime, host, and policy are separate metadata. |

Entry kinds (also in `model_info.client_model_id_kind` when set):

- **FRIENDLY ALIAS** — one backend `model` + `api_base` (most routes).
- **MODEL GROUP** — router entry; fans out to other client `model_name` targets.
  Example: `litellm-complexity-auto-router` (LiteLLM complexity auto-router).

`model_info.model_lane` and `model_info.placement_host` retain tracing and
placement details without putting infrastructure identity into the client ID.

### Examples

| Client `model_name` | Kind | Backend |
| --- | --- | --- |
| `qwen3-coder-30b-a3b` | FRIENDLY ALIAS | vLLM on `hom-lab-ctl-k3s-02` |
| `qwen2.5-coder-1.5b-base-q8_0` | FRIENDLY ALIAS | Ollama on `HOM-LAB-HVH-01` |
| `qwen2.5-coder-7b` | FRIENDLY ALIAS | Ollama on `dev-workstation-win` |

## Complexity auto-router (`litellm-complexity-auto-router`)

This optional feature is currently disabled. If commissioned later, pin the
LiteLLM chart and image versions before enabling it.

Clients call:

```text
model: litellm-complexity-auto-router
```

Tier map (local-first; enable only after a separate route review):

| Tier | Without cloud keys | With OpenAI | With Anthropic |
| --- | --- | --- | --- |
| SIMPLE | `qwen3-coder-30b-a3b` | same | same |
| MEDIUM | `qwen3-coder-30b-a3b` | same | same |
| COMPLEX | `qwen3-coder-30b-a3b` | `gpt-4o` | `claude-sonnet-4` |
| REASONING | `qwen3-coder-30b-a3b` | `gpt-4o` | `claude-sonnet-4` |

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
to revive mutate in an emergency. Historical overflow notes that drove those
drivers were **dated outdated 2026-09-09** and moved to
`docs/diagnostics/archive/litellm-context-window--k3s--diagnostics--outdated-2026-09-09.md`.
Current stub (points at 5090 untuned→tuned model truth):
`docs/diagnostics/litellm-context-window--k3s--diagnostics.md`.
**Do not diagnose live 32B issues as “missing trim.”**

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
| `litellm-env-secret` | `PROXY_MASTER_KEY`, `OPENAI_API_KEY` (when set), `ANTHROPIC_API_KEY` (when set), `GEMINI_API_KEY` (when set), `LANGFUSE_*` |
| `litellm-external-postgres` | `username`, `password` |

Helm `environmentSecrets` mounts `litellm-env-secret` into the pod; `proxy_config` uses `os.environ/OPENAI_API_KEY` and `os.environ/PROXY_MASTER_KEY`.

External PostgreSQL uses `k3s_litellm_gateway_db_endpoint` plus
`k3s_litellm_gateway_db_port` when rendering the database URL and status output.

## Model routes vs model catalog

`k3s_litellm_gateway_model_list` is the LiteLLM gateway route list. Client-facing
`model_name` values use the structured syntax in `defaults/model_client_ids.yml`
(`<model-slug>@<host-slug>~<friendly-lane>`).

For the current slice:

- `qwen3-coder-30b-a3b` is the current primary local coding lane
  (`cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` on vLLM / 5090).
- The old Qwen2.5 aliases below are historical migration references and must
  not be used as the current client source identity.
- `qwen2.5-coder-32b~coder-no-trim` is a historical alias from the
  trim era; both aliases now pass through unmutated. Oversized prompts fail at
  vLLM (32k). Archived mutate path:
  `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`.
- `qwen2.5-coder-32b~experiment` remains visible as a smoke alias, but it currently shares the
  same `vllm-primary` backend as coder-primary until a second runtime exists.
- `gpt-4o-mini@openai~cloud-fast` and `qwen2.5-coder-32b~default` stay present as migration rows while local-lane
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
