Guiding rule for all checkpoints (important)

Each checkpoint must satisfy:

clear start state

clear stop state

limited file surface area

no architectural guessing

contract may be refined, but not re-imagined

If a step violates any of those, agents start to hallucinate or over-optimize.

Checkpoint 1 — Canonical contract consolidation (foundation)
Goal

Produce one authoritative contract file that the rest of the repo obeys.

Inputs (agent may read)

all contract*.md files

spec-main-wsl2.md

spec-network-server.md

spec-rtx.md

winrm_ssh_checkpoints.md

Output

contracts/fuzlang.contract.yaml (fully populated, placeholders allowed)

no other files modified

Scope rules

merge, normalize, deduplicate

explicitly include:

mac-dev

server-225

network-server

dev-3090

explicitly declare:

winrm vs ssh surfaces

docker runtime per node

service placement

secrets scopes

storage authority

Done when

a human can answer “what runs where, how, and why” by reading only the YAML

no contradictory statements remain across docs

Why this works for agents

This is a bounded synthesis task, not code generation. Claude is very good at this.

Checkpoint 2 — Repo skeleton + governance rails
Goal

Create the final repo structure and governance rules, nothing else.

Inputs

fuzlang.contract.yaml

agreed folder structure (the one you locked in)

Outputs

full directory tree

empty placeholder files

docs/architecture_rules.md

Scope rules

do not implement roles

do not write playbooks logic

no variables beyond placeholders

Done when

tree matches the final structure exactly

every future file location is predetermined

Why this works

Agents are excellent at deterministic scaffolding when told not to be clever.

Checkpoint 3 — Inventory & node surfaces (control-plane correctness)
Goal

Make Ansible correctly aware of all nodes and their management surfaces.

Inputs

contract

repo skeleton

Outputs

inventory/inventory.yaml

inventory/group_vars/*

inventory/host_vars/*

Scope rules

implement the dual-surface model:

*-win (winrm)

*-wsl (ssh or wsl wrapper, per contract)

no role logic

no hardcoded secrets

Done when

each physical node is reachable in the correct way

no ambiguity about which surface runs which tasks

Why this works

This checkpoint isolates one of the highest-risk failure points (transport confusion).

Checkpoint 4 — Playbook wiring (no implementation yet)
Goal

Define execution flow without touching internals.

Inputs

inventory

contract

Outputs

all playbooks populated with:

correct hosts/groups

role ordering

no task bodies beyond includes

Scope rules

no task logic

no shell commands

no modules yet

Done when

a reader can understand lifecycle:

bootstrap → deploy → verify

nothing can accidentally run on the wrong surface

Why this works

Agents excel at declarative wiring when they don’t also have to invent logic.

Checkpoint 5 — Common baseline + verification (safe core)
Goal

Create the lowest-risk shared automation first.

Inputs

contract

inventory

playbooks

Outputs

roles/common/baseline

roles/common/health_checks

updates to verify_fabric.yaml

Scope rules

timezone

host identity

node facts

read-only verification

absolutely no service installs

Done when

can run verify_fabric across all nodes

second run is idempotent

Why this works

This gives you a “heartbeat” before touching complex systems.

Checkpoint 6 — Windows host bootstrap (winrm only)
Goal

Make Windows hosts structurally ready.

Inputs

contract

spec-main-wsl2.md

spec-network-server.md

spec-rtx.md

Outputs

windows_base roles for:

server-225

network-server

dev-3090

WSL enablement

SSH enablement

firewall skeletons

scheduled task scaffolding

Scope rules

winrm + PowerShell only

no docker compose

no linux logic

Done when

reboot-safe

WSL exists

SSH works

disks prepared

no runtime services yet

Why this works

This isolates “Windows weirdness” from everything else.

Checkpoint 7 — Linux / WSL runtime layer
Goal

Establish the steady-state runtime environment.

Inputs

contract

completed Windows bootstrap

Outputs

docker engine in WSL

compose support

directory mounts

runtime health checks

Scope rules

linux surface only

no windows feature changes

no guessing ports

Done when

docker ps works

compose up works

volumes land on correct disks

Why this works

This checkpoint is operationally critical but narrow.

Checkpoint 8 — Stack deployment per role (main / network / dev)
Goal

Bring up only the declared services.

Inputs

contract

rendered env strategy

stacks directory

Outputs

stacks running on:

server-225 (main)

network-server (authoritative)

dev-3090 (dev execution)

Scope rules

no cross-node drift

no new services

no port guessing

Done when

endpoints reachable

logs clean

restart safe

Why this works

By now, the agent is operating in a constrained, predictable environment.

Checkpoint 9 — Secrets & rendering pipeline (final glue)
Goal

Eliminate manual configuration permanently.

Inputs

vault files

contract outputs section

Outputs

rendered .env files

vault separation enforced

verify_fabric updated to check presence (not values)

Scope rules

no secrets printed

no duplication across scopes

Done when

secret rotation requires only vault edit + rerun

Why this checkpoint plan is “agent-safe”

no checkpoint mixes architecture + implementation

no checkpoint touches too many files

contract is revisited only when appropriate

each step produces a stable state

Yes — with the files you included, this plan allows Claude/Cursor to finish the project correctly.