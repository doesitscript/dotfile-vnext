---
name: work-laptop-mcp-collect
description: "Use when collecting an MCP server role and its design/logic from the parent dotfile-vnext project into the work-laptop-ai-tools export packet inventory. Use for inventory parent MCP roles, list what to port, or gather role + vault + wrapper dependencies before adopt. Do not use to enable or deploy MCP servers."
---

# Skill: Work-laptop MCP collect

Collect MCP server **implementation and design** from the parent project
(`dotfile-vnext/roles/mcp_servers/`) so the work-laptop packet can adopt them
later. Collection is read + dependency inventory, not commissioning.

## When to use / not use

Use when:

- adding or refreshing an MCP role for the work-laptop slice
- the user asks what parent MCP logic exists to bring over
- preparing inputs for `work-laptop-mcp-adopt`

Do not use when:

- only syncing the sibling (use `work-laptop-packet-ops`)
- enabling a server (`present`) — that is a separate commission step
- inventing a new MCP role from scratch in the packet without parent authority

## Inputs

- MCP role name (e.g. `firecrawl`, `morph`)
- Parent root: usually `/Users/joshc/develop/dotfile-vnext`
- Packet root: `exports/work-laptop-ai-tools` under parent (or sibling after sync)

## Reach (allowed)

- Parent: `roles/mcp_servers/<name>/`, `roles/mcp_servers/_shared/`, `bin/mcp-server-env-wrapper`, related wrappers
- Parent playbooks that list the role (e.g. `playbooks/mac/mcp_servers.yaml`) for reference only
- HRL: `implementation-guides/mcp/porting-mcp-servers-between-projects.md` when available
- Packet: read `export-manifest.yml`, `playbook.yaml`, `host_vars/work-laptop.yaml` to see what is already collected

## Workflow

1. Confirm the role exists under `roles/mcp_servers/<name>/` (SKILL.md not required; role README + defaults + tasks).
2. Record:
   - `*_state` default in role defaults
   - `*_supported_targets`
   - vault file path + key names (`load_vault.yml` / defaults)
   - env file + wrapper paths
   - extra deps (e.g. Morph → `ripgrep_cli`, drawio → Codex stdio wrapper)
   - whether the role has native `present|absent` or needs playbook `when:`
3. Check whether the role is already in packet `export-manifest.yml` and playbook.
4. Produce a short **collect receipt** (conversation or `references/` note) listing:
   - role path
   - secrets required
   - targets safe for work-laptop (vscode/codex vs codex-only)
   - blockers before adopt
5. Hand off to `work-laptop-mcp-adopt` unless the user only wanted inventory.

## Outputs

- Collect receipt with dependencies and remaps needed
- Clear handoff to `work-laptop-mcp-adopt`

## Validation

- Role path exists and supported_targets were read from defaults (not guessed)
- Vault key names quoted from `load_vault.yml` or defaults when secrets apply

## Failure boundaries

- Stop if the role is frozen/legacy with no clear present path and the user did not ask for gated `when:` adoption
- Do not edit sibling-only copies as authority

## Prohibited behavior

- Flipping `*_state` to `present`
- Writing API keys into tracked mcp.json / host_vars
- Skipping supported_targets check

## Progressive disclosure

- Load `references/hrl-pointers.md` for library paths
- After collect, use skill `work-laptop-mcp-adopt`
- Packet vault: skill `work-laptop-vault`
