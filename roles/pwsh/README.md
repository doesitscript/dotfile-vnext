# pwsh

Installs PowerShell 7+ and deploys the AllUsersAllHosts encoding profile on Windows.

## What it does

| Platform | Method |
|----------|--------|
| macOS | `brew install --cask powershell` via `community.general.homebrew_cask` |
| Ubuntu | Not yet automated (placeholder) |
| Windows | Deploys AllUsersAllHosts encoding profile for PS5.1 and PS7 |

## Windows — Encoding Profile

On Windows hosts, this role deploys `$PSDefaultParameterValues['*:Encoding'] = 'utf8'`
to the `AllUsersAllHosts` profile for both Windows PowerShell 5.1 and PowerShell 7
(when installed). This enforces UTF-8 without BOM across all PowerShell sessions,
shells, scheduled tasks, WinRM connections, and automation contexts.

**Why both versions?** PS5.1 and PS7 have separate `$PSHOME` paths and separate
global profiles. Configuring only one leaves the other using platform defaults
(UTF-16 / CRLF).

- PS5.1 profile: `C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1`
- PS7 profile: `C:\Program Files\PowerShell\7\profile.ps1`

Files are written with `[System.Text.UTF8Encoding]::new($false)` — no BOM, LF-only.
If PS7 is not installed, the PS7 task is skipped with an explicit debug message.

## Variables

| Variable | Default | Description |
|---|---|---|
| `pwsh_global_encoding_enabled` | `true` | Deploy encoding profile on Windows. Set to false to skip. |

## Playbook home

This role is applied in `playbooks/windows_base.yml`, which targets all
`windows_hosts`. It runs after `windows_base` as part of the shared baseline.

## Example

```bash
# All Windows hosts (via windows_base.yml)
ansible-playbook playbooks/windows_base.yml

# Single host
ansible-playbook playbooks/windows_base.yml --limit hom-lab-ctl-hvh-02
```
