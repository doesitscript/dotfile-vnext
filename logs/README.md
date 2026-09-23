# Project logs (deprecated storage location)

This directory is retained temporarily as a transition marker. New logs for
this project must not be written here.

On the Mac controller, controller-side Ansible execution logs and other
explicitly configured local tool logs belong under:

`~/Library/Logs/dotfile-vnext/`

For managed target hosts, configurable application/tool logs belong below the
inventory-defined `managed_application_log_root` for that host class. Build
paths as `<managed_application_log_root>/<application>/...`.

This does not relocate or redefine Windows system/Event Logs, OpenSSH logs,
K3s/Docker shared logs, Loki storage, or other infrastructure-owned logs.

Existing files formerly stored here were moved to the external Mac log root
under `legacy-project-logs/` for retention during the transition. Inspect them
only when explicitly troubleshooting or when a task names the relevant path.

Do **not** commit captured dumps, kubectl excerpts, or tool schemas — they can
include prompt/tool payloads from live Cursor sessions.

## Deprecated layout

| Path | Purpose |
| --- | --- |
| `logs/litellm-tools-capture/` | Former capture location; use external project log storage |
| `logs/runs/` | Former run-artifact location; use external project log storage |

Override any skill’s output with `OUT=/path` when a script supports it.

## Skills that formerly wrote here

| Skill (catalog name) | Default output | How |
| --- | --- | --- |
| `capture-litellm-tools-payload` | `logs/litellm-tools-capture/` | `scripts/collect_tools_capture.sh` pulls LiteLLM pod dumps + hook log greps after a tools-bearing request |
| `deploy-dev-workstation-ollama-runtime` | `logs/runs/<UTC>--deploy-dev-workstation-ollama-runtime.log` | `skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py` (bridged into `.cursor/skills/` via runtime bridge) |

Parent / sibling skills that **route** to that capture (they do not write files here by themselves unless handed off):

- `litellm-cursor-traffic-analyzer`
- `analyze-litellm-observable-surfaces`
- `tune-litellm-context-safety-net` (redeploy/verify; use capture skill when re-measuring tools)

## Historical collect example

From the repo root, after one Cursor Agent request through Ornith:

```bash
bin/codex-env bash skills/validation/capture-litellm-tools-payload/scripts/collect_tools_capture.sh
```

Historical files were written under `logs/litellm-tools-capture/`; new captures
should use an explicit external output path.

## Extending this folder

Do not add new runtime evidence here. New project skills should write to an
external path and document the path through their own skill/reference contract.

If a capture might include secrets (API keys, vault material), refuse to write
it to the repository; use an encrypted vault or operator-local path outside the
repo.

<!-- Historical inventory retained below for migration context. -->

Expected historical files under `logs/litellm-tools-capture/`:

- `summary.json`
- `tools-array-complete.json`
- `tool-Task.json`
- `tool-Shell.json`
- `summary-logs.txt`
- `litellm-tools-structure-dump.json`
