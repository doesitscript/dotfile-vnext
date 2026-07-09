# Hyper-V Ubuntu GPU-P After Action

## Outcome

The technical goal succeeded.

- `dxgkrnl-dkms` installed successfully on `hom-lab-ctl-k3s-02`
- `/dev/dxg` appeared in the guest
- `dxgkrnl` loaded and bound the guest render device
- the missing NVIDIA runtime dependency was identified with `strace`
- after populating `/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a`, `nvidia-smi` succeeded in the guest and reported the RTX 5090

The troubleshooting goal is complete, but the execution process was not clean enough to be treated as repo-native automation.

## What Actually Blocked Stage 5

The decisive evidence came from guest `strace` on `nvidia-smi`.

It showed a failed open for:

```text
/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a/libnvidia-ml.so.1
```

That proved the missing runtime dependency was not just `/usr/lib/wsl/lib`; the guest also needed the exact NVIDIA DriverStore subtree under `/usr/lib/wsl/drivers/<reported-folder-name>`.

## Process Problems Observed

### 1. Repo policy was violated around WSL use

WSL was used during diagnosis and file discovery on the Windows host. That was not aligned with the project constraint that WSL should not be part of the execution method for this workflow.

This must be treated as a process defect, even though it helped identify the correct file layout.

### 2. Transport method drifted away from the plan

The governed packets established a staged, repo-owned flow. During execution, ad hoc archive and transfer steps were introduced:

- temporary `zip` creation
- temporary `tar` creation
- direct `sftp` pull from the Windows host
- direct controller-to-guest `ssh` stream copy

Those steps were useful for finishing the repair, but they were not the clean repo-native flow we want to preserve.

### 3. Commentary wording was sometimes misleading

Some progress updates implied steps were part of the intended plan when they were really recovery workarounds.

Examples:

- archive creation sounded like the default plan rather than an ad hoc transport workaround
- WSL-based inspection sounded like an ordinary reference step rather than a policy exception
- “stalled” and “instead” wording implied hidden earlier steps that were never part of the approved plan packet

### 4. Windows shell quoting remained fragile

Several `ansible.windows.win_shell` commands failed because of quoting collisions between:

- PowerShell parsing
- embedded Bash
- regex or pipe characters
- here-strings / quoted inline commands

This did not block the final fix, but it made the run noisier and less trustworthy than it should have been.

### 5. Controller/guest privilege boundaries were not cleanly encoded

The final successful copy path depended on:

- controller access to the Windows host over SSH
- controller access to the Ubuntu guest over SSH with the Ansible key
- guest `sudo -n` working non-interactively

Those facts were discovered live instead of being expressed in a repeatable, preflighted repo workflow.

## TTY Problem

One failure during extraction reported:

```text
the input device is not a TTY
```

This was not a guest GPU problem. It was an execution-shape problem on the controller.

What happened:

- a local extraction command mixed a Python heredoc and follow-on shell commands
- it was launched through a PTY/login-shell execution path
- that combination caused the shell to behave as though interactive terminal semantics were required

What fixed it:

- rerunning the extraction in a plain non-interactive shell
- disabling PTY-style behavior for that step

Meaning:

- the TTY error was a tooling/execution bug in the run method
- it should not be interpreted as part of the Hyper-V, Ubuntu, `dxgkrnl`, or NVIDIA runtime diagnosis

## Inconsistencies To Correct In Future Runs

- Do not present ad hoc archive creation as if it is the planned transport method.
- Do not use WSL as a hidden discovery or transfer dependency when the project forbids it.
- Do not blur “reference layout learned from investigation” with “approved repo-native execution path.”
- Do not leave SSH key-path assumptions implicit between:
  - controller -> Windows host
  - controller -> Ubuntu guest
  - Windows host -> Ubuntu guest

## What The Stable Technical Conclusion Is

The final technical conclusion is narrow and solid:

1. `dxgkrnl-dkms` plus `/usr/lib/wsl/lib` was enough to unlock stage 4.
2. Stage 5 required the exact traced NVIDIA DriverStore subtree under `/usr/lib/wsl/drivers/<folder>`.
3. In this run, that folder was:

```text
nvmdsi.inf_amd64_e82263d194ad754a
```

4. After populating that exact folder, `nvidia-smi` worked in the guest.

## Required Follow-On

The next slice should be automation and process repair, not more troubleshooting.

Required follow-on work:

- convert the validated flow into repo-owned Ansible
- remove WSL from the supported execution path
- add transport preflight checks
- add a deterministic method for resolving and copying the exact DriverStore subtree
- encode non-interactive shell expectations so PTY/TTY failures do not recur

## Implemented Remediation

The repo now has a first supported-path implementation for those follow-on items:

- supported finalize playbook:
  - `playbooks/troubleshoot/hyperv_ubuntu_gpu_p_supported_finalize.yaml`
- non-interactive payload extraction helper:
  - `scripts/hyperv_gpu_p_extract_payload.py`

Those changes specifically address:

- removing WSL from the supported execution path
- replacing heredoc-heavy local extraction with a deterministic helper
- making the Windows payload transfer and extraction flow explicit
