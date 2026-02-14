# Parameter Injection Questionnaire

This questionnaire collects all values needed to replace placeholders in active configuration files for bootstrap/deploy steps.

---

## MAC-DEV NODE

### Q1: mac-dev connection address
- **Variable name**: `ansible_host` (in inventory)
- **Affects**: `inventory/inventory.yaml` (line 74)
- **Format**: IP address or hostname
- **Example**: `192.168.1.10` or `mac-dev.local`
- **Question**: What is the IP address or hostname for mac-dev?

### Q2: mac-dev SSH username
- **Variable name**: `ansible_user` (in inventory)
- **Affects**: `inventory/inventory.yaml` (line 76)
- **Format**: username string
- **Example**: `josh`
- **Question**: What is the SSH username for mac-dev?

---

## SERVER-225 NODE (Main Node)

### Q3: Server-225 WinRM connection address
- **Variable name**: `ansible_host` (server-225-win)
- **Affects**: `inventory/inventory.yaml` (line 11)
- **Format**: IP address or hostname
- **Example**: `192.168.1.225` or `Server-225`
- **Question**: What is the IP address or hostname for Server-225 WinRM access?

### Q4: Server-225 Windows admin username
- **Variable name**: `ansible_user` (server-225-win)
- **Affects**: `inventory/inventory.yaml` (line 13)
- **Format**: username string
- **Example**: `Administrator`
- **Question**: What is the Windows administrator username for Server-225?

### Q5: Server-225 WSL SSH connection address
- **Variable name**: `ansible_host` (server-225-wsl)
- **Affects**: `inventory/inventory.yaml` (line 44)
- **Format**: IP address or hostname (same as WinRM or forwarded port)
- **Example**: `192.168.1.225` or `Server-225`
- **Question**: What is the IP address or hostname for Server-225 WSL SSH access? (Usually same as WinRM)

### Q6: Server-225 WSL username
- **Variable name**: `ansible_user` (server-225-wsl)
- **Affects**: `inventory/inventory.yaml` (line 46)
- **Format**: username string
- **Example**: `ubuntu` or `user`
- **Question**: What is the WSL username for Server-225?

### Q7: Server-225 WSL distro name
- **Variable name**: `wsl_distro` (server-225-wsl)
- **Affects**: `inventory/inventory.yaml` (line 50), `inventory/group_vars/main_server.yaml` (line 17)
- **Format**: distro name string
- **Example**: `Ubuntu`
- **Question**: What is the WSL distro name installed on Server-225?

### Q8: Server-225 drive letter for data storage
- **Variable name**: `drive` (used in multiple paths)
- **Affects**: `inventory/group_vars/main_server.yaml` (lines 11-14)
  - `windows_data_root`: `"<drive>:\\ai"`
  - `wsl_mount_root`: `"/mnt/<drive>/ai"`
  - `stacks_root`: `"<drive>:\\ai\\stacks"`
  - `data_root`: `"<drive>:\\ai\\data"`
- **Format**: Single drive letter (uppercase for Windows, lowercase for WSL mount)
- **Example**: `D` (Windows) / `d` (WSL mount)
- **Question**: What drive letter will Server-225 use for AI data storage? (e.g., D for D:\ai)

### Q9: Server-225 LAN IP address
- **Variable name**: `lan_ip`
- **Affects**: `inventory/host_vars/server-225.yaml` (line 6)
- **Format**: IP address
- **Example**: `192.168.1.225`
- **Question**: What is the LAN IP address for Server-225?

---

## NETWORK-SERVER NODE

### Q10: network-server WinRM connection address
- **Variable name**: `ansible_host` (network-server-win)
- **Affects**: `inventory/inventory.yaml` (line 21)
- **Format**: IP address or hostname
- **Example**: `192.168.1.50` or `network-server`
- **Question**: What is the IP address or hostname for network-server WinRM access?

### Q11: network-server Windows admin username
- **Variable name**: `ansible_user` (network-server-win)
- **Affects**: `inventory/inventory.yaml` (line 23)
- **Format**: username string
- **Example**: `Administrator`
- **Question**: What is the Windows administrator username for network-server?

### Q12: network-server drive letter for data storage
- **Variable name**: `disk` (used in multiple paths)
- **Affects**: `inventory/group_vars/network_server.yaml` (lines 10, 11, 12, 16)
  - `windows_data_root`: `"<disk>:\\ai"`
  - `stacks_root`: `"<disk>:\\ai\\stacks"`
  - `data_root`: `"<disk>:\\ai\\data"`
  - `docker_data_root`: `"<disk>:\\docker-data"`
- **Format**: Single drive letter (uppercase)
- **Example**: `E` for E:\ai
- **Question**: What drive letter will network-server use for AI data storage? (e.g., E for E:\ai)

### Q13: network-server LAN IP address
- **Variable name**: `lan_ip`
- **Affects**: `inventory/host_vars/network-server.yaml` (line 6)
- **Format**: IP address
- **Example**: `192.168.1.50`
- **Question**: What is the LAN IP address for network-server?

### Q14: network-server Docker runtime choice
- **Variable name**: `docker_runtime`
- **Affects**: `inventory/group_vars/network_server.yaml` (line 6)
- **Format**: `windows-docker-engine` or `wsl2-ubuntu-docker-engine`
- **Example**: `windows-docker-engine`
- **Question**: Which Docker runtime will network-server use? (`windows-docker-engine` or `wsl2-ubuntu-docker-engine`)

**Note**: If you choose `wsl2-ubuntu-docker-engine`, you will also need to provide WSL connection details (similar to Q5, Q6, Q7 for Server-225).

---

## DEV-3090 NODE

### Q15: dev-3090 WinRM connection address
- **Variable name**: `ansible_host` (dev-3090-win)
- **Affects**: `inventory/inventory.yaml` (line 31)
- **Format**: IP address or hostname
- **Example**: `192.168.1.100` or `dev-3090`
- **Question**: What is the IP address or hostname for dev-3090 WinRM access?

### Q16: dev-3090 Windows admin username
- **Variable name**: `ansible_user` (dev-3090-win)
- **Affects**: `inventory/inventory.yaml` (line 33)
- **Format**: username string
- **Example**: `Administrator`
- **Question**: What is the Windows administrator username for dev-3090?

### Q17: dev-3090 WSL SSH connection address
- **Variable name**: `ansible_host` (dev-3090-wsl)
- **Affects**: `inventory/inventory.yaml` (line 53)
- **Format**: IP address or hostname (same as WinRM or forwarded port)
- **Example**: `192.168.1.100` or `dev-3090`
- **Question**: What is the IP address or hostname for dev-3090 WSL SSH access? (Usually same as WinRM)

### Q18: dev-3090 WSL username
- **Variable name**: `ansible_user` (dev-3090-wsl)
- **Affects**: `inventory/inventory.yaml` (line 55)
- **Format**: username string
- **Example**: `ubuntu` or `user`
- **Question**: What is the WSL username for dev-3090?

### Q19: dev-3090 WSL distro name
- **Variable name**: `wsl_distro` (dev-3090-wsl)
- **Affects**: `inventory/inventory.yaml` (line 59), `inventory/group_vars/dev_gpu.yaml` (line 17)
- **Format**: distro name string
- **Example**: `Ubuntu`
- **Question**: What is the WSL distro name installed on dev-3090?

### Q20: dev-3090 drive letter for data storage
- **Variable name**: `disk` and `drive` (used in multiple paths)
- **Affects**: `inventory/group_vars/dev_gpu.yaml` (lines 11-14)
  - `windows_data_root`: `"<disk>:\\ai"`
  - `wsl_mount_root`: `"/mnt/<drive>/ai"`
  - `stacks_root`: `"<disk>:\\ai\\stacks"`
  - `data_root`: `"<disk>:\\ai\\data"`
- **Format**: Single drive letter (uppercase for Windows, lowercase for WSL mount)
- **Example**: `D` (Windows) / `d` (WSL mount)
- **Question**: What drive letter will dev-3090 use for AI data storage? (e.g., D for D:\ai)

### Q21: dev-3090 LAN IP address
- **Variable name**: `lan_ip`
- **Affects**: `inventory/host_vars/dev-3090.yaml` (line 6)
- **Format**: IP address
- **Example**: `192.168.1.100`
- **Question**: What is the LAN IP address for dev-3090?

---

## NETWORK-SERVER WSL (Conditional - Only if Q14 answered with `wsl2-ubuntu-docker-engine`)

### Q22: network-server WSL SSH connection address (conditional)
- **Variable name**: `ansible_host` (network-server-wsl)
- **Affects**: `inventory/inventory.yaml` (line 62, currently commented)
- **Format**: IP address or hostname
- **Example**: `192.168.1.50` or `network-server`
- **Question**: [ONLY IF Q14 = wsl2] What is the IP address or hostname for network-server WSL SSH access?

### Q23: network-server WSL username (conditional)
- **Variable name**: `ansible_user` (network-server-wsl)
- **Affects**: `inventory/inventory.yaml` (line 64, currently commented)
- **Format**: username string
- **Example**: `ubuntu` or `user`
- **Question**: [ONLY IF Q14 = wsl2] What is the WSL username for network-server?

### Q24: network-server WSL distro name (conditional)
- **Variable name**: `wsl_distro` (network-server-wsl)
- **Affects**: `inventory/inventory.yaml` (line 68, currently commented)
- **Format**: distro name string
- **Example**: `Ubuntu`
- **Question**: [ONLY IF Q14 = wsl2] What is the WSL distro name installed on network-server?

---

## SUMMARY

**Total Questions**: 21 base questions + 3 conditional questions (if network-server uses WSL)

**Required for bootstrap/deploy**:
- All connection addresses (IPs/hostnames)
- All usernames (Windows admin, WSL, macOS)
- All WSL distro names (for WSL-based nodes)
- All drive letters (for storage paths)
- All LAN IPs (for host_vars)
- Docker runtime choice (for network-server)

**Not asked (deferred to later checkpoints)**:
- Final exposure decisions (localhost vs lan) - these are recommendations in contract
- Secret values - will be handled in Checkpoint 9
- Backup configuration - not needed for bootstrap
- Service-specific configurations - not needed for bootstrap

---

## NEXT STEPS

After you provide answers:
1. I will create `params/site.yaml` with your answers
2. I will update only `inventory/group_vars/*.yaml` and `inventory/host_vars/*.yaml`
3. I will NOT modify contracts, roles, or playbooks
4. I will run a final placeholder audit and report





