---
identifier: cursor-rg-path-macos-2026-09-22
title: Cursor agent cannot find user-installed ripgrep
---

# Cursor agent cannot find user-installed ripgrep

The reported symptom was `bash: line 1: rg: command not found` in Cursor's main
chat agent on the Mac controller (`mac-dev`, inventory local connection).

## Source and evidence boundaries

- `inventory/host_vars/mac-dev.yaml` commissions `ripgrep_cli_state: present`.
- `roles/ripgrep_cli` installs the pinned GitHub release to `~/.local/bin/rg`.
  The binary exists and executes as version 15.2.0.
- `roles/common/shell_config/templates/path.bash.j2` supplies `~/.local/bin`
  through shell startup. A non-login `bash -c` does not obtain it from that file.
- Cursor user settings had locale overrides but no terminal PATH override.
- Installed Cursor `out/vs/workbench/workbench.desktop.main.js` creates the
  agent terminal with `CURSOR_AGENT=1`, `strictEnv: false`; terminal environment
  construction reads `terminal.integrated.env.osx`.
- [Cursor terminal documentation](https://prod.cursor.com/docs/agent/tools/terminal)
  describes terminal execution and the `CURSOR_AGENT` marker.
- Recent Cursor Agent Exec logs were inspected, but the original failing
  invocation was not recovered. Its exact inherited PATH is therefore unknown.

A controlled non-login Bash probe with
`PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin` reproduces exit 127:

```text
/usr/local/bin/bash: line 1: rg: command not found
```

This establishes a reproducible PATH gap consistent with the report, not a
captured environment from the original agent invocation. No persistent local
settings were changed during diagnosis. Temporary environment overrides existed
only inside child processes and were gone before Ansible apply.

## Owning fix and module choice

`roles/cursor/tasks/macos_terminal_path.yml` uses `stat`, `slurp`, `file`, and
`copy` to merge the PATH override while retaining unrelated settings. Existing
repo settings merges and installed `ansible-doc` module documentation were
checked. Wrapped repo commands replaced Ansible MCP checks because this is
controller-local macOS work. Ansible/Context7 MCP tools were not available.

`cursor_macos_terminal_path` prepends the managed user CLI directories and keeps
the literal `${env:PATH}` runtime substitution. The install remains owned by
`ripgrep_cli`; no additional package or system-wide symlink is needed.

## Collector and verification

- Script: `scripts/diagnostics/cursor_shell_path.py`.
- Collector: `roles/troubleshooting_collectors/tasks/cursor_shell_path.yml`.
- Dedicated playbook: `playbooks/troubleshoot/collect_cursor_shell_path_artifacts.yaml`.
- Development-playbook tag: `collect_cursor_shell_path` (opt-in).
- Artifacts: `artifacts/troubleshooting/cursor_shell_path/mac-dev/*.json`.
- Probes run both Apple Bash and Homebrew Bash with the resolved Cursor terminal
  environment, executing version and exact-match search checks. They do not
  invoke an agent through the Cursor UI.
- Use `-vvv` for additional Ansible execution details. No service/event logs
  apply to the standalone `rg` process; the original agent invocation remains
  uncollected.

Separate findings: this Codex tool parent injects unsupported `C.UTF-8`; Apple
Bash 3.2 rejects the installed fzf completion script while Homebrew Bash accepts
it. Neither prevented the Homebrew login-shell `rg` probe. These are outside
this Cursor terminal PATH change.

Apply, preview, and undo are documented in `roles/cursor/README.md`.

## Applied validation receipt

On 2026-09-22, the existing development playbook ran with
`--limit mac-dev --tags cursor_terminal_path,ripgrep_cli`:

| Run | Result |
| --- | --- |
| Syntax check | Exit 0; runtime-created development group warning |
| Targeted lint | Exit 0; no violations |
| Check-mode preview | One settings change predicted; no failures |
| First apply | Exit 0; `ok=59 changed=1 failed=0 unreachable=0` |
| Second apply | Exit 0; `ok=59 changed=0 failed=0 unreachable=0` |
| Behavior | Both Bash binaries: before exit 127, after exit 0, exact `cursor-rg-proof` output, empty stderr |
| Preservation | Parsed settings differ only at `terminal.integrated.env.osx.PATH` |

Raw logs and before/after JSON are saved locally at
`artifacts/troubleshooting/cursor_shell_path/mac-dev/20260922-path-fix/`.
No temporary local configuration edits preceded either apply. Fresh Cursor
chat-agent UI execution remains untested; pre-existing terminals can retain the
old environment until replaced.
