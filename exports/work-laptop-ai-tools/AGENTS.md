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
| `work-laptop-mcp-commission` | User asked to **enable** MCP for Continue / Cline / Codex (flip present, client lists, vault gates) |
| `work-laptop-ide-clients` | Continue / Cline / Zed / `cx-*` config, LiteLLM key gates, empty UI, Documents repo roots |
| `work-laptop-day2-apply` | On the work Mac: `git pull` + playbook `--skip-tags hosts_file` + verify Continue/Cline/`cx-*` |
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
- Do not append Continue/Cline/Zed MCP lists unless asked.
- Never commit live vault secrets; ship example + README only.
- Prefer user-home Codex config (`~/.codex/config.toml`), Continue
  (`continue_ide_mcp_servers` → `~/.continue/config.yaml`), and Cline
  (`cline_ide_*` → `~/.cline/data/settings/`). Do **not** commission VS Code
  native `~/.vscode/mcp.json` on this slice unless explicitly asked.
- After packet edits: `work-laptop-packet-ops` → push sibling → on laptop
  `work-laptop-day2-apply`.

# BEGIN ANSIBLE MANAGED BLOCK: routing_morph-mcp
## Morph WarpGrep + Fast Apply (evaluation — under_evaluation)

Morph `morph-mcp` is **under evaluation** on this controller (installed 2026-09-02).
Access is Ansible-managed (`roles/mcp_servers/morph`). Prefer these Morph MCP
tools when they are available in the client.

### WarpGrep (`codebase_search`)

`codebase_search` is a WarpGrep subagent: natural-language search for relevant
context. Use it at the **beginning** of codebase explorations to find relevant
files/lines faster than repeated native grep/read loops.

- Prefer for broad semantic queries: "Find the XYZ flow", "How does XYZ work?",
  "Where is XYZ handled?", "Where is this error message coming from?"
- Do **not** use it to pinpoint exact keywords, symbols, or regex — use native
  grep/`rg` for those.
- `github_codebase_search` is for public GitHub repos without cloning.

### Fast Apply (`edit_file`)

IMPORTANT: Prefer `edit_file` over native search-and-replace or full-file writes
for multi-hunk or large-file edits. It works with partial snippets and
`// ... existing code ...` markers — no need for the full file content in the
edit payload.

- `edit_file` calls Morph's Fast Apply API and consumes **Morph API usage**
  (`MORPH_API_KEY`). Fall back to native edit on timeout/error.
- Batch all edits to one file in a single `edit_file` call when practical.

### Reflex tools

Reflex tools stay enabled but are passive until explicitly called.

Authority: `roles/mcp_servers/morph`, `docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md`
Vendor steering: https://docs.morphllm.com/guides/mcp
# END ANSIBLE MANAGED BLOCK: routing_morph-mcp
