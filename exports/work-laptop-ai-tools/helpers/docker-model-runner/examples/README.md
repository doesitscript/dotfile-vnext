# Docker Model Runner examples

**Automation: disabled.** These files are the future idempotent contract.
Do not invent a packet Ansible role from this folder until
`work_laptop_docker_model_runner_automation` is commissioned.

| File | Purpose |
| --- | --- |
| `compose.models.example.yml` | Compose `models:` top-level shape (Compose ≥ 2.38 + DMR) |
| `continue-config.snippet.example.yaml` | Continue OpenAI-compatible pointer at DMR |
| `redeploy-checklist.md` | Human Apply / Verify / Undo for wipe/reinstall |
| `echo-dmr-status.example.sh` | Echo-only status commands (does not mutate) |
| `save/` | Saved findings from the deprecated rsync/share era + LM Studio inbox |

Preferred-path doc: `../../DOCKER-MODEL-RUNNER.md` (from packet root:
`DOCKER-MODEL-RUNNER.md`).
