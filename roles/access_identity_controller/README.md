# access_identity_controller

Ensures the Ansible controller (e.g. your Mac) has an SSH keypair and publishes its public key path/content as host facts so other roles (e.g. Windows OpenSSH) can consume them. No hostnames or inventory assumptions—only `execution_nodes` group.

## Purpose

- Create/ensure `~/.ssh` and an ed25519 keypair (default: `~/.ssh/id_ed25519_ansible`).
- Set facts: `execution_node_pub_key_path`, `execution_node_private_key_path`, `execution_node_pub_key_content`.
- Optional: manage `known_hosts` entries (off by default).

## Defaults (override in group_vars / host_vars / CLI)

| Variable | Default | Description |
|----------|---------|-------------|
| `controller_ssh_dir` | `$HOME/.ssh` | SSH directory on controller |
| `controller_ssh_key_basename` | `id_ed25519_ansible` | Key filename without extension |
| `controller_ssh_private_key_path` | `controller_ssh_dir` + basename | Full path to private key |
| `controller_ssh_public_key_path` | private path + `.pub` | Full path to public key |
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
