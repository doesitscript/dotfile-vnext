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

```bash
# Bootstrap server-225 (main node)
./bin/fz bootstrap

# Bootstrap network-server and dev-3090 (Windows nodes)
./bin/fz bootstrap-winrm

# WSL bootstrap is handled automatically via SSH after Windows bootstrap
./bin/fz bootstrap-ssh  # Just shows info message
```

### Deploy

Deploy stacks to specific nodes.

```bash
# Deploy main stacks (server-225)
./bin/fz deploy main

# Deploy network stacks (network-server)
./bin/fz deploy network

# Deploy dev stacks (dev-3090)
./bin/fz deploy dev
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

### Contract

Lint and validate the contract file.

```bash
# Lint the contract YAML
./bin/fz contract lint
```

### Vault

Edit encrypted vault files.

```bash
# Edit shared vault (prompts for password)
./bin/fz vault edit shared

# Edit network vault with password file
./bin/fz vault edit network --vault-password-file ~/.vault_pass

# Edit main vault (prompts for password)
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

```bash
# See what would change without making changes
./bin/fz deploy main --check

# Show differences
./bin/fz deploy network --check --diff
```

### Vault Password

```bash
# Prompt for vault password
./bin/fz deploy network --ask-vault-pass

# Use vault password file
./bin/fz deploy network --vault-password-file ~/.vault_pass

# If .vault_pass exists in repo root, it's used automatically
```

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

