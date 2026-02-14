# Setup OpenSSH via WinRM — summary (grounded in current state)

This doc describes the temporary playbook `playbooks/setup_openssh_via_winrm.yaml` and the **current state** as gathered by `playbooks/current_state_openssh_winrm.yaml`. Re-run the current-state playbook to refresh the facts; the JSON report is `facts/current_state_openssh_winrm.json`.

---

## Current state (from last fact gather)

**Source:** `facts/current_state_openssh_winrm.json` (gathered at time shown in that file).

### Controller (Mac)

| Check | Value |
|-------|--------|
| Execution node `~/.ssh/id_ed25519_ansible.pub` exists | Yes |
| `vault/openssh_host_keys.vault.yml` exists | Yes |
| `bootstrap/openssh_host_keys/` key files | `ssh_host_ed25519_key`, `ssh_host_ed25519_key.pub`, `ssh_host_rsa_key`, `ssh_host_rsa_key.pub` |

### Windows host: server-225-win

| Check | Value |
|-------|--------|
| OpenSSH Server capability | Installed |
| Firewall rule `sshd-Server-In-TCP` | Enabled=True, LocalPort=22 |
| `C:\ProgramData\ssh\` host keys | `ssh_host_ecdsa_key`, `ssh_host_ed25519_key`, `ssh_host_rsa_key` |
| `%USERPROFILE%\.ssh\authorized_keys` | Exists=True, Lines=1 |
| Inventory `ansible_host` | DESKTOP-VLLM |
| Inventory `ansible_user` | josh |
| `win_ssh_port` (host_var) | 22 |

So on server-225-win: OpenSSH Server is installed, the firewall allows port 22, host keys are present, and the controller’s public key is already in `authorized_keys` (one line). Running `setup_openssh_via_winrm.yaml` against this host is idempotent and will not change behavior.

---

## What the playbook does (factual)

**Playbook:** `playbooks/setup_openssh_via_winrm.yaml`  
**Target:** `windows_hosts` (inventory group). Same group as `bootstrap_windows.yaml`.

### Pre-tasks (WinRM)

- **Enable PowerShell remoting:** Runs every time; `Enable-PSRemoting -Force -SkipNetworkProfileCheck` is safe to re-run (no “only if not done” check).
- **Firewall:** Idempotent — `win_firewall_rule` ensures rule `WinRM-HTTP-In-TCP` for TCP 5985 exists; no change if already correct.
- **TrustedHosts:** Only runs when `winrm_trustedhosts` is set in host_vars; when it runs, it sets the value (no “if not already set” check).

### Tasks

1. **Install OpenSSH Server:** OpenSSH.Server is a Windows *Capability* (not an optional feature). We use `win_shell` with `Add-WindowsCapability -Online`; `ansible.windows.win_optional_feature` is for DISM optional features only. Per [Windows SSH guide](https://docs.ansible.com/projects/ansible/latest/os_guide/windows_ssh.html): `Get-WindowsCapability -Name OpenSSH.Server* -Online | Add-WindowsCapability -Online`. Service `sshd` is managed with `ansible.windows.win_service` (start_mode=auto, state=started).
2. **Firewall for SSH:** Ensure rule `sshd-Server-In-TCP` (display name "Inbound rule for OpenSSH Server (sshd) on TCP port …") allows TCP on `win_ssh_port` (default 22).
3. **Verify firewall port:** Fail if rule `sshd-Server-In-TCP` LocalPort does not match `win_ssh_port`.
4. **Host keys:** If `vault/openssh_host_keys.vault.yml` exists on the controller, deploy to `C:\ProgramData\ssh\`. Else run `ssh-keygen -A` in `C:\ProgramData\ssh` (fallback).
5. **sshd service:** Set service `sshd` to start_mode=auto and state=started.
6. **DefaultShell:** Set `HKLM:\SOFTWARE\OpenSSH` DefaultShell to `C:\Windows\System32\wsl.exe` and DefaultShellCommandOption to `-d {{ wsl_distro }} -e /bin/bash -l` so SSH sessions use WSL bash.
7. **sshd_config:** Comment out `Match Group administrators` and `AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys` so `%USERPROFILE%\.ssh\authorized_keys` is used for all users; restart sshd if changed.
8. **User .ssh:** Ensure `%USERPROFILE%\.ssh` exists with mode 0700.
9. **authorized_keys:** Read public key from execution node `~/.ssh/id_ed25519_ansible.pub` (delegate to execution_nodes) and ensure its line is in `%USERPROFILE%\.ssh\authorized_keys`.

When connecting to this host via SSH, set `ansible_shell_type: bash` (DefaultShell is WSL bash).

### Modules used (FQCN)

- `ansible.builtin.stat`, `ansible.builtin.set_fact`, `ansible.builtin.include_vars`, `ansible.builtin.copy`
- `ansible.windows.win_shell`, `ansible.windows.win_copy`, `ansible.windows.win_file`, `ansible.windows.win_service`
- `community.windows.win_firewall_rule`, `community.windows.win_lineinfile`

### How to run

From the Mac (repo root), with env loaded (e.g. `source .envrc` or direnv):

```bash
.venv/bin/ansible-playbook playbooks/setup_openssh_via_winrm.yaml -i inventory/inventory.yaml --limit server-225-win
```

- Use `--ask-vault-pass` or `.vault_pass` if the playbook needs to read `vault/openssh_host_keys.vault.yml`.
- For multiple Windows hosts: `--limit server-225-win,network-server-win` or run once per host.

### Windows capabilities (lookup / install / remove)

- **List capabilities:** `ansible -m win_shell -a "Get-WindowsCapability -Online" -i inventory/inventory.yaml windows_hosts`
- **Install by name:** `ansible -m win_shell -a "Add-WindowsCapability -Online -Name {Name}" -i inventory/inventory.yaml windows_hosts`
- **Remove by name:** `ansible -m win_shell -a "Remove-WindowsCapability -Online -Name {Name}" -i inventory/inventory.yaml windows_hosts`

Use `ansible.windows.win_optional_feature` for *optional features* (e.g. `Microsoft-Windows-Subsystem-Linux`, `.NET 3.5`); use `win_shell` + `Add-WindowsCapability` for *capabilities* like OpenSSH.Server.

### Merge note

This playbook is temporary. Its OpenSSH-related logic matches the corresponding parts of `playbooks/bootstrap_windows.yaml`. When merging, fold it back into `bootstrap_windows.yaml` or replace that section with an include of this playbook’s tasks.
