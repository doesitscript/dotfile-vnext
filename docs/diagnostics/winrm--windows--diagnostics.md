# WinRM Windows Diagnostic Sources

## Logging Locations

- Service name:
  `WinRM`
- Listener/config surfaces:
  - `winrm enumerate winrm/config/listener`
  - `WSMan:\localhost\Listener`
- Windows Event Viewer channels:
  - `Microsoft-Windows-WinRM/Operational`
  - `System` with provider `Microsoft-Windows-WinRM`
- Repo-side Windows debug collector logic:
  `/Users/joshc/develop/dotfile-vnext/roles/access_identity_windows/tasks/debug_output.yml`
- Inventory surface for the current server-225 Windows host:
  `/Users/joshc/develop/dotfile-vnext/inventory/host_vars/server-225-win.yaml`

## Diagnostic Commands

- `Get-Service WinRM | Format-List Name,Status,StartType`
- `winrm enumerate winrm/config/listener`
- `Test-WSMan localhost`
- `Get-ChildItem WSMan:\localhost\Listener`
- `Get-WSManInstance -ResourceURI shell -Enumerate`
- `Get-NetTCPConnection -LocalPort 5985,5986`
- `Get-NetFirewallRule | Where-Object { $_.DisplayName -match 'WinRM|Remote Management' }`
- `Get-WinEvent -LogName 'Microsoft-Windows-WinRM/Operational' -MaxEvents 50`
- `Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Microsoft-Windows-WinRM'; StartTime=(Get-Date).AddHours(-6) } -MaxEvents 50`

## Event / Channel Sources

- `Microsoft-Windows-WinRM/Operational`
- `System` provider `Microsoft-Windows-WinRM`
- `System` provider `Service Control Manager` for WinRM service start/stop or failure transitions

These are the first places to inspect when WinRM is intermittently refusing
connections, listeners are misconfigured, or remote shells are getting stuck.

## Vendor / Tooling Diagnostics

- `winrm enumerate winrm/config/listener`
- `Test-WSMan`
- `Get-WSManInstance -ResourceURI shell -Enumerate`
- `Get-NetTCPConnection` for ports `5985` / `5986`
- `Get-Service WinRM`

## Notes

- In this repo, Windows bootstrap/control surfaces default to WinRM on port
  `5985` with `ansible_connection: winrm` for `*-win` hosts.
- Listener state, service state, and event output matter more than Ansible
  transport verbosity when the failure is "connection refused" or shell
  instability.
- The repo already has a Windows-side debug task that collects WinRM service
  state, listeners, active shells, and recent system events in:
  `/Users/joshc/develop/dotfile-vnext/roles/access_identity_windows/tasks/debug_output.yml`
