# SSH Setup Role

Configures OpenSSH Server for remote management when running locally on Windows servers.

## Purpose

This role sets up OpenSSH Server on a Windows host when executed locally. It's designed to be run with `connection: local` to bootstrap SSH before remote management is possible.

## Usage

### Local Execution

Run this role locally on a Windows server to enable SSH for remote access:

```yaml
- name: Setup SSH locally
  hosts: localhost-server-225
  connection: local
  roles:
    - role: common/ssh_setup
```

### What It Does

1. **Checks Windows environment** - Verifies the role is running on Windows
2. **Installs OpenSSH Server** - Installs the OpenSSH.Server Windows feature
3. **Starts SSH service** - Ensures SSH service is running and set to auto-start
4. **Configures firewall** - Opens the SSH port (default 22) in Windows Firewall
5. **Verifies configuration** - Confirms SSH is ready for remote access

## Requirements

- Must be run locally on a Windows host (`connection: local`)
- Requires PowerShell and administrative privileges
- Windows 10 1809+ or Windows Server 2019+ (for built-in OpenSSH)

## After Running

Once this role completes, you can connect remotely using:

```bash
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_server_225.yaml --limit server-225-wsl
```

## Notes

- The role installs OpenSSH Server if not already installed
- Default SSH port is 22 (configurable via registry)
- SSH keys are recommended for authentication (password auth can be enabled if needed)
- The role is idempotent - safe to run multiple times


