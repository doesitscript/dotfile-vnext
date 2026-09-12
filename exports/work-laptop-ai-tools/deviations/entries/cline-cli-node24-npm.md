---
id: cline-cli-node24-npm
title: Cline CLI needs Node 22+ and npm allow-scripts for native postinstall
status: accepted
updated_at: "2026-09-12"
---

# Cline CLI — Node 24 + allow-scripts

## Symptom

`npm i -g cline` on Node 20 (packet `node_default_version`) is below upstream’s
Node 22+ requirement. Fresh npm may also skip `cline` postinstall (native
binary) unless `--allow-scripts=cline,protobufjs` is set.

## Accommodation

- Role `cline_cli` installs via nvm Node major `cline_cli_node_version` (default
  `24`) without changing `node_default_version` for other tools.
- Install uses `npm prefix -g` for the binary path (works with corporate
  `~/.npmrc` prefix=; see `npm-global-prefix`).
- Config (models/MCP) stays in `cline_ide` under `~/.cline`.

## Reapply

```bash
ansible-playbook playbook.yaml --tags cline_cli,cline_ide --skip-tags hosts_file
cline --version
```
