yes — that writeup is the right shape, and it’s almost complete. what it still needs (to be unambiguous for ansible and your repo) is:

* a single canonical “contract object” (one file) with concrete field names
* explicit default choices where you haven’t pinned values yet
* a clear output plan: what gets rendered to each node, what goes in shared vault vs per-node vault, and what ansible must verify

below is a complete contract structure you can hand to the “main conversation” (or treat as the project’s canonical spec). it includes the task scheduler autostart decision for your wsl2-docker-on-main posture.

────────────────────────────────────────────────────────
fuzlang cross-node contract (canonical spec)
versioning

* contract_version: 1
* contract_name: fuzlang-lan-contract
* timezone: America/Chicago

1. node identity and addressing

* main_node

  * name: Server-225
  * role: primary-gpu-node
  * os: windows-server-2025
  * docker_runtime: wsl2-ubuntu-docker-engine
  * preferred_address: hostname (recommended) or ip
  * hostname_fqdn: optional (if you add local dns later)
  * lan_ip: placeholder (you must fill)
* network_node

  * name: network-server
  * role: storage-observability-node
  * os: windows-server-2025 (or whatever you chose for that box)
  * docker_runtime: windows-docker-engine (or wsl2, if you choose similarly)
  * preferred_address: hostname or ip
  * lan_ip: placeholder (you must fill)

addressing rule (pick one and make it authoritative)

* preferred_addressing: hostname or ip
  recommended: hostname if you will set up local dns; otherwise ip until you do

2. role map (service placement)
   service_placement

* ollama: main_node
* litellm_gateway: main_node (now)
* langfuse_web: network_node
* langfuse_worker: network_node (if separated)
* postgres: network_node
* clickhouse: network_node
* redis: network_node
* minio: network_node
* openwebui: main_node (if you run it)

service_properties (ansible uses this for enforcement)

* each service gets:

  * needs_gpu: true/false
  * data_persistent: true/false
  * rebuild_ok_without_data_loss: true/false
  * classification: production/tooling

migration_candidates

* litellm_gateway: may_move_to_network_node_later: true

3. cross-node endpoints (canonical base urls)
   these are what templates use; they must be stable.

endpoint_map

* langfuse_base_url: [http://network-server:3000](http://network-server:3000) (or http://<network_ip>:3000)
* minio_api_url: [http://network-server:9000](http://network-server:9000)
* minio_console_url: [http://network-server:9001](http://network-server:9001)
* ollama_base_url: [http://Server-225:11434](http://Server-225:11434) (only if other nodes need it)
* litellm_base_url: [http://Server-225:4000](http://Server-225:4000)

tls_plan

* lan_http_only: yes (recommended for now)
* tls_later: yes/no
* domain_later: yes/no

4. port contract (authoritative)
   ports

* langfuse_web

  * port: 3000
  * exposure: lan
  * firewall_open: yes
  * allowed_sources: lan
* minio_api

  * port: 9000
  * exposure: lan
  * firewall_open: yes
  * allowed_sources: lan or main_only (your choice)
* minio_console

  * port: 9001
  * exposure: lan
  * firewall_open: yes
  * allowed_sources: lan or main_only
* postgres

  * port: 5432
  * exposure: restricted
  * firewall_open: yes (only if main must connect directly)
  * allowed_sources: network_only (recommended) or allow_main_only
* clickhouse

  * ports: 8123 (http), 9000 (native) (only if you expose; otherwise internal)
  * exposure: restricted
  * allowed_sources: network_only or allow_main_only
* redis

  * port: 6379
  * exposure: restricted
  * allowed_sources: network_only or allow_main_only
* litellm_gateway

  * port: 4000
  * exposure: lan or localhost_only (depends on your clients)
  * allowed_sources: lan
* ollama

  * port: 11434
  * exposure: localhost_only (recommended unless network node needs it)
  * allowed_sources: main_only or allow_network_only

recommended defaults (for least regret)

* expose langfuse + minio to lan
* keep postgres/redis/clickhouse not exposed to full lan; allow only main_node if needed
* keep ollama localhost_only unless network-server must call it

5. shared secret contract
   secrets are grouped by scope so ansible can render vaults.

shared_secrets (needed on both nodes)

* langfuse_public_key (for clients that send traces)
* langfuse_secret_key (for clients that send traces)
* minio_access_key (if main writes artifacts to minio)
* minio_secret_key (if main writes artifacts to minio)

network_only_secrets (only on network_node)

* postgres_password
* clickhouse_password
* redis_password
* langfuse_nextauth_secret
* langfuse_salt
* any internal admin tokens for langfuse stack

main_only_secrets (only on main_node)

* any local ui auth (openwebui admin, etc.)
* any local api tokens that never leave main

secret_key_naming_convention

* prefix: FUZLANG_
* examples:

  * FUZLANG_LANGFUSE_PUBLIC_KEY
  * FUZLANG_LANGFUSE_SECRET_KEY
  * FUZLANG_MINIO_ACCESS_KEY
  * FUZLANG_MINIO_SECRET_KEY

6. storage contract (paths + ownership)
   storage_roots

* main_node

  * windows_data_root: D:\ai
  * wsl_mount_root: /mnt/d/ai
  * stacks_root: D:\ai\stacks
  * data_root: D:\ai\data
  * docker_data_root_location: inside wsl2 but bind mounts must point into /mnt/d/ai/data
* network_node

  * windows_data_root: (example) E:\ai or D:\ai (whatever disk is dedicated)
  * stacks_root: <disk>:\ai\stacks
  * data_root: <disk>:\ai\data
  * minio_disk: 8TB WD Red Plus (authoritative archive)
  * authoritative_data: yes

backup_contract

* authoritative_node: network_node
* backup_targets:

  * postgres volume path(s)
  * clickhouse volume path(s)
  * redis volume path(s)
  * minio data path(s)
* backup_frequency: placeholder
* backup_destination: placeholder

7. naming conventions (collision prevention)
   compose_project_names

* main: fuzlang-main
* network: fuzlang-net

docker_network_names

* internal_network_main: fuzlang_main_net
* internal_network_network: fuzlang_net_net

bucket_names (minio)

* artifacts_bucket: fuzlang-artifacts
* optional_trace_bucket: fuzlang-traces (only if you store traces as objects)

8. trust boundaries + firewall rules
   trust_policy

* db_services_allowed_sources: [network_node, main_node]
* lan_exposed_services: [langfuse_web, minio_api, minio_console, litellm_gateway(optional)]
* ollama_exposure: localhost_only (default)

ansible_firewall_rules_required

* allow inbound to lan_exposed_services ports on network_node
* allow inbound to litellm port on main_node if lan exposed
* if db access needed from main_node:

  * allow inbound on network_node db ports from main_node ip only
* otherwise:

  * bind db ports to localhost only inside compose and no firewall open

9. main node runtime specifics (wsl2 docker + autostart)
   main_node_runtime

* docker_runs_in_wsl2: yes
* distro: Ubuntu
* systemd_in_wsl: yes (recommended)
* docker_engine_in_wsl: yes
* docker_engine_on_windows: disabled (recommended to prevent confusion)
* compose_execution_location: inside wsl2, from /mnt/d/ai/stacks/<stack>

task_scheduler_autostart (spec you requested)

* enabled: yes
* task_name: autostart-ai-stack
* trigger: at_startup
* delay_seconds: 45 (30–60 ok)
* run_as: SYSTEM
* highest_privileges: yes
* action:

  * executable: C:\Windows\System32\wsl.exe
  * args: -d Ubuntu -- bash -lc "cd /mnt/d/ai/stacks/<primary_stack> && docker compose up -d"
* retry_policy:

  * restart_interval_seconds: 60
  * restart_count: 5
* success_criteria:

  * docker ps returns success in wsl
  * expected containers are running

10. contract outputs (what the contract must generate)
    generated_artifacts

* shared_contract_file:

  * path: contracts/fuzlang.contract.yaml
  * consumed_by: both playbooks
* vaults

  * shared_vault: vault/shared.vault.yml
  * main_vault: vault/main.vault.yml
  * network_vault: vault/network.vault.yml
* rendered_env_files

  * main_env: rendered/main/.env
  * network_env: rendered/network/.env
* node_facts

  * main: /etc/fuzlang/node_facts.json (or windows equivalent path)
  * network: /etc/fuzlang/node_facts.json

verification_outputs (ansible must check)

* endpoint health checks:

  * main can reach langfuse_base_url
  * main can reach minio_api_url
  * network can reach ollama_base_url only if allowed
* gpu checks:

  * nvidia-smi works on main windows
  * nvidia-smi works inside wsl2
  * docker gpu test container works (if you use gpu in containers)
* drift checks:

  * docker engine running in wsl2 (main)
  * docker engine not running on windows (main) if you choose that rule

────────────────────────────────────────────────────────

what you still must supply (the only missing user inputs)

* main_node lan ip
* network_node lan ip
* whether hostname or ip is authoritative right now
* whether postgres/redis/clickhouse will ever be accessed directly from main (yes/no)
* the exact disk letters you’ll use on network_node for stacks/data
* your final exposure choice for litellm and ollama (localhost vs lan vs allowlist)

if you paste those few values, this becomes a fully deterministic contract that ansible can enforce without guessing, including “docker-in-wsl2 + task scheduler autostart” on the rtx 5090 main server.
