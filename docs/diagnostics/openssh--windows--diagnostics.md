# OpenSSH Windows Diagnostic Sources

## Logging Locations

- Service name:
  `sshd`
- Default server configuration file:
  `C:\ProgramData\ssh\sshd_config`
- File-based logs when `SyslogFacility LOCAL0` is configured:
  `C:\ProgramData\ssh\logs\`
- ETW/Event Viewer when file logging is not redirected to `LOCAL0`
- Repo-side Windows debug collector logic:
  `/Users/joshc/develop/dotfile-vnext/roles/access_identity_windows/tasks/debug_output.yml`
- Current Windows inventory surface for server-225:
  `/Users/joshc/develop/dotfile-vnext/inventory/host_vars/HOM-LAB-HVH-02.yaml`

## Diagnostic Commands

- `Get-Service sshd | Format-List Name,Status,StartType`
- `Get-Process sshd`
- `Get-Content C:\ProgramData\ssh\sshd_config -Raw`
- `Get-ChildItem C:\ProgramData\ssh\logs`
- `Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 100`
- `Get-NetTCPConnection -LocalPort 22`
- `Get-NetFirewallRule | Where-Object { $_.DisplayName -match 'SSH|sshd|OpenSSH' }`
- `Get-NetFirewallProfile | Format-List Name,Enabled,DefaultInboundAction,LogFileName,LogBlocked,LogAllowed,LogIgnored,LogMaxSizeKilobytes`
- `Get-WinEvent -LogName 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall' -MaxEvents 50`
- `Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=5152,5157; StartTime=(Get-Date).AddHours(-6) } -MaxEvents 50`
- `Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 50`
- `Get-WinEvent -LogName 'OpenSSH/Admin' -MaxEvents 50`
- `Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Service Control Manager'; StartTime=(Get-Date).AddHours(-6) } | Where-Object { $_.Message -match 'sshd' }`

## Event / Channel Sources

- `OpenSSH/Operational`
- `OpenSSH/Admin`
- `System` provider `Service Control Manager` for service start/stop/failure transitions
- `Microsoft-Windows-Windows Firewall With Advanced Security/Firewall`
- `Security` event IDs `5152` and `5157` when Filtering Platform auditing is present

If file-based logging is not enabled, Event Viewer/ETW becomes the primary
diagnostic surface.
If the symptom is a timeout rather than an explicit authentication or transport
error, firewall-policy and drop/audit surfaces are often more revealing than
OpenSSH logs alone.

## Vendor / Tooling Diagnostics

- `Get-Service sshd`
- `Get-Process sshd`
- `Get-NetTCPConnection -LocalPort 22`
- `Get-Content C:\ProgramData\ssh\sshd_config -Raw`
- `Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 100`

## Notes

- Microsoft documents that Windows OpenSSH reads server config from
  `%programdata%\ssh\sshd_config` by default.
- Microsoft also documents that `SyslogFacility LOCAL0` writes file logs under
  `%programdata%\ssh\logs`; otherwise logging goes to ETW/Event Viewer.
- In this repo, Windows OpenSSH is intended to land directly on Windows for
  `HOM-LAB-HVH-02`, not on WSL.
- The repo already has a Windows-side debug task that collects `sshd` service
  status, `sshd_config`, ssh log files, and OpenSSH event log entries in:
  `/Users/joshc/develop/dotfile-vnext/roles/access_identity_windows/tasks/debug_output.yml`
- The dedicated remote-access collector now groups evidence into:
  - `control_surfaces`
  - `network_path`
  - `firewall_drop_path`
- For node-local collection on the Windows host itself, use:
  `/Users/joshc/develop/dotfile-vnext/bin/troubleshoot-windows-remote-access-local.ps1`
