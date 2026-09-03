---
name: work-laptop-vault-hydrate
description: "Use when copying API key values from the parent dotfile-vnext Ansible vault into the work-laptop-ai-tools packet vault without exposing values. Must run scripts/hydrate_vault_from_parent.py (via work_laptop_vault.py hydrate). Do not ansible-vault view the result in chat."
---

# Skill: Work-laptop vault hydrate

Copy matching parent vault values into the packet encrypted vault using the
packet hydrate script. Stdout is key **names** and presence only.

## When to use / not use

Use when the user asks to fill / hydrate / transfer packet vault keys from
parent `vault/shared.vault.yml` and `vault/mac_dev.vault.yml`.

Do not use for names-only inspection (`work-laptop-vault-status`).
Do not enable MCP servers.

## Script (required)

From **dotfile-vnext** (parent `.vault_pass` must exist):

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/work_laptop_vault.py hydrate --also-sibling
```

That CLI invokes `scripts/hydrate_vault_from_parent.py --init-empty --hydrate --also-sibling`.

From sibling with parent checkout next to it:

```bash
python scripts/work_laptop_vault.py hydrate \
  --parent-root /Users/joshc/develop/dotfile-vnext \
  --also-sibling
```

Prefer `bin/codex-env python` when running from parent so ansible-vault is on PATH.

## Workflow

1. Confirm `vault/key-hydrate-map.yml` lists the keys to copy.
2. Run the hydrate command above. Do not add flags that dump YAML.
3. Report `COPIED` / `EMPTY_IN_PARENT` / `ABSENT_IN_PARENT` names only.
4. Optional: run `work-laptop-vault-status` for a second names-only check.
5. Encrypted files stay gitignored. Tracked files (map/example/README) may
   need `work-laptop-packet-ops` if you edited them.

## Validation

- Command exits 0
- Output includes `VERIFY: destination is ansible-vault ciphertext`
- No secret substrings in the command output you paste back

## Prohibited behavior

- `ansible-vault view` or `decrypt` to stdout in this session
- Committing `vault/shared.vault.yml`
- Printing parent vault contents to debug a failure (fix the script instead)

## Progressive disclosure

- Engine: `scripts/hydrate_vault_from_parent.py`
- CLI: `scripts/work_laptop_vault.py`
- Paths: `scripts/vault_paths.py`
- Map: `vault/key-hydrate-map.yml`
- Router skill: `work-laptop-vault`
