# WinRM Setup Role

Configures WinRM for remote management when running locally on Windows servers.

## Purpose

This role sets up WinRM (Windows Remote Management) on a Windows host when executed locally. It's designed to be run with `connection: local` to bootstrap WinRM before remote management is possible.

## Usage

### Local Execution

Run this role locally on a Windows server to enable WinRM for remote access:

```yaml
- name: Setup WinRM locally
  hosts: localhost-server-225
  connection: local
  roles:
    - role: common/winrm_setup
```

### What It Does

1. **Checks Windows environment** - Verifies the role is running on Windows
2. **Starts WinRM service** - Ensures WinRM service is running and set to auto-start
3. **Configures WinRM listeners** - Sets up HTTPS (5986) and HTTP (5985) listeners
4. **Configures authentication** - Sets up NTLM/Kerberos authentication
5. **Opens firewall ports** - Creates firewall rules for ports 5985 and 5986

## Requirements

- Must be run locally on a Windows host (`connection: local`)
- Requires PowerShell and administrative privileges
- Windows must support WinRM (Windows 7+ / Windows Server 2008+)

## After Running

Once this role completes, you can connect remotely using:

```bash
ansible-playbook -i inventory/inventory.yaml playbooks/bootstrap_server_225.yaml --limit server-225-win
```

## Notes

- The role creates a self-signed certificate for HTTPS if none exists
- Firewall rules are created/updated to allow WinRM traffic
- The role is idempotent - safe to run multiple times


