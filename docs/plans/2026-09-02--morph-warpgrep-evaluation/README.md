---
title: Morph WarpGrep MCP evaluation
lifecycle: incomplete-wip
status: under_evaluation
started_at: 2026-09-02
netbox_scope: false
---

# Morph WarpGrep MCP — Evaluation Plan

## Summary

We are **evaluating** Morph WarpGrep (`@morphllm/morphmcp`) as a semantic codebase
search MCP for homelab development workflows. It is installed and wired, but not
yet promoted to steady-state “selected” tooling.

**Evaluation started:** 2026-09-02

## Problem

Broad repo exploration questions cause agents to run many grep/read cycles,
filling the main context window. WarpGrep searches in a separate subagent context
and returns focused snippets (~seconds per query).

## What was implemented (Ansible — not one-off)

| Component | Path |
| --- | --- |
| MCP role | `roles/mcp_servers/morph` |
| Playbook | `playbooks/mac/mcp_servers.yaml` (`--tags morph`) |
| Vault key | `vault_shared_morph_api_key` in `vault/shared.vault.yml` |
| Secret env | `~/.config/dotfile-vnext/mcp/env.d/morph.env` (0600) |
| Validation receipt | `docs/reports/mcp_server_validations/morph/README.md` |
| HRL pack | `homelab-reference-library/generated/context7/morphllm/warp-grep-mcp-cursor-setup/` |
| HRL guide | `homelab-reference-library/implementation-guides/morphllm/warp-grep-mcp-homelab.md` |

## Default tool posture

| Tool | Setting | Rationale |
| --- | --- | --- |
| `codebase_search` | **On** | Primary evaluation target |
| `github_codebase_search` | **On** | Upstream repo search without clone |
| `edit_file` | **Off** | Upstream default; avoids Cursor native editor collision |
| Reflex tools | **On** | Passive until called; no per-turn overhead |

## Client integration matrix

| Surface | Access (MCP wired) | Habit (steering) | Owner |
| --- | --- | --- | --- |
| **Cursor Agent** | **`~/.cursor/mcp.json`** via `cursor_user` → `user-morph-mcp` (**lab default**). Project target `cursor` supported but opt-in (allowlist + restart; Customize UI may omit Project) | `.cursor/rules/morph-warpgrep-evaluation.mdc` + `framework-mcp-and-tool-usage.mdc` | `roles/mcp_servers/morph` + `roles/cursor/rules/` |
| **Codex CLI** (`codex mcp list`) | `~/.codex/config.toml` → `[mcp_servers.morph-mcp]` | `AGENTS.md` managed block; `.codex/agents/*.toml` | `roles/mcp_servers/morph` |
| **Codex CLI** (in-repo session) | project `.codex/config.toml` overlay + user file | Same | Same |
| **Codex extension** | `~/.codex/config.toml` (shared with CLI; not project-only) | Same `AGENTS.md` + agent toml when workspace trusted | Same |
| **VS Code MCP** | `.vscode/mcp.json` → `morph-mcp` | N/A (use Cursor/Codex in this repo) | `roles/mcp_servers/morph` |
| **Continue extension** | `~/.continue/config.yaml` `mcpServers` via `continue_ide` | Project `.continue/rules/morph-warpgrep-evaluation.md` only (`continue_ide_rules: []`) | `roles/mcp_servers/morph` + `roles/continue_ide` |

**Homelab-findings (2026-09-02):** Cursor project MCP needs trust approval + reload;
Codex list/extension read user Codex config; Continue must not duplicate rules or
keep `new-mcp-server` stubs. Durable write-ups:
`docs/reports/mcp_server_validations/morph/2026-09-02--cursor-agent-enablement-findings.md`,
HRL `implementation-guides/mcp/client-enablement-matrix-cursor-codex-continue.md`.

## Steering surfaces (habit layer)

Managed by `roles/mcp_servers/morph/tasks/configure_routing.yml`:

1. **AGENTS.md** — `# BEGIN ANSIBLE MANAGED BLOCK: routing_morph-mcp`
2. **Codex agents** — `default.toml`, `explorer.toml`, `worker.toml` (inside `developer_instructions`)
3. **Continue** — `.continue/rules/morph-warpgrep-evaluation.md` + `continue_ide_rules` in host vars
4. **Cursor** — `framework-mcp-and-tool-usage.mdc` (source: `roles/cursor/rules/framework-mcp-and-tool-usage.mdc.cursor`)

Registry row: `docs/codex_framework/instruction-scope-registry.md`

## Apply / Verify / Undo

**Apply (full stack on mac-dev):**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml --limit mac-dev --tags morph
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml --limit mac-dev --tags continue_ide
```

**Verify:**

1. `.cursor/mcp.json`, project `.codex/config.toml`, `~/.codex/config.toml`, `.vscode/mcp.json` contain `morph-mcp` via wrapper (no inline API key)
2. `codex mcp list` shows `morph-mcp` (this command reads **user** `~/.codex/config.toml`)
3. `rg --version` works; `ripgrep` as a command is expected to fail (binary is `rg`)
4. `AGENTS.md` and `.codex/agents/explorer.toml` contain `routing_morph-mcp` managed block
5. `~/.continue/config.yaml` lists `morph-mcp` and rules file when continue_ide converged
6. Restart Cursor, Codex, and Continue; confirm MCP tool **`codebase_search`** (WarpGrep). There is no tool named `warpgrep`.
7. Cursor Agent: enable `morph-mcp` in Customize if logs show `project-1-dotfile-vnext-morph-mcp -> disconnected` with no `createClient`

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags morph -e morph_mcp_state=absent
# Remove continue entries from host_vars or set continue_ide_mcp_servers: [] and re-converge continue_ide
```

**Change class:** Idempotent configuration management

## Workspace status

| Repo | Status |
| --- | --- |
| dotfile-vnext | Integrated (evaluation) |
| homelab-reference-library | Context7 pack + catalog + implementation guide |
| global-skills | No MCP surface — no change |
| work-laptop-ai-tools | Not integrated (separate MCP stack) |

## Manual operator steps

1. After Morph Ansible converge: confirm Agent has `user-morph-mcp` / `codebase_search` (new chat if an old session predates user MCP).
2. **Cursor Settings → MCP** reflecting user `~/.cursor/mcp.json` is expected on the eval path (`cursor_user`). Other stack servers may still come from project `dotfile-vnext/.cursor/mcp.json`.
3. Continue servers are in `~/.continue/config.yaml`, not the Cursor MCP GUI.
4. Codex extension / `codex mcp list` read `~/.codex/config.toml`, not project-only.
5. WarpGrep needs `rg` on PATH (`~/.local/bin/rg`); command is not `ripgrep`. Tool name is `codebase_search`.

### Continue ETARGET (fixed 2026-09-02)

Do not launch via `npx --prefer-offline`. Clients must use the global `morph-mcp` binary from `@morphllm/morphmcp@0.8.212`. See `docs/reports/mcp_server_validations/morph/README.md`.

### Cursor Agent project enablement (proven 2026-09-03 after restart)

Project Morph works in Agent when: project `.cursor/mcp.json` has Morph,
`approvedProjectMcpServers` contains matching `project-*-morph-mcp:<hash>`,
and Cursor is fully restarted (mid-session add stayed disconnected). Customize
**Configure morph-mcp** may still show only **User** source — ignore that as
sole truth; check Agent namespaces.

Allowlist DB technique is **kept** as durable lab ops (not optional fluff).

Eval Ansible default remains `cursor_user`; project entry is currently a
manual one-off until inventory adds `cursor` to `morph_mcp_targets`.

## Remaining configuration / evaluation work

| Item | Owner | Notes |
| --- | --- | --- |
| Promote vs discard Morph | You | Use evaluation criteria table; keep `under_evaluation` until decided |
| Cost / latency sample set | Lab | Run N representative `codebase_search` queries; record API spend |
| Agent adoption check | Lab | Confirm agents prefer `codebase_search` when steered vs native Grep |
| Project Cursor MCP in Ansible | Optional | Proven manually; decide whether to add `cursor` to `morph_mcp_targets` + keep allowlist procedure |
| Deduplicate user vs project Morph | Optional | Both live now (`user-morph-mcp` + `project-1-…`); pick one for steady-state |
| `edit_file` trial | Lab | **Enabled for evaluation**; Morph Fast Apply = Morph API usage |
| Continue_ide re-converge | Optional | Sync host_vars `continue_ide_rules: []` if config drifted |
| VS Code Agent path | Low | `.vscode/mcp.json` wired; not primary daily surface |
| work-laptop-ai-tools | Out of scope | Separate MCP stack |

## Evaluation criteria (promote vs discard)

| Signal | Promote | Discard |
| --- | --- | --- |
| Broad exploration latency | Faster than repeated grep loops | Slower with no quality gain |
| Context efficiency | Cleaner answers, less filler | Same context bloat |
| Cost | Acceptable API usage | Prohibitive for daily use |
| Agent adoption | Uses `codebase_search` when steered | Ignores tool despite routing |

## On Deck — user decisions to integrate

- After evaluation, decide: promote to steady-state, keep `cursor_user` vs return to project MCP + approval runbook, trial `edit_file`, or `morph_mcp_state: absent`.
- Confirm whether Morph should also be commissioned on `work-laptop-ai-tools` (currently out of scope).

## Diagram Inventory

No architecture diagram required for evaluation wiring; see integration matrix above.

Other Available Diagram Types: capability routing diagram if promoted to steady-state MCP capability family.
