---
name: work-laptop-mcp-commission
description: "Use when the user explicitly asks to enable/deploy MCP servers on the work-laptop-ai-tools packet (flip *_state to present, Continue + Codex CLI/extension wiring, vault gates, WarpGrep). Do not target VS Code native mcp.json. Do not use for first-time catalog include (use work-laptop-mcp-adopt) or live apply on the laptop (user runs the sibling playbook)."
---

# Skill: Work-laptop MCP commission

Turn an **already adopted** MCP role from catalog (`absent`) into a
commissioned deployable server for this slice.

## Client targets for this slice (hard rule)

| Client | How MCP is wired | In `*_targets`? |
| --- | --- | --- |
| Continue extension (in VS Code) | `continue_ide_mcp_servers` → `~/.continue/config.yaml` | **no** — separate list |
| Codex CLI | `*_targets: [codex]` → `~/.codex/config.toml` | **yes** |
| Codex VS Code extension (`openai.chatgpt`) | same `~/.codex/config.toml` | **yes** (same as CLI) |
| VS Code native MCP | `~/.vscode/mcp.json` | **never** on this slice |

## When to use / not use

Use when the user wants servers **on** for Continue and/or Codex CLI/extension.

Do not use to invent a new role (collect + adopt first).
Do not `--apply` on the work laptop from this skill.
Do not add `vscode` to `*_targets` unless the user explicitly asks for VS Code
native MCP (default: no).

## Inputs

- Server names and clients
- Packet `host_vars/work-laptop.yaml`, `playbook.yaml`
- Role `*_supported_targets`, `load_vault.yml`
- HRL porting guide when available

## Workflow

1. Confirm the role is on `export-manifest.yml` and in `playbook.yaml`.
2. Set `*_state: present` (and `ripgrep_cli_state: present` for Morph).
3. Set `*_targets: [codex]` and `*_codex_config_path` → `~/.codex/config.toml`
   (covers Codex CLI **and** Codex VS Code extension).
4. **Continue:** append `continue_ide_mcp_servers`. Role `*_targets` do not
   update Continue. GUI PATH often lacks nvm — use `bin/work-laptop-nvm-exec`
   (and Morph env wrapper + `WORKSPACE_MODE`).
5. Keep `Continue.continue` and `openai.chatgpt` in `vscode_extensions` when
   those products are in scope (extensions host Continue/Codex; they are not
   VS Code native MCP).
6. **Secrets:** Morph requires `vault_shared_morph_api_key` (not REPLACE_ME).
   Context7/Firebase may install without vault. Hand off `work-laptop-vault`.
7. **Morph WarpGrep:** Continue rule at
   `~/.continue/rules/morph-warpgrep-evaluation.md`; do not also list that
   file in `continue_ide_rules`.
8. Update packet README + HRL slice commissioned table.
9. `work-laptop-packet-ops` validate + sync sibling.

## Validation

- Commissioned `*_state: present`
- `vscode` not in commissioned `*_targets`
- Continue entries exist for asked servers
- Morph vault gate documented
- Sibling synced

## Prohibited behavior

- Enabling servers the user did not name
- Writing `~/.vscode/mcp.json` for this slice by default
- Embedding API keys in Continue config / Codex TOML
- Treating sibling as design authority
