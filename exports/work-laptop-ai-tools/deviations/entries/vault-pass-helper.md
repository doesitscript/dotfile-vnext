---
id: vault-pass-helper
status: promoted
behavior_group: vault-password-ux
title: Packet vault via vault_pass.sh + .vault_pass
---

## Trigger

- Ansible asked for vault password on every laptop playbook run.

## Accommodation

- `ansible.cfg` → `vault_pass.sh` → gitignored `.vault_pass` (same password as parent).
- Do not use `--ask-vault-pass` on day-2.

## Re-apply

```bash
# On laptop sibling root: ensure .vault_pass exists (gitignored) and vault_pass.sh is executable
./vault_pass.sh  # should print password to stdout for ansible; never commit
```

## Generalize

- Any future packet playbooks that load `vault/shared.vault.yml`.
