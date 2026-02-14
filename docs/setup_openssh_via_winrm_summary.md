# Setup OpenSSH via WinRM — summary (grounded in current state)

This doc describes the temporary playbook `playbooks/setup_openssh_via_winrm.yaml` and the **current state** as gathered by `playbooks/current_state_openssh_winrm.yaml`. Re-run the current-state playbook to refresh the facts; the JSON report is `facts/current_state_openssh_winrm.json`.

---

## Current state (from last fact gather)

**Source:** `facts/current_state_openssh_winrm.json` (gathered at time shown in that file).

### Controller (Mac)

| Check | Value |
|-------|--------|
| `.mgmt/ansible_ssh.pub` exists | Yes |
| `vault/ansible_ssh.vault.yml` exists | Yes |
| `vault/openssh_host_keys.vault.yml` exists | Yes |
| `bootstrap/openssh_host_keys/` key files | `ssh_host_ed25519_key`, `ssh_host_ed25519_key.pub`, `ssh_host_rsa_key`, `ssh_host_rsa_key.pub` |

### Windows host: server-225-win

| Check | Value |
|-------|--------|
| OpenSSH Server capability | Installed |
| Firewall rule `sshd` | Enabled=True, LocalPort=22 |
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

1. **Install OpenSSH Server:** Run `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0` only if the capability is not already Installed.
2. **Firewall for SSH:** Ensure rule `sshd` allows TCP on `win_ssh_port` (default 22).
3. **Verify firewall port:** Fail if rule `sshd` LocalPort does not match `win_ssh_port`.
4. **Host keys:** If `vault/openssh_host_keys.vault.yml` exists on the controller, load it and deploy its contents to `C:\ProgramData\ssh\`. If the vault does not exist, run `ssh-keygen -A` in `C:\ProgramData\ssh` on the Windows host (fallback).
5. **sshd service:** Set service `sshd` to start_mode=auto and state=started.
6. **User .ssh:** Ensure `%USERPROFILE%\.ssh` exists with mode 0700.
7. **authorized_keys:** If `.mgmt/ansible_ssh.pub` exists on the controller, ensure its single-line content is present in `%USERPROFILE%\.ssh\authorized_keys` (create file if missing).

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

### Merge note

This playbook is temporary. Its OpenSSH-related logic matches the corresponding parts of `playbooks/bootstrap_windows.yaml`. When merging, fold it back into `bootstrap_windows.yaml` or replace that section with an include of this playbook’s tasks.
