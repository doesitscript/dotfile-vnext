---
name: work-laptop-mcp-adopt
description: "Use when adopting a parent MCP server role into the work-laptop-ai-tools packet or sibling build target: export-manifest, playbook tags, host_vars remaps, vault/env paths, default absent. Embeds HRL porting lessons. Do not use to commission or enable MCP by default."
---

# Skill: Work-laptop MCP adopt

Adopt a collected MCP role into the work-laptop packet using learned remaps
from HRL (and the condensed checklist in this skill). Default remains
**not commissioned** (`*_state: absent`).

## When to use / not use

Use when:

- `work-laptop-mcp-collect` finished (or the role is already understood)
- wiring manifest + playbook + host_vars for a new or refreshed MCP
- applying path/vault remaps for vscode/codex on this slice

Do not use when:

- only listing parent roles (use `work-laptop-mcp-collect`)
- user asked to enable/deploy the server live without an explicit commission ask
- changing Continue/Zed lists without an explicit ask (use `work-laptop-mcp-commission`)
- user asked to **enable** servers already in the catalog (use `work-laptop-mcp-commission`)

## Inputs

- MCP role name
- Collect receipt (or re-read role defaults)
- Packet root under parent `exports/work-laptop-ai-tools/`

## Authority

1. Edit the **export packet** in parent, never sibling-only.
2. Apply HRL lessons: load
   `/Users/joshc/develop/homelab-reference-library/implementation-guides/mcp/porting-mcp-servers-between-projects.md`
   when that checkout exists; otherwise use `references/porting-checklist.md`
   in this skill (condensed copy).
3. Sync sibling via `work-laptop-packet-ops` / `work-laptop-export-pack`.

## Reach (allowed)

- Parent `roles/mcp_servers/<name>/` (source; usually not modified for adopt)
- Packet: `export-manifest.yml`, `playbook.yaml`, `host_vars/work-laptop.yaml`, `bin/`, `vault/`
- Shared helpers: ensure `bin/mcp-server-env-wrapper` (and role-specific wrappers) are on the manifest
- HRL MCP guides when available

## Workflow

1. Load `references/porting-checklist.md` (and HRL guide if available).
2. Add role to `export-manifest.yml` `include` with `dest: roles/mcp_servers/<name>`.
3. Add playbook role entry + tags. For roles without present|absent, use:
   `when: <flag> | default('absent') == 'present'`.
4. In `host_vars/work-laptop.yaml`:
   - set `*_state: absent` (or packet gate flag `absent`)
   - set targets only from `*_supported_targets` (often `[vscode, codex]` or `[codex]`)
   - override vscode/codex paths to user home via `work_laptop_mcp_*` helpers
   - override env dir to `~/.config/work-laptop-ai-tools/mcp/env.d/`
   - override wrapper + `*_vault_file_path` to packet `bin/` + `vault/shared.vault.yml`
5. Do **not** append `continue_ide_mcp_servers` / `zed_ide_context_servers` unless asked.
6. If Morph: keep `ripgrep_cli_state: absent` until Morph is commissioned; note the dependency.
7. Update packet README optional-MCP note if the catalog changed.
8. If secrets: hand off to `work-laptop-vault` for example keys (no live secrets).
9. Run `work-laptop-packet-ops` to validate + sync sibling.

## Outputs

- Packet wired for the role at `absent`
- Sibling updated after sync
- Optional vault example key rows

## Validation

- `*_state` (or gate flag) is `absent`
- supported_targets honored
- export contract validate + sibling sync succeed

## Failure boundaries

- Stop before enabling if vault keys are required and missing — document, leave absent
- Stop if vscode requested but not in supported_targets — use codex-only or extend parent role first

## Prohibited behavior

- Enabling by default
- Embedding secrets in tracked client config
- Hand-editing only the sibling as authority

## Progressive disclosure

- `references/porting-checklist.md` — required remaps
- `references/hrl-pointers.md` — library living docs
- Companion: `work-laptop-mcp-collect`, `work-laptop-mcp-commission`, `work-laptop-vault`, `work-laptop-packet-ops`
