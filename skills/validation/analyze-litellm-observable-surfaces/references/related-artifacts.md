# Related Artifacts

## Observable surfaces (this lab)

| Surface | What it reports | How to reach |
| --- | --- | --- |
| `CustomLogger.async_pre_call_hook` | Request `data` before backend: messages, `tools`, `max_tokens`; trim + tools dump | Mounted `custom_callbacks.py`; stdout + `/tmp/litellm-tools-capture/` |
| LiteLLM pod stdout | Hook lines, proxy errors, Hosted_vllmException text | `kubectl -n litellm logs -l app.kubernetes.io/name=litellm` via Ansible on `hom-lab-ctl-k3s-02` |
| Pod `/tmp/litellm-tools-capture/` | Full `tools[]`, Task/Shell JSON, summary splits | `capture-litellm-tools-payload` collect script |
| Langfuse success callback | Post-call traces/generations when enabled | `k3s_litellm_gateway_langfuse_*` → Langfuse UI/API |
| `GET /v1/models` | Published aliases | Bearer LiteLLM master key to `http://litellm.hom.lab/v1/models` |
| Health / NodePort | Liveness, LAN exposure | `litellm` service / NodePort 30400 |
| External Postgres (`litellm` DB) | Proxy persistence / spend metadata if queried | Role DB contract — not the default tools dump path |

## Not a LiteLLM surface

- Cursor chat transcript fidelity after client-side errors
- Per-MCP tool schemas when Cursor only exposes `CallMcpTool` / `GetMcpTools` meta-tools in `tools[]`

## Key repo paths

- `roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2`
- `roles/k3s_litellm_gateway/defaults/main.yml`
- `docs/diagnostics/litellm-context-window--k3s--diagnostics.md`
