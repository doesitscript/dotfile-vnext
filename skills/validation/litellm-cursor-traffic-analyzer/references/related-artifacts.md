# Related Artifacts

## Repo surfaces

- `roles/k3s_litellm_gateway/` — gateway role, trim hook template, defaults
- `roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2` — `CustomLogger` + `async_pre_call_hook`
- `roles/k3s_litellm_gateway/README.md` — server-tuned drivers and failure modes
- `docs/diagnostics/litellm-context-window--k3s--diagnostics.md`
- `playbooks/deploy_litellm_gateway.yaml` — apply host `hom-lab-ctl-k3s-02`

## Sibling skills

- `capture-litellm-tools-payload`
- `analyze-litellm-observable-surfaces`
- `tune-litellm-context-safety-net`

## Known measured shape (Agent)

- ~19 Cursor built-in tools, `tool_tokens_total≈26k`, MCP schemas often `0` in `tools[]`
- Largest schemas historically: `Task`, `Shell`, then TodoWrite / AwaitShell / SwitchMode
- Message budgets can collapse to ~1–2k tokens after tools + safety + completion reserve
