ansible_vault
=============

Installs and configures ansible-vault (included with Ansible).

## Overview

This role installs Ansible, which includes the `ansible-vault` command-line tool for encrypting and managing secrets.

## Installation Methods

- **macOS**: Installed via Homebrew (`brew install ansible`)
- **Ubuntu/Debian**: Installed via apt (`apt install ansible`)
- **Windows**: Installed via Chocolatey (`choco install ansible`)

## Usage

After installation, you can use `ansible-vault` to encrypt and manage vault files:

```bash
# Encrypt a vault file
ansible-vault encrypt vault/secrets.yml

# Edit an encrypted vault file
ansible-vault edit vault/secrets.yml

# View an encrypted vault file
ansible-vault view vault/secrets.yml

# Decrypt a vault file (use with caution)
ansible-vault decrypt vault/secrets.yml
```

## Note

`ansible-vault` is included as part of the Ansible package. Installing Ansible will automatically provide the `ansible-vault` command.

