# Troubleshooting System — Design Decisions and Cleanup Notes

The active design is the mirror-tree pattern in `roles/troubleshooting_collectors/`
and `playbooks/troubleshoot/`. Everything else in this repo is either a complement
to that pattern or a legacy predecessor that predates it.

---

## Active Design

The mirror-tree pattern. Full description in:
- `roles/troubleshooting_collectors/README.md`
- `.cursor/rules/framework-troubleshooting-mode.mdc` — authoritative behavioral
  contract including the wired collectors table, the hard gate, and the
  "build the pair" workflow

The "build the pair" section in the rule (If No Collector Exists) is the
canonical description of how to extend the pattern to a new component.

---

## Cleanup Backlog

### 1. `900--failure-and-diagnostics.mdc` — condense, keep the connection order

This rule predates the mirror-tree pattern. Most of it is superseded by
`framework-troubleshooting-mode.mdc`. What it has that is still unique:

- The connection fallback order: primary (SSH/WinRM) → fallback (OpenSSH into
  PowerShell for Windows, SSH for Linux, `wsl.exe` for WSL)
- The two-attempt cap — this should move to sit next to the troubleshooting
  mode rule or the troubleshooting_collectors README, not live in isolation

The goal: condense 900 to ~2 sentences that reference the mirror-tree rule,
keep the connection fallback order, retire everything else.

### 2. `docs/diagnostics/` — pair with troubleshooting_collectors or retire

These files are knowledge-layer docs (where does a component log, what commands
expose its state). The hyperv and openssh ones are still referenced by collector
output (README.txt backlinks). They're not dead, but they're passive.

Future options:
- Move their content into the collector task file's header comments (co-locate
  knowledge with the runnable collector)
- Keep them as interpretation guides that the collector README points to
- Retire them if the collector output becomes self-explanatory enough

Not urgent. The hyperv one in particular is too detailed to lose.

### 3. `roles/access_identity_windows/tasks/debug_output.yml` — probably retired

This was the one-off debug task that predates `troubleshooting_collectors`.
OpenSSH diagnostics are now covered by `collect_windows_remote_access_artifacts`.
Candidate for removal once it is confirmed that the windows_remote_access
collector covers the same ground.

### 4. Naming inconsistency in existing collectors

The current collector task files and playbooks don't follow a strict naming
pattern (e.g. `hyperv_ubuntu_vm` vs `windows_remote_access` are different
naming shapes). Low priority but worth normalizing when a third collector is
added.

---

## Design Principles Captured This Session

- Mirror tags: the same tag goes on the broken resource task AND its collector
  task. `--tags collect_<component>` runs both in one pass — the lifecycle (to
  observe/reproduce) followed by the collector (to capture artifacts).
- Hard gate: you may not assess a failure without collector artifacts. "I ran
  the collector" is not evidence. The content of the artifact files is.
- `never` + `collect_<component>` is the correct Ansible tag pairing for the
  collector task. It is skipped on normal runs and only fires when explicitly
  requested.
- The two-attempt cap and the mirror-tree are meant to be co-located. They are
  the same system: stop iterating, build or run the collector, assess from
  artifacts.
