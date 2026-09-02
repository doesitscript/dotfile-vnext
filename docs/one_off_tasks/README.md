# One-off Tasks

This folder is for narrowly scoped, operator-approved exceptions.

Use it when work is:
- intentionally one-time
- semi-manual or bootstrap-like
- too irregular or risky to present as normal repeatable automation
- specific enough that future agents should not assume it is reusable by default

This folder is not the place for:
- general runbooks
- normal Ansible role behavior
- generic framework guidance
- cleanup logic that should really be made idempotent

## Rule of thumb

If a task needs ad-hoc remote commands because the original implementation was not cleanly reversible, document it here as an exception and keep the scope explicit.

Future agents should read these notes as:
- allowed only for the specific situation described
- not a standing permission to improvise remote cleanup
- something to confirm with the user before execution

## Subfolders

- **[codex-multi-terminal-workflow/](./codex-multi-terminal-workflow/)** — one-off trial for
  four distributed local Codex terminals (`cx-deep`, `cx-desktop`, `cx-skills`, `cx-hvh01`)
  plus cloud `cx-research`. Deploy with
  `codex-multi-terminal-workflow/deploy/install_one_off_tasks.sh`.
- **[on-offs/](./on-offs/)** — setting on/off timelines and tool matrices for active troubleshooting (e.g. GPU/FPS). Tables use **What we got** for raw pulse evidence in that column; see [on-offs/README.md](./on-offs/README.md).
