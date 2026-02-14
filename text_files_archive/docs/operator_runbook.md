# Operator Runbook: Remote-First Workflow

This document describes the operational workflow for managing the FuzLang infrastructure using Ansible from mac-dev.

## Overview

The infrastructure uses a **remote-first workflow** with a dual-surface model:
- **WinRM** for Windows host management (initial bootstrap, Windows features, services)
- **SSH** for WSL2 and Linux operations (Docker, stack deployment, day-to-day operations)

## Workflow Phases

### Phase 1: Initial Bootstrap (WinRM-Only)

**Goal**: Enable SSH and WSL prerequisites on Windows hosts.

**Steps**:

1. **Bootstrap main node (server-225)**:
   ```bash
   ./bin/fz bootstrap --limit server-225-win
   ```
   - Enables Windows Features (Hyper-V, Containers, WSL)
   - Installs OpenSSH Server
   - Creates directory structure
   - Configures power settings
   - Validates GPU driver

2. **Bootstrap network and dev nodes**:
   ```bash
   ./bin/fz bootstrap-winrm
   ```
   - Bootstrap network-server (Windows Docker Engine)
   - Bootstrap dev-3090 (WSL2 Docker Engine)
   - Same steps as main node

**What happens**:
- Windows Features are enabled (may require reboot)
- OpenSSH Server is installed and started
- WSL2 is installed and configured
- Directories are created on data drives
- GPU drivers are validated

**After this phase**:
- SSH is available on all Windows hosts
- WSL2 is ready for Docker operations
- You can pivot to SSH-based control

### Phase 2: Pivot to SSH-Based Control

**Goal**: Use SSH for day-to-day operations and WSL operations.

**Why SSH?**
- Faster for repeated operations
- Better for WSL2 access
- More efficient for Docker operations
- Standard Linux tooling works

**Operations**:

1. **Deploy network stacks** (uses WinRM for Windows Docker):
   ```bash
   ./bin/fz deploy network --ask-vault-pass
   ```

2. **Deploy main stacks** (uses SSH for WSL2 Docker):
   ```bash
   ./bin/fz deploy main --ask-vault-pass
   ```

3. **Deploy dev stacks** (uses SSH for WSL2 Docker):
   ```bash
   ./bin/fz deploy dev --ask-vault-pass
   ```

**Day-to-day operations**:
- Stack updates: `./bin/fz deploy <target>`
- Verification: `./bin/fz verify`
- Vault editing: `./bin/fz vault edit <scope>`

### Phase 3: Verify After Reboot

**Goal**: Ensure infrastructure survives reboots and services come back online.

**After any reboot**:

1. **Verify entire fabric**:
   ```bash
   ./bin/fz verify
   ```

2. **Check specific nodes**:
   ```bash
   ./bin/fz verify --limit server-225-win
   ./bin/fz verify --limit network-server-win
   ```

**What gets verified**:
- Endpoint reachability (from mac-dev)
- Docker runtime location (WSL vs Windows)
- Scheduled task exists (server-225 autostart)
- Volume locations (not on OS disk)
- GPU validation (on GPU nodes)
- Secrets present (env keys exist)

## Common Operations

### Bootstrap a New Node

```bash
# Bootstrap main node
./bin/fz bootstrap

# Bootstrap network and dev nodes
./bin/fz bootstrap-winrm
```

### Deploy Stacks

```bash
# Deploy network stacks (Postgres, Redis, ClickHouse, MinIO, Langfuse)
./bin/fz deploy network --ask-vault-pass

# Deploy main stacks (Ollama, LiteLLM, OpenWebUI)
./bin/fz deploy main --ask-vault-pass

# Deploy dev stacks (optional dev_ollama, dev_litellm)
./bin/fz deploy dev --ask-vault-pass
```

### Verify Infrastructure

```bash
# Verify entire fabric
./bin/fz verify

# Verify specific hosts
./bin/fz verify --limit server-225-win

# Verify in check mode (dry-run)
./bin/fz verify --check
```

### Edit Vault Files

```bash
# Edit shared vault
./bin/fz vault edit shared --ask-vault-pass

# Edit network vault
./bin/fz vault edit network --ask-vault-pass

# Edit main vault
./bin/fz vault edit main --ask-vault-pass

# Edit dev vault
./bin/fz vault edit dev --ask-vault-pass
```

### Selective Operations

```bash
# Run only specific tags
./bin/fz deploy network --tags stacks_network

# Skip specific tags
./bin/fz bootstrap --skip-tags firewall

# Limit to specific hosts
./bin/fz verify --limit "server-225-win:network-server-win"
```

## Connection Methods

### WinRM (Windows Host Management)

**Used for**:
- Initial bootstrap
- Windows Features installation
- Windows service management
- Scheduled task creation
- Windows-specific configuration

**Connection details**:
- Port: 5986 (HTTPS)
- Transport: NTLM
- Certificate validation: Ignored (LAN-only)

**When to use**:
- First-time setup
- Windows feature changes
- Service configuration
- Scheduled task management

### SSH (WSL2 and Linux Operations)

**Used for**:
- WSL2 access
- Docker operations
- Stack deployment
- Day-to-day management
- Linux-specific tasks

**Connection details**:
- Port: 22
- User: WSL username
- Key-based or password auth

**When to use**:
- Stack deployment
- Docker operations
- WSL2 management
- Regular maintenance

## Troubleshooting

### Connection Issues

**WinRM connection fails**:
```bash
# Check connection timeout
./bin/fz bootstrap --connection-timeout 60

# Verbose output
./bin/fz bootstrap -vvv
```

**SSH connection fails**:
- Verify OpenSSH Server is running on Windows host
- Check SSH port (22) is accessible
- Verify WSL distro is accessible

### Reboot Handling

**After Windows feature installation**:
- Ansible automatically reboots if needed
- Waits for system to come back online
- Continues with remaining tasks

**Manual reboot**:
```bash
# Verify after reboot
./bin/fz verify
```

### Vault Password Issues

**No vault password file**:
- Script will prompt for password
- Use `--ask-vault-pass` explicitly

**Vault password file**:
```bash
# Create .vault_pass in repo root
echo "your-password" > .vault_pass
chmod 600 .vault_pass

# Script will use it automatically
./bin/fz deploy network
```

## Safety Features

### Idempotency

All operations are idempotent:
- Safe to run multiple times
- Only makes changes when needed
- Reports what changed

### Fail-Fast

Scripts use `set -euo pipefail`:
- Exit immediately on errors
- Fail on undefined variables
- Fail if any command in pipeline fails

### Check Mode

Test changes without applying:
```bash
./bin/fz deploy network --check --diff
```

## Best Practices

1. **Always verify after changes**:
   ```bash
   ./bin/fz verify
   ```

2. **Use check mode first**:
   ```bash
   ./bin/fz deploy network --check
   ```

3. **Limit scope when testing**:
   ```bash
   ./bin/fz deploy network --limit network-server-win --tags stacks_network
   ```

4. **Keep vault files encrypted**:
   - Never commit unencrypted vault files
   - Use `./bin/fz vault edit` to modify
   - Store vault password securely

5. **Document changes**:
   - Note any manual changes
   - Update contract if needed
   - Commit changes with clear messages

## Workflow Summary

```
1. Initial Bootstrap (WinRM)
   ↓
2. Enable SSH + WSL
   ↓
3. Pivot to SSH (day-to-day)
   ↓
4. Deploy Stacks
   ↓
5. Verify After Reboot
   ↓
6. Ongoing Maintenance (SSH)
```

## Quick Reference

| Operation | Command |
|-----------|---------|
| Bootstrap main | `./bin/fz bootstrap` |
| Bootstrap network/dev | `./bin/fz bootstrap-winrm` |
| Deploy network | `./bin/fz deploy network` |
| Deploy main | `./bin/fz deploy main` |
| Deploy dev | `./bin/fz deploy dev` |
| Verify fabric | `./bin/fz verify` |
| Edit vault | `./bin/fz vault edit <scope>` |
| Contract lint | `./bin/fz contract lint` |



