# Connection Credentials Setup

This guide explains how to store and use WinRM and SSH passwords securely using Ansible Vault.

## Overview

Connection credentials (WinRM passwords for Windows hosts, SSH passwords if needed) are stored in an encrypted vault file: `vault/connection.vault.yml`.

## Setup Steps

### 1. Edit the Connection Vault

First, edit the connection vault file to add your actual passwords:

```bash
./bin/fz vault edit connection --ask-vault-pass
```

Or if you have a vault password file:

```bash
./bin/fz vault edit connection --vault-password-file ~/.vault_pass
```

**Note:** If the vault file doesn't exist yet or isn't encrypted, you can edit it directly, then encrypt it (see step 2).

### 2. Add Your Passwords

In the vault editor, replace the placeholders with your actual passwords:

```yaml
---
# WinRM Passwords (for Windows host management)
vault_winrm_server_225_password: "your-actual-password-here"
vault_winrm_network_server_password: "your-actual-password-here"
vault_winrm_dev_3090_password: "your-actual-password-here"

# SSH Passwords (if password auth is used instead of keys)
vault_ssh_server_225_password: "your-actual-password-here"
vault_ssh_dev_3090_password: "your-actual-password-here"
vault_ssh_mac_dev_password: "your-actual-password-here"
```

### 3. Encrypt the Vault

If the vault file isn't encrypted yet, encrypt it:

```bash
cd /Users/joshc/develop/dotfile-vnext
ansible-vault encrypt vault/connection.vault.yml
```

You'll be prompted for a vault password. **Remember this password** - you'll need it every time you run bootstrap/deploy commands.

### 4. Create a Vault Password File (Optional but Recommended)

To avoid typing the vault password every time, create a password file:

```bash
# Store vault password in a secure location outside the repo
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Or use environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
```

**Security Note:** Never commit the vault password file to git. Add it to `.gitignore` if you store it in the repo root.

## How It Works

1. **Host Variables**: Each Windows host has a `host_vars` file (e.g., `inventory/host_vars/server-225-win.yaml`) that references the vault variable:
   ```yaml
   ansible_password: "{{ vault_winrm_server_225_password }}"
   ```

2. **Vault Loading**: The bootstrap playbooks load the connection vault using `vars_files`, making the vault variables available.

3. **Automatic Decryption**: When you run bootstrap commands with `--ask-vault-pass` or `--vault-password-file`, Ansible automatically decrypts the vault and uses the passwords for WinRM connections.

## Usage

### Running Bootstrap with Vault Password

```bash
# Prompt for vault password
./bin/fz bootstrap --limit server-225-win --ask-vault-pass

# Use vault password file
./bin/fz bootstrap --limit server-225-win --vault-password-file ~/.vault_pass

# If ANSIBLE_VAULT_PASSWORD_FILE is set, it's used automatically
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
./bin/fz bootstrap --limit server-225-win
```

### Editing the Connection Vault

```bash
# Edit connection vault (prompts for vault password)
./bin/fz vault edit connection --ask-vault-pass

# Edit with password file
./bin/fz vault edit connection --vault-password-file ~/.vault_pass
```

**Note:** The `fz vault edit` command currently supports `shared`, `network`, `main`, and `dev` scopes. To edit the connection vault, you can either:
- Use `ansible-vault edit vault/connection.vault.yml` directly
- Or add `connection` scope support to the `fz vault edit` command

## File Structure

```
vault/
  ├── connection.vault.yml      # Encrypted connection credentials
  ├── shared.vault.yml          # Shared application secrets
  ├── network.vault.yml         # Network node secrets
  ├── main.vault.yml            # Main node secrets
  └── dev.vault.yml             # Dev node secrets

inventory/
  └── host_vars/
      ├── server-225-win.yaml   # References vault_winrm_server_225_password
      ├── network-server-win.yaml # References vault_winrm_network_server_password
      └── dev-3090-win.yaml     # References vault_winrm_dev_3090_password
```

## Security Best Practices

1. **Never commit unencrypted vault files** - Always encrypt before committing
2. **Store vault password files outside the repository** - Use `~/.vault_pass` or similar
3. **Use `chmod 600` on password files** - Restrict access to owner only
4. **Use different passwords for different hosts** - Don't reuse passwords
5. **Rotate passwords regularly** - Update vault when passwords change

## Troubleshooting

### "Vault password required" error

Make sure you're providing the vault password:
- Use `--ask-vault-pass` to prompt
- Use `--vault-password-file` to specify a file
- Set `ANSIBLE_VAULT_PASSWORD_FILE` environment variable

### "Task failed: ntlm: auth method ntlm requires a password"

This means the vault password wasn't provided or the connection vault wasn't loaded. Ensure:
1. You're using `--ask-vault-pass` or `--vault-password-file`
2. The connection vault is encrypted and contains the correct passwords
3. The host_vars file references the correct vault variable name

### "Variable 'vault_winrm_*_password' is undefined"

This means the connection vault wasn't loaded. Check that:
1. The bootstrap playbook includes `vars_files: - ../vault/connection.vault.yml`
2. The vault file exists and is properly encrypted
3. You're providing the correct vault password



