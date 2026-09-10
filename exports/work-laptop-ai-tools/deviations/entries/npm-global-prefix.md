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
- **2026-09-10:** Continue MCP — sourcing `nvm.sh` aborted with
  “globalconfig and/or a prefix setting, which are incompatible with nvm”
  before Context7 / Firebase / (wrapped) Morph could start.

## Accommodation

- Resolve `npm prefix -g`; install with `--prefix`; assert binary; repair if missing.
- Optional `~/.zshrc` PATH block for `<prefix>/bin`.
- Continue/MCP: `bin/work-laptop-nvm-exec` for GUI PATH gaps.
- **nvm-exec (2026-09-10):** do **not** source `nvm.sh` when `~/.npmrc` has
  `prefix`/`globalconfig`. Resolve `$NVM_DIR/versions/node/*/bin` (or default
  alias) onto `PATH`, then prepend the npm global bin from `npm prefix -g` or
  the npmrc `prefix=` line. Same wrapper for Context7, Firebase `npx`, Morph.

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags continue,mcp
bin/work-laptop-nvm-exec node -v
bin/work-laptop-nvm-exec context7-mcp --help >/dev/null
which codex; npm prefix -g
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| context7-mcp | yes | promoted in role + nvm-exec |
| morph-mcp | yes | nvm-exec + prefix-aware install |
| firebase-tools mcp | yes | npx via nvm-exec |
| New npm -g on slice | yes | copy Codex prefix pattern before inventing |
