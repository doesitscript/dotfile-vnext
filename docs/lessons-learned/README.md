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
| *(empty — add entries here)* | |

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
| *(empty — add entries here)* | |

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
├── windows/           ← Windows host, WSL, WinRM, PowerShell, OpenSSH
├── ansible/           ← Ansible engine, modules, WinRM transport, lint
├── docker/            ← Docker Engine, contexts, Compose, daemon config
├── linux/             ← Linux (WSL + bare-metal), systemd, networking
└── networking/        ← Hyper-V, bridged/NAT, firewall, SSH routing
```
