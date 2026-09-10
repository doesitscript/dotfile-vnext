# Related Artifacts

## Repo surfaces

- `roles/k3s_litellm_gateway/` — gateway role, Request Inspector callback, defaults
- `roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2` — observe-only inspector
- `roles/k3s_litellm_gateway/README.md` — Request Inspector; archived trim path
- `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/` — mutate trim archive
- `docs/diagnostics/litellm-context-window--k3s--diagnostics.md` — current stub (2026-09-09)
- `docs/diagnostics/archive/litellm-context-window--k3s--diagnostics--outdated-2026-09-09.md`
- `docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/diagrams/5090-vram-tuning-before-after.md`
- `playbooks/deploy_litellm_gateway.yaml` — apply host `hom-lab-ctl-k3s-02`

## Sibling skills

- `capture-litellm-tools-payload`
- `analyze-litellm-observable-surfaces`
- `tune-litellm-context-safety-net` (inspector thresholds / fallbacks — not mutate trim)

## Known measured shape (Agent)

- ~19 Cursor built-in tools, `tool_tokens_total≈26k`, MCP schemas often `0` in `tools[]`
- Largest schemas historically: `Task`, `Shell`, then TodoWrite / AwaitShell / SwitchMode
- Do **not** treat “revive trim” as the default remediation
