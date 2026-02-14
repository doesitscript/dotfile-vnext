# FuzLang Infrastructure CLI Tools

The `bin/fz` script provides a convenient command-line interface for managing the FuzLang infrastructure using Ansible.

## Prerequisites

- macOS (scripts run from mac-dev)
- Python 3.8+ (for virtual environment)
- Bash 4.0+

## Setup

The first time you run `bin/fz`, it will automatically:
1. Create a Python virtual environment (`.venv`) in the repo root
2. Install required Python dependencies from `scripts/requirements.txt`
3. Activate the virtual environment for subsequent commands

No manual setup required!

## Usage

```bash
./bin/fz <command> [options]
```

## Commands

### Bootstrap

Bootstrap nodes to prepare them for stack deployment.

**Guardrails:** Bootstrap commands require `--limit` or `--all` to prevent accidental execution on all hosts.

```bash
# Bootstrap server-225 (main node) - REQUIRES --limit or --all
./bin/fz bootstrap --limit server-225-win

# Bootstrap network-server and dev-3090 (Windows nodes) - REQUIRES --limit or --all
./bin/fz bootstrap-winrm --limit network-server-win

# Bootstrap all nodes
./bin/fz bootstrap-winrm --all

# WSL bootstrap is handled automatically via SSH after Windows bootstrap
./bin/fz bootstrap-ssh --limit server-225-wsl
```

### Deploy

Deploy stacks to specific nodes.

**Guardrails:** 
- All deploy commands require `--limit` or `--all`
- Network deployment requires confirmation (use `--yes` to skip)

```bash
# Deploy main stacks (server-225) - REQUIRES --limit or --all
./bin/fz deploy main --limit server-225-wsl

# Deploy network stacks (network-server) - REQUIRES --limit or --all and confirmation
./bin/fz deploy network --limit network-server-win
# Will prompt: "Continue with network deployment? [y/N]:"

# Skip confirmation for network deployment
./bin/fz deploy network --limit network-server-win --yes

# Deploy dev stacks (dev-3090) - REQUIRES --limit or --all
./bin/fz deploy dev --limit dev-3090-wsl
```

### Verify

Verify the entire fabric is correctly configured.

```bash
# Verify all nodes
./bin/fz verify

# Verify specific hosts
./bin/fz verify --limit server-225-win

# Verify in check mode (dry-run)
./bin/fz verify --check
```

### Init

Generate aliases for Ansible commands to use them directly without the `fz` prefix.

```bash
# Generate aliases file
./bin/fz init

# Source the aliases (or add to your shell profile)
source .fz_aliases.sh
```

After sourcing, you can use ansible commands directly:
- `ansible-playbook playbooks/verify_fabric.yaml --limit server-225-wsl`
- `ansible-vault edit vault/shared.vault.yml`
- `ansible all -m ping`

See [fz_init.md](./fz_init.md) for detailed documentation and explanations of all available Ansible commands.

### Contract

Lint and validate the contract file.

```bash
# Lint the contract YAML (shows summary of nodes, surfaces, endpoints, ports)
./bin/fz contract lint
```

The lint command:
- Validates YAML syntax
- Loads and parses the contract
- Prints a summary:
  - Node names
  - Surfaces (WSL2, Windows, etc.)
  - Key endpoints
  - Declared ports count
  - Contract version and name
- Never prints secret values

### Vault

Manage encrypted vault files.

#### Bootstrap Vault Password

Set up the vault password file for automatic password usage:

```bash
# Create ~/.vault_pass (prompts for password)
./bin/fz vault bootstrap
```

#### Encrypt Vault Files

Encrypt unencrypted vault files:

```bash
# Encrypt shared vault (uses ~/.vault_pass if available)
./bin/fz vault encrypt shared

# Encrypt network vault
./bin/fz vault encrypt network

# Encrypt connection vault
./bin/fz vault encrypt connection
```

#### Edit Vault Files

Edit encrypted vault files:

```bash
# Edit shared vault (uses ~/.vault_pass automatically)
./bin/fz vault edit shared

# Edit network vault with explicit password file
./bin/fz vault edit network --vault-password-file ~/.vault_pass

# Edit main vault (prompts for password if no file found)
./bin/fz vault edit main --ask-vault-pass

# Edit dev vault
./bin/fz vault edit dev
```

## Common Options

All commands forward these options to `ansible-playbook`:

### Limiting Execution

```bash
# Run only on specific hosts
./bin/fz verify --limit server-225-win
./bin/fz deploy network --limit network-server-win

# Run on multiple hosts
./bin/fz verify --limit "server-225-win:network-server-win"
```

### Tags

```bash
# Run only tasks with specific tags
./bin/fz deploy network --tags stacks_network

# Skip tasks with specific tags
./bin/fz bootstrap --skip-tags firewall
```

### Check Mode (Dry-Run)

When using `--check`, a clear message is displayed indicating no changes will be applied.

```bash
# See what would change without making changes
./bin/fz deploy main --check
# Output: "CHECK MODE: No changes will be applied"

# Show differences
./bin/fz deploy network --check --diff
```

### Vault Password

```bash
# Prompt for vault password
./bin/fz deploy network --ask-vault-pass

# Use vault password file
./bin/fz deploy network --vault-password-file ~/.vault_pass

# Use ANSIBLE_VAULT_PASSWORD_FILE environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
./bin/fz deploy network

# If .vault_pass exists in repo root, it's used automatically
```

### Vault Management

Edit vault files securely using your preferred editor:

```bash
# Edit shared vault (uses $EDITOR, falls back to vim)
./bin/fz vault edit shared

# Edit network vault
./bin/fz vault edit network

# Edit main vault
./bin/fz vault edit main

# Edit dev vault
./bin/fz vault edit dev
```

**Vault Password File Recommendations:**
- Store vault password files outside the repository
- Use `ANSIBLE_VAULT_PASSWORD_FILE` environment variable for convenience
- Never commit password files to version control
- Use a secure location like `~/.vault_pass` with `chmod 600`

The vault edit command:
- Opens the encrypted vault file in your `$EDITOR` (or vim if not set)
- Never decrypts secrets to stdout
- Uses `ANSIBLE_VAULT_PASSWORD_FILE` if set, otherwise prompts interactively
- Falls back to `.vault_pass` in repo root if available

### Verbosity

```bash
# More verbose output
./bin/fz verify -v      # Verbose
./bin/fz verify -vv     # More verbose
./bin/fz verify -vvv    # Debug
./bin/fz verify -vvvv   # Connection debug
```

### Other Options

```bash
# Start at specific task
./bin/fz bootstrap --start-at-task "Install OpenSSH"

# Step through tasks one at a time
./bin/fz deploy network --step

# Connection timeout
./bin/fz verify --connection-timeout 30

# Parallel execution
./bin/fz verify --forks 5
```

## Examples

### Complete Bootstrap Flow

```bash
# 1. Bootstrap main node
./bin/fz bootstrap

# 2. Bootstrap network and dev nodes
./bin/fz bootstrap-winrm

# 3. Deploy network stacks
./bin/fz deploy network --ask-vault-pass

# 4. Deploy main stacks
./bin/fz deploy main --ask-vault-pass

# 5. Verify everything
./bin/fz verify
```

### Selective Deployment

```bash
# Deploy only network stacks with specific tags
./bin/fz deploy network --tags stacks_network --limit network-server-win

# Check what would change
./bin/fz deploy network --check --diff
```

### Vault Management

```bash
# Edit shared vault (prompts for password)
./bin/fz vault edit shared

# Edit network vault with password file
./bin/fz vault edit network --vault-password-file ~/.vault_pass
```

### Verification

```bash
# Verify entire fabric
./bin/fz verify

# Verify specific hosts
./bin/fz verify --limit server-225-win

# Verify only Windows hosts
./bin/fz verify --limit windows_hosts

# Verify in check mode
./bin/fz verify --check
```

## Vault Password File

You can create a `.vault_pass` file in the repo root to avoid typing the vault password each time:

```bash
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

**Recommended:** Store vault password files outside the repository:

```bash
# Store in home directory
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Use environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
```

**Important:** Never commit password files to version control. Add `.vault_pass` to `.gitignore` if storing in repo root.

## macOS Notifications

If `terminal-notifier` is installed, the CLI will send macOS notifications on successful completion of:
- Bootstrap operations
- Deploy operations  
- Verify operations

Install with:
```bash
brew install terminal-notifier
```

Notifications are optional - the CLI works fine without it.

**Important:** Add `.vault_pass` to `.gitignore` to avoid committing it!

The script will automatically use this file if it exists, unless you explicitly specify `--ask-vault-pass` or `--vault-password-file`.

## Idempotency

All scripts are designed to be idempotent - you can run them multiple times safely. They will:
- Only make changes when needed
- Report what changed
- Not cause errors on subsequent runs

## Fail Fast

Scripts use `set -euo pipefail` to:
- Exit immediately on errors
- Fail on undefined variables
- Fail if any command in a pipeline fails

This ensures you catch issues early rather than having partial failures.

## Troubleshooting

### Virtual Environment Issues

If the virtual environment gets corrupted:

```bash
rm -rf .venv
./bin/fz verify  # Will recreate .venv automatically
```

### Connection Issues

If you have connection timeouts:

```bash
./bin/fz verify --connection-timeout 60
```

### Verbose Debugging

For detailed debugging:

```bash
./bin/fz verify -vvvv  # Maximum verbosity
```

## Integration with CI/CD

The scripts are designed to work in CI/CD pipelines:

```bash
# In CI, use password file
./bin/fz deploy network --vault-password-file "${VAULT_PASS_FILE}"

# Check mode for validation
./bin/fz verify --check
```

