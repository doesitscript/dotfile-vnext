# hyperv_networking

Enables Hyper-V, creates an External Virtual Switch bridged to a physical
adapter, and deploys `.wslconfig` with `networkingMode=bridged`. This gives
WSL its own LAN IP address — directly reachable without `netsh portproxy`.

**Deprecation notice**: Microsoft marked `networkingMode=bridged` as
deprecated since WSL 2.4.5. The option still functions but may be removed.
If bridge mode fails, set `wsl_networking_mode: nat` in host_vars to fall
back to NAT + portproxy (handled by `access_identity_windows/tasks/ubuntu.yml`).

## Composed from myllynen/windows-ansible-roles

This role does not contain raw PowerShell for Hyper-V or `.wslconfig`.
Instead it delegates to:

- **`dsc_settings`** — applies `WindowsOptionalFeature` (Hyper-V) and
  `VMSwitch` (External Switch) DSC resources via `ansible.windows.win_dsc`.
  Requires `HyperVDsc` PowerShell module (auto-installed by Phase 1).
- **`wsl_configuration`** — deploys `templates/wslconfig_bridged.j2` to
  `%USERPROFILE%\.wslconfig` with proper Windows line endings.

## Variables

| Variable | Default | Description |
|---|---|---|
| `hyperv_switch_name` | `WSL-Bridge` | Hyper-V External Virtual Switch name |
| `hyperv_adapter_name` | `Wi-Fi` | Physical adapter to bridge |
| `hyperv_allow_management_os` | `true` | Keep Windows host connected through the bridge |
| `wsl_static_ip` | `192.168.50.222/24` | Static IP for WSL guest (used by `ubuntu.yml` Netplan) |
| `wsl_gateway` | `192.168.50.1` | Gateway for WSL guest |
| `wsl_dns_server` | `8.8.8.8` | DNS for WSL guest |

## Playbook integration

```yaml
# playbooks/access_windows.yaml
roles:
  - role: hyperv_networking
    when: wsl_networking_mode | default('nat') == 'bridged'
  - access_identity_windows
```

Only runs for hosts with `wsl_networking_mode: bridged` in host_vars.

## Related

- `roles/access_identity_windows/tasks/ubuntu.yml` — WSL guest networking
  (Netplan for bridge, portproxy for NAT) gated by `wsl_networking_mode`
- `roles/access_identity_windows/tasks/firewall.yml` — SSH firewall rules
