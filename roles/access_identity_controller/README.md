# access_identity_controller

Ensures the Ansible controller (e.g. your Mac) has an SSH keypair, publishes its public key as host facts, and templates `~/.ssh/config` from desired-state SSH targets.

## Purpose

- Create/ensure `~/.ssh` and an ed25519 keypair (default: `~/.ssh/id_ed25519_ansible`).
- Set facts: `execution_node_pub_key_path`, `execution_node_private_key_path`, `execution_node_pub_key_content`.
- Template `~/.ssh/config` from durable SSH desired state in inventory/hostvars.
- Create `~/.ssh/sockets/` for SSH ControlMaster multiplexing.
- Optional: manage `known_hosts` entries (off by default).

## Defaults (override in group_vars / host_vars / CLI)

| Variable | Default | Description |
|----------|---------|-------------|
| `controller_ssh_dir` | `$HOME/.ssh` | SSH directory on controller |
| `controller_ssh_key_basename` | `id_ed25519_ansible` | Key filename without extension |
| `controller_ssh_private_key_path` | `controller_ssh_dir` + basename | Full path to private key |
| `controller_ssh_public_key_path` | private path + `.pub` | Full path to public key |
| `controller_manage_ssh_config` | `true` | Template `~/.ssh/config` from deployed targets |
| `controller_manage_known_hosts` | `false` | Whether to add known_hosts entries |
| `controller_known_hosts_targets` | `[]` | List of `{ host: "name", port: 22 }` |

## Example commands

```bash
# Run only on execution_nodes (controller identity)
ansible-playbook playbooks/access_controller.yaml -i inventory/inventory.yaml --limit execution_nodes

# Run with a custom key path (override)
ansible-playbook playbooks/access_controller.yaml -i inventory/inventory.yaml --limit execution_nodes \
  -e "controller_ssh_key_basename=id_ed25519_mykey"
```

## Best practices

- Run this playbook first when setting up a new controller; Windows access role depends on these facts.
- Do not define `execution_node_pub_key_*` in inventory—they are set by this role.
- Use `connection: local` and `hosts: execution_nodes` so the play runs on the machine where the key lives.

## `~/.ssh/config` management

This role templates `~/.ssh/config` from the `ssh_targets` inventory group.

- Windows hosts get entries when their OpenSSH desired state is `present`.
- Active `wsl_hosts` get entries by group membership.
- Linux VMs get entries when they have realized connection facts such as `ansible_host`.
- The template no longer depends on cached `ssh_configured` facts, so entries do
  not disappear just because a fact cache is cold or missing.

The template also creates:
- `Host <name>-powershell` aliases for Windows hosts with `ssh_powershell_port` defined.
- `Host <name>-ipv6` aliases when `host_ipv6` is defined for a target.
- A `Host *` block with `ControlMaster`/`ControlPath`/`ControlPersist` for SSH multiplexing.
- The `~/.ssh/sockets/` directory required by `ControlPath`.

Ansible provides `ansible.utils.ipwrap` for configuration formats that require
bracketed IPv6 addresses, but OpenSSH `HostName` entries here need the raw IPv6
literal instead. The repo therefore does not use `ipwrap` for `~/.ssh/config`
generation.

**Requires fact caching** to be enabled in `ansible.cfg` (jsonfile, timeout 86400).

Set `controller_manage_ssh_config: false` to skip templating and hand-manage the config.

A backup of the previous config is created each time the template runs.

## Full pipeline

Use `playbooks/access.yaml` to run the entire chain in one command:

```bash
ansible-playbook playbooks/access.yaml -i inventory/inventory.yaml
```

This runs:
1. Controller identity (keypair + facts)
2. Windows SSH setup (OpenSSH, keys, firewall, ports)
3. Controller SSH config (template `~/.ssh/config` from desired-state inputs)
