# WSL 2 Persistence — Findings, Root Cause, and Fix

**Environment:** WSL 2.6.3 (Build 2.6.3.0), Windows 11 24H2 (Build 26100),
Ubuntu 24.04 distro, bridged networking via Hyper-V External VMSwitch.

**Date confirmed:** March 2026

---

## The Problem

SSH connections from Mac to WSL (`server-225-wsl`, `network-server-wsl`) and
Docker contexts that rely on those SSH connections would fail with:

```
ssh: connect to host 192.168.50.222 port 22: Operation timed out
ssh: connect to host 192.168.50.222 port 22: Connection refused
```

The failures were intermittent — a fresh `wsl.exe` command from Windows would
bring the distro back immediately, but within 8–30 seconds of the last
`wsl.exe` process exiting, the VM became unreachable again.

---

## Root Cause: WSL 2 VM Idle Shutdown

WSL 2 runs each Linux distro inside a lightweight Hyper-V VM. When **all
`wsl.exe` sessions exit** (i.e. no Windows process holds an active connection
into the distro), WSL considers the VM "idle" and shuts it down after a
configurable timeout. On Windows 11 24H2 with WSL 2.6.x, this idle timer
defaults to roughly 8 seconds.

When the VM shuts down:
- The WSL distro's bridged IP address (`192.168.50.222`) becomes unreachable.
- sshd, dockerd, and all other daemons are killed.
- Any in-flight SSH connection receives `Connection refused` or times out.
- Mac `docker --context mac-dev` calls fail because the SSH tunnel to the
  engine host drops.

Daemons running **inside** the VM (sshd, dockerd managed by systemd) do **not**
count as active sessions from the host's perspective. Only `wsl.exe` processes
running on the Windows side count.

---

## What We Tried First: `.wslconfig` `vmIdleTimeout`

### Key naming changed in WSL 2.6.x

The setting is documented online as `vm.idleTimeout` (dotted). WSL 2.6.x
rejects dotted key names with a parse error:

```
wsl: Expected '=' in C:\Users\joshc\.wslconfig: 4
```

The correct key name in WSL 2.6.x is **`vmIdleTimeout`** (camelCase, no dot).

Values:
| Value | Meaning |
|---|---|
| `-1` | Never auto-shutdown |
| `0` | Shutdown immediately when all sessions exit |
| `>0` | Shutdown after N milliseconds of idle |

### `.wslconfig` MUST use LF line endings

WSL 2.6.x's config parser requires **LF-only** (`\n`) line endings. CRLF
(`\r\n`) causes the parser to fail on line 1 with:

```
wsl: Expected ' ' or '\n' in C:\Users\joshc\.wslconfig: 1
```

When parsing fails, WSL **silently ignores the entire file** and falls back to
all defaults — including `networkingMode=NAT`. There is no warning in the
Windows event log and no user-visible error. The VM simply starts in NAT mode
instead of bridged, and all `.wslconfig` settings are ignored.

**This means `networkingMode=bridged` was never being applied** until the
`newline_sequence: '\n'` fix was applied to the Ansible `win_template` task.
The Ansible default for `win_template` on Windows targets is CRLF.

### `vmIdleTimeout=-1` is parsed but not honored in WSL 2.6.3

After fixing the CRLF issue and using the correct camelCase key, we set
`vmIdleTimeout=-1`. WSL parsed the config without errors. The VM still shut
down after ~20–30 seconds of no active `wsl.exe` sessions.

This appears to be a bug in WSL 2.6.3 (Build 2.6.3.0 on Windows 11 Build
26100). The setting is retained in the template (`wslconfig_bridged.j2`) as
belt-and-suspenders in case a future WSL update fixes the behavior.

---

## The Actual Fix: WSLKeepalive Windows Scheduled Task

### What it does

A Windows Scheduled Task named `WSLKeepalive` runs:

```
wsl.exe -d "Ubuntu-24.04" -u root -- sleep infinity
```

This holds a permanent `wsl.exe` process open inside the distro. As long as
this process is running, WSL never reaches the "idle" state and never shuts
down the VM. SSH from Mac and Docker contexts remain reachable indefinitely.

### Why sleep infinity

`sleep infinity` is a valid command on Ubuntu 24.04 bash. It runs forever and
uses negligible CPU. The process holds the wsl.exe session open on the Windows
side, which is the only thing WSL checks when deciding whether to idle-shutdown.

### Why it must run as joshc (not SYSTEM)

WSL distros are **registered per-user** in the Windows registry
(`HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss`). The SYSTEM account
has no WSL configuration; running `wsl.exe` as SYSTEM produces no error but
also starts no VM — the call exits silently. The task must run as the same
Windows user who owns the distro (`joshc`).

This means the trigger is `/SC ONLOGON` rather than `/SC ONSTART`. For this
project's use cases (SSH from Mac, Docker contexts), the user is always logged
in when the WSL distro needs to be reachable, so this is acceptable.

### Why schtasks.exe instead of PowerShell cmdlets

The PowerShell Scheduled Task API (`New-ScheduledTaskAction`, `Register-
ScheduledTask`, etc.) uses CIM/WMI under the hood. In WinRM remote sessions on
Windows 11 24H2, these CIM classes fail with:

```
Cannot convert value "\MSFT_TaskExecAction" to type CimInstance[]
```

`schtasks.exe` is a plain Win32 executable with no CIM dependency. It works
correctly in all WinRM sessions and is the reliable tool for this use case.

### Ansible task location

Implemented in:
- `roles/access_identity_windows/tasks/ubuntu.yml` — Step 7
- Creates/updates the `WSLKeepalive` scheduled task on the Windows host
- Starts the task immediately if not already running
- Cleans up legacy debug tasks (`AnsibleWSLTest`, `AnsibleWSLKeepalive_*`)

---

## Summary of All File Changes Made

| File | Change | Reason |
|---|---|---|
| `roles/access_identity_windows/templates/wslconfig_bridged.j2` | `newline_sequence: '\n'` on the `win_template` task | CRLF causes silent full-file rejection |
| `roles/access_identity_windows/templates/wslconfig_bridged.j2` | `vm.idleTimeout=0` → `vmIdleTimeout=-1` | Dotted key rejected; 0 means immediate shutdown |
| `roles/access_identity_windows/tasks/ubuntu.yml` Step 1.2 | `newline_sequence: '\r\n'` → `'\n'` | Same CRLF issue |
| `roles/access_identity_windows/tasks/ubuntu.yml` Step 7 | Added WSLKeepalive scheduled task (new) | Actual fix for idle shutdown |

---

## Validation

After the keepalive task was running on both `server-225-win` and
`network-server-win`:

```
# SSH from Mac after 30+ seconds of no wsl.exe activity:
ssh joshc@192.168.50.222   →  DESKTOP-VLLM  (server-225-wsl)  ✅
ssh joshc@192.168.50.240   →  AI-NET-SERVER (network-server-wsl) ✅

# Docker hello-world from Mac:
docker --context mac-dev run --rm hello-world  →  "Hello from Docker!"  ✅

# Docker hello-world inside WSL:
(server-225-wsl)   docker run --rm hello-world  →  "Hello from Docker!"  ✅
(network-server-wsl) docker run --rm hello-world →  "Hello from Docker!"  ✅
```

---

## If WSL Goes Offline Again

1. Check if the keepalive task is running:
   ```powershell
   schtasks /Query /TN WSLKeepalive /FO LIST
   ```
2. If `Status: Ready` (not Running), start it:
   ```powershell
   schtasks /Run /TN WSLKeepalive
   ```
3. If the task is missing entirely, re-run the access_windows playbook:
   ```bash
   ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml \
     --limit server-225-win,network-server-win --tags wsl
   ```
4. If WSL was shut down deliberately (`wsl --shutdown`), the keepalive task
   will NOT auto-restart until the user logs off and back on. Start it manually
   with `schtasks /Run /TN WSLKeepalive`, or reboot the Windows host.
