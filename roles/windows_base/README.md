# windows_base

Shared Windows base configuration role. Applies Windows feature state, power settings,
data directory creation, Windows Defender exclusions, and registry settings to a managed
Windows host. All behavior is controlled via the `windows_base_config` dictionary.

## Consumed by

- `roles/server_225/windows_base` — delegates to this role
- `roles/dev_3090/windows_base` — delegates to this role
- `roles/network_server/windows_base` — delegates to this role

## Usage

Called via `playbooks/windows_base.yml` (all Windows hosts) or via node-specific site
playbooks (`site_server_225.yaml`, `site_dev_3090.yaml`, `site_network_server.yaml`).

```yaml
- name: Apply shared Windows base configuration
  ansible.builtin.include_role:
    name: windows_base
```

## Variables

All configuration is passed via `windows_base_config` in host_vars or group_vars.
See `meta/argument_specs.yml` for full parameter documentation.

```yaml
windows_base_config:
  enable_hyperv: true
  enable_containers: true
  enable_vmp: true
  high_performance_power: true
  disable_sleep: true
  disable_usb_suspend: true
  defender_exclusions: true
  long_paths: true
  disable_secure_boot_updates: true
```

Required inventory variables (set per-host):

| Variable | Example | Purpose |
|---|---|---|
| `windows_data_root` | `D:\ai` | Root path for AI/data storage |
| `stacks_root` | `D:\ai\stacks` | Docker stacks path |
| `data_root` | `D:\ai\data` | Data storage path |

## Idempotent

All tasks are idempotent. Re-running produces no changes on a correctly configured host.

## Tags

This role does not define tags. Tag control is handled by the calling playbook.
