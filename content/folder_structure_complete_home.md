Got it. Treat it like a peer node, but name it like a real part of the fabric.

Here are naming options that fit your style (server-like, role-first, not “brother”), plus the contract/repo changes using one recommended choice.

Recommended node name + role (use this)

node name: dev-3090
role: dev-gpu-node
os: windows-11
purpose: programming + ollama + optional inference services

Why this works:

consistent with server-like naming

encodes what matters (dev + 3090)

doesn’t imply authority or ownership

fits alongside Server-225 and network-server without sounding goofy

Alternative naming options (pick one if you prefer)

more “server-like”

server-3090 (role still dev-gpu-node)

gpu-node-3090

compute-3090

more role-focused (no gpu in name)

dev-gpu-node

dev-compute-node

lab-gpu-node

more aligned with your current naming

server-3090-dev

server-dev-3090

If you want one that mirrors Server-225’s numeric pattern:

server-3090

server-3090-aux

Updated contract: add the Windows 11 dev GPU node

Add a peer node called dev-3090:

nodes.dev_node

name: dev-3090

role: dev-gpu-node

os: windows-11

authority_level: execution

docker_runtime: choose one (deterministic)

wsl2-ubuntu-docker-engine (recommended if you hate docker-on-windows there too)

windows-docker-engine

gpu: rtx-3090

persistent_data_allowed: limited

inbound_allowed: yes (restricted by port contract)

lan_ip: <to_be_filled>

Then update these sections:

service_placement (add optional services that may run here)

dev_ollama: dev-3090 (optional)

dev_litellm: dev-3090 (optional)

dev_worker: dev-3090 (optional batch/inference jobs)

endpoints (only if you expose them)

dev_ollama_base_url: http://dev-3090:11434

dev_litellm_base_url: http://dev-3090:4000

ports (same rules style as the other servers)

dev_ollama

port: 11434

exposure: restricted or lan

allowed_sources: [mac-dev, Server-225, network-server] (your choice)

dev_litellm

port: 4000

exposure: restricted or lan

allowed_sources: [mac-dev, Server-225, network-server]

secrets

shared_secrets readable by dev-3090 if it will:

send traces to langfuse

write artifacts to minio

dev_only_secrets:

local ui tokens, any local auth

outputs

vault/dev.vault.yml

rendered_env/dev/.env

node_facts/dev.json

Trust boundary default

dev-3090 is an execution peer like Server-225

it is not authoritative for storage

it does not receive db credentials unless you explicitly decide it must talk to dbs directly

Repo layout: rename “brother” to “dev” consistently

Minimal peer-node organization with consistent naming:

inventory/group_vars/

mac_dev.yaml

main_server.yaml

network_server.yaml

dev_gpu.yaml

inventory/host_vars/

mac-dev.yaml

Server-225.yaml

network-server.yaml

dev-3090.yaml

playbooks/

bootstrap_mac.yaml

bootstrap_server_225.yaml

bootstrap_network_server.yaml

bootstrap_dev_3090.yaml

deploy_dev_stacks.yaml

roles/

dev_3090/

windows_base/

ssh/

wsl2_or_windows_docker_runtime/

gpu_driver_validation/

stacks_dev/

stacks/dev/

ollama/

litellm/ (optional)

vault/

dev.vault.yml

rendered/dev/

.env

This makes it a first-class peer node without implying it owns anything critical.

One more naming improvement (optional but useful)

If you want total symmetry, you can also rename:

network-server → server-net (or storage-01)

Server-225 → server-225 (already fine)

But you don’t have to. dev-3090 slots in cleanly as-is.

If you want, I’ll lock this in by producing a single canonical snippet you can paste into your contract under nodes + service placement + ports + outputs using dev-3090 and dev_gpu.yaml naming, with placeholders only where you truly haven’t decided values yet (IP addresses, exposure choice).

so is hthis last message the findal udpated folder structure?

Yes — the last message defines the final, corrected folder structure for what you’ve decided.

Nothing is provisional anymore. What changed was naming and scope, not the model.

Below is the final authoritative structure, rewritten cleanly one last time so there’s no ambiguity about “is this the one.”

Final repository structure (authoritative)
fuzlang-infra/
│
├── README.md
│
├── contracts/
│   └── fuzlang.contract.yaml
│
├── inventory/
│   ├── inventory.yaml
│   ├── group_vars/
│   │   ├── all.yaml
│   │   ├── mac_dev.yaml
│   │   ├── main_server.yaml
│   │   ├── network_server.yaml
│   │   └── dev_gpu.yaml
│   │
│   └── host_vars/
│       ├── mac-dev.yaml
│       ├── server-225.yaml
│       ├── network-server.yaml
│       └── dev-3090.yaml
│
├── playbooks/
│   ├── bootstrap_mac.yaml
│   ├── bootstrap_server_225.yaml
│   ├── bootstrap_network_server.yaml
│   ├── bootstrap_dev_3090.yaml
│   ├── deploy_main_stacks.yaml
│   ├── deploy_network_stacks.yaml
│   ├── deploy_dev_stacks.yaml
│   └── verify_fabric.yaml
│
├── roles/
│   ├── common/
│   │   ├── baseline/
│   │   ├── firewall/
│   │   ├── ssh_keys/
│   │   └── health_checks/
│   │
│   ├── mac_dev/
│   │   ├── homebrew/
│   │   ├── dev_tools/
│   │   ├── dotfiles/
│   │   └── ansible_runner/
│   │
│   ├── server_225/
│   │   ├── windows_base/
│   │   ├── wsl2/
│   │   ├── docker_in_wsl/
│   │   ├── task_scheduler_autostart/
│   │   ├── gpu_driver_validation/
│   │   └── stacks_main/
│   │
│   ├── network_server/
│   │   ├── windows_base/
│   │   ├── docker_runtime/
│   │   ├── storage_layout/
│   │   ├── stacks_network/
│   │   └── backup_baseline/
│   │
│   └── dev_3090/
│       ├── windows_base/
│       ├── ssh/
│       ├── wsl2_or_windows_docker_runtime/
│       ├── gpu_driver_validation/
│       └── stacks_dev/
│
├── stacks/
│   ├── main/
│   │   ├── ollama/
│   │   ├── litellm/
│   │   └── openwebui/
│   │
│   ├── network/
│   │   ├── langfuse/
│   │   ├── postgres/
│   │   ├── clickhouse/
│   │   ├── redis/
│   │   └── minio/
│   │
│   └── dev/
│       ├── ollama/
│       └── litellm/
│
├── vault/
│   ├── shared.vault.yml
│   ├── main.vault.yml
│   ├── network.vault.yml
│   └── dev.vault.yml
│
└── rendered/
    ├── main/
    │   └── .env
    ├── network/
    │   └── .env
    └── dev/
        └── .env

What is now locked in

mac-dev, server-225, network-server, and dev-3090 are peers

All four are first-class Ansible targets

Authority is enforced by the contract, not by folder placement

Windows Server and Windows 11 nodes are treated consistently

GPU nodes (5090 + 3090) follow the same operational pattern

Docker runtime differences are explicit and deterministic

Nothing “special” is hidden or implied

This structure:

scales to more nodes

survives long gaps in memory

lets you onboard someone else without explanation

prevents accidental authority creep

maps cleanly to Ansible roles/playbooks

Final answer to your question

Yes.
This is the final updated folder structure.

If you want, the next clean steps are:

generate inventory.yaml once, correctly

fill fuzlang.contract.yaml with the locked decisions

write exactly one “hello-world” stack per node to validate wiring

Just tell me which one to do next.