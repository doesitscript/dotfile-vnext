# drawio — draw.io MCP tool server

Installs the active draw.io MCP server from npm and manages repo-local MCP
client config for Cursor, Codex, and VS Code. The `openapi` target is present
as an explicit v1 stub and fails fast if selected.

## Boundary vs create-diagrams pack

This role is **interactive MCP editing** of draw.io diagrams.

For **reproducible architecture diagrams** from a Mingrammer model, use the
global skill pack instead:

- `create-diagrams` (author `.py`; this project defaults to **SVG**)
- `create-diagrams-drawio` (`.py` → `.drawio`)
- Policy: `docs/codex_framework/architecture-diagram-routing.md`

Do not treat this MCP role as the authoring source of truth for new durable
architecture diagrams.

## Classification

- Runtime: Node.js
- Install method: npm
- Interaction model: interactive/editor
- Verify mode: tool listing plus editor-launch validation
- Supported targets: Cursor, Codex, VS Code, OpenAPI stub

## Apply / Verify / Undo / Change Class

- Apply: run `playbooks/mac/mcp_servers.yaml` with this role included. By default it targets Cursor and Codex in the current repo root.
- Verify: syntax-check the play, validate the role against `.cursor/mcp.json` and `.codex/config.toml`, and run an explicit VS Code-targeted converge to confirm `.vscode/mcp.json` creation/merge.
- Undo: run the same play with `drawio_mcp_state=absent` to remove the npm package and the managed entries from the selected targets.
- Change class: idempotent config for a local controller-side MCP tool server.

## What this role does

- macOS: installs `drawio-mcp-server` globally using the nvm-managed npm already used elsewhere in this repo.
- Ubuntu: installs the same package globally using the resolved nvm npm.
- Legacy cleanup: removes the previous `@drawio/mcp` package if it is present so the lgazo server is the only managed local draw.io server.
- Cursor: creates or merges a `drawio` entry into `.cursor/mcp.json`.
- Codex: creates or merges a `drawio` entry into `.codex/config.toml`.
  For Codex, the role uses a small repo-local stdio wrapper so Draw.io editor
  asset-init messages do not corrupt the MCP handshake, and it uses dedicated
  ports so Codex does not collide with another local Draw.io MCP instance.
  The role also prewarms the editor asset cache so Codex does not spend its
  startup window downloading draw.io assets on first launch.
- VS Code: creates or merges a `drawio` entry into `.vscode/mcp.json`.
- OpenAPI: deliberately fails fast until that target is implemented.
- Removal: `drawio_mcp_state=absent` removes the npm package plus the managed entries from the selected targets.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `drawio_mcp_state` | `present` | Ensure the package/config is present or absent. |
| `drawio_mcp_package_name` | `drawio-mcp-server` | Active draw.io MCP npm package. |
| `drawio_mcp_server_key` | `drawio` | Key written under `mcpServers`. |
| `drawio_mcp_project_root` | `{{ dotfiles_home }}` | Repo root used to derive default config targets. |
| `drawio_mcp_targets` | `['cursor', 'codex']` | Target client configs to manage. |
| `drawio_mcp_cursor_config_path` | `{{ drawio_mcp_project_root }}/.cursor/mcp.json` | Repo-local Cursor target path. |
| `drawio_mcp_codex_config_path` | `{{ drawio_mcp_project_root }}/.codex/config.toml` | Repo-local Codex target path. |
| `drawio_mcp_codex_wrapper_path` | `{{ drawio_mcp_project_root }}/bin/drawio-mcp-codex-stdio-wrapper.js` | Repo-local wrapper for Codex stdio startup. |
| `drawio_mcp_codex_extension_port` | `3349` | Dedicated Draw.io extension port for Codex. |
| `drawio_mcp_codex_http_port` | `3006` | Dedicated Draw.io editor HTTP port for Codex. |
| `drawio_mcp_codex_startup_timeout_sec` | `45` | Startup timeout for the Draw.io Codex MCP entry. |
| `drawio_mcp_codex_asset_path` | `~/.cache/drawio-mcp-server-assets` | Prewarmed asset cache path used by the Codex entry. |
| `drawio_mcp_vscode_config_path` | `{{ drawio_mcp_project_root }}/.vscode/mcp.json` | Repo-local VS Code target path. |
| `drawio_mcp_command` | `""` | Resolved executable path. Setting this skips install tasks for validation or custom installs. |
| `drawio_mcp_args` | `['--editor']` | Runtime args passed to the server. |
| `drawio_mcp_env` | role path env | Runtime env passed to the server. |
| `drawio_mcp_codex_entry` | command/args/env/startup timeout entry | Structured Codex MCP entry override. |
| `drawio_mcp_bin_candidates` | `[]` | Optional override for executable candidates checked after npm install. |
| `drawio_mcp_legacy_packages` | `['@drawio/mcp']` | Previous draw.io MCP npm packages removed during present-state convergence. |

## Tags

| Tag | Description |
|-----|-------------|
| `mcp` | All MCP server roles. |
| `drawio` | This role's tasks. |
| `diagrams` | Diagramming tooling. |
| `workspace` | Local development workstation tooling. |
| `mcp_target_cursor` | Focus the run on repo-local Cursor config. |
| `mcp_target_codex` | Focus the run on repo-local Codex config. |
| `mcp_target_vscode` | Focus the run on repo-local VS Code config. |
| `mcp_target_openapi` | Trigger the explicit OpenAPI stub failure. |

## Usage

The role is included in `playbooks/mac/mcp_servers.yaml`.

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_codex
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio,mcp_target_vscode
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio -e drawio_mcp_state=absent
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags drawio -e '{"drawio_mcp_targets":["cursor","codex","vscode"]}'
```

## Validation

See `docs/reports/mcp_server_validations/` for the reusable validation shape and
the draw.io-specific validation artifacts.

## Reference

- https://github.com/lgazo/drawio-mcp-server
