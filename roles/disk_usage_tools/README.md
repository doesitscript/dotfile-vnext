# disk_usage_tools

Installs disk usage inspection tools on managed nodes.

## Windows

Windows hosts install WinDirStat from Chocolatey with
`chocolatey.chocolatey.win_chocolatey`.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `disk_usage_tools_state` | `present` | Desired lifecycle state for managed disk usage tools. Use `absent` to remove them. |

## Tags

The calling playbook exposes:

- `disk_usage_tools`
- `windirstat`

## Idempotence

Package state is managed through the package manager, so repeated runs should
not change a correctly configured host.
