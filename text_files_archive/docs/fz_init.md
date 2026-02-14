# Fz Init - Ansible Command Aliases

The `fz init` command generates shell aliases that allow you to use Ansible commands directly without the `fz` wrapper. This makes it convenient to run ansible commands from anywhere in your shell.

## Overview

When you run `fz init`, it creates a `.fz_aliases.sh` file in the repository root that contains aliases for all Ansible commands. These aliases automatically:
- Activate the virtual environment (`.venv`)
- Set `ANSIBLE_CONFIG` to use `ansible.cfg`
- Change to the repository root directory
- Use the correct inventory file (`inventory/inventory.yaml`)
- Use the venv versions of all Ansible commands

## Setup

1. **Generate the aliases file:**
   ```bash
   ./bin/fz init
   ```

2. **Source the aliases in your current shell:**
   ```bash
   source .fz_aliases.sh
   ```

3. **Or add to your shell profile** (`~/.zshrc` or `~/.bashrc`) for permanent access:
   ```bash
   source /path/to/dotfile-vnext/.fz_aliases.sh
   ```

After sourcing, you can use all Ansible commands directly without the `fz` prefix.

## Available Ansible Commands

### ansible-playbook

Execute Ansible playbooks to configure and deploy infrastructure. This is the primary command for running automation tasks defined in YAML playbooks.

**Example:**
```bash
ansible-playbook playbooks/verify_fabric.yaml --limit server-225-wsl
```

### ansible-vault

Encrypt, decrypt, and edit sensitive data stored in Ansible vault files. Essential for managing secrets and credentials securely.

**Example:**
```bash
ansible-vault edit vault/shared.vault.yml
ansible-vault encrypt vault/dev.vault.yml
```

### ansible

Execute ad-hoc commands on remote hosts without writing a playbook. Useful for quick tasks like checking connectivity or gathering facts.

**Example:**
```bash
ansible all -m ping
ansible server-225-wsl -a "uptime"
```

### ansible-galaxy

Install, manage, and share Ansible roles and collections from Ansible Galaxy or other sources. Helps organize and reuse automation code.

**Example:**
```bash
ansible-galaxy install geerlingguy.docker
ansible-galaxy collection install community.general
```

### ansible-config

View and manage Ansible configuration settings. Useful for inspecting current configuration and understanding how Ansible is configured.

**Example:**
```bash
ansible-config view
ansible-config dump
```

### ansible-inventory

Display or transform Ansible inventory information. Helps visualize which hosts are available and how they're organized.

**Example:**
```bash
ansible-inventory --list
ansible-inventory --graph
```

### ansible-console

Interactive console for executing Ansible ad-hoc commands. Provides a REPL-like environment for exploring and testing Ansible commands.

**Example:**
```bash
ansible-console
# Then in the console:
all> ping
server-225-wsl> shell uptime
```

### ansible-doc

Display documentation for Ansible modules, plugins, and roles. Essential reference tool for understanding what modules do and how to use them.

**Example:**
```bash
ansible-doc ping
ansible-doc -l  # List all modules
```

### ansible-pull

Pull playbooks from a version control repository and execute them locally on managed nodes. Used for pull-based deployment models.

**Example:**
```bash
ansible-pull -U https://github.com/user/repo.git playbook.yml
```

## How It Works

The aliases are implemented as shell functions that:
1. Detect the repository root (works in both bash and zsh)
2. Activate the virtual environment if not already active
3. Set up the Ansible environment (config, inventory, working directory)
4. Execute the requested Ansible command with all arguments passed through

## Benefits

- **Direct access**: Use standard Ansible commands without typing `fz` first
- **Consistent environment**: Always uses the correct venv, config, and inventory
- **Shell integration**: Works with tab completion and shell history
- **Portable**: Aliases work from any directory once sourced

## Notes

- The aliases file (`.fz_aliases.sh`) is generated in the repo root and should not be committed to version control
- If the virtual environment doesn't exist, the aliases will warn you to run `fz verify` first
- The aliases automatically handle vault password files configured in `ansible.cfg`
- All commands use the inventory file at `inventory/inventory.yaml` automatically

## Troubleshooting

**Aliases not working:**
- Make sure you've sourced the `.fz_aliases.sh` file
- Check that the virtual environment exists (run `fz verify` to create it)

**Command not found:**
- Ensure the virtual environment has Ansible installed
- Run `fz verify` to ensure dependencies are installed

**Wrong directory:**
- The aliases automatically change to the repo root, so you can run commands from anywhere
- If you need to run commands in a different directory, use `cd` after the command or use `fz` directly

