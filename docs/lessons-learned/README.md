# Lessons Learned — Operational Intelligence Library

This folder is a permanent record of non-obvious findings, root causes, and
proven fixes from operating and building this infrastructure. Each entry
documents something that cost real time to figure out, so it never has to be
re-discovered from scratch.

**How to use it:** Scan the index below when you hit a confusing problem — odds
are it has been seen before. When you solve something new and hard, add an entry
here so future-you gets the benefit.

**How to add an entry:** Pick the right technology subfolder, create a markdown
file with a descriptive name (describe the problem, not the date), and add a
one-line summary row to the index below.

---

## Index

### `windows/` — Windows host, WSL, WinRM, PowerShell, OpenSSH

| File | One-line summary |
|---|---|
| [wsl-idle-shutdown-and-wslconfig-parsing.md](windows/wsl-idle-shutdown-and-wslconfig-parsing.md) | WSL 2.6.x shuts down after ~8s idle; `vmIdleTimeout` is ignored; CRLF in `.wslconfig` silently rejects the entire file; fix is a keepalive scheduled task running as the user |

### `ansible/` — Ansible engine, modules, WinRM transport, lint

| File | One-line summary |
|---|---|
| [netbox-service-inventory-should-use-hybrid-preview-not-direct-auto-write.md](ansible/netbox-service-inventory-should-use-hybrid-preview-not-direct-auto-write.md) | NetBox service inventory should stay repo-first with read-only runtime discovery; hybrid preview gives drift visibility without letting temporary runtime state become source of truth |
| [vscode-ansible-mcp-server-bundler-tsconfig--UNRESOLVED.md](ansible/vscode-ansible-mcp-server-bundler-tsconfig--UNRESOLVED.md) | v26.x tsconfig switched to `moduleResolution: "bundler"` + `@src/*` path aliases; plain `tsc` leaves aliases unresolved in compiled JS; `ERR_MODULE_NOT_FOUND` at runtime; workaround is pinning to v25.12.2; fix for v26.x+ is `tsc-alias` post-build step |

### `codex/` — Codex behavior, framework design, repo instruction workflow

| File | One-line summary |
|---|---|
| [deprecated-or-disproven-paths-must-be-replaced-not-extended.md](codex/deprecated-or-disproven-paths-must-be-replaced-not-extended.md) | Once a path is deprecated, disproven, or already replaced, the framework should switch to replacement-path research or implementation instead of layering more workarounds on top |
| [research-should-surface-existing-building-blocks-before-custom-orchestration.md](codex/research-should-surface-existing-building-blocks-before-custom-orchestration.md) | Research should identify native modules, community resources, and DSC building blocks before settling on custom Windows/Hyper-V orchestration |

### `docker/` — Docker Engine, contexts, Compose, daemon config

| File | One-line summary |
|---|---|
| *(empty — add entries here)* | |

### `linux/` — Linux distros (WSL and bare-metal), systemd, networking

| File | One-line summary |
|---|---|
| *(empty — add entries here)* | |

### `networking/` — Hyper-V, bridged/NAT modes, firewall, SSH routing

| File | One-line summary |
|---|---|
| [hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md](networking/hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md) | A guest-hosted service can be healthy while the Windows Hyper-V `portproxy` publication layer is dead; prove controller path, guest-local path, and Windows host path separately, then restart `iphlpsvc` if needed |
| [hyper-v-routed-subnet-needs-router-route-or-host-nat.md](networking/hyper-v-routed-subnet-needs-router-route-or-host-nat.md) | A Hyper-V guest lane cannot cleanly have both true routed guest-IP access and outbound internet at the same time unless the upstream router learns the guest subnet; otherwise choose either host NAT or a router static route |

---

## Candidates for migration

These existing docs elsewhere in the repo contain lessons-learned content and
should be migrated into this library when time allows:

| Current path | Suggested destination | Why |
|---|---|---|
| `docs/winrm_troubleshooting.md` | `ansible/winrm-connection-issues.md` | Specific bug + fix for WinRM ConvertFrom-Json array deserialization |
| `docs/setup_openssh_via_winrm_summary.md` | `windows/openssh-setup-via-winrm.md` | Operational notes on bootstrapping OpenSSH when only WinRM is available |
| `docs/powershell/possible_fix_bom_endline_crlf.md` | `windows/powershell-bom-and-line-endings.md` | Stub for the BOM/CRLF encoding pitfalls (expand with full findings) |
| `docs/debug-ssh-vvv.md` | `networking/ssh-debug-vvv-reference.md` | SSH debug output reference during connection troubleshooting |

---

## Folder layout

```
lessons-learned/
├── README.md          ← this file (index)
├── codex/             ← Codex behavior, framework design, instruction workflow
├── windows/           ← Windows host, WSL, WinRM, PowerShell, OpenSSH
├── ansible/           ← Ansible engine, modules, WinRM transport, lint
├── docker/            ← Docker Engine, contexts, Compose, daemon config
├── linux/             ← Linux (WSL + bare-metal), systemd, networking
└── networking/        ← Hyper-V, bridged/NAT, firewall, SSH routing
```
