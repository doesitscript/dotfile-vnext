---
name: work-laptop-mcp-commission
description: "Use when the user explicitly asks to enable/deploy MCP servers on the work-laptop-ai-tools packet (flip *_state to present, Continue/VS Code/Codex wiring, vault gates, WarpGrep). Do not use for first-time catalog include (use work-laptop-mcp-adopt) or live apply on the laptop (user runs the sibling playbook)."
---

# Skill: Work-laptop MCP commission

Turn an **already adopted** MCP role from catalog (`absent`) into a
commissioned deployable server for this slice.

## When to use / not use

Use when the user names clients (VS Code, Codex CLI, Codex extension,
Continue) and wants servers **on** for the next laptop playbook run.

Do not use to invent a new role (collect + adopt first).
Do not `--apply` on the work laptop from this skill.

## Inputs

- Server names and clients
- Packet `host_vars/work-laptop.yaml`, `playbook.yaml`
- Role `*_supported_targets`, `load_vault.yml`
- HRL porting guide when available

## Workflow

1. Confirm the role is on `export-manifest.yml` and in `playbook.yaml`.
2. Set `*_state: present` (and `ripgrep_cli_state: present` for Morph).
3. Keep user-home vscode/codex path overrides.
4. **Continue:** append `continue_ide_mcp_servers`. Role `*_targets` do not
   update Continue. VS Code GUI PATH often lacks nvm — use
   `bin/work-laptop-nvm-exec` (and Morph env wrapper + `WORKSPACE_MODE`).
5. **Codex CLI + Codex VS Code extension:** `*_targets` must include `codex`
   and `*_codex_config_path` must be `~/.codex/config.toml` (or dual-write
   `*_configure_codex_user`).
6. **VS Code built-in MCP / Continue extension:** `vscode` in targets →
   `~/.vscode/mcp.json`; Continue list as in step 4. Add `openai.chatgpt` to
   `vscode_extensions` when commissioning Codex-in-VS-Code.
7. **Secrets:** Morph requires `vault_shared_morph_api_key` (not REPLACE_ME).
   Context7/Firebase may install without vault. Hand off `work-laptop-vault`.
8. **Morph WarpGrep:** enable continue rule at
   `~/.continue/rules/morph-warpgrep-evaluation.md`; do not also list that
   file in `continue_ide_rules`. Disable Cursor/Copilot project routing on
   this slice unless asked.
9. Update packet README + HRL slice commissioned table.
10. `work-laptop-packet-ops` validate + sync sibling.

## Validation

- Commissioned `*_state: present`
- Continue entries exist for asked servers
- Morph vault gate documented
- Sibling synced

## Prohibited behavior

- Enabling servers the user did not name
- Embedding API keys in mcp.json / Continue config
- Treating sibling as design authority
