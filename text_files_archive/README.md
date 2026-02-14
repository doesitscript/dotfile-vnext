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

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.

## Contract

All configuration is driven by `contracts/fuzlang.contract.yaml`.





