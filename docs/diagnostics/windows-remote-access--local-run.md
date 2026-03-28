# Windows Remote Access Local Troubleshooting Run

Use this when `server-225-win` is reachable locally but remote control surfaces
from another machine are failing or flapping.

## Local Helper

Run this directly on the Windows host from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\bin\troubleshoot-windows-remote-access-local.ps1
```

That writes artifacts under:

```text
.\artifacts\troubleshooting\windows_remote_access\<COMPUTERNAME>\<timestamp>\
```

## Optional Scoped Run

To narrow collection to a subset of evidence groups:

```powershell
powershell -ExecutionPolicy Bypass -File .\bin\troubleshoot-windows-remote-access-local.ps1 `
  -ArtifactGroups control_surfaces,network_path
```

Supported groups:

- `control_surfaces`
- `network_path`
- `firewall_drop_path`

## What It Collects

- WinRM service, listeners, shell state, TCP listeners, firewall rules, and
  WinRM event channels
- OpenSSH service, processes, config, log files, TCP listeners, firewall rules,
  and OpenSSH event channels
- network adapters, IPv4 bindings, and recent network-related System events
- firewall profile policy, configured firewall logs, advanced-security firewall
  events, and Security drop/audit events `5152` / `5157`

## Related Diagnostics Notes

- [winrm--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/winrm--windows--diagnostics.md)
- [openssh--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/openssh--windows--diagnostics.md)
