# drawio — draw.io MCP tool server

Installs the official draw.io MCP tool server from npm and manages repo-local
MCP client config for Cursor and VS Code. The `openapi` target is present as an
explicit v1 stub and fails fast if selected.

## Classification

- Runtime: Node.js
- Install method: npm
- Interaction model: launcher
- Verify mode: tool listing plus editor-launch validation
- Supported targets: Cursor, VS Code, OpenAPI stub

## Apply / Verify / Undo / Change Class

- Apply: run `playbooks/mac/mcp_servers.yaml` with this role included. By default it targets Cursor in the current repo root.
- Verify: syntax-check the play, validate the role against `.cursor/mcp.json`, and run an explicit VS Code-targeted converge to confirm `.vscode/mcp.json` creation/merge.
- Undo: run the same play with `drawio_mcp_state=absent` to remove the npm package and the managed entries from the selected targets.
- Change class: idempotent config for a local controller-side MCP tool server.

## What this role does

- macOS: installs `@drawio/mcp` globally using the nvm-managed npm already used elsewhere in this repo.
- Ubuntu: installs the same package globally using the resolved nvm npm.
- Cursor: creates or merges a `drawio` entry into `.cursor/mcp.json`.
- VS Code: creates or merges a `drawio` entry into `.vscode/mcp.json`.
- OpenAPI: deliberately fails fast until that target is implemented.
- Removal: `drawio_mcp_state=absent` removes the npm package plus the managed entries from the selected targets.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `drawio_mcp_state` | `present` | Ensure the package/config is present or absent. |
| `drawio_mcp_package_name` | `@drawio/mcp` | Official draw.io MCP npm package. |
| `drawio_mcp_server_key` | `drawio` | Key written under `mcpServers`. |
| `drawio_mcp_project_root` | `{{ dotfiles_home }}` | Repo root used to derive default config targets. |
| `drawio_mcp_targets` | `['cursor']` | Target client configs to manage. |
| `drawio_mcp_cursor_config_path` | `{{ drawio_mcp_project_root }}/.cursor/mcp.json` | Repo-local Cursor target path. |
| `drawio_mcp_vscode_config_path` | `{{ drawio_mcp_project_root }}/.vscode/mcp.json` | Repo-local VS Code target path. |
| `drawio_mcp_command` | `""` | Resolved executable path. Setting this skips install tasks for validation or custom installs. |
| `drawio_mcp_args` | `[]` | Optional runtime args passed to the server. |
| `drawio_mcp_bin_candidates` | `[]` | Optional override for executable candidates checked after npm install. |

## Tags

| Tag | Description |
|-----|-------------|
| `mcp` | All MCP server roles. |
| `drawio` | This role's tasks. |
| `diagrams` | Diagramming tooling. |
| `workspace` | Local development workstation tooling. |
| `mcp_target_cursor` | Focus the run on repo-local Cursor config. |
| `mcp_target_vscode` | Focus the run on repo-local VS Code config. |
| `mcp_target_openapi` | Trigger the explicit OpenAPI stub failure. |

## Usage

The role is included in `playbooks/mac/mcp_servers.yaml`.

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_vscode
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio -e drawio_mcp_state=absent
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio -e '{"drawio_mcp_targets":["cursor","vscode"]}'
```

## Validation

See `docs/reports/mcp_server_validations/` for the reusable validation shape and
the draw.io-specific validation artifacts.

## Reference

- https://www.drawio.com/doc/faq/ai-drawio-generation
- https://github.com/jgraph/drawio-mcp
