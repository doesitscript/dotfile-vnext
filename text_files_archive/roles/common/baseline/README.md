# Common Baseline Role

Sets timezone and creates node facts file for all nodes.

## What it does

1. **Timezone enforcement**: Sets timezone from contract (`America/Chicago`) on all platforms
   - macOS: Uses `systemsetup`
   - Windows: Uses `win_timezone` module
   - Linux/WSL: Uses `timezone` module

2. **Node facts file**: Creates a JSON file with node identity information
   - Location per OS:
     - macOS/Linux: `/etc/fuzlang/node_facts.json`
     - Windows: `C:\ProgramData\fuzlang\node_facts.json`
   - Contains: hostname, FQDN, OS info, timezone, IP addresses, physical node, surface type

## Requirements

- Timezone variable from `group_vars/all.yaml`
- Physical node and surface type from inventory

## Idempotency

- Timezone setting is idempotent (only changes if different)
- Node facts file is overwritten each run (always current)

## Safety

- No firewall changes
- No package installations
- No service modifications
- Read-only verification of timezone after setting



