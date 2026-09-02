# Gemini LiteLLM lanes (Google Developer API)

Operator runbook for **Google Gemini free-tier routes** published through
`litellm.hom.lab` when `vault_shared_gemini_api_key` is set in
`vault/shared.vault.yml`.

Ansible owner: `roles/k3s_litellm_gateway` (`defaults/main/gemini_model_routes.yml`).

## Vault setup

```bash
cd /Users/joshc/develop/dotfile-vnext
./bin/fz vault edit shared
```

Add (or update):

```yaml
# roles/k3s_litellm_gateway | playbooks/deploy_litellm_gateway.yaml
# Obtain key: https://aistudio.google.com/apikey
# LiteLLM env: GEMINI_API_KEY
vault_shared_gemini_api_key: "AIza..."
```

Azure prep (no routes until commissioned):

```yaml
vault_shared_azure_ai_api_key: ""
# vault_shared_azure_openai_endpoint: "https://REPLACE.openai.azure.com/"
```

Deploy:

```bash
ansible-playbook playbooks/deploy_litellm_gateway.yaml
```

Verify routes:

```bash
curl -s http://litellm.hom.lab/v1/model/info \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" | jq '.data[].model_name'
```

## Published client model IDs

| Client `model_name` | Backend | Use when |
| --- | --- | --- |
| `gemini-2.5-flash@google~long-context` | `gemini/gemini-2.5-flash` | **Large context** — plans, logs, multi-file dumps |
| `gemini-2.5-pro@google~deep-reasoning` | `gemini/gemini-2.5-pro` | **Hard reasoning** — research synthesis, architecture critique |
| `gemini-2.5-flash@google~public-research` | `gemini/gemini-2.5-flash` | **Daily driver** — tools, MCP, fast homelab Q&A |
| `gemini-2.5-flash-lite@google~bulk` | `gemini/gemini-2.5-flash-lite` | **Bulk work** — Langfuse tags, summaries, classification |
| `gemini-embedding-001@google~embeddings` | `gemini/gemini-embedding-001` | **RAG embeddings** — not chat |

Gateway: `http://litellm.hom.lab/v1` with LiteLLM master key from vault.

## Operator tips (read before picking a lane)

### Long context vs deep reasoning

**Large-context lane:** use **`gemini-2.5-flash@google~long-context`** as the
primary route when you need to fit a lot of tokens (explicit **1M** context window
on the Gemini Developer API free tier).

**Quality fallback:** use **`gemini-2.5-pro@google~deep-reasoning`** when the task
is hard reasoning, multi-step research synthesis, or architecture critique —
**not** when the main goal is maximum context size. Pro is the quality lane; Flash
is the volume lane.

Both long-context and public-research point at `gemini-2.5-flash` on purpose:
different **client IDs** so you can trace intent in Langfuse without changing
the backend model.

### Free-tier rate limits (approximate)

From homelab agent assignments (`docs/agent-design/ansible/model-assignments.md`):

| Model family | Rough RPD | Homelab role fit |
| --- | --- | --- |
| `gemini-2.5-pro` | ~100 | Researcher — use sparingly |
| `gemini-2.5-flash` | ~250 | Coordinator + planner combined |
| `gemini-2.5-flash-lite` | ~1000 | Observer / bulk eval work |

Re-check [Google Gemini pricing](https://ai.google.dev/gemini-api/docs/pricing)
before production reliance — free tier and limits change.

### Privacy / routing policy

All Gemini routes ship with `routing_policy: azure-allowed` in `model_info`.
Treat them as **scrubbed / public-context** lanes until a privacy classifier
exists. Do not send vault contents, credentials, or private host details without
review.

### Codex / Cursor note

Direct Google OpenAI compatibility is **Chat Completions** only. Codex terminal
profiles that require **Responses API** still need a credentialed LiteLLM route —
see `docs/plans/2026-09-01--homelab-local-ai-clients-codex/templates/gemini-via-litellm.config.toml.example`.

For Cursor-native Gemini, paste the API key in **Cursor Settings → Models**;
Cursor does not read Ansible vault.

### Avoid for new work

- `gemini-2.0-flash` / `gemini-2.0-flash-lite` — shut down per Google models page
- Preview models for steady-state automation unless you accept deprecation churn

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Set `vault_shared_gemini_api_key` → `ansible-playbook playbooks/deploy_litellm_gateway.yaml` |
| **Verify** | `/v1/model/info` lists five `gemini-*@google~*` routes; test chat on long-context lane |
| **Undo** | Remove or empty vault key → redeploy (routes omitted; `GEMINI_API_KEY` dropped from secret) |
| **Change class** | Idempotent config — vault key + Helm values |

## Related

- Role README: `roles/k3s_litellm_gateway/README.md`
- Skill: `gemini-free-tier-model-chooser`
- Agent RPD notes: `docs/agent-design/ansible/model-assignments.md`
- Local stack overview: `docs/reference/local-ai-chat-and-image-stack.md`

## Sources checked

- Google Gemini pricing page (free tier verified 2026-09-01 UTC)
- `roles/k3s_litellm_gateway/defaults/main/gemini_model_routes.yml`
- `docs/intake/netbox/netbox_ai_infra_impl_planning_wip/gpu-lane-and-model-lane-mapping-evaluation.md`
