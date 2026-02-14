# Local and Remote Execution Guide

This guide explains how to run Ansible playbooks both locally (on the target server) and remotely (from a control node like mac-dev).

## Overview

The inventory now supports both local and remote execution modes:

- **Local execution**: Run playbooks directly on the target server to bootstrap WinRM/SSH
- **Remote execution**: Run playbooks from a control node (mac-dev) to manage servers remotely

## Inventory Structure

### Local Execution Targets

The inventory includes localhost entries for each physical node:

- `localhost-server-225` - Run locally on server-225
- `localhost-network-server` - Run locally on network-server
- `localhost-dev-3090` - Run locally on dev-3090
- `localhost-mac-dev` - Run locally on mac-dev

### Remote Execution Targets

The inventory includes remote surface entries:

- `server-225-win` - WinRM connection to server-225
- `server-225-wsl` - SSH connection to server-225 WSL
- `network-server-win` - WinRM connection to network-server
- `dev-3090-win` - WinRM connection to dev-3090
- `dev-3090-wsl` - SSH connection to dev-3090 WSL
- `mac-dev` - SSH connection to mac-dev

## Bootstrap Workflow

### Step 1: Bootstrap WinRM/SSH Locally

On each Windows server, run the local bootstrap playbook to enable remote management:

```bash
# On server-225, network-server, or dev-3090
cd /path/to/dotfile-vnext
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-<node>
```

Examples:
```bash
# On server-225
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-server-225

# On network-server
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-network-server

# On dev-3090
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-dev-3090
```

This will:
- Configure WinRM for remote management (ports 5985/5986)
- Configure OpenSSH Server for remote management (port 22)
- Open necessary firewall ports

### Step 2: Run Playbooks Remotely

After local bootstrap, you can run playbooks remotely from mac-dev:

```bash
# From mac-dev
cd /path/to/dotfile-vnext
./bin/fz bootstrap --limit server-225-win --ask-vault-pass
```

## Playbook Execution Modes

### Local Execution

Use local execution when:
- Bootstrapping WinRM/SSH for the first time
- Running on the server itself
- No remote access is available yet

**Connection**: `connection: local`

**Target**: `localhost-<node>` inventory entries

**Example**:
```yaml
- name: Setup WinRM locally
  hosts: localhost-server-225
  connection: local
  roles:
    - role: common/winrm_setup
```

### Remote Execution

Use remote execution when:
- Managing servers from a control node
- WinRM/SSH is already configured
- Standard operational workflows

**Connection**: `winrm` (Windows) or `ssh` (Linux/WSL)

**Target**: `<node>-win` or `<node>-wsl` inventory entries

**Example**:
```yaml
- name: Bootstrap server remotely
  hosts: server-225-win
  vars_files:
    - ../vault/connection.vault.yml
  roles:
    - role: common/baseline
```

## Roles Supporting Both Modes

### WinRM Setup Role

- **Local**: `common/winrm_setup` - Configures WinRM when run locally
- **Remote**: WinRM is used automatically when targeting `-win` hosts

### SSH Setup Role

- **Local**: `common/ssh_setup` - Configures SSH when run locally
- **Remote**: SSH is used automatically when targeting `-wsl` hosts

### Other Roles

Most roles work with both local and remote execution:
- `common/baseline` - Works remotely via WinRM
- `server_225/windows_base` - Works remotely via WinRM
- `dev_3090/ssh` - Works remotely via WinRM (configures SSH)

## Usage Examples

### Bootstrap a New Server

1. **On the server** (local):
   ```bash
   ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-server-225
   ```

2. **From mac-dev** (remote):
   ```bash
   ./bin/fz bootstrap --limit server-225-win --ask-vault-pass
   ```

### Run Regular Operations

All regular operations use remote execution:

```bash
# Deploy stacks
./bin/fz deploy main --ask-vault-pass

# Verify fabric
./bin/fz verify --ask-vault-pass

# Run health checks
./bin/fz health --ask-vault-pass
```

## Connection Requirements

### Local Execution

- PowerShell (Windows) or Bash (Linux/macOS)
- Administrative privileges
- Ansible installed on the target server

### Remote Execution

- WinRM configured (for Windows hosts)
- SSH configured (for Linux/WSL hosts)
- Network connectivity
- Authentication credentials in vault

## Troubleshooting

### WinRM Not Accessible

If WinRM is not accessible remotely, run the local bootstrap:

```bash
# On the Windows server
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-<node>
```

### SSH Not Accessible

If SSH is not accessible remotely, run the local bootstrap:

```bash
# On the Windows server
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_local_winrm_ssh.yaml --limit localhost-<node>
```

### Connection Timeout

Check firewall rules and network connectivity:

```bash
# Test WinRM connectivity
ansible server-225-win -i inventory/inventory.yaml -m win_ping --ask-vault-pass

# Test SSH connectivity
ansible server-225-wsl -i inventory/inventory.yaml -m ping
```

## Summary

- **Local execution**: Use `localhost-<node>` targets with `connection: local`
- **Remote execution**: Use `<node>-win` or `<node>-wsl` targets with standard connections
- **Bootstrap first**: Run local bootstrap to enable remote management
- **Then go remote**: Use remote execution for all regular operations


