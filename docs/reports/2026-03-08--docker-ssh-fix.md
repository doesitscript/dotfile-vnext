# Docker + SSH Fix Report — March 8–9, 2026

## Summary

Three separate but related problems were diagnosed and fixed across two days:

1. Docker on Mac was broken — the Docker context was configured to connect to `server-225-wsl` via SSH, and WSL was shutting down, killing the connection
2. SSH keygen in WinRM sessions was hanging — the Windows OpenSSH `ssh-keygen` reads its passphrase prompt from the console, not stdin, so piping didn't work
3. The `sshd` restart task in `access_identity_windows` was referencing a variable before it was defined, causing an undefined variable error on first run

---

## Problem 1 — Docker on Mac Broken

**Root cause:** The Mac's Docker context (`server-225-wsl`) connects to the Docker daemon running inside WSL on server-225 over SSH. WSL 2 has an `vmIdleTimeout` behavior where the VM shuts itself down after all `wsl.exe` processes exit. When WSL shuts down, the SSH connection drops, which kills the Docker context. Any shell command that triggered Docker (including `pip install`) would hang or fail because Docker was trying to reconnect.

**Evidence:** Every shell command was emitting a Docker SSH timeout error before the actual command output. `pip install` was failing with exit code 1 with only the Docker error as output.

**Fixes applied:**

*`roles/access_identity_windows/templates/wslconfig_bridged.j2`*
Added `vmIdleTimeout=-1` to `.wslconfig`:
```ini
# Keep WSL VM running after the last wsl.exe process exits.
# vmIdleTimeout=-1 means never auto-shutdown. Without this, WSL 2 shuts down the
# VM after a short idle period, killing all SSH connections and Docker contexts.
vmIdleTimeout=-1
```

*`roles/access_identity_windows/tasks/ubuntu.yml`*
Added a WSL keepalive scheduled task (Step 7). The `vmIdleTimeout` setting is unreliable on WSL 2.6.x — the setting is parsed but auto-shutdown is not prevented. The reliable fix is a Windows Scheduled Task that runs `wsl.exe -d Ubuntu-24.04 -u root -- sleep infinity` at logon, keeping a wsl.exe process alive at all times. The task is created via `schtasks.exe` (avoids WinRM CIM class issues) and runs as the interactive user.

Also changed `newline_sequence` for `.wslconfig` from `\r\n` to `\n` to prevent CRLF corruption of the config file.

Also cleaned up legacy debug/test scheduled tasks (`AnsibleWSLTest`, `AnsibleWSLDiag`, `AnsibleWSLKeepalive`, `AnsibleWSLKeepalive_Ubuntu_24_04`) left over from earlier debugging.

**Commits:** `fd8dbb5` (docker setup), `94294b3` (DOCKER IS WORKING AGAIN)

---

## Problem 2 — SSH Keygen Hanging in WinRM Sessions

**Root cause:** Windows OpenSSH `ssh-keygen` reads the passphrase from the console (a real TTY), not from stdin. WinRM sessions have no terminal attached. When the task tried to pipe `\n\n` to `ssh-keygen -N ""` to accept the empty passphrase, the process hung indefinitely waiting for console input that never arrived.

**Fix applied:**

*`roles/docker_client/tasks/windows.yml`*

Replaced the stdin-piping approach with a `cmd.exe` wrapper. `cmd.exe` treats `""` as an empty string argument, which is the correct way to pass `-N ""` on Windows:

```powershell
# Before (hung in WinRM):
Write-Output "`n`n" | ssh-keygen -t ed25519 -f $keyPath -q 2>&1 | Out-Null

# After (works in WinRM):
$escapedPath = $keyPath -replace '"', '""'
cmd /c "ssh-keygen -t ed25519 -f ""$escapedPath"" -N """" -q 2>&1" | Out-Null
```

The same fix was applied in `playbooks/_debug_wsl_auth.yaml` for the debug/test keygen task.

**Commit:** `94294b3`

---

## Problem 3 — sshd Restart Task: Undefined Variable on First Run

**Root cause:** The `Restart sshd when PowerShell SSH config changed` task was inside the `powershell-ssh` block and its `when` condition referenced `sshd_ps_port_result` — a variable registered by an earlier task in the same block. In Ansible, the `when` condition on a task inside a block is evaluated before the block runs, so `sshd_ps_port_result` was undefined at evaluation time, causing the task to error on first run.

Additionally, the task used the deprecated `bash.exe` as the OpenSSH `DefaultShell`. The correct value on modern systems with WSL is `wsl.exe`.

**Fixes applied:**

*`roles/access_identity_windows/tasks/main.yml`*

- Moved the restart task **outside** the `powershell-ssh` block so its `when` condition is evaluated after all preceding register tasks have run
- Changed `when` condition from `| default({}).changed | default(false)` to the cleaner `is changed` Jinja2 test
- Changed `DefaultShell` from `bash.exe` to `wsl.exe`
- Changed `DefaultShellCommandOption` to `-e` for correct command passthrough through `wsl.exe`

```yaml
# Moved outside block — when vars are now defined before this task evaluates
- name: Restart sshd when PowerShell SSH config changed
  ansible.windows.win_service:
    name: sshd
    state: restarted
  when: >-
    sshd_ps_port_result is changed or
    sshd_ps_subsystem_result is changed or
    sshd_ps_match_result is changed or
    sshd_ps_force_result is changed
  tags: [admin, powershell-ssh, ps_port]
```

**Commits:** `1bc16dd` (Fixes ssh into systems), `7b4ccc5` (Fix PowerShell SSH block restart task evaluation)

---

## Current Status

| Component | Status |
|-----------|--------|
| Docker on Mac (server-225-wsl context) | Working — WSL stays alive via keepalive task + vmIdleTimeout=-1 |
| SSH keygen in WinRM | Working — cmd.exe wrapper passes empty passphrase correctly |
| sshd restart task | Working — moved outside block, uses `is changed` test |
| SSH into systems | Fixed — DefaultShell is now wsl.exe, block structure corrected |

---

## Files Changed

| File | Change |
|------|--------|
| `roles/access_identity_windows/templates/wslconfig_bridged.j2` | Added `vmIdleTimeout=-1` |
| `roles/access_identity_windows/tasks/ubuntu.yml` | WSL keepalive scheduled task, newline fix, legacy task cleanup |
| `roles/docker_client/tasks/windows.yml` | ssh-keygen cmd.exe wrapper |
| `roles/access_identity_windows/tasks/main.yml` | DefaultShell wsl.exe, restart task moved outside block |
| `playbooks/_debug_wsl_auth.yaml` | Updated debug playbook to test cmd.exe keygen approach |
| `docs/debug-ssh-vvv.md` | SSH debug runbook added |
