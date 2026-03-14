# Deploy Shell Configuration

This guide explains how to deploy shell configuration (direnv, cursor editor, aliases, PATH management) to your development environment using the standalone `deploy_shell_config.yaml` playbook.

## Overview

The `deploy_shell_config.yaml` playbook **creates and owns** your bash setup. Run the playbook; no manual steps. It configures:

- **`.bash_profile`**: Managed by Ansible; sources `~/.bashrc` so login shells (e.g. macOS Terminal) get the same config
- **`.bashrc`**: Managed by Ansible; sources all `~/.bashrc.d/*.bash` files
- **`.bashrc.d/`**: Modular directory; each role adds its own `*.bash` file
  - **direnv**: `~/.bashrc.d/direnv.bash` — `eval "$(direnv hook bash)"`
  - **cursor**: `~/.bashrc.d/cursor.bash` — `EDITOR="cursor --wait"`
  - **shell_config**: `path.bash`, `aliases.bash` — PATH and common aliases
- **PATH management**: WSL-specific PATH prioritization (Linux binaries before Windows)

## Prerequisites

- Repository cloned and accessible
- Virtual environment set up (`.venv` exists)
- Inventory configured with target host
- Vault password file (if using encrypted vaults)

## Quick Start

### Deploy to Mac (mac-dev)

```bash
cd /Users/joshc/develop/dotfile-vnext
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev
```

### Deploy to WSL (server-225-wsl)

```bash
cd /Users/joshc/develop/dotfile-vnext
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit server-225-wsl
```

## Detailed Usage

### Using run-playbook.sh (Recommended)

The `bin/run-playbook.sh` wrapper provides:
- Automatic logging to `logs/runs/`
- Inventory validation
- Virtual environment setup
- Consistent error handling

**Basic syntax:**
```bash
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit <host>
```

**With additional Ansible arguments:**
```bash
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml \
  --limit mac-dev \
  --check \
  --diff
```

**Common options:**
- `--limit <host>`: Target specific host (mac-dev, server-225-wsl, etc.)
- `--check`: Dry-run mode (see what would change)
- `--diff`: Show differences
- `--ask-vault-pass`: Prompt for vault password
- `--vault-password-file <file>`: Use vault password file

### What Gets Deployed

The playbook runs three roles in order:

1. **`common/shell_config`**
   - Creates `~/.bashrc.d/` directory
   - Ensures `~/.bash_profile` sources `~/.bashrc` (so login shells get the same config)
   - Adds sourcing block to `.bashrc` so it runs all `~/.bashrc.d/*.bash` (non-destructive)
   - Deploys `path.bash` (WSL PATH prioritization)
   - Deploys `aliases.bash` (common aliases)

2. **`direnv`**
   - Installs direnv via package manager (Homebrew on Mac, apt on Ubuntu)
   - Deploys `direnv.bash` with `eval "$(direnv hook bash)"`

3. **`cursor`**
   - Deploys `cursor.bash` with `export EDITOR="cursor --wait"`

## After Deployment

### Activate Configuration

Reload your shell so the new config is used:

```bash
source ~/.bashrc
# or
source ~/.bash_profile
# or open a new terminal
```

### Verify Installation

```bash
# Check direnv is installed
which direnv

# Check direnv hook is loaded
type direnv
# Should show: direnv is a function

# Check .bashrc.d exists
ls -la ~/.bashrc.d/
# Should show: path.bash, aliases.bash, direnv.bash, cursor.bash

# Check EDITOR is set
echo $EDITOR
# Should show: cursor --wait
```

## Using direnv

### Create .envrc File

In any project directory, create a `.envrc` file:

```bash
cd ~/my-project
cat > .envrc << 'EOF'
export PROJECT_NAME="my-project"
export API_KEY="secret-key"
export DATABASE_URL="postgresql://localhost/mydb"
EOF
```

### Allow direnv

First time in a directory, you must allow direnv:

```bash
direnv allow
```

### Automatic Loading

After `direnv allow`:
- **Entering the directory**: Environment variables are automatically loaded
- **Leaving the directory**: Environment variables are automatically unloaded

### Example Workflow

```bash
# Create test directory
mkdir -p ~/test-direnv
cd ~/test-direnv

# Create .envrc
echo 'export TEST_VAR="hello from direnv"' > .envrc

# Allow it (first time only)
direnv allow

# Check variable is set
echo $TEST_VAR
# Output: hello from direnv

# Leave directory
cd ~

# Check variable is unset
echo $TEST_VAR
# Output: (empty)
```

## Troubleshooting

### direnv Not Found

If `which direnv` returns nothing:

1. Check the playbook ran successfully:
   ```bash
   ansible-playbook playbooks/deploy_shell_config.yaml --limit mac-dev --check
   ```

2. Verify direnv was installed:
   ```bash
   # On Mac
   brew list direnv
   
   # On Ubuntu/WSL
   dpkg -l | grep direnv
   ```

3. Re-run the playbook:
   ```bash
   ./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev
   ```

### Hook Not Loading

If `type direnv` shows "not found":

1. Check `.bashrc` sources `.bashrc.d`:
   ```bash
   grep -A 5 "bashrc.d" ~/.bashrc
   ```

2. Check `direnv.bash` exists:
   ```bash
   ls -la ~/.bashrc.d/direnv.bash
   ```

3. Manually source it:
   ```bash
   source ~/.bashrc.d/direnv.bash
   type direnv  # Should now show it's a function
   ```

### PATH Issues in WSL

If Windows binaries are being used instead of Linux versions:

1. Check `path.bash` is deployed:
   ```bash
   cat ~/.bashrc.d/path.bash
   ```

2. Verify it's being sourced:
   ```bash
   source ~/.bashrc.d/path.bash
   which hub  # Should show /usr/bin/hub, not /mnt/c/...
   ```

## Idempotency

The playbook is **idempotent** - safe to run multiple times:

- Existing configurations are not overwritten unnecessarily
- Only missing or changed items are updated
- Safe to re-run after manual changes

## Logs

Playbook runs are logged to:
```
logs/runs/YYYYMMDD_HHMMSS_deploy_shell_config/
├── run.log              # Full playbook output
└── ansible.log          # Ansible controller log
```

## Related Documentation

- `roles/common/shell_config/README.md` - Shell config role details
- `roles/direnv/README.md` - Direnv role details
- `roles/cursor/README.md` - Cursor role details
- `docs/operator_runbook.md` - General operational workflow

## Quick Reference

| Operation | Command |
|-----------|---------|
| Deploy to Mac | `./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev` |
| Deploy to WSL | `./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit server-225-wsl` |
| Dry-run | Add `--check` flag |
| Show differences | Add `--diff` flag |
| Reload shell | `source ~/.bashrc` |
| Verify direnv | `type direnv` |
| Check config files | `ls -la ~/.bashrc.d/` |
