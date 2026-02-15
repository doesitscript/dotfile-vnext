# group_vars

Group variables for the lab stack. Loaded by the playbook for the `server_225` group.

## Files and purpose

| File | Purpose |
|------|--------|
| `server_225.yml` | Non-secret settings: project name, deploy path, domain, dashboard user. Safe to commit. |
| `vault.yml` | **Encrypted** secrets (e.g. `vault_traefik_dashboard_password`). Create with `ansible-vault create group_vars/vault.yml`; do not commit plaintext. |

The playbook includes `group_vars/vault.yml` via `vars_files`; run with `--ask-vault-pass` or use a vault password file when executing.
