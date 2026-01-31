Below is a **clean, canonical contract** that **adds a Mac development node** as a first-class participant **without contaminating runtime authority**.
This is written so it can be handed directly to “the main conversation,” checked into a repo, and consumed by Ansible on all nodes.

This is a **contract**, not prose: explicit fields, explicit intent, no inference.

---

FUZLANG MULTI-NODE CONTRACT
version: 1.0
timezone: America/Chicago

---

## 1) Nodes (authoritative inventory)

### mac_dev_node

* name: mac-dev
* role: development-control-plane
* os: macOS
* authority_level: non-authoritative
* persistent_data_allowed: no
* secrets_storage: local keychain + ansible vault (read-only shared)
* docker_runtime: optional (local testing only)
* rebuild_expectation: disposable / reprovisionable
* outbound_only: true

Purpose:
Authoring, testing, orchestration, Ansible execution.
Never authoritative for data, services, or secrets.

---

### main_node

* name: Server-225
* role: primary-gpu-node
* os: windows-server-2025
* authority_level: execution
* docker_runtime: wsl2-ubuntu-docker-engine
* gpu: rtx-5090
* persistent_data_allowed: limited (non-authoritative)
* outbound_and_inbound: true

Purpose:
GPU compute, inference, gateways, client-facing APIs.

---

### network_node

* name: network-server
* role: storage-observability-node
* os: windows-server-2025
* authority_level: authoritative
* docker_runtime: windows-docker-engine (or wsl2 if chosen later)
* persistent_data_allowed: yes
* outbound_and_inbound: true

Purpose:
Databases, Langfuse, MinIO, long-lived state.

---

## 2) Addressing & identity

* preferred_addressing: hostname (fallback: ip)
* mac_dev_node:

  * address: dynamic (no inbound assumptions)
* main_node:

  * hostname: Server-225
  * lan_ip: <to_be_filled>
* network_node:

  * hostname: network-server
  * lan_ip: <to_be_filled>

Rule:
mac_dev_node never appears in firewall allowlists.

---

## 3) Role map (service placement)

service_placement:

* ollama: main_node
* litellm_gateway: main_node (migration_candidate: true)
* openwebui: main_node
* langfuse_web: network_node
* postgres: network_node
* clickhouse: network_node
* redis: network_node
* minio: network_node

mac_dev_node runs:

* no long-running services
* no databases
* no gateways

---

## 4) Endpoint contract (canonical URLs)

endpoint_map:

* langfuse_base_url: [http://network-server:3000](http://network-server:3000)
* minio_api_url: [http://network-server:9000](http://network-server:9000)
* minio_console_url: [http://network-server:9001](http://network-server:9001)
* litellm_base_url: [http://Server-225:4000](http://Server-225:4000)
* ollama_base_url: [http://Server-225:11434](http://Server-225:11434)

tls_plan:

* lan_http_only: yes
* tls_later: yes

mac_dev_node usage:

* consumes endpoints
* never hosts endpoints

---

## 5) Port exposure contract

ports:

* langfuse_web:

  * port: 3000
  * exposure: lan
* minio_api:

  * port: 9000
  * exposure: lan
* minio_console:

  * port: 9001
  * exposure: lan
* postgres:

  * port: 5432
  * exposure: restricted
  * allowed_sources: [network_node, main_node]
* clickhouse:

  * ports: [8123, 9000]
  * exposure: restricted
  * allowed_sources: [network_node, main_node]
* redis:

  * port: 6379
  * exposure: restricted
  * allowed_sources: [network_node, main_node]
* litellm_gateway:

  * port: 4000
  * exposure: lan
* ollama:

  * port: 11434
  * exposure: localhost_only (default)

mac_dev_node: no inbound ports.

---

## 6) Secrets contract (critical)

### shared_secrets (readable by mac + main + network)

* FUZLANG_LANGFUSE_PUBLIC_KEY
* FUZLANG_LANGFUSE_SECRET_KEY
* FUZLANG_MINIO_ACCESS_KEY
* FUZLANG_MINIO_SECRET_KEY

### network_only_secrets

* FUZLANG_POSTGRES_PASSWORD
* FUZLANG_CLICKHOUSE_PASSWORD
* FUZLANG_REDIS_PASSWORD
* FUZLANG_LANGFUSE_NEXTAUTH_SECRET
* FUZLANG_LANGFUSE_SALT

### main_only_secrets

* FUZLANG_OPENWEBUI_ADMIN_TOKEN (if used)
* any local inference tokens

Rules:

* mac_dev_node may read shared secrets for templating
* mac_dev_node may not store or persist secrets
* secrets rendered only to main/network nodes

---

## 7) Storage contract

authoritative_data_node: network_node

storage_roots:

* mac_dev_node:

  * none (stateless)
* main_node:

  * windows_data_root: D:\ai
  * wsl_mount_root: /mnt/d/ai
  * authoritative_data: no
* network_node:

  * data_root: <disk>:\ai\data
  * stacks_root: <disk>:\ai\stacks
  * minio_disk: 8TB WD Red Plus
  * authoritative_data: yes

backup_policy:

* performed_on: network_node
* includes:

  * postgres volumes
  * clickhouse volumes
  * redis volumes
  * minio buckets

---

## 8) mac_dev_node setup contract (new)

mac_dev_node responsibilities:

* git repositories
* ansible execution
* ssh key management
* local validation/testing only

mac_dev_node tooling (managed by ansible):

* homebrew
* ansible
* docker (optional, dev-only)
* kubectl (optional)
* terraform (optional)
* shell + dotfiles

mac_dev_node prohibitions:

* no production docker compose up
* no direct writes to databases
* no secrets persistence
* no long-running services

---

## 9) WSL2 + Docker runtime contract (main node)

main_node_runtime:

* docker_runs_in_wsl2: yes
* distro: ubuntu
* systemd_enabled: yes
* docker_engine_on_windows: disabled
* compose_execution_path: /mnt/d/ai/stacks/<stack>

Task Scheduler autostart:

* enabled: yes
* trigger: at_startup
* delay_seconds: 45
* run_as: SYSTEM
* action:

  * wsl.exe -d Ubuntu -- bash -lc "cd /mnt/d/ai/stacks/<primary_stack> && docker compose up -d"
* retries: 5

---

## 10) Trust boundaries

trust_rules:

* mac_dev_node:

  * outbound only
  * no inbound trust
* main_node:

  * accepts LAN client traffic
  * talks to network_node services
* network_node:

  * accepts traffic only from main_node for databases
  * LAN access only for Langfuse/MinIO

---

## 11) Contract outputs (what automation must generate)

generated_artifacts:

* contracts/fuzlang.contract.yaml
* vault/shared.vault.yml
* vault/main.vault.yml
* vault/network.vault.yml
* rendered_env/main/.env
* rendered_env/network/.env
* node_facts/main.json
* node_facts/network.json

mac_dev_node receives:

* read-only contract
* no env files
* no vault files (except shared, decrypted at runtime only)

---

## 12) Explicit non-goals (lock this in)

* mac_dev_node is not a server
* mac_dev_node never holds data authority
* mac_dev_node is disposable
* only network_node is authoritative for state
* only ansible modifies server configuration

---

### Why this works

* Mac is a **control plane**, not a liability
* Servers are deterministic and isolated
* Secrets, storage, and trust are unambiguous
* Ansible has zero guesswork
* You can add CI later without changing the contract

If you want, next I can:

* Split this into **three Ansible inventories** (mac / main / network)
* Generate **role boundaries** so mac cannot accidentally deploy runtime services
* Produce a **diagram-level summary** that matches this contract exactly

Just say which.
