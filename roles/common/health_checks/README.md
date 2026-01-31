# Health Checks Role

Read-only verification tasks that report node status.

## What it does

Reports:
1. **Hostname**: Current hostname of the node
2. **IP Addresses**: All IPv4 addresses (excluding loopback)
3. **Disk Free Space**: Available disk space information
4. **Node Facts File**: Verifies node facts file exists and reports path

## Platform Support

- macOS: Uses standard Unix commands
- Windows: Uses PowerShell commands
- Linux/WSL: Uses standard Linux commands

## Safety

- **Read-only**: No modifications to the system
- **Best-effort**: Failed checks don't fail the playbook
- **No changes**: All tasks have `changed_when: false`

## Usage

This role is typically run as part of `verify_fabric.yaml` to check the health of all nodes in the infrastructure.

## Output

All information is displayed via `debug` tasks, showing:
- Hostname
- IP addresses (comma-separated)
- Disk information (formatted per platform)
- Physical node and surface type
- Node facts file status

