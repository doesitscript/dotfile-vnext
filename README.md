# FUZLANG Infrastructure

Multi-node AI infrastructure automation using Ansible.

## Structure

- `contracts/` - Canonical contract definitions
- `inventory/` - Ansible inventory and variables
- `playbooks/` - Ansible playbooks
- `roles/` - Ansible roles
- `stacks/` - Docker Compose stack definitions
- `vault/` - Encrypted secrets (Ansible Vault)
- `rendered/` - Generated configuration files

## Nodes

- **mac-dev**: Development control plane (macOS)
- **Server-225**: Primary GPU node (Windows Server 2025, RTX 5090)
- **network-server**: Storage and observability node (Windows Server 2025)
- **dev-3090**: Development GPU node (Windows 11, RTX 3090)

## Prerequisites for Windows Servers

Before running `bin/bootstrap-local.ps1` on a new Windows server, ensure:

1. **PowerShell Execution Policy**: Allow script execution (run as Administrator):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Repository Cloned**: The dotfile-vnext repository must be cloned to the target server (e.g., `D:\develop\dotfile-vnext`)

3. **Administrator Privileges**: The script must be run from an elevated PowerShell session (Run as Administrator)

4. **Network Access**: The server should have network connectivity for downloading WSL distributions if needed

The bootstrap script will automatically configure WinRM HTTPS, enable WSL features, and set up firewall rules. A reboot may be required after WSL features are enabled.

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.

## Contract

All configuration is driven by `contracts/fuzlang.contract.yaml`.



