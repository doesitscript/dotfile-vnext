# access_identity_windows

Configures Windows-side access over WinRM and OpenSSH.

Current preferred path:
- WinRM remains the bootstrap/control surface.
- OpenSSH listens on the Windows host itself.
- Direct SSH lands in a Windows shell via `DefaultShell`.
- OpenSSH lifecycle is controlled by `openssh_server_state: present|absent`.

## Purpose

- Ensure the Windows OpenSSH Server capability is installed.
- Manage `sshd_config` for a single primary Windows SSH listener.
- Set `DefaultShell` to Windows PowerShell so SSH lands on Windows.
- Install the controller public key into:
  - `C:\ProgramData\ssh\administrators_authorized_keys`
  - the Ansible user's `authorized_keys`
- Keep the Windows firewall aligned with the current SSH scope.

## Current Behavior

- `win_ssh_port` is the primary Windows OpenSSH port.
- The current preferred default is port `22`.
- The role removes legacy listener ports and legacy `pwsh-sshd` / `Match LocalPort` config that used to redirect SSH behavior.

## Defaults

| Variable | Default | Description |
|----------|---------|-------------|
| `openssh_server_state` | `present` | Desired lifecycle state for Windows OpenSSH |
| `openssh_server_capability` | `OpenSSH.Server~~~~0.0.1.0` | Windows capability name |
| `openssh_server_capability_become` | `true` | Run capability install/removal with Windows `runas` escalation |
| `openssh_server_capability_become_user` | `SYSTEM` | Account used for the escalated capability install/removal |
| `win_ssh_port` | `22` | Primary Windows OpenSSH listener |
| `win_ssh_powershell_port` | `2223` | Legacy cleanup variable only; not an active preferred path |
| `administrators_authorized_keys_path` | `C:\ProgramData\ssh\administrators_authorized_keys` | Admin authorized_keys path required by Windows OpenSSH |
| `controller_ssh_public_key_path` | `~/.ssh/id_ed25519_ansible.pub` | Public key deployed from the controller |
## Typical Run

```bash
.venv/bin/ansible-playbook playbooks/access.yaml -i inventory/inventory.yaml \
  --limit 'execution_nodes,hom-lab-hvh-02'
```

For Windows-only OpenSSH work:

```bash
.venv/bin/ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml \
  --limit hom-lab-hvh-02 --tags admin
```

## Verification

After a successful run:

- `sshd` should be `Running`.
- `C:\ProgramData\ssh\sshd_config` should contain a single active `Port {{ win_ssh_port }}` directive before any `Match` block.
- Direct SSH from the Mac should work:

```bash
ssh hom-lab-hvh-02
```

PowerShell-only command check:

```bash
ssh hom-lab-hvh-02 'Get-Location | Select-Object -ExpandProperty Path'
```

Expected result: a Windows path such as `C:\Users\joshc`, not a Linux guest path.

## Scope Notes

- This role configures the Windows SSH surface only.
- If you want Linux companion access, treat that as separate work after Windows SSH is healthy.
- The controller SSH config should render from durable desired-state inputs, not cached `ssh_configured` runtime facts.
