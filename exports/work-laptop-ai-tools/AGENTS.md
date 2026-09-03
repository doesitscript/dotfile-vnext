# AGENTS.md — work-laptop-ai-tools packet

Slice-local instructions for `exports/work-laptop-ai-tools` and the generated
sibling repo `work-laptop-ai-tools`. Prefer these over inventing ad-hoc flows
when the task is packet MCP, vault, or sync.

## Authority

| Layer | Path |
| --- | --- |
| Design authority (edit here) | this packet under `dotfile-vnext/exports/work-laptop-ai-tools/` |
| Shared MCP role logic | `dotfile-vnext/roles/mcp_servers/*` (parent) |
| Generated build target | sibling `../work-laptop-ai-tools` |
| Living process docs | HRL `implementation-guides/mcp/work-laptop-ai-tools-mcp-slice.md` and `porting-mcp-servers-between-projects.md` |

Do not treat the sibling checkout as design authority. Edit the packet (or
parent roles), then sync.

## Local skills (`.agents/skills/`)

These skills are specific to this slice and its external build target. Prefer
them when the task matches. Do not use them for unrelated parent-repo work
unless the user explicitly asks.

| Skill | Use when |
| --- | --- |
| `work-laptop-mcp-collect` | Collect / inventory an MCP role from the parent project into the packet design set |
| `work-laptop-mcp-adopt` | Wire a collected MCP into packet playbook/host_vars/manifest with HRL remaps; default `absent` |
| `work-laptop-mcp-commission` | User asked to **enable** MCP for VS Code / Codex / Continue (flip present, Continue lists, vault gates) |
| `work-laptop-vault` | Packet vault router: init / hydrate / status via `scripts/work_laptop_vault.py` |
| `work-laptop-vault-hydrate` | Copy parent vault values with `hydrate_vault_from_parent.py` (no values in chat) |
| `work-laptop-vault-status` | Names-only ciphertext + nonempty key check via `vault_status.py` |
| `work-laptop-packet-ops` | Validate export contract, sync sibling, smoke; delegates heavy scripts to parent `work-laptop-export-pack` |

Discovery path: `.agents/skills/<name>/SKILL.md` (Cursor + Codex). Skills are
synced into the sibling so laptop sessions can discover them.

## Reach (intentional)

Slice skills may read/write:

- parent `roles/mcp_servers/` and related `bin/` helpers
- this packet (`export-manifest.yml`, `playbook.yaml`, `host_vars/`, `vault/`)
- sibling checkout after sync
- HRL MCP guides when the library checkout is available

Physical skill location does not sandbox those paths.

## Hard defaults

- New MCP catalog entries stay `*_state: absent` until the user commissions them
  (`work-laptop-mcp-commission`).
- Do not append Continue/Zed MCP lists unless asked.
- Never commit live vault secrets; ship example + README only.
- Prefer user-home Codex config (`~/.codex/config.toml`) and Continue
  (`continue_ide_mcp_servers`). Do **not** commission VS Code native
  `~/.vscode/mcp.json` on this slice unless explicitly asked.

