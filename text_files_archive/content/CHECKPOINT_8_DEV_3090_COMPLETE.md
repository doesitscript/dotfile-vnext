# Checkpoint 8: Dev-3090 Bootstrap + Dev Stacks - Complete

## Summary

Implemented **Checkpoint 8: Dev-3090 Bootstrap + Dev Stacks** with dual runtime path support (WSL2 and Windows Docker Engine) and optional dev service deployment.

## Contract Revisit

**Docker Runtime Choice:**
- Contract recommends: `wsl2-ubuntu-docker-engine`
- Group vars default: `wsl2-ubuntu-docker-engine`
- **Implementation:** Both paths supported, guarded by `docker_runtime` variable
  - `wsl2-ubuntu-docker-engine` → WSL2 Docker Engine path
  - `windows-docker-engine` → Windows Docker Engine path

## Deliverables

### ✅ roles/dev_3090/windows_base/tasks/main.yml

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

### ✅ roles/dev_3090/ssh/tasks/main.yml

**Features:**
- **OpenSSH Server** verification and startup
- **SSH port** detection
- **SSH readiness** for WSL access
- **Idempotent** - ensures SSH is running

**Purpose:**
- Enables Ansible to connect to WSL via SSH
- Required for WSL2 Docker Engine path

### ✅ roles/dev_3090/wsl2_or_windows_docker_runtime/tasks/main.yml

**Features:**
- **Dual runtime path support**:
  - WSL2 Docker Engine path (default)
  - Windows Docker Engine path (alternative)
- **Runtime selection** based on `docker_runtime` variable
- **WSL2 Path**:
  - WSL default version set to 2
  - WSL distro installation (Ubuntu)
  - Systemd configuration in WSL
  - Docker Engine installation in WSL
  - Docker service management in WSL
  - Windows Docker Engine disabled (if configured)
- **Windows Path**:
  - Windows Docker Engine installation
  - Docker service management
  - Docker verification
- **Automatic reboot** handling for Windows Docker installation
- **Idempotent** - checks before installing

**Configuration:**
- Uses `docker_runtime` from group_vars to determine path
- WSL path uses `wsl_distro`, `systemd_in_wsl`, `docker_engine_in_wsl` variables
- Windows path uses standard Windows Docker installation

### ✅ roles/dev_3090/gpu_driver_validation/tasks/main.yml

**Features:**
- **Read-only validation** of NVIDIA GPU driver
- **Checks nvidia-smi** availability
- **Reports**:
  - Driver version
  - GPU name and memory (expected: RTX 3090)
  - GPU temperature and utilization
- **Fails playbook** if driver not found (hard requirement)
- **Validates expected GPU** (RTX 3090 from group_vars)

**Safety:**
- Does not install drivers (manual step required)
- Only validates presence and reports status

### ✅ roles/dev_3090/stacks_dev/tasks/main.yml

**Features:**
- **Optional service deployment**:
  - `dev_ollama` (optional, GPU-enabled)
  - `dev_litellm` (optional)
- **Dual runtime path support**:
  - WSL2 path: Uses SSH, shell commands, Linux paths
  - Windows path: Uses WinRM, win_shell, Windows paths
- **Port exposure** per contract (configurable):
  - Default: Restricted (localhost only)
  - Can be changed to LAN exposure via group_vars
- **Service dependencies**: LiteLLM depends on Ollama
- **Health checks** for all services
- **.env file template** (placeholder for Checkpoint 9 secrets)
- **Docker network** (`fuzlang_dev_net`) created
- **Idempotent** - uses `docker compose up -d`

**Configuration:**
- `deploy_dev_ollama`: Set to `true` to deploy (default: `false`)
- `deploy_dev_litellm`: Set to `true` to deploy (default: `false`)
- `dev_ollama_exposure`: Port binding (default: `127.0.0.1:11434:11434`)
- `dev_litellm_exposure`: Port binding (default: `127.0.0.1:4000:4000`)

**Endpoints (per contract):**
- Dev Ollama: `http://dev-3090:11434` (restricted by default)
- Dev LiteLLM: `http://dev-3090:4000` (restricted by default)

### ✅ playbooks/bootstrap_dev_3090.yaml (updated)

**Role order:**
1. `common/baseline` - Timezone and node facts
2. `dev_3090/windows_base` - Windows features, OpenSSH, directories
3. `dev_3090/ssh` - SSH configuration for WSL access
4. `dev_3090/wsl2_or_windows_docker_runtime` - Docker runtime (WSL2 or Windows)
5. `dev_3090/gpu_driver_validation` - GPU driver check
6. `common/firewall` - Firewall rules (separate role)

**Correct order:** ✅ All roles in proper sequence

### ✅ playbooks/deploy_dev_stacks.yaml (updated)

**Dual play support:**
- **Play 1**: Targets `dev-3090-wsl` (SSH) when `docker_runtime == 'wsl2-ubuntu-docker-engine'`
- **Play 2**: Targets `dev-3090-win` (WinRM) when `docker_runtime == 'windows-docker-engine'`

**Role:**
- `dev_3090/stacks_dev` - Deploys optional dev services

### ✅ inventory/group_vars/dev_gpu.yaml (updated)

**New variables:**
- `deploy_dev_ollama`: `false` (set to `true` to deploy)
- `deploy_dev_litellm`: `false` (set to `true` to deploy)
- `dev_ollama_exposure`: `127.0.0.1:11434:11434` (restricted by default)
- `dev_litellm_exposure`: `127.0.0.1:4000:4000` (restricted by default)

## Requirements Met

✅ **Dual runtime path support** - Both WSL2 and Windows Docker Engine paths implemented  
✅ **Guarded by variable** - Runtime choice controlled by `docker_runtime` variable  
✅ **Peer execution node** - Same automation maturity as server-225  
✅ **No authoritative storage** - Only dev stacks, no database services  
✅ **Optional dev services** - dev_ollama and dev_litellm are optional  
✅ **Secrets scope** - Uses placeholder .env files (will use vault/dev.vault.yml in Checkpoint 9)  
✅ **Port exposure per contract** - Restricted by default, configurable to LAN  
✅ **Idempotent** - All roles can be run multiple times safely  

## Runtime Path Selection

**WSL2 Docker Engine (default):**
- `docker_runtime: wsl2-ubuntu-docker-engine`
- Uses SSH connection to WSL
- Docker runs inside WSL2
- Windows Docker Engine disabled
- Stacks deployed via SSH to WSL

**Windows Docker Engine (alternative):**
- `docker_runtime: windows-docker-engine`
- Uses WinRM connection to Windows
- Docker runs natively on Windows
- Stacks deployed via WinRM to Windows

**Configuration:**
- Set `docker_runtime` in `inventory/group_vars/dev_gpu.yaml`
- Default: `wsl2-ubuntu-docker-engine` (per contract recommendation)

## Dev Stack Deployment

**Optional Services:**
- `dev_ollama`: GPU-enabled Ollama instance for dev/testing
- `dev_litellm`: LiteLLM gateway for dev/testing

**Deployment Control:**
- Set `deploy_dev_ollama: true` to deploy Ollama
- Set `deploy_dev_litellm: true` to deploy LiteLLM
- Both default to `false` (optional services)

**Port Exposure:**
- Default: Restricted (localhost only)
- Can be changed to LAN exposure:
  - `dev_ollama_exposure: "0.0.0.0:11434:11434"`
  - `dev_litellm_exposure: "0.0.0.0:4000:4000"`

## Next Steps

Ready to proceed to **Checkpoint 9: Secrets & Rendering Pipeline** (vault files, rendered .env files, verification updates)

**Note:** 
- Firewall rules are handled by `common/firewall` role (separate)
- Secrets will be rendered in Checkpoint 9 (currently using placeholder .env files)
- Dev stacks are optional and must be explicitly enabled via group_vars



