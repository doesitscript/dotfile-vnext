# Operator Identities

Operator-scoped identity registry for emails and credential pointers used across
products (LLM logins today, mail relay and others later). Not tied to a single
host such as `mac-dev`. NetBox is out of scope for this registry.

## Layers

| Layer | Location | Contents |
| --- | --- | --- |
| 1 — Identity | `inventory/group_vars/all/operator_identities.yml` | Stable keys, emails, class, vault/env pointers |
| 2 — Credential | `vault/operator_credentials.vault.yml` | Passwords and future app-specific secrets |
| 3 — Binding | Role defaults or future `operator_identity_bindings.yml` | Product → `identity_key` + credential ref |

## Stable account keys

| Key | Email | Password in vault |
| --- | --- | --- |
| `personal` | joshcastillo@gmail.com | No |
| `work` | josh.castillo.work@gmail.com | `vault_operator_identity_work_primary_password` |
| `dev` | joshcastillo.dev@gmail.com | `vault_operator_identity_dev_primary_password` |

## Loading credentials in playbooks/roles

When a role needs secrets:

```yaml
- name: Load operator credentials vault
  ansible.builtin.include_vars:
    file: "{{ playbook_dir }}/../vault/operator_credentials.vault.yml"
    name: vault_vars
  no_log: true
```

Resolve email from registry:

```jinja
{{ operator_identities.accounts.work.email }}
```

Resolve password from vault (or env override when defined on the account):

```jinja
{{ vault_vars[vault_operator_identity_work_primary_password]
   | default(lookup('env', operator_identities.accounts.work.primary_password_env_var), true) }}
```

## Runtime env overrides

Optional cmdline/local override without editing vault:

- `OPERATOR_IDENTITY_WORK_PASSWORD`
- `OPERATOR_IDENTITY_DEV_PASSWORD`

Pointers are declared on each sandbox account in `operator_identities.yml`.

## Related

- `vault/README.md` — `*.vault.yml` vs `*.plain.yml` naming and git rules
- `inventory/group_vars/all/ai_agent_profiles.yml` — model lanes (separate concern)
- `vault/mac_dev.vault.yml` — mac-dev host secrets (not operator identities)
