# Inventory & Variable Conventions

## Variable Precedence in This Project

From lowest to highest priority (Ansible standard):
1. Role defaults (`roles/*/defaults/main.yml`)
2. Group vars (`inventory/group_vars/*.yaml`)
3. Host vars (`inventory/host_vars/*.yaml`)
4. Play vars / task vars

## params/site.yaml

`params/site.yaml` is the **human-editable source of truth** for site-specific data: IPs, usernames, drive letters, WSL distro names. It is consumed by bootstrap scripts to generate `host_vars/` files. Roles and playbooks do NOT read `params/site.yaml` directly — they consume the generated inventory variables.

## group_vars Structure

- `windows_hosts.yaml` — WinRM connection settings (transport, port, scheme)
- `wsl_hosts.yaml` — SSH connection settings (user, key, python interpreter)
- `server_225.yaml` — Shared vars for both surfaces of server-225 (WSL distro, storage paths)
- `network_server.yaml`, `dev_3090.yaml` — Same pattern for other nodes

## host_vars Structure

Host vars files are **partially generated** by `bin/bootstrap-local.ps1`. They contain:
- Connection details (ansible_host, ansible_user, ansible_password for WinRM)
- WSL-specific vars (wsl_distro, wsl_user)
- Drive/path configuration

**Do not hand-edit generated fields** without understanding the bootstrap regeneration flow. If bootstrap runs again, it preserves `win_password` but may overwrite other fields.

## Adding a New Variable

1. If it's site-specific (IP, username, path): add to `params/site.yaml`, update bootstrap to propagate it
2. If it's group-wide (connection settings, shared config): add to appropriate `group_vars/` file
3. If it's role-specific with a sensible default: add to `roles/*/defaults/main.yml`
4. If it's host-specific and not generated: add to `host_vars/` directly

## Inventory File

`inventory/inventory.yaml` defines groups and host membership. `hosts_mapping.yaml` maps physical node names to hostnames/IPs for auto-detection during bootstrap.
