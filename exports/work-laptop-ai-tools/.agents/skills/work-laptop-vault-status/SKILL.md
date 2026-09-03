---
name: work-laptop-vault-status
description: "Use when checking whether the work-laptop-ai-tools packet Ansible vault exists, is ciphertext, and which mapped keys are nonempty — names only. Must run scripts/vault_status.py (via work_laptop_vault.py status). Do not ansible-vault view."
---

# Skill: Work-laptop vault status

Names-only health check for `vault/shared.vault.yml`.

## When to use / not use

Use after hydrate, before Morph commission, or when the user asks if the
packet vault is ready.

Do not use to copy values (`work-laptop-vault-hydrate`).

## Script (required)

From **dotfile-vnext**:

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env python \
  exports/work-laptop-ai-tools/scripts/work_laptop_vault.py status
```

That CLI invokes `scripts/vault_status.py`.

## Workflow

1. Run the status command.
2. Report: ciphertext yes/no, gitignore line, `NONEMPTY` / `EMPTY` /
   `MISSING_EXPECTED` / `EXTRA_KEYS` (names only).
3. If dest is missing, tell the user to run `work-laptop-vault-hydrate`.

## Validation

- Script does not print values
- Exit 1 if dest missing or not `$ANSIBLE_VAULT` ciphertext

## Prohibited behavior

- `ansible-vault view`
- Inferring key contents from length or prefixes

## Progressive disclosure

- `scripts/vault_status.py`
- Router: `work-laptop-vault`
