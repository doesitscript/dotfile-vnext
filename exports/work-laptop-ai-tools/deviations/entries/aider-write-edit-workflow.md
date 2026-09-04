---
id: aider-write-edit-workflow
status: promoted
behavior_group: aider-cli-edit
title: Aider must apply edits in dirty trees (not shell-create fallbacks)
---

## Trigger

- Inbound `intake.md`: Aider could not create the file and suggested a shell
  command for the operator instead.
- Follow-up (sibling `a37cd53`): managed `yes:` key invalid on Aider 0.86+ —
  CLI broke after every apply until converted to `yes-always`.

## Accommodation

- `dirty-commits: true` (laptop trees are often dirty)
- `suggest-shell-commands: false` (prefer apply-edits)
- `yes-always: true` (Aider 0.86+; never emit legacy `yes:`)
- `map-tokens: 2048`, `map-refresh: files` (repo index for planning — not full
  file contents)
- Deploy `.aiderignore` from intake ignore list
- Version probe **fails** the play when rendered config is invalid
- Document `/add <file>` / `aider --read <file>`; paths are worktree-relative

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags aider
grep -E 'dirty-commits|suggest-shell|yes-always|map-tokens|map-refresh' ~/.aider.conf.yml
# must NOT contain a bare `yes:` key
! grep -E '^yes:' ~/.aider.conf.yml
aider --version
```

## Conversion rule (long-term)

When a CLI config key is renamed upstream, treat it as a **conversion**: update
the role template + defaults + inventory alias map, and fail verification if
the old key would leave a broken managed file. Do not keep emitting the old
key “for compatibility.”

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Other CLI agents that refuse dirty git | yes | same dirty-tree + no-shell-fallback pattern |
| Kilo / Cline managed JSON | yes | merge/convert — see `managed-ide-config-merge` |
| Codex local lanes | related | keep write paths explicit in skills |
