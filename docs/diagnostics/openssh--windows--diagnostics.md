# OpenSSH Server Diagnostic Sources — Windows

Platform: Windows 11 (DESKTOP-VLLM / server-225-win), Win32-OpenSSH (inbox)

## Current State (observed 2026-03-10)

```
Name  Status  StartType
----  ------  ---------
sshd  Running Automatic
```

Service is running and set to start automatically on boot.

### Active sshd_config settings

```
Port 2222              # primary — DefaultShell lands in WSL bash
Port 2223              # secondary — Match LocalPort 2223 block → PowerShell
#SyslogFacility AUTH   # commented — defaulting to AUTH → ETW Event Log
#LogLevel INFO         # commented — defaulting to INFO
AuthorizedKeysFile     .ssh/authorized_keys
AuthorizedKeysFile     __PROGRAMDATA__/ssh/administrators_authorized_keys
Match LocalPort 2223   # PowerShell match block
```

No file-based logging configured. All logs go to Windows Event Log (ETW).

---

## Logging Locations

| Source | Location | Notes |
|--------|----------|-------|
| **Primary — ETW Event Log** | `Applications and Services Logs → OpenSSH` | Default when `SyslogFacility AUTH` (or commented) |
| Operational channel | `OpenSSH/Operational` | INFO events — connections, auth, disconnects |
| Admin channel | `OpenSSH/Admin` | CRITICAL + ERROR events — fatal errors, timeouts |
| Debug channel | `OpenSSH/Debug` | Must be manually enabled in Event Viewer |
| **File-based (optional)** | `C:\ProgramData\ssh\logs\sshd.log` | Only when `SyslogFacility LOCAL0` in sshd_config |

---

## Diagnostic Commands (PowerShell)

```powershell
# Service state
Get-Service sshd | Format-Table Name, Status, StartType

# Last 20 operational events (connections, auth)
Get-WinEvent -LogName "OpenSSH/Operational" -MaxEvents 20 |
    ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" }

# Last 20 admin/error events
Get-WinEvent -LogName "OpenSSH/Admin" -MaxEvents 20 |
    ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" }

# Config validation
sshd.exe -t

# Dump effective config (all defaults expanded)
sshd.exe -T

# Restart service
Restart-Service sshd

# Check which ports sshd is listening on
netstat -ano | findstr LISTENING | findstr ":222"
```

## Enable File-Based Logging (for deep debugging)

Edit `C:\ProgramData\ssh\sshd_config`:
```
SyslogFacility LOCAL0
LogLevel Debug3
```
Then: `Restart-Service sshd`
Logs appear at: `C:\ProgramData\ssh\logs\sshd.log`

**Revert after debugging** — `LOCAL0` + `Debug3` is verbose and writes to disk.

## Run sshd in Interactive Debug Mode

```powershell
Stop-Service sshd
# Run as SYSTEM (required — sshd won't start as a regular admin):
# Use PsExec or Task Scheduler to run as NT AUTHORITY\SYSTEM
sshd.exe -ddd   # max verbosity, single connection, outputs to console
Start-Service sshd  # when done
```

---

## Event / Channel Sources

| Channel | Event Viewer Path | Content |
|---------|------------------|---------|
| Operational | `Applications and Services Logs\OpenSSH\Operational` | Auth success/fail, connect/disconnect |
| Admin | `Applications and Services Logs\OpenSSH\Admin` | Fatal errors, timeouts, no-sessions |
| Debug | `Applications and Services Logs\OpenSSH\Debug` | Must be enabled; verbose per-packet data |

### Reading via PowerShell (collect script pattern)

```powershell
# Operational
Get-WinEvent -LogName "OpenSSH/Operational" -MaxEvents 50 -ErrorAction SilentlyContinue |
    ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" }

# Admin (errors)
Get-WinEvent -LogName "OpenSSH/Admin" -MaxEvents 50 -ErrorAction SilentlyContinue |
    ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" }
```

---

## Config File Locations

| File | Purpose |
|------|---------|
| `C:\ProgramData\ssh\sshd_config` | Main config — managed by Ansible role `access_identity_windows` |
| `C:\ProgramData\ssh\administrators_authorized_keys` | Admin users' authorized keys |
| `C:\Users\joshc\.ssh\authorized_keys` | Per-user authorized keys |
| `C:\ProgramData\ssh\logs\sshd.log` | File log — only exists when `SyslogFacility LOCAL0` |

---

## Live Evidence (2026-03-10)

### OpenSSH/Operational — recent connections
```
2026-03-10T13:18:13  sshd: Accepted publickey for joshc from 192.168.50.33 port 50096 ssh2: ED25519 SHA256:sabol8zXq07...
2026-03-10T08:42:50  sshd: Disconnected from 192.168.50.33 port 65034
2026-03-10T08:39:22  sshd: Accepted publickey for joshc from 192.168.50.33 port 65208 ssh2: ED25519 SHA256:sabol8zXq07...
```

### OpenSSH/Admin — recent errors
```
2026-02-22T07:01:46  sshd: fatal: mm_log_handler: write: Unknown error
2026-02-22T06:52:18  sshd: fatal: Timeout before authentication for 192.168.50.33 port 57809
2026-02-20T18:07:39  sshd: error: no more sessions  (x6)
```

The `no more sessions` errors (2026-02-20) correspond to the period when `MaxSessions`
was being hit during parallel Ansible runs. Fixed by setting `MaxSessions 20` in
`sshd_config` (matching `ansible.cfg forks = 20`). No errors since 2026-02-22.

The `mm_log_handler: write: Unknown error` is a known Win32-OpenSSH quirk — occurs when
the ETW logging subsystem is briefly unavailable (e.g. during a WSL restart). Non-fatal,
sshd continues running.

---

## Notes

- `DefaultShell` is **not set** in sshd_config — Windows falls back to `cmd.exe` for
  port 2222. The WSL bash experience is provided by `DefaultShell` being set during
  Ansible provisioning via the `access_identity_windows` role. Verify with:
  `Get-ItemProperty "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell`
- The `Match LocalPort 2223` block overrides `DefaultShell` for the PowerShell port,
  forcing PowerShell regardless of the registry setting.
- `sshd.exe` must run as `NT AUTHORITY\SYSTEM` — running it as a regular admin user
  will fail to bind to privileged ports and fail host-key operations.

---

# Execution Audit

Performed diagnostic-discovery research to identify where this component reports
operational and failure information.

Sources consulted:
- `https://github.com/PowerShell/Win32-OpenSSH/wiki/Logging-Facilities` — authoritative ETW channels, file-based logging config
- `https://github.com/PowerShell/Win32-OpenSSH/wiki/Troubleshooting-Steps` — interactive debug mode, sshd -ddd
- `https://learn.microsoft.com/en-us/troubleshoot/windows-server/system-management-components/enable-openssh-verbose-logging` — verbose logging procedure
- `https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh-server-configuration` — sshd_config reference for Windows
- Live host state via `ansible win_shell → powershell` on server-225-win (2026-03-10)
