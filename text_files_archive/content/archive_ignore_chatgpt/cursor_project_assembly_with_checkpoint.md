# Project assembly with checkpoints
_Exported on 1/31/2026 at 01:13:04 CST from Cursor (2.2.44)_

---

**User**

@dotfile-vnext/assemble_checkpoints.md contrsutcet my project using the content folder and checkpoints so i can review at different points

---

**Cursor**


Reviewing the content folder to understand the contracts and specs, then implementing each checkpoint sequentially.



Creating the initial todo list and starting Checkpoint 1: canonical contract consolidation.



Starting Checkpoint 1: creating the canonical contract file by consolidating all contract information.


```yaml
---
# FUZLANG Cross-Node Contract (Canonical Spec)
# Version: 1.0
# Contract Name: fuzlang-lan-contract
# Timezone: America/Chicago

contract_version: 1
contract_name: fuzlang-lan-contract
timezone: America/Chicago

# ============================================================================
# 1. NODE IDENTITY AND ADDRESSING
# ============================================================================
nodes:
  mac_dev_node:
    name: mac-dev
    role: development-control-plane
    os: macOS
    authority_level: non-authoritative
    persistent_data_allowed: false
    secrets_storage: local_keychain_plus_ansible_vault_readonly
    docker_runtime: optional_local_testing_only
    rebuild_expectation: disposable_reprovisionable
    outbound_only: true
    preferred_address: dynamic
    lan_ip: null  # No inbound assumptions

  main_node:
    name: Server-225
    role: primary-gpu-node
    os: windows-server-2025
    authority_level: execution
    docker_runtime: wsl2-ubuntu-docker-engine
    gpu: rtx-5090
    persistent_data_allowed: limited_non_authoritative
    outbound_and_inbound: true
    preferred_address: hostname  # or ip
    hostname_fqdn: null  # optional if local DNS added later
    lan_ip: "<to_be_filled>"

  network_node:
    name: network-server
    role: storage-observability-node
    os: windows-server-2025
    authority_level: authoritative
    docker_runtime: windows-docker-engine  # or wsl2 if chosen later
    persistent_data_allowed: true
    outbound_and_inbound: true
    preferred_address: hostname  # or ip
    lan_ip: "<to_be_filled>"

  dev_node:
    name: dev-3090
    role: dev-gpu-node
    os: windows-11
    authority_level: execution
    docker_runtime: wsl2-ubuntu-docker-engine  # recommended
    gpu: rtx-3090
    persistent_data_allowed: limited
    inbound_allowed: true
    preferred_address: hostname  # or ip
    lan_ip: "<to_be_filled>"

addressing_rule:
  preferred_addressing: hostname  # fallback: ip
  recommendation: "hostname if local DNS will be set up; otherwise ip until DNS is configured"

# ============================================================================
# 2. ROLE MAP (SERVICE PLACEMENT)
# ============================================================================
service_placement:
  ollama: main_node
  litellm_gateway: main_node  # migration_candidate: true
  openwebui: main_node
  langfuse_web: network_node
  langfuse_worker: network_node  # if separated
  postgres: network_node
  clickhouse: network_node
  redis: network_node
  minio: network_node
  # Optional dev services
  dev_ollama: dev_node  # optional
  dev_litellm: dev_node  # optional
  dev_worker: dev_node  # optional batch/inference jobs

service_properties:
  ollama:
    needs_gpu: true
    data_persistent: false
    rebuild_ok_without_data_loss: true
    classification: production
  litellm_gateway:
    needs_gpu: false
    data_persistent: false
    rebuild_ok_without_data_loss: true
    classification: production
  langfuse_web:
    needs_gpu: false
    data_persistent: true
    rebuild_ok_without_data_loss: false
    classification: production
  postgres:
    needs_gpu: false
    data_persistent: true
    rebuild_ok_without_data_loss: false
    classification: production
  clickhouse:
    needs_gpu: false
    data_persistent: true
    rebuild_ok_without_data_loss: false
    classification: production
  redis:
    needs_gpu: false
    data_persistent: true
    rebuild_ok_without_data_loss: false
    classification: production
  minio:
    needs_gpu: false
    data_persistent: true
    rebuild_ok_without_data_loss: false
    classification: production

migration_candidates:
  litellm_gateway:
    may_move_to_network_node_later: true

# ============================================================================
# 3. CROSS-NODE ENDPOINTS (CANONICAL BASE URLS)
# ============================================================================
endpoint_map:
  langfuse_base_url: "http://network-server:3000"  # or http://<network_ip>:3000
  minio_api_url: "http://network-server:9000"
  minio_console_url: "http://network-server:9001"
  ollama_base_url: "http://Server-225:11434"  # only if other nodes need it
  litellm_base_url: "http://Server-225:4000"
  dev_ollama_base_url: "http://dev-3090:11434"  # optional
  dev_litellm_base_url: "http://dev-3090:4000"  # optional

tls_plan:
  lan_http_only: true  # recommended for now
  tls_later: true
  domain_later: true

# ============================================================================
# 4. PORT CONTRACT (AUTHORITATIVE)
# ============================================================================
ports:
  langfuse_web:
    port: 3000
    exposure: lan
    firewall_open: true
    allowed_sources: lan

  minio_api:
    port: 9000
    exposure: lan
    firewall_open: true
    allowed_sources: lan  # or main_only (your choice)

  minio_console:
    port: 9001
    exposure: lan
    firewall_open: true
    allowed_sources: lan  # or main_only

  postgres:
    port: 5432
    exposure: restricted
    firewall_open: true  # only if main must connect directly
    allowed_sources: network_only  # recommended, or allow_main_only

  clickhouse:
    ports: [8123, 9000]  # http, native
    exposure: restricted
    allowed_sources: network_only  # or allow_main_only

  redis:
    port: 6379
    exposure: restricted
    allowed_sources: network_only  # or allow_main_only

  litellm_gateway:
    port: 4000
    exposure: lan  # or localhost_only (depends on clients)
    allowed_sources: lan

  ollama:
    port: 11434
    exposure: localhost_only  # recommended unless network node needs it
    allowed_sources: main_only  # or allow_network_only

  dev_ollama:
    port: 11434
    exposure: restricted  # or lan
    allowed_sources: [mac-dev, Server-225, network-server]  # your choice

  dev_litellm:
    port: 4000
    exposure: restricted  # or lan
    allowed_sources: [mac-dev, Server-225, network-server]

port_recommendations:
  expose_to_lan: [langfuse_web, minio_api, minio_console, litellm_gateway]
  keep_restricted: [postgres, redis, clickhouse]
  keep_localhost_only: [ollama]  # unless network-server must call it

# ============================================================================
# 5. SHARED SECRET CONTRACT
# ============================================================================
secrets:
  shared_secrets:
    description: "Needed on both nodes (readable by mac + main + network + dev)"
    keys:
      - FUZLANG_LANGFUSE_PUBLIC_KEY
      - FUZLANG_LANGFUSE_SECRET_KEY
      - FUZLANG_MINIO_ACCESS_KEY
      - FUZLANG_MINIO_SECRET_KEY

  network_only_secrets:
    description: "Only on network_node"
    keys:
      - FUZLANG_POSTGRES_PASSWORD
      - FUZLANG_CLICKHOUSE_PASSWORD
      - FUZLANG_REDIS_PASSWORD
      - FUZLANG_LANGFUSE_NEXTAUTH_SECRET
      - FUZLANG_LANGFUSE_SALT
      - FUZLANG_LANGFUSE_ENCRYPTION_KEY  # if used

  main_only_secrets:
    description: "Only on main_node"
    keys:
      - FUZLANG_OPENWEBUI_ADMIN_TOKEN  # if used
      - local_inference_tokens  # any local API tokens that never leave main

  dev_only_secrets:
    description: "Only on dev_node"
    keys:
      - local_ui_tokens  # any local auth
      - dev_inference_tokens

secret_key_naming_convention:
  prefix: FUZLANG_
  examples:
    - FUZLANG_LANGFUSE_PUBLIC_KEY
    - FUZLANG_LANGFUSE_SECRET_KEY
    - FUZLANG_MINIO_ACCESS_KEY
    - FUZLANG_MINIO_SECRET_KEY

secret_rules:
  mac_dev_node:
    may_read_shared_secrets: true
    may_store_secrets: false
    may_persist_secrets: false
  secrets_rendered_only_to: [main_node, network_node, dev_node]

# ============================================================================
# 6. STORAGE CONTRACT (PATHS + OWNERSHIP)
# ============================================================================
storage_roots:
  mac_dev_node:
    description: "Stateless - no persistent storage"
    windows_data_root: null
    wsl_mount_root: null
    stacks_root: null
    data_root: null

  main_node:
    windows_data_root: "D:\\ai"
    wsl_mount_root: "/mnt/d/ai"
    stacks_root: "D:\\ai\\stacks"
    data_root: "D:\\ai\\data"
    docker_data_root_location: "inside wsl2 but bind mounts must point into /mnt/d/ai/data"
    authoritative_data: false

  network_node:
    windows_data_root: "<disk>:\\ai"  # example: E:\\ai or D:\\ai
    stacks_root: "<disk>:\\ai\\stacks"
    data_root: "<disk>:\\ai\\data"
    minio_disk: "8TB WD Red Plus (authoritative archive)"
    authoritative_data: true

  dev_node:
    windows_data_root: "<disk>:\\ai"  # to be determined
    wsl_mount_root: "/mnt/<drive>/ai"
    stacks_root: "<disk>:\\ai\\stacks"
    data_root: "<disk>:\\ai\\data"
    authoritative_data: false

backup_contract:
  authoritative_node: network_node
  backup_targets:
    - postgres volume path(s)
    - clickhouse volume path(s)
    - redis volume path(s)
    - minio data path(s)
  backup_frequency: "<placeholder>"
  backup_destination: "<placeholder>"

# ============================================================================
# 7. NAMING CONVENTIONS (COLLISION PREVENTION)
# ============================================================================
naming:
  compose_project_names:
    main: fuzlang-main
    network: fuzlang-net
    dev: fuzlang-dev

  docker_network_names:
    internal_network_main: fuzlang_main_net
    internal_network_network: fuzlang_net_net
    internal_network_dev: fuzlang_dev_net

  bucket_names:
    artifacts_bucket: fuzlang-artifacts
    optional_trace_bucket: fuzlang-traces  # only if traces stored as objects

# ============================================================================
# 8. TRUST BOUNDARIES + FIREWALL RULES
# ============================================================================
trust_policy:
  mac_dev_node:
    outbound_only: true
    no_inbound_trust: true
    never_in_firewall_allowlists: true

  main_node:
    accepts_lan_client_traffic: true
    talks_to_network_node_services: true

  network_node:
    accepts_traffic_from_main_for_databases: true
    lan_access_only_for: [langfuse_web, minio_api, minio_console]

  dev_node:
    execution_peer: true
    not_authoritative_for_storage: true
    does_not_receive_db_credentials: true  # unless explicitly decided

ansible_firewall_rules_required:
  allow_inbound_to_lan_exposed_services_ports_on_network_node: true
  allow_inbound_to_litellm_port_on_main_node_if_lan_exposed: true
  if_db_access_needed_from_main_node:
    allow_inbound_on_network_node_db_ports_from_main_node_ip_only: true
  otherwise:
    bind_db_ports_to_localhost_only_inside_compose: true
    no_firewall_open: true

# ============================================================================
# 9. MAIN NODE RUNTIME SPECIFICS (WSL2 DOCKER + AUTOSTART)
# ============================================================================
main_node_runtime:
  docker_runs_in_wsl2: true
  distro: Ubuntu
  systemd_in_wsl: true  # recommended
  docker_engine_in_wsl: true
  docker_engine_on_windows: disabled  # recommended to prevent confusion
  compose_execution_location: "inside wsl2, from /mnt/d/ai/stacks/<stack>"

task_scheduler_autostart:
  enabled: true
  task_name: autostart-ai-stack
  trigger: at_startup
  delay_seconds: 45  # 30-60 ok
  run_as: SYSTEM
  highest_privileges: true
  action:
    executable: "C:\\Windows\\System32\\wsl.exe"
    args: '-d Ubuntu -- bash -lc "cd /mnt/d/ai/stacks/<primary_stack> && docker compose up -d"'
  retry_policy:
    restart_interval_seconds: 60
    restart_count: 5
  success_criteria:
    - docker ps returns success in wsl
    - expected containers are running

# ============================================================================
# 10. NETWORK NODE RUNTIME SPECIFICS
# ============================================================================
network_node_runtime:
  docker_runtime: windows-docker-engine  # or wsl2 if chosen later
  docker_data_root: "<disk>:\\docker-data"  # non-OS disk
  compose_execution_location: "<disk>:\\ai\\stacks"

# ============================================================================
# 11. DEV NODE RUNTIME SPECIFICS
# ============================================================================
dev_node_runtime:
  docker_runs_in_wsl2: true  # recommended
  distro: Ubuntu
  systemd_in_wsl: true
  docker_engine_in_wsl: true
  docker_engine_on_windows: disabled
  compose_execution_location: "inside wsl2, from /mnt/<drive>/ai/stacks/<stack>"

# ============================================================================
# 12. MANAGEMENT SURFACES (WINRM vs SSH)
# ============================================================================
management_surfaces:
  windows_host_surface:
    connection: winrm
    used_for:
      - Windows Features
      - Hyper-V
      - WSL installation
      - Windows Roles
      - Registry changes
      - Services (Task Scheduler, Windows services)
      - Firewall rules
      - Disk initialization
      - GPU driver install/validation
      - OS-level hardening

  wsl_surface:
    connection: ssh
    used_for:
      - Docker commands
      - Docker Compose
      - Managing containers
      - Deploying stacks
      - Inspecting logs
      - Linux tooling
      - Anything under /mnt/d/...

  dual_surface_model:
    description: "Each physical Windows machine has two management surfaces"
    pattern:
      - "<hostname>-win"  # WinRM surface
      - "<hostname>-wsl"  # SSH surface
    examples:
      - server-225-win
      - server-225-wsl
      - network-server-win
      - network-server-wsl  # if WSL runtime chosen
      - dev-3090-win
      - dev-3090-wsl

# ============================================================================
# 13. CONTRACT OUTPUTS (WHAT THE CONTRACT MUST GENERATE)
# ============================================================================
generated_artifacts:
  shared_contract_file:
    path: contracts/fuzlang.contract.yaml
    consumed_by: [both_playbooks]

  vaults:
    shared_vault: vault/shared.vault.yml
    main_vault: vault/main.vault.yml
    network_vault: vault/network.vault.yml
    dev_vault: vault/dev.vault.yml

  rendered_env_files:
    main_env: rendered/main/.env
    network_env: rendered/network/.env
    dev_env: rendered/dev/.env

  node_facts:
    main: /etc/fuzlang/node_facts.json  # or windows equivalent path
    network: /etc/fuzlang/node_facts.json
    dev: /etc/fuzlang/node_facts.json

  mac_dev_node_receives:
    - read_only_contract: true
    - no_env_files: true
    - no_vault_files: true  # except shared, decrypted at runtime only

verification_outputs:
  endpoint_health_checks:
    - main can reach langfuse_base_url
    - main can reach minio_api_url
    - network can reach ollama_base_url only if allowed

  gpu_checks:
    - nvidia-smi works on main windows
    - nvidia-smi works inside wsl2 (main)
    - docker gpu test container works (if gpu used in containers)
    - nvidia-smi works on dev windows
    - nvidia-smi works inside wsl2 (dev)

  drift_checks:
    - docker engine running in wsl2 (main)
    - docker engine not running on windows (main) if rule chosen
    - docker engine running in wsl2 (dev)
    - docker engine not running on windows (dev) if rule chosen

# ============================================================================
# 14. EXPLICIT NON-GOALS (LOCK THIS IN)
# ============================================================================
non_goals:
  - mac_dev_node is not a server
  - mac_dev_node never holds data authority
  - mac_dev_node is disposable
  - only network_node is authoritative for state
  - only ansible modifies server configuration
  - no overclocking
  - no gaming workloads
  - no desktop UX tuning
  - no VM sprawl
  - no Windows consumer features
  - no Docker-in-WSL for production (WSL is workbench, Docker is factory)

# ============================================================================
# 15. MISSING USER INPUTS (MUST BE FILLED)
# ============================================================================
missing_inputs:
  - main_node lan_ip
  - network_node lan_ip
  - dev_node lan_ip
  - whether hostname or ip is authoritative right now
  - whether postgres/redis/clickhouse will ever be accessed directly from main (yes/no)
  - exact disk letters for network_node (stacks/data)
  - exact disk letters for dev_node (stacks/data)
  - final exposure choice for litellm and ollama (localhost vs lan vs allowlist)
  - network_node docker runtime choice (windows-docker-engine vs wsl2)

```


Checkpoint 1 complete. Starting Checkpoint 2: creating the repo skeleton and governance rails.


```markdown
# Architecture Rules and Governance

## Core Principles

1. **Contract is Authoritative**
   - All decisions must be traceable to `contracts/fuzlang.contract.yaml`
   - No services, ports, or secrets may be added without contract update
   - Any ambiguity must be left as a placeholder in the contract, not guessed

2. **Dual Surface Model**
   - Every Windows host has a `-win` surface managed by WinRM
   - Every Docker-in-WSL host has a `-wsl` surface managed by SSH (or wsl-command wrapper)
   - Windows roles must never run docker compose
   - WSL roles must never install Windows features or touch firewall/scheduler

3. **No Architectural Guessing**
   - If a step violates any checkpoint rule, agents must stop and report
   - Contract may be refined, but not re-imagined
   - Each checkpoint must satisfy:
     - Clear start state
     - Clear stop state
     - Limited file surface area
     - No architectural guessing

4. **Surface Boundary Enforcement**
   - Windows roles: WinRM + PowerShell only
   - WSL roles: SSH + Bash only
   - No mixing of Windows modules into Linux tasks or vice versa
   - New variables always come from contract or group_vars, not hardcoded

5. **Authority Boundaries**
   - Only network_node is authoritative for state
   - Only Ansible modifies server configuration
   - mac_dev_node is disposable and non-authoritative
   - No cross-node authority drift

## Checkpoint Rules

### Checkpoint 1: Canonical Contract Consolidation
- **DO**: Merge, normalize, deduplicate contract information
- **DO NOT**: Re-imagine the contract or add new services

### Checkpoint 2: Repo Skeleton + Governance Rails
- **DO**: Create full directory tree, empty placeholder files, architecture rules
- **DO NOT**: Implement roles, write playbook logic, or add variables beyond placeholders

### Checkpoint 3: Inventory & Node Surfaces
- **DO**: Implement dual-surface model (`-win` and `-wsl` hosts)
- **DO NOT**: Add role logic or hardcoded secrets

### Checkpoint 4: Playbook Wiring
- **DO**: Define execution flow with correct hosts/groups and role ordering
- **DO NOT**: Add task logic, shell commands, or modules yet

### Checkpoint 5: Common Baseline + Verification
- **DO**: Create lowest-risk shared automation (timezone, host identity, node facts)
- **DO NOT**: Install services or touch complex systems

### Checkpoint 6: Windows Host Bootstrap
- **DO**: Make Windows hosts structurally ready (WSL, SSH, firewall skeletons)
- **DO NOT**: Add docker compose or Linux logic

### Checkpoint 7: Linux / WSL Runtime Layer
- **DO**: Establish steady-state runtime environment (docker engine in WSL, compose support)
- **DO NOT**: Change Windows features or guess ports

### Checkpoint 8: Stack Deployment Per Role
- **DO**: Bring up only declared services from contract
- **DO NOT**: Add cross-node drift, new services, or port guessing

### Checkpoint 9: Secrets & Rendering Pipeline
- **DO**: Eliminate manual configuration (rendered .env files, vault separation)
- **DO NOT**: Print secrets or duplicate across scopes

## Failure Signals

If any of these occur, stop and report:
- Cursor adds Docker Desktop, Kubernetes, or random services
- Cursor opens ports broadly without contract authorization
- Cursor mixes WinRM modules into Linux tasks or vice versa
- Cursor adds variables not from contract or group_vars
- Cursor creates services not declared in contract
- Cursor guesses values instead of using placeholders

## Success Criteria

- A human can answer "what runs where, how, and why" by reading only the YAML contract
- No contradictory statements remain across docs
- Each physical node is reachable in the correct way
- No ambiguity about which surface runs which tasks
- A reader can understand lifecycle: bootstrap → deploy → verify
- Nothing can accidentally run on the wrong surface

```


Creating placeholder files for the repo skeleton:


```markdown
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

```

```yaml
---
# FUZLANG Infrastructure Inventory
# Dual-surface model: each Windows host has -win (WinRM) and -wsl (SSH) surfaces

all:
  children:
    # Windows host surfaces (WinRM)
    windows_hosts:
      hosts:
        server-225-win:
          ansible_host: "<to_be_filled>"  # Server-225 IP or hostname
          ansible_connection: winrm
          ansible_user: Administrator
          ansible_port: 5986
          ansible_winrm_transport: ntlm
          ansible_winrm_server_cert_validation: ignore
          physical_node: server-225
          surface_type: windows_host

        network-server-win:
          ansible_host: "<to_be_filled>"  # network-server IP or hostname
          ansible_connection: winrm
          ansible_user: Administrator
          ansible_port: 5986
          ansible_winrm_transport: ntlm
          ansible_winrm_server_cert_validation: ignore
          physical_node: network-server
          surface_type: windows_host

        dev-3090-win:
          ansible_host: "<to_be_filled>"  # dev-3090 IP or hostname
          ansible_connection: winrm
          ansible_user: Administrator
          ansible_port: 5986
          ansible_winrm_transport: ntlm
          ansible_winrm_server_cert_validation: ignore
          physical_node: dev-3090
          surface_type: windows_host

    # WSL surfaces (SSH)
    wsl_hosts:
      hosts:
        server-225-wsl:
          ansible_host: "<to_be_filled>"  # Server-225 IP or hostname (SSH to Windows, then WSL)
          ansible_connection: ssh
          ansible_user: "<to_be_filled>"  # WSL username
          ansible_port: 22
          physical_node: server-225
          surface_type: wsl
          wsl_distro: Ubuntu

        dev-3090-wsl:
          ansible_host: "<to_be_filled>"  # dev-3090 IP or hostname (SSH to Windows, then WSL)
          ansible_connection: ssh
          ansible_user: "<to_be_filled>"  # WSL username
          ansible_port: 22
          physical_node: dev-3090
          surface_type: wsl
          wsl_distro: Ubuntu

        # network-server-wsl:  # Only if network-server uses WSL runtime
        #   ansible_host: "<to_be_filled>"
        #   ansible_connection: ssh
        #   ansible_user: "<to_be_filled>"
        #   ansible_port: 22
        #   physical_node: network-server
        #   surface_type: wsl
        #   wsl_distro: Ubuntu

    # macOS development node
    mac_hosts:
      hosts:
        mac-dev:
          ansible_host: "<to_be_filled>"  # mac-dev IP or hostname
          ansible_connection: ssh
          ansible_user: "<to_be_filled>"
          ansible_port: 22
          physical_node: mac-dev
          surface_type: macos

    # Logical groups for playbook targeting
    main_node:
      hosts:
        server-225-win:
        server-225-wsl:

    network_node:
      hosts:
        network-server-win:
        # network-server-wsl:  # Uncomment if WSL runtime chosen

    dev_node:
      hosts:
        dev-3090-win:
        dev-3090-wsl:

  vars:
    ansible_python_interpreter: auto

```

```yaml
---
# Variables for all hosts
timezone: America/Chicago
contract_file: contracts/fuzlang.contract.yaml

```

```yaml
---
# Variables for mac-dev node
node_role: development-control-plane
os: macOS
authority_level: non-authoritative
persistent_data_allowed: false
outbound_only: true

```

```yaml
---
# Variables for Server-225 (main node)
node_role: primary-gpu-node
os: windows-server-2025
authority_level: execution
docker_runtime: wsl2-ubuntu-docker-engine
gpu: rtx-5090
persistent_data_allowed: limited_non_authoritative

# Storage paths
windows_data_root: "D:\\ai"
wsl_mount_root: "/mnt/d/ai"
stacks_root: "D:\\ai\\stacks"
data_root: "D:\\ai\\data"

# WSL configuration
wsl_distro: Ubuntu
systemd_in_wsl: true
docker_engine_in_wsl: true
docker_engine_on_windows: disabled

# Task scheduler autostart
task_scheduler_enabled: true
task_scheduler_delay_seconds: 45

```

```yaml
---
# Variables for network-server node
node_role: storage-observability-node
os: windows-server-2025
authority_level: authoritative
docker_runtime: windows-docker-engine  # or wsl2 if chosen later
persistent_data_allowed: true

# Storage paths (placeholders - to be filled)
windows_data_root: "<disk>:\\ai"  # example: E:\\ai or D:\\ai
stacks_root: "<disk>:\\ai\\stacks"
data_root: "<disk>:\\ai\\data"
minio_disk: "8TB WD Red Plus"

# Docker configuration
docker_data_root: "<disk>:\\docker-data"  # non-OS disk

```

```yaml
---
# Variables for dev-3090 node
node_role: dev-gpu-node
os: windows-11
authority_level: execution
docker_runtime: wsl2-ubuntu-docker-engine
gpu: rtx-3090
persistent_data_allowed: limited

# Storage paths (placeholders - to be filled)
windows_data_root: "<disk>:\\ai"
wsl_mount_root: "/mnt/<drive>/ai"
stacks_root: "<disk>:\\ai\\stacks"
data_root: "<disk>:\\ai\\data"

# WSL configuration
wsl_distro: Ubuntu
systemd_in_wsl: true
docker_engine_in_wsl: true
docker_engine_on_windows: disabled

```

```yaml
---
# Host-specific variables for mac-dev
host_name: mac-dev
physical_node: mac-dev

```

```yaml
---
# Host-specific variables for Server-225
# Applied to both server-225-win and server-225-wsl
host_name: Server-225
physical_node: server-225
lan_ip: "<to_be_filled>"

```

```yaml
---
# Host-specific variables for network-server
# Applied to network-server-win (and network-server-wsl if used)
host_name: network-server
physical_node: network-server
lan_ip: "<to_be_filled>"

```

```yaml
---
# Host-specific variables for dev-3090
# Applied to both dev-3090-win and dev-3090-wsl
host_name: dev-3090
physical_node: dev-3090
lan_ip: "<to_be_filled>"

```


Checkpoint 3 complete. Starting Checkpoint 4: playbook wiring.


```yaml
---
# Bootstrap mac-dev node
# Targets: mac-dev (SSH)
# Purpose: Set up development control plane

- name: Bootstrap mac-dev node
  hosts: mac-dev
  become: false
  roles:
    - role: common/baseline
    - role: mac_dev/homebrew
    - role: mac_dev/dev_tools
    - role: mac_dev/dotfiles
    - role: mac_dev/ansible_runner
    - role: common/ssh_keys

```

```yaml
---
# Bootstrap Server-225 (main node)
# Targets: server-225-win (WinRM)
# Purpose: Make Windows host structurally ready

- name: Bootstrap Server-225 Windows host
  hosts: server-225-win
  become: false
  roles:
    - role: common/baseline
    - role: server_225/windows_base
    - role: server_225/wsl2
    - role: server_225/task_scheduler_autostart
    - role: server_225/gpu_driver_validation
    - role: common/firewall

```

```yaml
---
# Bootstrap network-server node
# Targets: network-server-win (WinRM)
# Purpose: Make Windows host structurally ready

- name: Bootstrap network-server Windows host
  hosts: network-server-win
  become: false
  roles:
    - role: common/baseline
    - role: network_server/windows_base
    - role: network_server/docker_runtime
    - role: network_server/storage_layout
    - role: common/firewall

```

```yaml
---
# Bootstrap dev-3090 node
# Targets: dev-3090-win (WinRM)
# Purpose: Make Windows host structurally ready

- name: Bootstrap dev-3090 Windows host
  hosts: dev-3090-win
  become: false
  roles:
    - role: common/baseline
    - role: dev_3090/windows_base
    - role: dev_3090/wsl2_or_windows_docker_runtime
    - role: dev_3090/gpu_driver_validation
    - role: common/firewall

```

```yaml
---
# Deploy main stacks on Server-225
# Targets: server-225-wsl (SSH)
# Purpose: Bring up ollama, litellm, openwebui stacks

- name: Deploy main stacks on Server-225
  hosts: server-225-wsl
  become: false
  roles:
    - role: server_225/docker_in_wsl
    - role: server_225/stacks_main

```

```yaml
---
# Deploy network stacks on network-server
# Targets: network-server-win (WinRM) or network-server-wsl (SSH) depending on runtime
# Purpose: Bring up langfuse, postgres, clickhouse, redis, minio stacks

- name: Deploy network stacks on network-server
  hosts: network_node
  become: false
  roles:
    - role: network_server/stacks_network

```

```yaml
---
# Deploy dev stacks on dev-3090
# Targets: dev-3090-wsl (SSH)
# Purpose: Bring up optional dev ollama, litellm stacks

- name: Deploy dev stacks on dev-3090
  hosts: dev-3090-wsl
  become: false
  roles:
    - role: dev_3090/stacks_dev

```

```yaml
---
# Verify entire fabric
# Targets: Mixed (Windows checks on -win, Linux checks on -wsl, endpoints from mac-dev)
# Purpose: Verify all nodes are correctly configured and services are running

- name: Verify Windows hosts
  hosts: windows_hosts
  become: false
  roles:
    - role: common/health_checks

- name: Verify WSL hosts
  hosts: wsl_hosts
  become: false
  roles:
    - role: common/health_checks

- name: Verify endpoints from mac-dev
  hosts: mac-dev
  become: false
  roles:
    - role: common/health_checks

```


Checkpoints 1–4 are complete. Creating a checkpoint status document for review:


```markdown
# Checkpoint Status

This document tracks progress through the checkpoint plan defined in `assemble_checkpoints.md`.

## ✅ Checkpoint 1 — Canonical Contract Consolidation (COMPLETE)

**Goal**: Produce one authoritative contract file that the rest of the repo obeys.

**Output**:
- ✅ `contracts/fuzlang.contract.yaml` - Fully populated with all contract information
- ✅ Placeholders included where values need to be filled
- ✅ All nodes explicitly declared: mac-dev, Server-225, network-server, dev-3090
- ✅ WinRM vs SSH surfaces declared
- ✅ Docker runtime per node declared
- ✅ Service placement declared
- ✅ Secrets scopes declared
- ✅ Storage authority declared

**Status**: Complete. A human can answer "what runs where, how, and why" by reading only the YAML.

---

## ✅ Checkpoint 2 — Repo Skeleton + Governance Rails (COMPLETE)

**Goal**: Create the final repo structure and governance rules, nothing else.

**Output**:
- ✅ Full directory tree created
- ✅ Empty placeholder files created
- ✅ `docs/architecture_rules.md` created with explicit governance rules
- ✅ `README.md` created

**Status**: Complete. Every future file location is predetermined.

---

## ✅ Checkpoint 3 — Inventory & Node Surfaces (COMPLETE)

**Goal**: Make Ansible correctly aware of all nodes and their management surfaces.

**Output**:
- ✅ `inventory/inventory.yaml` with dual-surface model:
  - `*-win` hosts (WinRM)
  - `*-wsl` hosts (SSH)
- ✅ `inventory/group_vars/*` with node-specific variables
- ✅ `inventory/host_vars/*` with host-specific variables
- ✅ No role logic
- ✅ No hardcoded secrets

**Status**: Complete. Each physical node is reachable in the correct way. No ambiguity about which surface runs which tasks.

---

## ✅ Checkpoint 4 — Playbook Wiring (COMPLETE)

**Goal**: Define execution flow without touching internals.

**Output**:
- ✅ All playbooks populated with:
  - Correct hosts/groups
  - Role ordering
  - No task bodies beyond includes
- ✅ Playbooks:
  - `bootstrap_mac.yaml`
  - `bootstrap_server_225.yaml`
  - `bootstrap_network_server.yaml`
  - `bootstrap_dev_3090.yaml`
  - `deploy_main_stacks.yaml`
  - `deploy_network_stacks.yaml`
  - `deploy_dev_stacks.yaml`
  - `verify_fabric.yaml`

**Status**: Complete. A reader can understand lifecycle: bootstrap → deploy → verify. Nothing can accidentally run on the wrong surface.

---

## ⏳ Checkpoint 5 — Common Baseline + Verification (PENDING)

**Goal**: Create the lowest-risk shared automation first.

**Planned Output**:
- `roles/common/baseline` - timezone, host identity, node facts
- `roles/common/health_checks` - read-only verification
- Updates to `verify_fabric.yaml`

**Status**: Not started. Waiting for implementation.

---

## ⏳ Checkpoint 6 — Windows Host Bootstrap (PENDING)

**Goal**: Make Windows hosts structurally ready.

**Planned Output**:
- `roles/server_225/windows_base`
- `roles/network_server/windows_base`
- `roles/dev_3090/windows_base`
- WSL enablement
- SSH enablement
- Firewall skeletons
- Scheduled task scaffolding

**Status**: Not started. Waiting for implementation.

---

## ⏳ Checkpoint 7 — Linux / WSL Runtime Layer (PENDING)

**Goal**: Establish the steady-state runtime environment.

**Planned Output**:
- Docker engine in WSL
- Compose support
- Directory mounts
- Runtime health checks

**Status**: Not started. Waiting for implementation.

---

## ⏳ Checkpoint 8 — Stack Deployment Per Role (PENDING)

**Goal**: Bring up only the declared services.

**Planned Output**:
- Stacks running on:
  - server-225 (main)
  - network-server (authoritative)
  - dev-3090 (dev execution)

**Status**: Not started. Waiting for implementation.

---

## ⏳ Checkpoint 9 — Secrets & Rendering Pipeline (PENDING)

**Goal**: Eliminate manual configuration permanently.

**Planned Output**:
- Rendered .env files
- Vault separation enforced
- `verify_fabric.yaml` updated to check presence (not values)

**Status**: Not started. Waiting for implementation.

---

## Review Points

You can review the project at any checkpoint:

1. **After Checkpoint 1**: Review the contract to ensure all decisions are captured
2. **After Checkpoint 2**: Review the structure to ensure all locations are correct
3. **After Checkpoint 3**: Review inventory to ensure all nodes are correctly defined
4. **After Checkpoint 4**: Review playbooks to ensure execution flow is correct
5. **After Checkpoint 5**: Review baseline automation before touching complex systems
6. **After Checkpoint 6**: Review Windows bootstrap before adding runtime
7. **After Checkpoint 7**: Review WSL runtime before deploying stacks
8. **After Checkpoint 8**: Review stack deployment before finalizing secrets
9. **After Checkpoint 9**: Final review of complete system

## Next Steps

To continue implementation, proceed with Checkpoint 5: Common Baseline + Verification.

```


Completed checkpoints 1–4. Summary:

## Completed checkpoints

### Checkpoint 1: Canonical contract consolidation
- Created `contracts/fuzlang.contract.yaml` consolidating all contract information
- Includes all nodes (mac-dev, Server-225, network-server, dev-3090)
- Defines service placement, ports, secrets, storage, and management surfaces

### Checkpoint 2: Repo skeleton + governance rails
- Created directory structure
- Added placeholder files for all roles and playbooks
- Created `docs/architecture_rules.md` with governance rules

### Checkpoint 3: Inventory & node surfaces
- Created `inventory/inventory.yaml` with dual-surface model (`-win` for WinRM, `-wsl` for SSH)
- Created group_vars and host_vars files
- Each physical node has correct management surfaces defined

### Checkpoint 4: Playbook wiring
- Created all playbooks with correct hosts/groups and role ordering
- No task logic yet — just structure
- Lifecycle clear: bootstrap → deploy → verify

## Review point

You can review the project structure now. Created `CHECKPOINT_STATUS.md` to track progress.

## What's next

Remaining checkpoints (5–9) will implement:
- Common baseline automation
- Windows host bootstrap
- WSL runtime layer
- Stack deployment
- Secrets & rendering pipeline

Should I continue with checkpoints 5–9, or do you want to review first?

