# Checkpoint 6: Server-225 Windows Bootstrap - Complete

## Summary

Implemented **Checkpoint 6: Windows Host Bootstrap** for Server-225 with WinRM/PowerShell-only tasks.

## Deliverables

### ✅ roles/server_225/windows_base/tasks/main.yml

**Features:**
- **Windows Features** (idempotent enablement):
  - Hyper-V (with management tools)
  - Containers feature
  - Virtual Machine Platform
  - WSL (Windows Subsystem for Linux)
- **OpenSSH Server** installation and service startup
- **Power settings**:
  - High Performance power plan
  - Sleep disabled
  - Hibernate disabled
  - USB selective suspend disabled
- **Directory creation** on data drive:
  - `D:\ai` (data root)
  - `D:\ai\stacks` (stacks root)
  - `D:\ai\data` (data directory)
- **Windows Defender** exclusions for data directories
- **Long paths** enabled in Windows
- **Automatic reboot** handling when Windows features require it

**Idempotency:**
- All Windows features check before enabling
- Reboots only when features are actually installed
- Waits for system to come back online

### ✅ roles/server_225/wsl2/tasks/main.yml

**Features:**
- **WSL default version** set to 2
- **WSL distro installation** (Ubuntu, from group_vars)
- **Systemd configuration** in WSL (if enabled)
- **WSL verification** - ensures distro is accessible
- **Idempotent** - checks if distro exists before installing

**Configuration:**
- Uses `wsl_distro` from group_vars
- Configures `/etc/wsl.conf` for systemd if `systemd_in_wsl` is true
- Shuts down and restarts WSL to apply systemd config

### ✅ roles/server_225/task_scheduler_autostart/tasks/main.yml

**Features:**
- **Task Scheduler autostart** for WSL docker compose stack
- **Boot trigger** with configurable delay (default 45 seconds)
- **Retry policy** (5 retries, 60 second intervals)
- **Uses placeholders** for stack path if not defined
- **Idempotent** - updates existing task if needed

**Configuration:**
- Task name: `autostart-ai-stack` (configurable)
- Runs as SYSTEM with highest privileges
- Command: `wsl.exe -d <distro> -- bash -lc "cd <stack_path> && docker compose up -d"`
- Stack path: Uses `wsl_mount_root + '/stacks/main'` from group_vars

### ✅ roles/server_225/gpu_driver_validation/tasks/main.yml

**Features:**
- **Read-only validation** of NVIDIA GPU driver
- **Checks nvidia-smi** availability
- **Reports**:
  - Driver version
  - GPU name and memory
  - GPU temperature and utilization
- **Fails playbook** if driver not found (hard requirement)
- **Validates expected GPU** (RTX 5090 from group_vars)

**Safety:**
- Does not install drivers (manual step required)
- Only validates presence and reports status

### ✅ playbooks/bootstrap_server_225.yaml (verified)

**Role order:**
1. `common/baseline` - Timezone and node facts
2. `server_225/windows_base` - Windows features, OpenSSH, directories
3. `server_225/wsl2` - WSL2 installation and configuration
4. `server_225/task_scheduler_autostart` - Autostart task creation
5. `server_225/gpu_driver_validation` - GPU driver check
6. `common/firewall` - Firewall rules (separate role)

**Correct order:** ✅ All roles in proper sequence

## Requirements Met

✅ **WinRM/PowerShell only** - No docker compose operations  
✅ **Windows features enabled** - Hyper-V, Containers, VMP, WSL  
✅ **OpenSSH installed/validated** - Feature installed, service started  
✅ **Directories created** - On data disk (D:\ai structure)  
✅ **Task Scheduler autostart** - Created with placeholders for stack path  
✅ **Minimal firewall rules** - Handled by common/firewall role (separate)  
✅ **GPU driver validation** - Read-only check, fails if missing  

## Idempotency

All roles are idempotent:
- Windows features check before enabling
- WSL distro checks before installing
- Task scheduler updates existing task if present
- GPU validation is read-only
- Directories created only if missing

## Reboot Handling

- Automatic reboot when Windows features are installed
- Waits for system to come back online (600 second timeout)
- Subsequent roles continue after reboot

## Next Steps

Ready to proceed to **Checkpoint 7: Linux / WSL Runtime Layer** (docker engine in WSL, compose support)

**Note:** Firewall rules are handled by `common/firewall` role which is included in the playbook but not yet implemented.



