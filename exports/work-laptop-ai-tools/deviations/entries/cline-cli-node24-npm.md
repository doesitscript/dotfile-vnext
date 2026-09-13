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

Corporate `~/.npmrc` with `prefix` / `globalconfig` also makes `nvm install`
fail (exit 11) while activating Node 24.

## Accommodation

- Role `cline_cli` installs via nvm Node major `cline_cli_node_version` (default
  `24`) without changing `node_default_version` for other tools.
- NVM bootstrap temporarily moves `~/.npmrc` aside and restores it on EXIT so
  nvm can install/activate; the later `npm install -g` still sees corporate
  `prefix=` (see `npm-global-prefix`).
- NVM install progress goes to stderr so the task registers only the Node path.
- Install uses `npm prefix -g` for the binary path.
- Config (models/MCP) stays in `cline_ide` under `~/.cline`.

## Reapply

```bash
ansible-playbook playbook.yaml --tags cline_cli,cline_ide --skip-tags hosts_file
cline --version
```
