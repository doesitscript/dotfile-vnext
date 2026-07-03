# openai_docs — OpenAI developer docs MCP + local Codex runtime

Adds the OpenAI developer docs MCP server to repo-local Cursor config and
keeps the Codex docs entry disabled by default, while installing the local
Codex runtime used for the `codex` MCP server entry on macOS and Ubuntu.

Apply: converge the role from `playbooks/mac/mcp_servers.yaml`.
Verify: inspect `.cursor/mcp.json`, inspect `.codex/config.toml`, and confirm
the `openaiDeveloperDocs` and `codex` entries match the selected targets.
Undo: set `openai_docs_mcp_state: absent` and rerun the role.
Change class: idempotent config.

## What this role does

- installs `@openai/codex` via the nvm-managed npm on macOS and Ubuntu
- manages the `openaiDeveloperDocs` entry in Cursor config
- manages the optional local `codex` entry in Cursor config
- manages the disabled, non-required `openaiDeveloperDocs` block and optional local `codex` block in project `.codex/config.toml`
- keeps Codex TOML merge/remove behavior on the shared helper path instead of using `codex mcp` CLI mutation
- consumes the shared inventory version contract so the Codex runtime can be pinned without forking role logic

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
| `openai_docs_codex_package_base_name` | `@openai/codex` | Base npm package name for the local Codex runtime. |
| `openai_docs_codex_version` | `{{ codex_tooling_version_contract.cli }}` | Optional pinned version for the local Codex runtime. |
| `openai_docs_codex_package_name` | resolved package spec | Effective npm package spec used by the install/remove task. |
| `openai_docs_codex_command` | `""` | Resolved local Codex binary path. |
| `openai_docs_codex_enabled` | `true` | Whether the local `codex` MCP entry is managed. |
| `openai_docs_docs_codex_entry` | disabled docs URL entry | Structured Codex entry for `openaiDeveloperDocs`; disabled by default because Codex can fail hard when remote docs MCP resource-template listing is unsupported. |
| `openai_docs_codex_entry` | disabled local `codex` entry | Optional overrides for the local `codex` entry; disabled by default in Codex config to avoid self-MCP startup loops. |

## Notes

- `openapi` remains a deliberate stub target for this role in this pass.
- Codex config is managed in project `.codex/config.toml`, not `~/.codex/config.toml`.
- The Codex-side `openaiDeveloperDocs` entry is disabled and non-required by default; keep Cursor-side docs MCP available for docs workflows until Codex handles remote MCP resource-template negotiation without taking down the process.
- The Codex-side local `codex` MCP entry is disabled by default; Cursor can still use its own `codex` MCP entry from `.cursor/mcp.json`.
- The shared helper pattern preserves unrelated Codex config outside the managed MCP blocks.
- If `.codex/config.toml` already contains an unmanaged `openaiDeveloperDocs` entry, the role leaves that single table in place instead of appending a duplicate managed table.
- The shared inventory variable `codex_tooling_version_contract` is the intended
  single control point for Codex runtime and Cursor-extension pinning.
