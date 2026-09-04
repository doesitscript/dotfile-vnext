# Intake (processed)

Inbound from the work-laptop sibling. Processed by
`work-laptop-improvement-review` + parent role updates.

## Delivered (this cycle)

| Ask | Where |
| --- | --- |
| Aider must create/edit files (not only suggest shell) | `roles/aider` → `dirty-commits: true`, `suggest-shell-commands: false`, `yes: true`, `.aiderignore` |
| Homebrew Python 3.12 for pipx | `aider_pipx_python` (optional `--python`) |
| Cline skip JSONC VS Code settings merge | `roles/cline_ide` jq gate |
| Firecrawl respect `npm prefix -g` | `roles/mcp_servers/firecrawl` mac tasks |

See `deviations/register.yaml` for accepted long-term accommodations.

## Aider new-file habit

Before asking Aider to write a new path: `/add <file>` so it is in the chat
(https://aider.chat/docs/usage/tips.html).

## Ignore guidance

Repo-root `.aiderignore` is deployed by the aider role from the intake ignore
list (tfstate, venvs, node_modules, IDE noise, etc.).
