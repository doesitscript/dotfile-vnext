---
title: Morph MCP — Cursor Agent enablement findings
document_type: investigation
status: reviewed
authority: internal
source_type: homelab-findings
retrieved_at: "2026-09-02"
last_reviewed_at: "2026-09-03"
related:
  - docs/reports/mcp_server_validations/morph/README.md
  - docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md
  - roles/mcp_servers/morph/README.md
tags:
  - morph
  - mcp
  - cursor
  - codex
  - continue
  - homelab-findings
---

# Morph MCP — Cursor Agent enablement findings (2026-09-02)

**Provenance:** Homelab / lab findings from live probes on `mac-dev` during the
Morph WarpGrep evaluation. These are **our** operational truths for this
Cursor/Codex/Continue stack — not Morph vendor docs and not Cursor marketing.

**Failure framing (important):** The Agent “Morph missing” incident was primarily
a **Cursor project-MCP enablement** failure (allowlist + restart), not a Morph
package/API failure. The same gate can block **any** project MCP server written
only into `.cursor/mcp.json`. Early setup treated “Ansible wrote mcp.json” as
done; that was incomplete Cursor commissioning.

Transcript context: agent chat covering Morph install, CLI WarpGrep demo, then
Cursor Agent enablement fix.

## Verdict

| Claim | Status (this lab) |
| --- | --- |
| Ansible can install Morph + vault key + `rg` | Pass |
| WarpGrep works via Morph SDK / API key | Pass (CLI `MorphClient.warpGrep.execute`) |
| Codex CLI/extension can see Morph | Pass (`~/.codex/config.toml`) |
| Continue can list Morph tools | Pass (after global `morph-mcp` binary) |
| Cursor Agent gets Morph from **user** `~/.cursor/mcp.json` | **Pass** (`user-morph-mcp`; often hot-connects without quit) |
| Cursor Agent gets Morph from **project** `.cursor/mcp.json` | **Pass after restart** when project entry exists **and** allowlist has matching `{id}:{configHash}` (2026-09-02 ~23:41). Pre-restart one-off stayed `disconnected`. |
| Customize UI shows a Project source for Morph when user+project both exist | **Fail / incomplete UI** — Configure morph-mcp showed **only User** (`~/.cursor/mcp.json`, “1 source”) while Agent already had `project-1-dotfile-vnext-morph-mcp` |

## Finding 1 — Project MCP allowlist (`approvedProjectMcpServers`)

**Keep this.** Reading and updating Cursor’s project-MCP allowlist in
`globalStorage/state.vscdb` is a **durable lab technique**, not something to
soft-pedal. Cursor does not expose this key as a Settings page name; we still
use it for diagnosis and for enabling project servers when the UI is incomplete
or missing.

**Storage (macOS Cursor):**

```text
~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
ItemTable key: cursor/approvedProjectMcpServers
Values: ["project-<N>-<folder>-<serverKey>:<configHash>", ...]
```

**How we use it going forward:**

1. Confirm project `.cursor/mcp.json` has the server entry.
2. Read the allowlist (sqlite) and check for `project-*-<serverKey>:<hash>`.
3. If missing or hash stale after command/args/env change: compute Cursor’s
   config hash (same fields as workbench `computeServerConfigHash`: `command`,
   `args`, `env`, `envFile`, `url`, `headers`, `auth`) and upsert the
   `identifier:hash` string into `approvedProjectMcpServers`.
4. Prefer writing the DB while Cursor is **quit** (or fully restart after).
   Live in-memory allowlist often ignores mid-session DB writes.
5. Prove with logs / Agent namespaces: `createClient` for
   `project-*-<server>` → tools ready; optional tool call.

**Evidence this works:** after Morph hashes were already in the allowlist and
Morph was re-added to project `mcp.json`, a full Cursor restart
(`20260902T234106`) produced `createClient` for
`project-1-dotfile-vnext-morph-mcp` and Agent exposed that namespace (plus
`user-morph-mcp`). Live `codebase_search` via the **project** namespace
succeeded 2026-09-03.

**Hashes used for Morph on mac-dev (2026-09-02 entry):**

```text
project-1-dotfile-vnext-morph-mcp:31d360bb
project-0-dotfile-vnext-morph-mcp:31d360bb
```

Any Morph command/args/env change invalidates `31d360bb` — recompute.

### Finding 1a — Customize UI is not the source of truth

Operator screenshots 2026-09-03: **Configure morph-mcp** listed **Source: User
only** (`~/.cursor/mcp.json`), “1 source”, tools connected — **no Project
row**. MCPs gallery showed a single **morph-mcp** card with badge **User**.

Meanwhile Agent had **both** `user-morph-mcp` and
`project-1-dotfile-vnext-morph-mcp` ready. So:

- Do **not** require a visible “Project” toggle in Customize to conclude project
  MCP is enabled.
- Trust Agent namespaces + logs + allowlist DB over that panel when they
  disagree.
- Vendor docs still mention Customize toggles; for Morph with dual user+project
  entries that UI was incomplete in this Cursor build.

### Finding 1b — Hot-load without quitting Cursor

| Change | Observed |
| --- | --- |
| Add Morph to **user** `~/.cursor/mcp.json` | Often **connects in-session** (`user-morph-mcp`). |
| Add Morph to **project** `.cursor/mcp.json` | File may refresh; Agent can stay **`disconnected`** until allowlist is correct **and** a full restart (or successful reload of allowlist into memory). |

Eval Ansible path still prefers `cursor_user` so daily work does not depend on
the project allowlist dance. Project path is proven when allowlist + restart
are done.

## Finding 2 — morphsdk import errors during CLI demo

**Not a Morph config failure.** Ad-hoc Node `import '@morphllm/morphsdk'` from
repo cwd failed because the SDK is nested under the global
`@morphllm/morphmcp` package. Running from that package directory (or using
`morph-mcp` / MCP) works. Do not treat that import error as evidence the Ansible
role is broken.

## Finding 3 — Codex reads user config

`codex mcp list` and the Codex IDE extension read **`~/.codex/config.toml`**,
not only project `.codex/config.toml`. Morph must be written to both. Use
`startup_timeout_sec = 120`, `tool_timeout_sec = 60`, and
`mcp_optional_startup_grace_ms = 0`. Codex “resources Method not found” for
Morph is benign (Morph does not expose MCP resources).

## Finding 4 — Continue pitfalls

1. Do not launch via `npx --prefer-offline` (ETARGET on nested deps). Use pinned
   global `morph-mcp` binary.
2. Do not list the same rule in `~/.continue/config.yaml` `rules:` **and** drop
   it under project `.continue/rules/` — Continue loads both → duplicate rule
   warning.
3. Delete Continue UI stubs like `.continue/mcpServers/new-mcp-server.yaml`
   (`npx -y <your-mcp-server>`) — they produce “Failed to connect to New MCP
   server”.

## Finding 5 — Naming

| Intent | Correct name |
| --- | --- |
| WarpGrep MCP tool | `codebase_search` |
| ripgrep binary | `rg` (not `ripgrep`) |

## Finding 6 — `edit_file` posture (words matter)

Morph MCP **exposes** `edit_file` (Fast Apply) in the tool list on this machine
(`user-morph-mcp` toolCount includes it). Our older “disabled” wording meant
**habit / preference: do not prefer it over native Cursor edits by default** —
**not** “tool gated off in the MCP server.”

**Billing:** `edit_file` calls Morph’s Fast Apply API (`api.morphllm.com`) with
`MORPH_API_KEY`. It consumes **Morph API usage** (prompt/completion tokens on
Morph’s side). It is **not** a free local-only patch tool.

Lab decision 2026-09-02 late: treat `edit_file` as **enabled for evaluation**
(allowed / encouraged to trial); document Morph API cost; still fine to fall
back to native edit on timeout/error.

## Live proof

1. User `~/.cursor/mcp.json` Morph entry → log:
   `createClient: identifier="user-morph-mcp"` → `connected` → `toolCount: 7`.
2. Agent dynamic tools include `user-morph-mcp` / `codebase_search`.
3. Called `codebase_search` on `dotfile-vnext`; returned Morph role / routing
   file hits.
4. Ansible re-apply `--tags morph` with `morph_mcp_targets: [cursor_user, codex, vscode]`
   removed Morph from project `.cursor/mcp.json` and kept user entry
   (`changed=2`, `failed=0`).
5. **One-off project re-add (2026-09-02 ~23:17):** Morph put back into project
   `.cursor/mcp.json` (same entry as user). Cursor refreshed
   `project-1-dotfile-vnext-morph-mcp` but status stayed **`disconnected`**
   until full restart.
6. **After Cursor restart (2026-09-02 ~23:41):** logs show `createClient` for
   both `user-morph-mcp` and `project-1-dotfile-vnext-morph-mcp`. Agent
   namespaces both `ready`. Project `codebase_search` call succeeded
   (2026-09-03). Allowlist already contained Morph `…:31d360bb` entries.
7. **UI mismatch (operator screenshots):** Configure morph-mcp → Source = User
   only (“1 source”); no Project row — while Agent had project Morph tools.

## Related durable surfaces

- Role: `roles/mcp_servers/morph` (`cursor_user` target; project one-off is
  manual until inventory adds `cursor`)
- Plan: `docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md`
- HRL: `implementation-guides/mcp/client-enablement-matrix-cursor-codex-continue.md`
- HRL investigation: `notes/investigations/2026-09-02--mcp-client-enablement-cursor-codex-continue.md`
