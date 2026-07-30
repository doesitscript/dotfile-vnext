---
title: "fuzlang.contract.yaml — Deprecation, Rename, and Decomposition"
status: brainstorm
created: 2026-07-29
---

# fuzlang.contract.yaml — Deprecation, Rename, and Decomposition

## Context

`contracts/fuzlang.contract.yaml` is a legacy scaffold from the early days of
the project. It already carries a `DEPRECATED SCAFFOLD` header (added
previously) but remains in the repo and is still referenced by live code.

## Issues

### 1. Misspelled product name

The filename uses "fuzlang" which does not match the actual product/project
name. The correct spelling needs to be determined and the file renamed (or
retired) accordingly.

This typo was introduced early as a voice-to-text/name-memory miss and then
spread into role names, variable prefixes, stack labels, and modeled service
identifiers.

### 2. Stale and duplicated content

The file contains ~600 lines covering:

- Node identity and addressing
- Cross-node endpoint maps
- Compose stack definitions
- Security policy and network rules
- Runtime notes and capability scaffolding

Much of this content has since migrated to authoritative locations:

| Section in fuzlang.contract.yaml | Current authoritative location |
|---|---|
| Node identity / addressing | `inventory/host_vars/`, NetBox |
| Endpoint map (`litellm_base_url`, etc.) | `inventory/group_vars/all/`, role defaults |
| Compose stacks | `policy/compose_stacks.yml`, role defaults |
| Security / network policy | `policy/`, role defaults, firewall roles |
| LiteLLM / Langfuse config | `roles/k3s_litellm_gateway/`, `contracts/litellm.yaml` |
| Open WebUI config | `contracts/open-webui.yaml` |

### 3. Live variable references still exist

Some live Ansible code still uses `fuzlang_*` variable names sourced from or
related to this contract:

- `fuzlang_external_postgres_connect_address` — used by `k3s_litellm_gateway`
  for the external PostgreSQL connection
- `fuzlang_external_postgres_port` — same
- `fuzlang_external_postgres_user` / `fuzlang_external_postgres_password` — same

These variables are defined in inventory and referenced in role defaults. They
work today but carry the misspelled prefix.

## Current blast radius (2026-07-30 sweep)

This is not just one legacy file name. Current repo usage falls into several
different risk classes:

### Low-risk text/doc references

- comments and prose in docs, plans, diagnostics, and lessons learned
- archive/history references that can be left as historical text

### Medium-risk repo structure references

- `roles/stacks_fuzlang_net/`
- `playbooks/deploy_network_stacks*.yaml`
- policy references such as `reference_role: roles/stacks_fuzlang_net`

These are repo-owned and can be renamed, but callers and docs must move
together.

### Higher-risk live variable contracts

- `inventory/group_vars/all/fuzlang_external_services.yml`
- `fuzlang_external_postgres_*`
- `fuzlang_external_redis_*`
- `fuzlang_external_clickhouse_*`
- `fuzlang_external_s3_*`
- `fuzlang_storage_windows_publish_host`

These feed live roles including:

- `roles/k3s_langfuse_platform/`
- `roles/k3s_litellm_gateway/`
- `roles/stacks_fuzlang_net/`

Blind replacement here is unsafe because current deployments and recovery
playbooks rely on these names.

### Highest-risk modeled/runtime identity strings

- Compose project name: `fuzlang-net`
- NetBox/service names: `postgres-fuzlang`, `redis-fuzlang`
- NetBox/service tags and metadata such as `stack-fuzlang-net`
- docker label filters like `com.docker.compose.project=fuzlang-net`

These may exist outside repo text too: in live containers, labels, published
service metadata, and NetBox-modeled objects. They cannot be treated as a
simple search/replace.

## Decision space

| Option | Description | Effort |
|---|---|---|
| A. Retire entirely | Delete the file, move any still-unique content to proper locations, rename `fuzlang_*` vars | High — needs var rename across roles/inventory |
| B. Rename + prune | Fix the filename spelling, remove sections that have migrated, keep as a thin cross-node reference | Medium |
| C. Break apart | Extract each section to its authoritative location, delete the file, rename vars | High |
| D. Keep as-is | Leave it deprecated with the header warning, address later | Low |

## Recommendation

Option A or C is the cleanest long-term path. The `fuzlang_*` variable rename
is the main effort — it touches `k3s_litellm_gateway` defaults, inventory
host_vars, and the vault. This could be done as a focused variable-rename PR.

Do not do a repo-wide blind rename. The safer path is a phased migration with
compatibility aliases:

1. Introduce a new correctly named shared contract file and variable surface.
2. Keep `fuzlang_*` as compatibility aliases that default to the new names.
3. Update consuming roles to prefer the new names while accepting the old ones.
4. Re-converge live automation and verify Langfuse/LiteLLM/data-plane callers.
5. Only then rename repo role names, stack labels, and modeled service names.
6. Retire the old aliases after verification receipts exist.

## Proposed migration phases

### Phase 1 — variable alias bridge

- Add a new canonical shared contract name for the external Langfuse data plane
- Preserve `fuzlang_*` vars as deprecated aliases
- Update role READMEs and comments to point at the new source of truth

### Phase 2 — consumer cutover

- Switch `k3s_langfuse_platform` and `k3s_litellm_gateway` to prefer the new
  canonical names
- Keep fallback to old names during the transition
- Run apply + verify on the AI lane after the cutover

### Phase 3 — structural rename

- rename `roles/stacks_fuzlang_net/` to a correct capability name
- update playbook callers, policy references, and docs
- preserve runtime labels only if live automation still depends on them

### Phase 4 — modeled identity cleanup

- evaluate whether `fuzlang-net`, `postgres-fuzlang`, `redis-fuzlang`, and
  `stack-fuzlang-net` should be renamed in NetBox and Docker metadata
- perform that as a declared NetBox/modeling change, not as incidental text
  cleanup

## Recommendation for current work

Treat this as a focused maturity packet, not a side-effect cleanup. The next
safe implementation slice is:

- create the new canonical variable surface
- add deprecated alias compatibility
- update Langfuse/LiteLLM consumers first
- defer role/NetBox/runtime identity renames to a second slice

## References

- `contracts/fuzlang.contract.yaml` — the file in question
- `contracts/litellm.yaml` — newer LiteLLM-specific contract
- `contracts/open-webui.yaml` — newer Open WebUI contract
- `roles/k3s_litellm_gateway/defaults/main.yml` — uses `fuzlang_*` vars
- `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` — sets some `fuzlang_*` vars
