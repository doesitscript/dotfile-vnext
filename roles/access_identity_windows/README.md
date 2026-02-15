# access_identity_windows

Enables OpenSSH Server on Windows hosts reachable via WinRM, configures the required `administrators_authorized_keys` file and ACL (no inheritance; Administrators + SYSTEM FullControl), and installs the controller’s public key. Optionally verifies SSH from the controller. WinRM is left unchanged.

## Purpose

- Install OpenSSH Server capability, start sshd, open firewall (port 22).
- Create `C:\ProgramData\ssh\administrators_authorized_keys` with correct ACL (invariant).
- Add controller public key from `execution_nodes` host facts (run access_controller first).
- Optionally verify SSH key auth from the controller.

## Defaults (override in group_vars / host_vars / CLI)

| Variable | Default | Description |
|----------|---------|-------------|
| `openssh_server_capability` | `OpenSSH.Server~~~~0.0.1.0` | Windows capability name |
| `win_ssh_port` | `22` | SSH port |
| `win_ssh_user` | (set in host_vars/group_vars) | User for SSH key auth; e.g. same as `win_user` or `ansible_user` |
| `administrators_authorized_keys_path` | `C:\ProgramData\ssh\administrators_authorized_keys` | Key file path |
| `verify_ssh_from_controller` | `true` | Run SSH test from controller after config |
| `verify_ssh_connect_timeout_seconds` | `15` | SSH connect timeout for verification |

## Example commands

```bash
# Run after access_controller; target one Windows host
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win

# All Windows hosts
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml

# Skip SSH verification (e.g. in CI or when controller can’t reach host)
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win \
  -e "verify_ssh_from_controller=false"
```

## Proof Ansible over SSH (no inventory change)

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.builtin.raw -a "whoami" \
  -e "ansible_connection=ssh ansible_user=<win_ssh_user from host_vars> ansible_ssh_private_key_file=~/.ssh/id_ed25519_ansible"
```

## Best practices

- Run `access_controller` first so `execution_node_pub_key_content` is set.
- Target via `hosts: windows_hosts` and use `--limit` for a single host when needed.
- Do not remove or “simplify” the ACL block (inheritance disabled, Administrators + SYSTEM FullControl).
- Leave WinRM enabled; this role only adds OpenSSH.
