# Goals: large IDE workspace and AI-context hygiene

> This file is the retained goals record. The prior strategy and evaluation
> documents were superseded after the live Context7 research pass and moved to
> `archive/2026-09-23--superseded-pre-context7-strategy/`. The current way
> forward is tracked in [current-way-forward.md](current-way-forward.md).

## User target

The repository should remain effective for home-infrastructure work while
becoming cheaper for IDEs and AI agents to inspect. The solution should be
long-term and scalable across Cursor, Codex, Copilot, and other agent clients,
without requiring a separate hand-maintained rule for every AI tool.

The larger goal is to determine whether the current workspace architecture is
contributing to the long-running inability to use home-lab models reliably for
basic tasks. The directory findings are hypotheses to verify or rectify with
better patterns, not merely user preferences to encode.

## Goals

The repository should remain effective for home-infrastructure work while
becoming cheaper for IDEs and AI agents to inspect. The solution should be
long-term and scalable across Cursor, Codex, Copilot, and other agent clients,
without requiring a separate hand-maintained rule for every AI tool.

The project must preserve these boundaries:

- logs and evidence are opt-in;
- `playbooks/` remains readable source;
- `docs/` remains readable source, including wanted diagrams;
- `.venv/` remains usable by local tools but is not a context corpus;
- generated output, caches, archives, binaries, and runtime evidence have a
  clear boundary from source.

The investigation must distinguish retrieval pollution, instruction pollution,
runtime pressure from Cursor/extensions/MCP servers/active loops, and genuine
model/gateway/context/tool-capability faults. Workspace size is a hypothesis to
verify, not an assumed root cause.

## Required outcome

The implementation should establish a repository-wide source boundary where
possible, with client settings as supplemental performance controls. It must
not claim that any ignore file is universal access control. Explicitly named
paths must remain inspectable.

The current plan must keep a five-stage evidence distinction:

1. path metadata discovered;
2. file contents opened/read;
3. content returned in tool output;
4. content confirmed in model context;
5. content used in the response.

The desired behavior for `logs/` is that it is absent from normal exploration
and only inspected when the user explicitly requests a path. A keep-file or
README may remain tracked while descendants remain ignored:

```gitignore
logs/*
!logs/.gitkeep
!logs/README.md
```

This does not prevent explicitly requested access and must be reconciled with
already tracked files before implementation.

## Source preservation goals

`playbooks/` is source and must remain discoverable. Its approximate 130 MB
footprint requires file-level attribution before cleanup or exclusion.

`docs/` should remain AI-readable because it contains project operating
knowledge. Desired diagrams remain in Git; generated renderings, embedded
binaries, duplicate exports, and historical bulk need separate treatment.

## Runtime goal: `.venv/`

`.venv/` is a tool dependency, not project source. It should remain available
to `bin/codex-env`, Ansible, Python tooling, and any required language tooling,
but should be excluded from Git, search, file watching, and AI context. The
evaluation should identify whether the environment contains avoidable caches,
duplicate interpreters, downloaded wheels, model data, or project artifacts.
The durable fix may include a smaller environment, external cache locations,
reproducible lock/requirements files, and stronger wrapper boundaries.

## Anti-patterns to investigate

- Treating `.gitignore` as if it were a complete AI-agent access policy.
- Keeping generated logs, reports, exports, or binaries beside source files.
- Using a giant shared `.venv/` for unrelated projects or downloaded data.
- Excluding all of `docs/` or `playbooks/` because some descendants are large.
- Relying on each AI client to maintain a different copy of ignore rules.
- Allowing long-lived agent sessions and MCP/webview extensions to make a large
  workspace expensive even after repository exclusions are improved.

## Current-pass performance note

The observed Composer wakelocks that disable background throttling are included
in the current pass. They require an explicit check of Cursor renderer and
GPU-helper behavior for improvement opportunities. This is a sequencing note,
not a decision to exclude them from remediation. The evaluation should explain
to the user what those wakelocks mean, whether they are expected during active
agent work, and whether they continue after the work should be idle.

## Controlled comparison goal

Compare the current full workspace with a minimal source-focused workspace
using the same basic home-lab agent tasks. Record time to first useful answer,
irrelevant retrieval, context size, tool-call correctness, failure rate, CPU,
and memory. This is the main way to distinguish a workspace problem from a
model or gateway problem.

## Decision goal after evaluation

The next revision should recommend one of these scopes:

1. Git-only baseline;
2. Git baseline plus repository content relocation/cleanup;
3. Git baseline plus layout cleanup plus runtime/environment boundary changes.

The evaluation must keep the user's explicit-log-access requirement and source
readability for `playbooks/` and `docs/` intact.

## Mac controller log convention

For this project, manually configured or redirectable logs generated on the Mac
controller should use the macOS-native pattern:

```text
~/Library/Logs/<owner>/
```

Examples:

```text
~/Library/Logs/dotfile-vnext/ansible.log
~/Library/Logs/dotfile-vnext/runs/
~/Library/Logs/dotfile-vnext/diagnostics/
~/Library/Logs/<tool-name>/
```

This is a controller-side convention, not an attempt to centralize every log
generated by services across the homelab. Vendor tools should retain their
native logging location unless their logging is explicitly configured or
captured by a controller-side wrapper.

The inventory contract for configurable application/tool logs is
`managed_application_log_root`. It is selected by inventory class and may be
overridden in host vars for a commissioned external application-log location.
Roles should construct paths below it as:

```text
<managed_application_log_root>/<application>/<file-or-subdirectory>
```

This contract explicitly excludes existing Windows system/Event Log placement,
OpenSSH logs, K3s/Docker shared logs, Loki storage, and other infrastructure
logging. Those surfaces must not be changed by this application-log variable.
The implementation reference is
[managed-application-log-paths.md](../../reference/managed-application-log-paths.md).
