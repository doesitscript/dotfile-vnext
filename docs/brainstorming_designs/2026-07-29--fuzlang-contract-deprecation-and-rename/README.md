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

## References

- `contracts/fuzlang.contract.yaml` — the file in question
- `contracts/litellm.yaml` — newer LiteLLM-specific contract
- `contracts/open-webui.yaml` — newer Open WebUI contract
- `roles/k3s_litellm_gateway/defaults/main.yml` — uses `fuzlang_*` vars
- `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` — sets some `fuzlang_*` vars
