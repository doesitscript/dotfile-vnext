---
id: npm-global-prefix
status: promoted
behavior_group: npm-global-install
title: Corporate ~/.npmrc prefix= for npm globals
---

## Trigger

- Corporate `~/.npmrc` sets `prefix=` (e.g. `~/.npm-packages`).
- Globals land under that prefix, not next to the nvm node binary.
- Codex shim missing; Context7 expected beside nvm bin.

## Accommodation

- Resolve `npm prefix -g`; install with `--prefix`; assert binary; repair if missing.
- Optional `~/.zshrc` PATH block for `<prefix>/bin`.
- Continue/MCP: `bin/work-laptop-nvm-exec` for GUI PATH gaps.

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags codex_cli,mcp
which codex; npm prefix -g
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| context7-mcp | yes | promoted in role |
| morph-mcp | yes | use nvm-exec + prefix-aware install |
| firebase-tools mcp | yes | npx via nvm-exec |
| New npm -g on slice | yes | copy Codex prefix pattern before inventing |
