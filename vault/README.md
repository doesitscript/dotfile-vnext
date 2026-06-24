# Vault files

Encrypted secrets and naming conventions for this repo.

## File suffix convention

| Pattern | Meaning | Git |
| --- | --- | --- |
| `*.vault.yml` | ansible-vault encrypted secrets | Commit (ciphertext only) |
| `*.plain.yml` | Plaintext secret staging or decrypt export | Never commit — ignored via `vault/*.plain.yml` in `.gitignore` |

Edit encrypted files in place:

```bash
ansible-vault edit vault/<name>.vault.yml
```

Do not decrypt to a long-lived `*.plain.yml` file unless you accept it stays local-only
and will not appear in `git status`. Prefer `ansible-vault edit` for routine changes.

## Vault password

- Repo root: `.vault_pass` (gitignored)
- Ansible config: `vault_password_file = vault_pass.sh` in `ansible.cfg`

## Files in this directory

| File | Scope |
| --- | --- |
| `operator_credentials.vault.yml` | Operator identity passwords — see `docs/reference/operator-identities.md` |
| `mac_dev.vault.yml` | mac-dev controller secrets (Tunnelblick, become, etc.) |
| `shared.vault.yml` | Cross-host shared secrets |
| `main.vault.yml`, `dev.vault.yml`, `network.vault.yml` | Node/network scoped secrets |
| `ansible_ssh.vault.yml`, `openssh_host_keys.vault.yml` | SSH key material |

Project-root `vault.yml` holds app/service secrets for roles that load it via
`roles/*/tasks/load_vault.yml`.
