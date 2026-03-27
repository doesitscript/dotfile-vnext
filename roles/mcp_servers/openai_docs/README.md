# openai_docs — OpenAI developer docs MCP + local Codex runtime

Adds the OpenAI developer docs MCP server to repo-local Cursor config and
project Codex config, and installs the local Codex runtime used for the `codex`
MCP server entry on macOS and Ubuntu.

Apply: converge the role from `playbooks/mac/mcp_servers.yaml`.
Verify: inspect `.cursor/mcp.json`, inspect `.codex/config.toml`, and confirm
the `openaiDeveloperDocs` and `codex` entries match the selected targets.
Undo: set `openai_docs_mcp_state: absent` and rerun the role.
Change class: idempotent config.

## What this role does

- installs `@openai/codex` via the nvm-managed npm on macOS and Ubuntu
- manages the `openaiDeveloperDocs` entry in Cursor config
- manages the optional local `codex` entry in Cursor config
- manages the `openaiDeveloperDocs` and optional local `codex` blocks in project `.codex/config.toml`
- keeps Codex TOML merge/remove behavior on the shared helper path instead of using `codex mcp` CLI mutation

## Target model

Supported targets for this role:
- `cursor`
- `codex`
- `openapi` stub

Default targets:
- `cursor`
- `codex`

Target tags:
- `mcp_target_cursor`
- `mcp_target_codex`
- `mcp_target_openapi`

## Variables

| Variable | Default | Description |
|---|---|---|
| `openai_docs_mcp_state` | `present` | Ensure the capability is present or absent. |
| `openai_docs_mcp_targets` | `['cursor', 'codex']` | Config targets to manage. |
| `openai_docs_mcp_cursor_config_path` | `{{ openai_docs_mcp_project_root }}/.cursor/mcp.json` | Cursor config path. |
| `openai_docs_mcp_codex_config_path` | `{{ openai_docs_mcp_project_root }}/.codex/config.toml` | Project Codex config path. |
| `openai_docs_mcp_url` | `https://developers.openai.com/mcp` | Streamable HTTP docs MCP URL. |
| `openai_docs_codex_command` | `""` | Resolved local Codex binary path. |
| `openai_docs_codex_enabled` | `true` | Whether the local `codex` MCP entry is managed. |
| `openai_docs_docs_codex_entry` | docs URL entry | Structured Codex entry for `openaiDeveloperDocs`. |
| `openai_docs_codex_entry` | `{}` | Optional overrides for the local `codex` entry. |

## Notes

- `openapi` remains a deliberate stub target for this role in this pass.
- Codex config is managed in project `.codex/config.toml`, not `~/.codex/config.toml`.
- The shared helper pattern preserves unrelated Codex config outside the managed MCP blocks.
