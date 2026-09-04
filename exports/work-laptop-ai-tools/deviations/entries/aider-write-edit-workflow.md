---
id: aider-write-edit-workflow
status: promoted
behavior_group: aider-cli-edit
title: Aider must apply edits in dirty trees (not shell-create fallbacks)
---

## Trigger

- Inbound `intake.md`: Aider could not create the file and suggested a shell
  command for the operator instead.

## Accommodation

- `dirty-commits: true` (laptop trees are often dirty)
- `suggest-shell-commands: false` (prefer apply-edits)
- `yes: true` (approve applies in this slice)
- Deploy `.aiderignore` from intake ignore list
- Document `/add <file>` before writing new paths

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags aider
grep -E 'dirty-commits|suggest-shell|yes:' ~/.aider.conf.yml
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Other CLI agents that refuse dirty git | yes | same dirty-tree + no-shell-fallback pattern |
| Codex local lanes | related | keep write paths explicit in skills |
