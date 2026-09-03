# Morph MCP Server (WarpGrep + Fast Apply)

Semantic codebase search and Fast Apply tools for Cursor, Codex, Continue, and VS Code.

**Status: under evaluation** — see `docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md`.

## Upstream

- **Docs:** https://docs.morphllm.com/mcpquickstart
- **MCP agent steering:** https://docs.morphllm.com/guides/mcp
- **WarpGrep:** https://docs.morphllm.com/sdk/components/warp-grep
- **Package:** `@morphllm/morphmcp` (global npm install, binary `morph-mcp`)
- **API keys:** https://www.morphllm.com/

## Classification

| Attribute | Value |
|---|---|
| Runtime | Node.js |
| Install Method | npm global (`morph-mcp` binary) |
| Interaction Model | launcher |
| Supported Targets | `cursor_user`, `cursor`, `vscode`, `codex` (+ Continue via `continue_ide`) |
| Default Targets | **`cursor_user`** (lab default), plus host_vars may add `codex` / `vscode` |
| Verify Mode | tool_listing |

## Cursor targets (both exist; default is user)

| Target | Config path | Agent namespace | Lab default? |
|---|---|---|---|
| `cursor_user` | `~/.cursor/mcp.json` | `user-morph-mcp` | **Yes** |
| `cursor` | `<repo>/.cursor/mcp.json` | `project-N-<folder>-morph-mcp` | Opt-in |

Both are first-class Ansible options (`morph_mcp_targets`). Default inventory
uses **`cursor_user` only**. Add `cursor` when you deliberately want project
scope (and follow the allowlist + restart procedure).

### This was a Cursor problem, not a Morph-only problem

Writing any server into project `.cursor/mcp.json` is **not sufficient** for
Cursor Agent. Cursor also requires the project-MCP allowlist
(`state.vscdb` → `cursor/approvedProjectMcpServers` as `{id}:{configHash}`) and
usually a full restart for Agent to `createClient`. That gate applies to
**any** project MCP server (context7, firecrawl, Morph, …). Early Morph Agent
failures were enablement/ops mistakes on that Cursor gate — not evidence Morph
binary/API was broken. Prefer `cursor_user` to avoid that gate for daily eval.

Keep using the allowlist DB technique for diagnosis and for project-scope
commissioning. See
`docs/reports/mcp_server_validations/morph/2026-09-02--cursor-agent-enablement-findings.md`.

### Customize UI may not show Project (non-breaking)

**Potentially always true on this Cursor build:** Configure morph-mcp / MCPs
gallery may list only the **User** source (`~/.cursor/mcp.json`, “1 source”)
even when project Morph is live in Agent. Operators report never seeing a
Project row there. Treat that as a **non-breaking UI reporting gap** — verify
with Agent namespaces + logs + allowlist DB, not the panel alone. Dual
user+project can make the UI look “User only” while both namespaces work.

## Default tool posture

| Tool | Lab posture | Notes |
|---|---|---|
| `codebase_search` | enabled (prefer) | WarpGrep — broad semantic exploration |
| `github_codebase_search` | enabled (prefer) | Public GitHub without clone |
| Reflex tools | enabled (passive) | No cost until invoked |
| `edit_file` | **enabled for evaluation** | Morph Fast Apply API — Morph API usage |

## Vault

Store the Morph API key in `vault/shared.vault.yml` as `vault_shared_morph_api_key`.

```bash
bin/codex-env ansible-vault encrypt_string --stdin-name vault_shared_morph_api_key | pbcopy
```

Runtime secret file (mode `0600`):

```text
~/.config/dotfile-vnext/mcp/env.d/morph.env
```

## Steering (habit layer — Morph vendor recommended)

The role deploys Morph’s recommended Fast Apply + Warp Grep steering
(adapted to real tool names `edit_file` / `codebase_search`) to every surface
we configure:

| Surface | Path |
|---|---|
| Codex / Cursor project agents | `AGENTS.md` (`routing_morph-mcp` block) |
| Codex subagents | `.codex/agents/{default,explorer,worker}.toml` |
| Cursor Agent rules | `.cursor/rules/morph-warpgrep-evaluation.mdc` |
| Cursor framework router | `.cursor/rules/framework-mcp-and-tool-usage.mdc` (points at Morph) |
| Continue | `.continue/rules/morph-warpgrep-evaluation.md` |
| VS Code / Copilot | `.github/copilot-instructions.md` (`routing_morph-mcp` block) |

Continue MCP **access** is via `continue_ide_mcp_servers` in host_vars — re-run
`continue_ide` after morph path changes. Do not also list the Continue rule in
`continue_ide_rules` (duplicate load).

## Prerequisites

- Node.js via `roles/common/node`
- BurntSushi `rg` via `roles/ripgrep_cli`
- Playbook `playbooks/mac/mcp_servers.yaml --tags morph` includes ripgrep_cli

## Apply / Verify / Undo / Change Class

**Apply:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags morph
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags continue_ide
```

**Verify:**

1. `~/.cursor/mcp.json` contains `morph-mcp` when `cursor_user` is selected
2. Project `.cursor/mcp.json` contains Morph only when `cursor` is selected
3. `.codex/config.toml` + `~/.codex/config.toml` have `[mcp_servers.morph-mcp]`
4. `codex mcp list` shows `morph-mcp`
5. Steering files contain Morph Fast Apply / Warp Grep guidance (table above)
6. No tracked config contains `MORPH_API_KEY`
7. Agent can call `codebase_search` (WarpGrep)

**Undo:**

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags morph -e morph_mcp_state=absent
```

**Change Class:** Idempotent configuration management

## Library reference

HRL: `homelab-reference-library/implementation-guides/morphllm/warp-grep-mcp-homelab.md`
