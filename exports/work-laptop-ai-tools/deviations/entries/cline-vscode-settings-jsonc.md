---
id: cline-vscode-settings-jsonc
status: promoted
behavior_group: vscode-settings-merge
title: Skip Cline legacy VS Code settings merge when settings.json is JSONC
---

## Trigger

- Laptop VS Code `settings.json` uses JSONC (comments) — Ansible `from_json`
  merge failed; providers.json still needed to deploy.

## Accommodation

- `jq -e .` probe; skip merge when non-strict JSON; still deploy
  `~/.cline/data/settings/providers.json` + MCP.

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags cline
test -s ~/.cline/data/settings/providers.json
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Any role merging VS Code settings.json | yes | JSONC-safe probe before from_json |
