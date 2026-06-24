# Vault files

Encrypted secrets and naming conventions for this repo.

## File suffix convention

| Pattern | Meaning | Git |
| --- | --- | --- |
| `*.vault.yml` | Ansible Vault secrets: either whole-file encrypted or plain YAML with inline `!vault` values | Commit only encrypted secret values |
| `*.plain.yml` | Plaintext secret staging or decrypt export | Never commit — ignored via `vault/*.plain.yml` in `.gitignore` |

Edit whole-file encrypted vaults in place:

```bash
bin/codex-env ansible-vault edit vault/<name>.vault.yml
```

For plain YAML files with inline `!vault` values, such as `vault/mac_dev.vault.yml`,
do not use `ansible-vault edit`. Generate an encrypted value block and paste it
over the matching empty/plain YAML value:

```bash
bin/codex-env ansible-vault encrypt_string --stdin-name vault_context7_mcp_api_key | pbcopy
```

Paste the raw secret in the terminal, press `Ctrl-D`, then replace:

```yaml
vault_context7_mcp_api_key: ""
```

with the encrypted block now on the clipboard:

```yaml
vault_context7_mcp_api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ...
```

When output is piped to `pbcopy`, the encrypted block is copied to the clipboard
instead of printed in the terminal.

Do not decrypt to a long-lived `*.plain.yml` file unless you accept it stays
local-only and will not appear in `git status`. Prefer `ansible-vault edit` for
whole-file vaults and inline `encrypt_string` blocks for mixed YAML files.

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
