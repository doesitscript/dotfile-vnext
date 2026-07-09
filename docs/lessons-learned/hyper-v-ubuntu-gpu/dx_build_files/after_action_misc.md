# Hyper-V Ubuntu GPU-P After Action Misc

## Purpose

This note captures the smaller but important execution defects that should not be lost now that the main GPU path is working.

The goal here is not to restate the whole repair. It is to preserve the process-level corrections we need before this becomes automation.

## Misc Findings

### Archive creation was a workaround, not the contract

Temporary archives were created during execution to move large payloads more reliably:

- `wsl-lib.tar`
- `driverstore.zip`

These were transport workarounds. They should not be treated as the authoritative library-entry or GPU-P plan shape.

Future docs should say that clearly whenever a temporary archive is used.

### “Stalled” language needs to be more precise

When a step was described as “stalled,” it usually meant one of these:

- a long-running copy had not been polled yet
- the Windows archive step was still working
- a previous fetch returned a partial or corrupt local artifact

That wording was too vague. Future notes should say exactly which command was still running and what had or had not completed.

### “Instead” language hid whether a step was planned or improvised

Phrases like “instead of” or “switching to” blurred two different cases:

- the original planned method
- the improvised recovery path used during live troubleshooting

Future notes should label steps explicitly as one of:

- planned packet step
- validated repo method
- temporary recovery workaround

### Host-side WSL reference use must be called out as a policy exception

Even if WSL helped reveal the right Linux-facing runtime shape, it was not aligned with the repo rule for this slice.

Any future mention of WSL in these notes must state one of two things clearly:

- it is forbidden for the supported execution path, or
- it is being used only as an investigative reference and must not become part of automation

### The host-to-guest SSH path was not ready as a first-class surface

At least one attempted host-to-guest SSH action failed with public-key authentication errors.

That means the project did not have a cleanly declared supported path for:

- Windows host -> Ubuntu guest direct file copy

The final successful path used:

- controller -> Windows host SSH
- controller -> Ubuntu guest SSH

Future automation should choose one supported path and encode it explicitly.

### Windows `win_shell` inline Bash is too fragile for complex probes

The failed `find /usr/lib/wsl/drivers ...` probe was not a GPU issue. It was a quoting/parsing issue caused by stacking:

- PowerShell
- `wsl.exe`
- `bash -lc`
- pipes and regex

For anything beyond simple one-liners, future Windows-side commands should use one of these safer patterns:

- a short `.ps1` script rendered and executed remotely
- a base64-encoded PowerShell command
- a repo-owned helper script with explicit arguments

### PTY/TTY expectations must be explicit

The `the input device is not a TTY` error happened because a command shape that belonged in a non-interactive shell ran through an execution style that behaved like an interactive terminal.

The lesson is simple:

- file extraction and heredoc-heavy local helper steps should use non-PTY execution
- long-running local data transforms should avoid shells that imply terminal semantics

## Corrections To Preserve

- The correct runtime proof came from `strace`, not from assumption.
- The correct missing path was:

```text
/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a/libnvidia-ml.so.1
```

- The correct technical fix was to populate that exact folder in the guest.
- The correct process conclusion is that the troubleshooting succeeded, but the run method still needs cleanup before it is reusable.

## Follow-On Repair Themes

- eliminate unsupported WSL dependence from the supported method
- codify the supported copy path
- reduce quoting-heavy ad hoc shell work
- add transport and privilege preflights
- make temporary archives explicit and disposable, not part of the conceptual workflow

## Implemented Repo Fixes

The repo now includes concrete follow-on artifacts for these themes:

- `playbooks/troubleshoot/hyperv_ubuntu_gpu_p_supported_finalize.yaml`
  - uses host-visible Windows paths instead of WSL
  - encodes the supported payload export, fetch, and guest-apply flow
- `scripts/hyperv_gpu_p_extract_payload.py`
  - replaces the fragile local heredoc extraction path with a non-interactive helper

One boundary remains true:

- I can route the supported repo flow away from PTY-sensitive steps, and that is now implemented.
- I cannot fully change the Codex tool runner's global PTY/login-shell behavior from inside the repo itself.
