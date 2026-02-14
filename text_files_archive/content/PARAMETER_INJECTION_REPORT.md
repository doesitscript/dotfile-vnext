# Parameter Injection Review Report

## Summary
Reviewed all files for hardcoded values that should be placeholders or variables. Replaced all found instances.

## Files Modified

### 1. `inventory/inventory.yaml`
**Changes Made:**
- Replaced `ansible_user: Administrator` (3 instances) with `ansible_user: "<to_be_filled>"  # Windows admin username`
- Replaced `wsl_distro: Ubuntu` (3 instances) with `wsl_distro: "<to_be_filled>"  # WSL distro name (e.g., Ubuntu)`

**Location:**
- Lines 13, 23, 33: Windows admin usernames
- Lines 50, 59, 68: WSL distro names

### 2. `inventory/group_vars/main_server.yaml`
**Changes Made:**
- Replaced hardcoded drive letter `D:` with `<drive>` placeholder:
  - `windows_data_root: "D:\\ai"` → `windows_data_root: "<drive>:\\ai"  # example: D:\\ai`
  - `wsl_mount_root: "/mnt/d/ai"` → `wsl_mount_root: "/mnt/<drive>/ai"  # example: /mnt/d/ai`
  - `stacks_root: "D:\\ai\\stacks"` → `stacks_root: "<drive>:\\ai\\stacks"  # example: D:\\ai\\stacks`
  - `data_root: "D:\\ai\\data"` → `data_root: "<drive>:\\ai\\data"  # example: D:\\ai\\data`
- Replaced `wsl_distro: Ubuntu` with `wsl_distro: "<to_be_filled>"  # WSL distro name (e.g., Ubuntu)`

**Location:**
- Lines 11-14: Storage paths with drive letters
- Line 17: WSL distro name

### 3. `inventory/group_vars/dev_gpu.yaml`
**Changes Made:**
- Replaced `wsl_distro: Ubuntu` with `wsl_distro: "<to_be_filled>"  # WSL distro name (e.g., Ubuntu)`

**Location:**
- Line 17: WSL distro name

### 4. `contracts/fuzlang.contract.yaml`
**Changes Made:**
- Replaced hardcoded drive letter `D:` and `/mnt/d/` with `<drive>` placeholders:
  - `windows_data_root: "D:\\ai"` → `windows_data_root: "<drive>:\\ai"  # example: D:\\ai`
  - `wsl_mount_root: "/mnt/d/ai"` → `wsl_mount_root: "/mnt/<drive>/ai"  # example: /mnt/d/ai`
  - `stacks_root: "D:\\ai\\stacks"` → `stacks_root: "<drive>:\\ai\\stacks"  # example: D:\\ai\\stacks`
  - `data_root: "D:\\ai\\data"` → `data_root: "<drive>:\\ai\\data"  # example: D:\\ai\\data`
  - `docker_data_root_location: "inside wsl2 but bind mounts must point into /mnt/d/ai/data"` → `docker_data_root_location: "inside wsl2 but bind mounts must point into /mnt/<drive>/ai/data"`
  - `compose_execution_location: "inside wsl2, from /mnt/d/ai/stacks/<stack>"` → `compose_execution_location: "inside wsl2, from /mnt/<drive>/ai/stacks/<stack>"`
- Replaced `distro: Ubuntu` (2 instances) with `distro: "<to_be_filled>"  # WSL distro name (e.g., Ubuntu)`
- Replaced hardcoded distro in task scheduler args:
  - `args: '-d Ubuntu -- bash -lc "cd /mnt/d/ai/stacks/<primary_stack> && docker compose up -d"'` → `args: '-d <wsl_distro> -- bash -lc "cd /mnt/<drive>/ai/stacks/<primary_stack> && docker compose up -d"'`

**Location:**
- Lines 268-272: Storage paths for main_node
- Line 353: WSL distro in main_node_runtime
- Line 357: Compose execution location
- Line 368: Task scheduler args with distro and drive
- Line 389: WSL distro in dev_node_runtime

## Values Already Using Placeholders (No Changes Needed)

### IP Addresses
- All `ansible_host` values use `"<to_be_filled>"`
- All `lan_ip` values use `"<to_be_filled>"`

### Drive Letters (Network and Dev Nodes)
- `inventory/group_vars/network_server.yaml`: Already uses `<disk>` placeholder
- `inventory/group_vars/dev_gpu.yaml`: Already uses `<disk>` placeholder
- `contracts/fuzlang.contract.yaml`: Network and dev nodes already use `<disk>` or `<drive>` placeholders

### Exposure Decisions
- Contract contains recommendations (e.g., "localhost_only # recommended") but final decisions are documented as placeholders in the `missing_inputs` section
- No hardcoded final exposure decisions found

### Usernames
- WSL usernames already use `"<to_be_filled>"`
- macOS username already uses `"<to_be_filled>"`

## Summary of Placeholders Now Required

Before proceeding to role implementation, the following must be filled:

1. **IP Addresses/Hostnames:**
   - All `ansible_host` values in `inventory/inventory.yaml`
   - All `lan_ip` values in `inventory/host_vars/*.yaml`

2. **Usernames:**
   - Windows admin usernames (3 instances in `inventory/inventory.yaml`)
   - WSL usernames (2 instances in `inventory/inventory.yaml`)
   - macOS username (1 instance in `inventory/inventory.yaml`)

3. **Drive Letters:**
   - Server-225 drive letter (4 paths in `inventory/group_vars/main_server.yaml` and contract)
   - Network-server drive letter (already placeholder, but needs value)
   - Dev-3090 drive letter (already placeholder, but needs value)

4. **WSL Distro Names:**
   - Server-225 WSL distro (2 instances: inventory and contract)
   - Dev-3090 WSL distro (2 instances: inventory and contract)
   - Network-server WSL distro (if WSL runtime chosen)

5. **Exposure Decisions:**
   - Final exposure choice for litellm and ollama (localhost vs lan vs allowlist)
   - Network-server docker runtime choice (windows-docker-engine vs wsl2)

## Status
✅ **All hardcoded values have been replaced with placeholders**
✅ **No role implementation will proceed until parameters are confirmed**





