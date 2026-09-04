---
name: work-laptop-mcp-commission
description: "Use when the user explicitly asks to enable/deploy MCP servers on the work-laptop-ai-tools packet (flip *_state to present, Continue + Cline + Codex CLI/extension wiring, vault gates, WarpGrep). Do not target VS Code native mcp.json. Do not use for first-time catalog include (use work-laptop-mcp-adopt) or live apply on the laptop (work-laptop-day2-apply)."
---

# Skill: Work-laptop MCP commission

Turn an **already adopted** MCP role from catalog (`absent`) into a
commissioned deployable server for this slice.

## Client targets for this slice (hard rule)

| Client | How MCP is wired | In `*_targets`? |
| --- | --- | --- |
| Continue extension (in VS Code) | `continue_ide_mcp_servers` → `~/.continue/config.yaml` | **no** — separate list |
| Cline extension (`saoudrizwan.claude-dev`) | `cline_ide_mcp_servers` → `~/.cline/.../cline_mcp_settings.json` | **no** — separate list (usually mirrors Continue) |
| Codex CLI | `*_targets: [codex]` → `~/.codex/config.toml` | **yes** |
| Codex VS Code extension (`openai.chatgpt`) | same `~/.codex/config.toml` | **yes** (same as CLI) |
| VS Code native MCP | `~/.vscode/mcp.json` | **never** on this slice |

IDE model/key setup (LiteLLM, empty UI, `cx-*` paths): skill
`work-laptop-ide-clients`. Laptop playbook apply: `work-laptop-day2-apply`.

## When to use / not use

Use when the user wants servers **on** for Continue, Cline, and/or Codex
CLI/extension.

Do not use to invent a new role (collect + adopt first).
Do not `--apply` on the work laptop from this skill (hand off
`work-laptop-day2-apply`).
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
5. **Cline:** keep `cline_ide_mcp_servers: "{{ continue_ide_mcp_servers }}"`
   (or append the same server entry). Do not assume `*_targets` updates Cline.
6. Keep `Continue.continue`, `saoudrizwan.claude-dev`, and `openai.chatgpt` in
   `vscode_extensions` when those products are in scope.
7. **Secrets:**
   - Morph: `vault_shared_morph_api_key` (not REPLACE_ME)
   - Continue/Cline present runs need `vault_k3s_litellm_gateway_master_key`
     (`*_require_api_key: true`) — empty LiteLLM key → empty-looking UI
   - Hand off `work-laptop-vault` for hydrate/status
8. **Morph WarpGrep:** Continue rule at
   `~/.continue/rules/morph-warpgrep-evaluation.md`; do not also list that
   file in `continue_ide_rules`.
9. Update packet README + HRL slice commissioned table.
10. `work-laptop-packet-ops` validate + sync sibling; remind user to
    `work-laptop-day2-apply` on the laptop.

## Validation

- Commissioned `*_state: present`
- `vscode` not in commissioned `*_targets`
- Continue (and Cline, when in scope) entries exist for asked servers
- Morph + LiteLLM vault gates documented
- Sibling synced

## Prohibited behavior

- Enabling servers the user did not name
- Writing `~/.vscode/mcp.json` for this slice by default
- Embedding API keys in Continue/Cline config / Codex TOML
- Treating sibling as design authority
- Claiming laptop apply done without `work-laptop-day2-apply` evidence
