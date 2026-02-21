# access_identity_windows

Enables OpenSSH Server on Windows hosts reachable via WinRM, configures the required `administrators_authorized_keys` file and ACL (no inheritance; Administrators + SYSTEM FullControl), and installs the controller's public key. Optionally verifies SSH from the controller. WinRM is left unchanged.

## Purpose

- Install OpenSSH Server capability, start sshd, configure listen port (`win_ssh_port`), open firewall.
- Set `DefaultShell` to `C:\Windows\System32\bash.exe` (WSL Bash).
- Create `C:\ProgramData\ssh\administrators_authorized_keys` with correct ACL (invariant).
- Add controller public key from `execution_nodes` host facts (run access_controller first).
- Optionally verify SSH key auth from the controller.

## Default shell: why Bash (WSL) is required

The `DefaultShell` registry value (`HKLM:\SOFTWARE\OpenSSH\DefaultShell`) controls what shell runs when a user connects via SSH. This role sets it to `C:\Windows\System32\bash.exe` (WSL).

**This is required for VS Code Remote-SSH and Cursor Remote-SSH to work.** These editors expect a Unix-like shell on the remote end. If `DefaultShell` is set to PowerShell, the remote IDE connection will fail.

- `bash.exe` requires WSL to be installed on the Windows host.
- If WSL is not installed, sshd will reject all logins with "shell does not exist".
- A commented-out PowerShell block is preserved in `tasks/main.yml` in case you need to temporarily switch back for debugging plain SSH sessions.
- For direct PowerShell access without changing the default shell, use the secondary port (see below).

## PowerShell SSH (`powershell-ssh` tag)

A secondary SSH port (`win_ssh_powershell_port`, default `2223`) provides a PowerShell session without affecting the primary WSL/bash port used by VS Code and Cursor. This works via a `Match LocalPort` block appended to the **end** of `sshd_config`:

```
Match LocalPort 2223
    ForceCommand powershell.exe -NoLogo -NoProfile
```

The `Match` block **must** be at the bottom of `sshd_config` (after all global directives and after `Match Group administrators`). If placed earlier, it captures unrelated directives and breaks sshd.

The role also creates a firewall rule (`sshd-PowerShell-In-TCP`) for this port.

**Usage:**

```bash
ssh -p 2223 -i ~/.ssh/id_ed25519_ansible joshc@DESKTOP-VLLM
```

Add this to `~/.ssh/config` on the Mac so you can connect with just `ssh server-225-win-powershell`:

```
Host server-225-win-powershell
    HostName DESKTOP-VLLM
    User joshc
    Port 2223
    IdentityFile ~/.ssh/id_ed25519_ansible
    StrictHostKeyChecking no
```

**Run only the PowerShell SSH tasks:**

```bash
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml \
  --limit server-225-win --tags powershell-ssh
```

## Defaults (override in group_vars / host_vars / CLI)

| Variable | Default | Description |
|----------|---------|-------------|
| `openssh_server_capability` | `OpenSSH.Server~~~~0.0.1.0` | Windows capability name |
| `win_ssh_port` | `2222` | Primary SSH port (WSL/bash shell) |
| `win_ssh_powershell_port` | `2223` | Secondary SSH port (forced PowerShell session) |
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

# Skip SSH verification (e.g. in CI or when controller can't reach host)
ansible-playbook playbooks/access_windows.yaml -i inventory/inventory.yaml --limit server-225-win \
  -e "verify_ssh_from_controller=false"
```

## Manual SSH from the Mac (why you must use `-i`)

The role installs the **execution node's** public key (`~/.ssh/id_ed25519_ansible.pub` on the Mac) into Windows `authorized_keys`. The SSH client does **not** try `id_ed25519_ansible` by default; it tries `id_rsa`, `id_ed25519`, etc. So you must pass the key explicitly:

```bash
ssh -i ~/.ssh/id_ed25519_ansible -p 2222 joshc@DESKTOP-VLLM
```

If you don't have that key yet: run the **access_controller** playbook first (it creates `~/.ssh/id_ed25519_ansible` if missing), then run **access_windows** so that key is deployed. To create the key manually:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ansible -N ""
```

Then re-run the Windows playbook so the new `.pub` is installed. Optional: add to `~/.ssh/config` so you don't need `-i` every time:

```
Host DESKTOP-VLLM
  User joshc
  Port 2222
  IdentityFile ~/.ssh/id_ed25519_ansible
```

## Proof Ansible over SSH (no inventory change)

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.builtin.raw -a "whoami" \
  -e "ansible_connection=ssh ansible_user=joshc ansible_port=2222 ansible_ssh_private_key_file=~/.ssh/id_ed25519_ansible"
```

## Best practices

- Run `access_controller` first so `execution_node_pub_key_content` is set.
- Target via `hosts: windows_hosts` and use `--limit` for a single host when needed.
- Do not remove or "simplify" the ACL block (inheritance disabled, Administrators + SYSTEM FullControl).
- Leave WinRM enabled; this role only adds OpenSSH.

## Troubleshooting

### Where are the OpenSSH logs on Windows?

Windows OpenSSH writes to the **Windows Event Log**, not to a text file. There is no `/var/log/auth.log` equivalent on disk unless you explicitly enable file-based logging in `sshd_config`.

**To view logs on the machine:**

1. `Win+R` > `eventvwr.msc` > Enter
2. Expand `Applications and Services Logs` > `OpenSSH` > `Operational`

**To view logs remotely via WinRM (from the Mac):**

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_shell \
  -a "Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 30 | Format-List TimeCreated,Message"
```

There is also an `OpenSSH/Admin` log at the same tree level; replace `Operational` with `Admin` in the command above.

### "User X not allowed because shell Y does not exist"

sshd validates the `DefaultShell` registry value (`HKLM:\SOFTWARE\OpenSSH\DefaultShell`) before allowing login. If the configured shell binary does not exist on the Windows PATH or at the absolute path specified, sshd rejects the user immediately — before checking keys or passwords. The user appears as "invalid user" in the logs even though the Windows account exists.

**Symptoms:** Every SSH attempt fails with `Permission denied`. Logs show:

```
sshd: User joshc not allowed because shell bash.exe does not exist
```

**Fix:** Set `DefaultShell` to an executable that exists. To check the current value via WinRM:

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_shell \
  -a "Get-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell | Select-Object -ExpandProperty DefaultShell"
```

To reset it to PowerShell (always present on Windows):

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_regedit \
  -a "path=HKLM:\\SOFTWARE\\OpenSSH name=DefaultShell data=C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe type=string state=present"
```

Then restart sshd:

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_service \
  -a "name=sshd state=restarted"
```

### Port 2222 — connection refused

If `ssh -p 2222 user@host` returns "Connection refused", check:

1. The `Port 2222` line is present in `C:\ProgramData\ssh\sshd_config` (not commented out)
2. The firewall rule exists and targets the correct port:

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_shell \
  -a "Get-NetFirewallRule -Name 'sshd-Server-In-TCP' | Get-NetFirewallPortFilter | Select-Object LocalPort"
```

3. sshd is actually running:

```bash
ansible server-225-win -i inventory/inventory.yaml -m ansible.windows.win_service \
  -a "name=sshd"
```

### Pubkey auth fails but password prompt appears

If SSH falls through to a password prompt instead of accepting your key, check:

1. You are passing the correct key: `ssh -i ~/.ssh/id_ed25519_ansible -p 2222 user@host`
2. The key is in the right `authorized_keys` file. For admin users, Windows OpenSSH reads `C:\ProgramData\ssh\administrators_authorized_keys` instead of `~\.ssh\authorized_keys`. Both files must have correct ACLs (no inheritance; only Administrators + SYSTEM with FullControl).


### Troubleshooting

kills sessions tmux is aware of
```sh
tmux ls | awk '/vsct-/ {print $1}' | sed 's/:$//' | xargs -r -n 1 tmux kill-session -t
```
Option 2 — Kill a specific session
If you know the name:

Code
tmux kill-session -t vsct-12345
Option 3 — From inside tmux
If you’re inside the session and want to nuke it:

Code
tmux kill-session