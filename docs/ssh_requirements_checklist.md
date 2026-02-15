# SSH requirements checklist

This doc maps each mandatory SSH requirement to where it is set up in the repo. Use it to verify everything is in place.

## Bootstrap orchestration (Windows vs Mac)

- **Windows (bootstrap as Ansible step):** From the controller (Mac or any host with WinRM to the Windows box), run **`./bin/fz bootstrap --limit server-225-win`**. That runs the playbook **`playbooks/bootstrap_windows.yaml`** **against** the Windows host over WinRM. It ensures WinRM is on, installs/configures OpenSSH Server (port 22), host keys, sshd service, and adds the ansible public key to Windows `authorized_keys`. No WSL in this playbook; it only makes the Windows system manageable over SSH. Requires WinRM reachable first (e.g. one-time `.\bin\bootstrap-local.cmd` on the Windows machine for facts/host_vars, or HTTP WinRM).
- **Server (Windows) first-touch / facts:** On the Windows machine itself you can run `.\bin\bootstrap-local.cmd` to collect facts, write host_vars, and (via PowerShell) configure OpenSSH and add keys; after that, from the controller, **`fz bootstrap --limit server-225-win`** is the Ansible bootstrap step for that Windows host.
- **Mac:** Run **on the Mac**: `./bin/fz bootstrap --limit mac-dev`. That runs `bootstrap_mac.yaml` (creates ansible key only when vault is missing, installs private key to `~/.ssh/id_ed25519_ansible`, runs baseline/homebrew/ansible_runner, writes facts to `facts/mac-dev.json`).
- **Same key, same design:** One ansible key pair at `~/.ssh/id_ed25519_ansible` on the execution node (Mac). No repo copy. Bootstrap is a concept for every system: each system has an Ansible bootstrap step (Windows: `bootstrap_windows.yaml`; Mac: `bootstrap_mac.yaml`).

## Windows (OpenSSH Server)

SSH to the Windows host (port 22) then into WSL via default shell.

| Requirement | Where it's set up | File / location |
|-------------|-------------------|------------------|
| OpenSSH Server installed | Windows capability | `bin/bootstrap-local.ps1` – `Add-WindowsCapability -Name OpenSSH.Server~~~~0.0.1.0` |
| Port 22 open (firewall) | Firewall rule `sshd` | `bin/bootstrap-local.ps1` – `New-NetFirewallRule -Name sshd -LocalPort 22` |
| sshd_config Port 22 | Admin config | `bin/bootstrap-local.ps1` – writes/updates `C:\ProgramData\ssh\sshd_config` |
| Host keys present | `C:\ProgramData\ssh\` | `bin/bootstrap-local.ps1` – runs `ssh-keygen -A` in that dir if no `ssh_host_*_key` |
| sshd service Automatic + started | Service `sshd` | `bin/bootstrap-local.ps1` – `Set-Service sshd -StartupType Automatic`, `Start-Service sshd` (with try/catch) |
| Your key in Windows authorized_keys | User profile | Standard key: `id_ed25519_ansible`. From Mac: playbook reads `~/.ssh/id_ed25519_ansible.pub` and adds to `authorized_keys`. Or `bin/bootstrap-local.ps1` appends `bootstrap/id_ed25519_ansible.pub` if present (deprecated: `bootstrap/mac_ssh_key.pub`). |

Optional: DefaultShell = WSL so SSH drops into bash – same script sets `HKLM:\SOFTWARE\OpenSSH` DefaultShell and DefaultShellCommandOption.

---

## WSL (Ubuntu openssh-server)

Ansible (and Mac) SSH into the WSL user; same key as Windows.

| Requirement | Where it's set up | File / location |
|-------------|-------------------|------------------|
| openssh-server installed, ssh started | Apt + systemd | `playbooks/bootstrap_local.yml` – `openssh-server`, `service: ssh state: started enabled: true` |
| PubkeyAuthentication yes | sshd_config | `playbooks/bootstrap_local.yml` – `lineinfile` on `/etc/ssh/sshd_config` |
| PasswordAuthentication yes (optional) | sshd_config | `playbooks/bootstrap_local.yml` – same |
| User ~/.ssh (0700) | WSL user dir | `playbooks/bootstrap_local.yml` – `file` for `/home/{{ user_id }}/.ssh` |
| Same public key in WSL authorized_keys | WSL user | Deploy from Mac: playbooks read execution node `~/.ssh/id_ed25519_ansible.pub` and add to Windows/WSL `authorized_keys`. |
| Ansible key pair (canonical) | Execution node | `~/.ssh/id_ed25519_ansible` and `.pub` on Mac; playbooks read from here at run time, no repo copy |

---

## Mac (controller)

Ansible runs on the Mac and SSHs to server-225-wsl using the private key and host_vars.

| Requirement | Where it's set up | File / location |
|-------------|-------------------|------------------|
| Private key on Mac | `~/.ssh/id_ed25519_ansible` | `playbooks/bootstrap_mac.yaml` – installs from vault or from just-generated key (Mac-first) |
| Correct host_vars for server-225-wsl | Inventory | `inventory/host_vars/server-225-wsl.yaml` (and/or `inventory/group_vars/wsl_hosts.yaml`). Must include: `ansible_connection: ssh`, `ansible_host`, `ansible_user`, `ansible_port`, `ansible_ssh_private_key_file: "~/.ssh/id_ed25519_ansible"`, `ansible_python_interpreter: /usr/bin/python3`. Written by `bin/bootstrap-local.ps1`; overwritten by `playbooks/bootstrap_local.yml` template. |

`ansible_ssh_private_key_file` and `ansible_python_interpreter` are written by:
- **PowerShell:** `bin/bootstrap-local.ps1` when it writes WSL host_vars (so they exist even if you run with `-RunAll:$false`).
- **Ansible:** `playbooks/templates/host_vars_wsl.yml.j2` when `playbooks/bootstrap_local.yml` runs.

---

## Verification

Use Ansible (playbooks and inventory) and the steps in this checklist to verify SSH setup. No separate verification script; playbooks and host_vars are the source of truth.

### Verify server-225-wsl host_vars in debug output

Run:

```bash
ansible server-225-wsl -i inventory/inventory.yaml -m ping -vvv
```

In the debug output, the line starting with `<DESKTOP-VLLM> SSH: EXEC ssh ...` should show each required setting as follows:

| Required host_var | What to look for in the SSH EXEC line |
|-------------------|--------------------------------------|
| `ansible_connection: ssh` | Line says `ESTABLISH SSH CONNECTION` (not WinRM). |
| `ansible_host` | Hostname in the `ssh` command (e.g. `DESKTOP-VLLM`). |
| `ansible_user` | `-o 'User="josh"'` (or your user). |
| `ansible_port` | `-o Port=22`. |
| `ansible_ssh_private_key_file` | `-o 'IdentityFile="/Users/joshc/.ssh/id_ed25519_ansible"'` (path may differ). |
| `ansible_python_interpreter` | Remote command ends with `'/usr/bin/python3 && sleep 0'`. |

If any of these are missing or wrong, update `inventory/host_vars/server-225-wsl.yaml` or `inventory/group_vars/wsl_hosts.yaml` (group_vars apply to all WSL hosts).
