# access_identity_windows

Configures Windows-side access over WinRM and OpenSSH.

Current preferred path:
- WinRM remains the bootstrap/control surface.
- OpenSSH listens on the Windows host itself.
- Direct SSH lands in a Windows shell via `DefaultShell`.
- WSL is optional and out of scope unless `wsl_enabled=true`.
- OpenSSH lifecycle is controlled by `openssh_server_state: present|absent`.

## Purpose

- Ensure the Windows OpenSSH Server capability is installed.
- Manage `sshd_config` for a single primary Windows SSH listener.
- Set `DefaultShell` to Windows PowerShell so SSH lands on Windows, not WSL.
- Install the controller public key into:
  - `C:\ProgramData\ssh\administrators_authorized_keys`
  - the Ansible user's `authorized_keys`
- Keep the Windows firewall aligned with the current SSH scope.
- Optionally install/configure WSL only when explicitly enabled.

## Current Behavior

- `win_ssh_port` is the primary Windows OpenSSH port.
- The current preferred default is port `22`.
- The role removes legacy listener ports and legacy `pwsh-sshd` / `Match LocalPort` config that used to redirect SSH behavior.
- The role checks WSL state and requests `wsl.exe --shutdown` if a distro is currently running, so the Windows-only SSH path is not hijacked by an active WSL shell.

## Defaults

| Variable | Default | Description |
|----------|---------|-------------|
| `openssh_server_state` | `present` | Desired lifecycle state for Windows OpenSSH |
| `openssh_server_capability` | `OpenSSH.Server~~~~0.0.1.0` | Windows capability name |
| `win_ssh_port` | `22` | Primary Windows OpenSSH listener |
| `win_ssh_powershell_port` | `2223` | Legacy cleanup variable only; not an active preferred path |
| `administrators_authorized_keys_path` | `C:\ProgramData\ssh\administrators_authorized_keys` | Admin authorized_keys path required by Windows OpenSSH |
| `controller_ssh_public_key_path` | `~/.ssh/id_ed25519_ansible.pub` | Public key deployed from the controller |
| `wsl_enabled` | `false` | Enable WSL installation/configuration only when explicitly requested |

## Typical Run

```bash
.venv/bin/ansible-playbook playbooks/access.yaml -i inventory/inventory.yaml \
  --limit 'execution_nodes,server-225-win'
```

For Windows-only OpenSSH work:

```bash
.venv/bin/ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml \
  --limit server-225-win --tags admin
```

## Verification

After a successful run:

- `sshd` should be `Running`.
- `C:\ProgramData\ssh\sshd_config` should contain a single active `Port {{ win_ssh_port }}` directive before any `Match` block.
- Direct SSH from the Mac should work:

```bash
ssh server-225-win
```

PowerShell-only command check:

```bash
ssh server-225-win 'Get-Location | Select-Object -ExpandProperty Path'
```

Expected result: a Windows path such as `C:\Users\joshc`, not a WSL/Linux path.

## Scope Notes

- This role no longer treats WSL as the default SSH landing shell.
- `win_ssh_powershell_port` and older WSL-oriented SSH patterns remain only as legacy/reference cleanup material while the repo transitions.
- If you want Linux companion access, treat that as separate work after Windows SSH is healthy.
- The controller SSH config should render from durable desired-state inputs, not cached `ssh_configured` runtime facts.
