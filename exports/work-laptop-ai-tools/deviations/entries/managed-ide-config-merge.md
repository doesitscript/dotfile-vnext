---
id: managed-ide-config-merge
status: promoted
behavior_group: ide-config-lifecycle
title: Managed IDE configs must convert/merge — not blind-overwrite user state
---

## Trigger

- Kilo live path is `kilo.jsonc`; an earlier role wrote `config.json` and later
  overwrote `kilo.jsonc` wholesale, risking loss of user MCP/custom agents.
- Aider `yes` → `yes-always` showed that a full rewrite with a **stale key**
  breaks the tool after every apply.

## Accommodation

- **Kilo** `kilo_ide_apply_mode: merge` (default):
  1. Convert `~/.config/kilo/config.json` → `kilo.jsonc` once if needed
  2. Merge managed provider + agent ids + model top-level keys
  3. Preserve user MCP, custom agents, other providers
  4. Remove legacy `config.json` after conversion
- **Cline** `cline_ide_providers_merge: true`: keep non-managed providers;
  `models.json` remains the managed catalog (full replace of that file only).
- **Aider**: convert inventory `aider_yes` → render `yes-always`; never write
  `yes:`.

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags kilo,cline,aider
test -f ~/.config/kilo/kilo.jsonc && test ! -f ~/.config/kilo/config.json
grep -E 'yes-always' ~/.aider.conf.yml
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Zed / Continue managed YAML | yes | prefer merge or documented full-replace ownership |
| Any future IDE role | yes | choose merge vs overwrite explicitly in defaults |
