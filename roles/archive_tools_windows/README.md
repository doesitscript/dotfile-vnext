# archive_tools_windows

Manages Windows archive utilities through Chocolatey.

The initial managed tool is 7-Zip via the Chocolatey `7zip` package. The role
also verifies that `7z.exe` is available after install.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `archive_tools_windows_state` | `present` | Desired lifecycle state for managed archive tools. Use `absent` to remove them. |
| `archive_tools_windows_chocolatey_packages` | `[7zip]` | Chocolatey packages to manage. |
| `archive_tools_windows_verify_command` | `7z.exe` | Command name used for post-install verification. |

## Example

```yaml
---
- name: Manage Windows archive tools
  hosts: windows_hosts
  gather_facts: false
  roles:
    - role: archive_tools_windows
```

## Tags

The companion playbook exposes:

- `preview`
- `archive_tools_windows`
- `7zip`

## Idempotence

Package state is managed with `chocolatey.chocolatey.win_chocolatey`, so repeated
runs should not change a correctly configured host.
