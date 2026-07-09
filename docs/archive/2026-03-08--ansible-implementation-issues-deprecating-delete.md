---
deprecated: true
deprecating_reason: WSL scope reform 2026-05-28 — server paths must not use WSL
coordinator_review: pending
---

# Ansible Implementation Issues — March 8–9, 2026

This report covers the specific issues encountered while implementing fixes through Ansible — problems that required re-approach, retries, or rethinking the solution strategy. Organized by issue, not by chronology.

---

## Issue 1 — `ansible_env.HOME` Unavailable on Windows Hosts

**Where:** `roles/docker_client/tasks/main.yml`

**What happened:** The task used `{{ ansible_env.HOME }}` to build the destination path for a template deployment. On Unix hosts this works. On Windows, the environment does not have a `HOME` variable — it has `USERPROFILE`. Ansible gathered `ansible_env` as a dict, and accessing `.HOME` on a Windows host returned an error:

```
Error while resolving value for 'dest': object of type 'dict' has no attribute 'HOME'
fatal: [HOM-LAB-HVH-02]: FAILED!
fatal: [home-lab-auth-hvh-01]: FAILED!
```

The Mac host passed; both Windows hosts failed.

**Fix:** Added `when: ansible_facts['system'] != "Windows"` to the Unix-only template task. For tasks that need to write to Windows paths, use `{{ ansible_env.USERPROFILE }}` or the `win_` equivalent modules.

**Lesson:** `ansible_env.HOME` is not cross-platform. Windows requires `USERPROFILE`. Tasks that deploy shell config files to `~/.bashrc.d/` must be explicitly guarded from running on Windows hosts.

---

## Issue 2 — `pywinrm` Not Installed: WinRM Tasks Failed Immediately

**Where:** Any task targeting Windows hosts via WinRM

**What happened:** The first run after activating `.venv` failed with:
```
[ERROR]: winrm or requests is not installed: No module named 'winrm'
```

The venv was activated but `pywinrm` and `requests` had not been installed into it. Every WinRM task failed at the connection attempt before any module code ran.

**Compounding factor:** When trying to install `pywinrm` via `pip install`, every shell command was prefixed with a Docker SSH timeout error (see Issue 3). The pip install appeared to fail entirely because the exit code was 1 and only the Docker error was visible in output.

**Fix:** Set `DOCKER_CONTEXT=default` to bypass the Docker SSH context before running pip, then ran `pip install pywinrm requests`. Required sourcing `.envrc` and `.venv/bin/activate` as a unit before every ansible command — the project rule requiring this combination exists for exactly this reason.

---

## Issue 3 — Docker Context SSH Interference With All Shell Commands

**Where:** Mac controller shell environment

**What happened:** The Mac's Docker context was configured to connect to the Docker daemon on `server-225-wsl` via SSH. `server-225-wsl` was unreachable (WSL had shut down). On every shell command, Docker's background SSH connection attempt fired, timed out, and printed an error. This contaminated every command's stderr and exit code, including pip installs, making it appear that pip had failed when the actual pip operation may or may not have completed.

This was not immediately obvious — the error looked like a pip failure, not a Docker context problem.

**Diagnosis sequence:**
1. Saw `pip install` exit code 1 with only Docker SSH error as output
2. Ran the pip command again with `DOCKER_CONTEXT=default` — pip succeeded
3. Confirmed: the issue was Docker, not pip or the venv

**Root cause of the Docker context failure:** WSL 2 auto-shuts down the VM when no `wsl.exe` processes are running. The Docker daemon inside WSL went down with it, killing the SSH connection. This is why Docker was broken in the first place (see the companion report).

---

## Issue 4 — `win_copy` Writes CRLF + UTF-8 BOM; WSL Bash Rejects Both

**Where:** `roles/docker_client/tasks/windows.yml` — the SSH authorization script task

**What happened:** The initial approach wrote a bash script to `C:\Windows\Temp\win_authorize_ssh.sh` using `ansible.windows.win_copy`. The script was then executed inside WSL via `wsl.exe -u root -- bash /mnt/c/Windows/Temp/win_authorize_ssh.sh`.

The script failed to execute. The reason: `win_copy` writes files with Windows line endings (CRLF) and a UTF-8 BOM by default. Bash requires LF line endings and will not execute a script that starts with a BOM character — it treats the BOM as a syntax error or as part of the shebang line.

**Fix:** After `win_copy` wrote the file, a PowerShell post-processing step was added to re-write it with correct encoding:

```powershell
$raw = [System.IO.File]::ReadAllText('C:\Windows\Temp\win_authorize_ssh.sh')
$noBomUtf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText(
    'C:\Windows\Temp\win_authorize_ssh.sh',
    ($raw -replace "`r`n", "`n"),
    $noBomUtf8
)
```

`New-Object System.Text.UTF8Encoding $false` creates a UTF-8 encoder without BOM emission. The `-replace "`r`n", "`n"` strips CRLF to LF.

**Lesson:** Any file written to Windows that will be consumed by WSL/Linux must be explicitly written as LF + no BOM. `win_copy`, `win_template` with `newline_sequence: '\r\n'`, and PowerShell's `Set-Content` all write CRLF by default. The `[System.IO.File]::WriteAllText` with explicit encoding is the reliable cross-boundary approach.

This is also why `wslconfig_bridged.j2` was changed from `newline_sequence: '\r\n'` to `'\n'` — `.wslconfig` is parsed by the WSL kernel, not Windows, and CRLF in that file caused parsing failures.

---

## Issue 5 — `ssh-keygen` Passphrase Prompt Hangs in WinRM (No TTY)

**Where:** `roles/docker_client/tasks/windows.yml`

**What happened:** Generating an SSH key pair required passing an empty passphrase to `ssh-keygen`. The standard approach on Windows is to pipe newlines into the process to answer the passphrase prompts:

```powershell
# Attempt 1 — hung indefinitely in WinRM:
Write-Output "`n`n" | ssh-keygen -t ed25519 -f $keyPath -q 2>&1 | Out-Null
```

This worked when run interactively in a real terminal. In a WinRM session, it hung. The reason: Windows OpenSSH's `ssh-keygen` reads the passphrase from the console (a real TTY device), not from stdin. WinRM sessions have no TTY attached. The process was waiting for console input that would never arrive.

**Approaches tried:**

1. `Write-Output "\n\n" | ssh-keygen ...` — hung (stdin, not console)
2. `echo "" | ssh-keygen ...` (cmd-style) — same problem
3. Passing `-N ""` directly to ssh-keygen in PowerShell — Windows ssh-keygen does not accept `-N ""` as an empty string argument through PowerShell's argument parsing; it interprets the empty string as missing
4. `cmd /c "ssh-keygen -t ed25519 -f ""$path"" -N """" -q 2>&1"` — **worked**

The cmd.exe approach works because cmd.exe has different argument parsing rules. `""""` in cmd is cmd's syntax for a literal empty string passed as an argument value. This bypasses the TTY requirement entirely by providing the passphrase as a command-line argument through a shell that handles the quoting correctly.

**Final implementation:**
```powershell
$escapedPath = $keyPath -replace '"', '""'
cmd /c "ssh-keygen -t ed25519 -f ""$escapedPath"" -N """" -q 2>&1" | Out-Null
```

The path is escaped for cmd's quoting rules (`"` → `""`) and then embedded in the cmd.exe command string.

---

## Issue 6 — OpenSSH `DefaultShell`: `bash.exe` Is Deprecated, Requires `wsl.exe`

**Where:** `roles/access_identity_windows/tasks/main.yml`

**What happened:** The role was setting `DefaultShell` to `bash.exe` in `HKLM:\SOFTWARE\OpenSSH`. On older systems, `bash.exe` was the WSL entry point. On current systems with WSL 2, `bash.exe` is a legacy wrapper that exists for compatibility but has known issues with non-interactive command passthrough — `ssh host some-command` would not work reliably because `bash.exe` does not correctly handle the `-c` command option for non-interactive invocations.

The specific symptom: interactive SSH sessions worked (you could log in), but Ansible's `ssh` connection plugin — which connects and immediately runs a command — would fail or produce unexpected behavior.

**Fix:** Changed `DefaultShell` from `bash.exe` to `wsl.exe`, and added a second registry key:

```yaml
- name: Set OpenSSH DefaultShellCommandOption for wsl.exe
  ansible.windows.win_regedit:
    path: HKLM:\SOFTWARE\OpenSSH
    name: DefaultShellCommandOption
    data: "-e"
    type: string
    state: present
```

`DefaultShellCommandOption: -e` tells OpenSSH what flag to pass to the default shell when running a command non-interactively (equivalent to `sh -c`). For `wsl.exe`, the correct option is `-e` (execute command), not `-c`. Without this, `wsl.exe` receives the command as a login argument and doesn't execute it as a command string.

**Lesson:** `bash.exe` and `wsl.exe` have different argument handling. `wsl.exe -e command` is the correct non-interactive invocation pattern. Setting `DefaultShell` without setting `DefaultShellCommandOption` to match the shell's actual flags leaves SSH in a half-working state.

---

## Issue 7 — `sshd` Restart Task: Undefined Variable on First Run

**Where:** `roles/access_identity_windows/tasks/main.yml` — the `powershell-ssh` block

**What happened:** The sshd restart handler was inside a `block:` and its `when` condition referenced `sshd_ps_port_result`, a variable registered by an earlier task inside the same block:

```yaml
block:
  - name: Ensure Port 2222 in sshd_config   # registers sshd_ps_port_result
    ...
    register: sshd_ps_port_result

  - name: Restart sshd when PowerShell SSH config changed
    ansible.windows.win_service:
      name: sshd
      state: restarted
    when: sshd_ps_port_result is changed   # FAILS on first run
```

On the first run against a host, `sshd_ps_port_result` had never been registered. The task failed with `'sshd_ps_port_result' is undefined`.

**First fix attempt:** Added `| default({}).changed | default(false)` guards to each condition — allowing the expression to evaluate to `false` when the variable is undefined rather than erroring:

```yaml
when: >-
  (sshd_ps_port_result | default({})).changed | default(false) or
  ...
```

This resolved the undefined error but introduced a different problem: the `| default({}).changed` chain is fragile. A registered task result is a dict with a `changed` key; an empty dict `{}` does not have a `changed` key, so the second `| default(false)` is what carries it. This worked but was evaluated by subsequent reviewers as unclear and error-prone.

**Final fix:** Moved the restart task **outside** the block entirely, then changed the condition to use the clean Ansible `is changed` test:

```yaml
block:
  - name: Ensure Port 2222 ...
    register: sshd_ps_port_result
  - name: Ensure Subsystem sftp ...
    register: sshd_ps_subsystem_result
  ...
  tags: [admin, powershell-ssh, ps_port]

# Outside the block — all register vars are now defined before this evaluates
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

**Lesson:** In Ansible, `when` on a task inside a `block` is evaluated at runtime as the task is encountered, not pre-compiled. But if a variable hasn't been registered yet in the current play execution context, it is undefined — even if it will be registered by an earlier task in the same block. Tasks that depend on registered results from sibling tasks inside a block should live outside the block.

---

## Issue 8 — Docker Context SSH URI Hardcoded to `localhost`

**Where:** `roles/docker_client/tasks/windows.yml`

**What happened:** The initial Docker context creation task hardcoded the SSH URI:

```powershell
$sshUri = 'ssh://{{ docker_engine_ssh_user }}@localhost:{{ docker_engine_ssh_port }}'
```

`localhost` is correct when Docker CLI is running on the same Windows machine as the WSL instance — the Docker context connects from Windows to its own WSL. But when the Mac controller was testing Docker connectivity by inspecting the context remotely, or when the context needed to be usable from any machine, `localhost` pointed to the wrong host.

**Fix:** Parametrized with `docker_engine_ssh_host` variable:

```powershell
$sshUri = 'ssh://{{ docker_engine_ssh_user }}@{{ docker_engine_ssh_host }}:{{ docker_engine_ssh_port }}'
```

The variable defaults to `localhost` in `defaults/main.yml` for the standard same-machine case but can be overridden per host.

---

## Issue 9 — WSL `apt update` During Provisioning: Long Runtime, No Progress Feedback

**Where:** `roles/access_identity_windows/tasks/ubuntu.yml` — WSL distribution package update

**What happened:** After installing a fresh WSL Ubuntu-24.04 distro, the role runs `apt update && apt upgrade`. This task runs inside WSL via `wsl.exe` through WinRM. The task produced no output for several minutes because `apt` buffers its output and the WinRM connection was waiting for the process to complete before returning any result.

On at least one run this caused the user to Ctrl+C the playbook, requiring a re-run with `--tags wsl-reset,wsl` to start the WSL provisioning over.

**How this was handled:** Not changed structurally — the task still runs apt via WSL. The workaround is to be patient or to run the package update separately with a higher timeout. The root cause is inherent to running long-lived apt operations through WinRM: there is no streaming output, and the task will appear hung until it completes. This is noted as a known limitation.

---

## Summary Table

| Issue | Root Cause | Retries Required | Final Approach |
|-------|-----------|-----------------|----------------|
| `ansible_env.HOME` on Windows | Platform difference — Windows has USERPROFILE not HOME | 1 | Guard task with `when: system != Windows` |
| `pywinrm` not installed | Missing venv dependency | 1 | pip install after clearing Docker context |
| Docker context SSH blocking pip | WSL shutdown → Docker SSH fail → poisons shell | Multiple | `DOCKER_CONTEXT=default` + root fix (keepalive) |
| `win_copy` writes CRLF+BOM | Windows default encoding incompatible with WSL bash | 1 | PowerShell `WriteAllText` with explicit UTF8 no-BOM |
| `ssh-keygen` hangs in WinRM | Windows ssh-keygen reads passphrase from TTY, not stdin | 3 approaches tried | `cmd /c` wrapper with cmd empty-string quoting |
| `bash.exe` deprecated DefaultShell | bash.exe doesn't handle `-c` correctly on WSL2 | 1 | Changed to `wsl.exe` + `DefaultShellCommandOption: -e` |
| `sshd_ps_port_result` undefined | Block `when` evaluated before register task runs | 2 (default guard, then move outside block) | Moved restart task outside block |
| Docker URI hardcoded `localhost` | Context only valid on local machine | 1 | Parametrized with `docker_engine_ssh_host` |
| `apt update` long runtime through WinRM | WinRM buffers output until process exits | n/a | Known limitation, no structural fix |
