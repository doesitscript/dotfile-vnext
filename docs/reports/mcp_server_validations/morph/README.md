# Morph MCP (WarpGrep) validation

**Status: under evaluation** — `docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md`

Applied:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags morph
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags continue_ide
```

## Incident — Continue `ETARGET` (2026-09-02)

Continue showed `Failed to connect to "morph-mcp"` / `MCP error -32000: Connection closed`.

Root cause (npm log `2026-09-03T01_32_51_215Z-debug-0.log`):

```
npm error code ETARGET
npm error notarget No matching version found for @ai-sdk/provider-utils@4.0.50.
```

The client launched `npx --prefer-offline -y @morphllm/morphmcp`. `--prefer-offline` used a stale packument cache, so nested dep `@ai-sdk/provider-utils@4.0.50` failed to resolve and the process exited. Cursor Agent in that same session also had **no** `morph-mcp` tools (same launch failure).

**Fix (Ansible, not one-off):** install `@morphllm/morphmcp@0.8.212` globally via nvm npm and point clients at the `morph-mcp` binary. Re-applied `--tags morph` and `--tags continue_ide`.

Live start evidence (this turn):

```
[os=macOS] Workspace mode enabled: Using /Users/joshc/develop/dotfile-vnext as allowed directory
[os=macOS] Secure MCP Filesystem Server running on stdio
```

Binary: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/morph-mcp` → `@morphllm/morphmcp@0.8.212`

## Verify checklist

### MCP access layer

- [x] `~/.cursor/mcp.json` contains `morph-mcp` via wrapper + binary (`cursor_user`)
- [x] Project `.cursor/mcp.json` Morph removed on eval path (avoid disconnected twin)
- [x] `.vscode/mcp.json` contains `morph-mcp`
- [x] `.codex/config.toml` + `~/.codex/config.toml` contain `[mcp_servers.morph-mcp]`
- [x] `~/.config/dotfile-vnext/mcp/env.d/morph.env` mode 0600
- [x] No `MORPH_API_KEY` in tracked client config
- [x] `~/.continue/config.yaml` lists morph-mcp using the global binary
- [x] Cursor Agent: `user-morph-mcp` connected; `codebase_search` callable (2026-09-02)
- [x] `~/.local/bin/rg --version` (role `ripgrep_cli` GitHub release 15.2.0; command is not `ripgrep`)
- [x] `codex mcp list` / `codex mcp get morph-mcp` shows enabled Morph with `startup_timeout_sec: 120`

### Habit / steering layer

- [x] `AGENTS.md` contains `# BEGIN ANSIBLE MANAGED BLOCK: routing_morph-mcp`
- [x] `.codex/agents/explorer.toml` contains routing block inside `developer_instructions`
- [x] `.continue/rules/morph-warpgrep-evaluation.md` exists
- [x] `framework-mcp-and-tool-usage.mdc` mentions evaluation status

## Cursor GUI vs project config

User-level `~/.cursor/mcp.json` is `{"mcpServers": {}}` (empty). Cursor **Settings → MCP** often shows that user file, so it can look like “no servers” even when project servers exist.

Project servers live in [`dotfile-vnext/.cursor/mcp.json`](../../.cursor/mcp.json). This multi-root Cursor window already loads other project servers from that file (`context7`, `firecrawl`, `netbox`, `langfuse-docs`). `morph-mcp` was configured there but did not start until the npx ETARGET path was replaced.

Continue uses `~/.continue/config.yaml`, not Cursor’s MCP GUI.

## Reflex tools decision

Left enabled (upstream default). Passive until invoked; no per-turn overhead.

## Incident — Codex extension / `codex mcp list` empty (2026-09-02)

`codex mcp list` and the Codex IDE extension read **`~/.codex/config.toml`**, not project `.codex/config.toml`. Morph was only in the project file. Codex optional servers also have a **1s** catalog grace (`mcp_optional_startup_grace_ms` default 1000).

**Fix:** role writes Morph to user + project Codex config with `startup_timeout_sec = 120`, `tool_timeout_sec = 60`, and `mcp_optional_startup_grace_ms = 0`.

## Incident — `ripgrep: command not found`

The WarpGrep local-search dependency is ripgrep; the binary is **`rg`**. There is
no `ripgrep` command. On macOS 12, Homebrew tried to source-build Rust/LLVM for
current ripgrep, so `roles/ripgrep_cli` installs the BurntSushi GitHub release
binary to `~/.local/bin/rg`. `playbooks/mac/mcp_servers.yaml --tags morph`
includes that role.

## Cursor Agent tools missing while Continue shows 7 tools

Cursor logs (`20260902T205832` / `20260902T213901`): `project-1-dotfile-vnext-morph-mcp`
is discovered as stdio then stays `disconnected`. `createClient` only ran for
context7, firecrawl, netbox, langfuse-docs.

**Root cause (homelab-findings, not Morph packaging):** Cursor project MCP
**trust approval** (`cursor/approvedProjectMcpServers` + config hash). Ansible
cannot enable project MCP inside a live Agent session without a full reload
after approval.

**Fix applied 2026-09-02 evening:** Ansible target `cursor_user` →
`~/.cursor/mcp.json`. Live: `user-morph-mcp` connected, `toolCount: 7`,
`codebase_search` callable in Agent. Project Morph entry removed while evaluating.

Full write-up:
[`2026-09-02--cursor-agent-enablement-findings.md`](./2026-09-02--cursor-agent-enablement-findings.md)

HRL: `implementation-guides/mcp/client-enablement-matrix-cursor-codex-continue.md`

## Verify checklist (updated after Agent enablement)

- [x] `~/.cursor/mcp.json` contains `morph-mcp` (`cursor_user`)
- [x] Project `.cursor/mcp.json` does **not** list Morph (eval path)
- [x] Cursor Agent: `user-morph-mcp` / `codebase_search` callable
- [x] WarpGrep CLI demo via Morph SDK + vault key + `rg` succeeded
- [x] Continue stub `new-mcp-server.yaml` removed; duplicate rules cleared
- [ ] Evaluation promote/discard decision (cost, latency, agent adoption)
- [ ] Optional: re-enable project Cursor MCP with approve+reload runbook

## What was fixed in steering pass (2026-09-02)

- Added Ansible-managed routing blocks (not one-off hand edits)
- Synced `roles/cursor/rules/framework-mcp-and-tool-usage.mdc.cursor` with active Cursor rule
- Wired Continue `mcpServers` + `rules` via `continue_ide` host vars
- Added evaluation plan packet and instruction-scope-registry row
- Updated HRL implementation guide and Context7 pack
- Replaced `npx --prefer-offline` launch with pinned global `morph-mcp` binary after Continue ETARGET
