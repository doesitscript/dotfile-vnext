---
name: NetBox authority enforcement and framework extension
overview: >-
  Promote the NetBox kingmaker intake into the active framework and runtime
  contract: harden NetBox-scoped plan governance, add a reusable authority gate,
  and stage inventory-root compatibility without breaking current targeting.
scope: implementation
lifecycle: implemented
completion_percent: 100
netbox_scope: true
promoted_from: docs/intake/netbox-kingmaker-project-overall-wip.md
depends_on_plans: []
unblocks:
  - docs/plans/2026-05-28--netbox-authority-gate-implementation-incomplete/README.md
  - docs/plans/2026-05-28--netbox-inventory-root-compatibility-incomplete/README.md
child_plans:
  - docs/plans/2026-05-28--netbox-authority-gate-implementation-incomplete/README.md
  - docs/plans/2026-05-28--netbox-inventory-root-compatibility-incomplete/README.md
---

# NetBox authority enforcement and framework extension

**Promoted from:** [netbox-kingmaker-project-overall-wip.md](../../intake/netbox-kingmaker-project-overall-wip.md)

**Design intent:** NetBox becomes blocking for NetBox-scoped work in this repo, but not a universal prerequisite for bootstrap, recovery, or unrelated capabilities.

## Summary

- Keep the current conditional model: NetBox is blocking for `netbox_scope: true` work and for plans that touch naming, services, registry, DNS intent, or ingress metadata.
- Add one repo-local authority gate and one read-only reconciliation playbook so the repo has a concrete execution graph, not narrative-only guidance.
- Stage NetBox-as-inventory-root behind a compatibility child plan; do not break `site.yaml` or current static group routing.
- Preserve the layered service-identity model: L1 NetBox service slug remains distinct from L4 logical hostname.

## Architecture/Structure Diagram

```mermaid
graph TB
  intake["docs/intake/netbox-kingmaker-project-overall-wip.md"]
  umbrella["This umbrella packet"]

  subgraph framework [Framework enforcement]
    agents["AGENTS.md"]
    partner["docs/codex_framework/partner_process.md"]
    plansreadme["docs/plans/README.md"]
    planreceipt["docs/codex_framework/plan-verification-receipt.md"]
    rules["framework-plan-governance.mdc<br/>framework-partner-process.mdc<br/>framework-netbox-modeling.mdc"]
  end

  subgraph runtime [Runtime gate]
    playbook["playbooks/reconcile_netbox.yaml"]
    gate["bin/netbox-authority-gate.sh"]
    static["scripts/check_netbox_plan_governance.sh"]
    artifacts["artifacts/netbox-reconciliation/<date>/*.json"]
    svcart["artifacts/netbox-service-inventory/latest.json"]
  end

  subgraph netbox [Live NetBox + runtime]
    api["NetBox API"]
    infra["Docker / K3s / Hyper-V / DNS intent"]
    nbinv["inventory/netbox.yml"]
  end

  subgraph children [Child plans]
    authgate["netbox-authority-gate-implementation"]
    invroot["netbox-inventory-root-compatibility"]
    consumers["existing DNS / Traefik / vLLM packets"]
  end

  intake --> umbrella
  umbrella --> framework
  umbrella --> runtime
  umbrella --> children
  playbook --> api
  playbook --> infra
  gate --> static
  gate --> playbook
  playbook --> artifacts
  playbook --> svcart
  nbinv --> api
```

## Capability Routing Diagram

```mermaid
graph LR
  req["Plan or execution request"] --> scope{"Touches NetBox-managed naming,<br/>services, registry, DNS intent,<br/>ingress, or NetBox SSOT facts?"}
  scope -->|No| normal["Normal repo plan/execute path"]
  scope -->|Yes| nb["Require netbox_scope: true + Mandatory NetBox slice"]

  nb --> mode{"Bootstrap or recovery of NetBox itself?"}
  mode -->|Yes| exception["Allowed exception with explicit bootstrap/recovery labeling<br/>and apply/verify/undo contract"]
  mode -->|No| preview["Run authority gate preview"]

  preview --> result{"Declared / Applied / Verified pass?"}
  result -->|No| blocked["Block promotion, execute-complete, and CI pass"]
  result -->|Yes| proceed["Allow live apply or reconciliation receipt updates"]
```

## Naming/Modeling Diagram

```mermaid
graph TD
  l1["L1 service.slug<br/>netbox-web"]
  l2["L2 VM<br/>hom-lab-ctl-dkr-02"]
  l3["L3 primary_access_point<br/>http://192.168.50.158:8000/"]
  l4["L4 logical_hostname<br/>hom-lab-ctl-nbx-01"]
  l5["L5 fqdn<br/>nbx.hom.lab or chosen zone"]
  matrix["Authority matrix<br/>NetBox facts vs runtime facts vs derived DNS"]

  l1 --> l2
  l2 --> l3
  l4 -. alongside .-> l1
  l4 --> l5
  matrix --> l1
  matrix --> l3
  matrix --> l4
```

## Mandatory NetBox slice

### Objects affected

- Devices, VMs, interfaces, IP addresses, prefixes, config contexts, services, ingress metadata, DNS intent rows, tags, clusters

### Declared / Applied / Verified

- **Declared:** plan packets, framework rules, naming schema, playbooks, and gate scripts align on NetBox-scoped blocking behavior.
- **Applied:** live NetBox apply remains on the existing `ipam_netbox_seed_*` surfaces; this umbrella adds read-only reconciliation and packet enforcement, not a new mutation path.
- **Verified:** `scripts/validate_netbox_repo_consistency.sh`, `artifacts/netbox-service-inventory/latest.json`, `artifacts/netbox-reconciliation/latest.json`, and `artifacts/netbox-reconciliation/latest.inventory-compatibility.json` are the standard receipt surfaces.

### Apply method

- Reuse `netbox.netbox` collection and current `ipam_netbox` seed tasks for live mutation.
- Reuse `pynetbox` controller dependency through existing repo runtime for read-only API checks.
- Use `playbooks/reconcile_netbox.yaml` and `bin/netbox-authority-gate.sh` as the shared enforcement path.

### Promotion gate

- NetBox-scoped plans are not complete until receipt evidence covers Declared, Applied, and Verified surfaces.
- Bootstrap and recovery exceptions are allowed only when explicitly labeled as bootstrap/recovery work and kept out of steady-state completion claims.

## Checklist

- [x] **NF-1** — Promote intake to umbrella packet and add child packets
- [x] **NF-2** — Framework docs and rules aligned on NetBox-scoped blocking behavior plus bootstrap/recovery exception
- [x] **NF-3** — Runtime authority gate and reconciliation playbook added
- [x] **NF-4** — Existing NetBox-scoped plans updated to the new Mandatory NetBox slice shape
- [x] **NF-5** — CI/static enforcement scaffolded for the new packet format

## Child plans

- [netbox-authority-gate-implementation](../2026-05-28--netbox-authority-gate-implementation-incomplete/README.md)
- [netbox-inventory-root-compatibility](../2026-05-28--netbox-inventory-root-compatibility-incomplete/README.md)

## Apply / Verify / Undo / Change class

| | |
|--|--|
| **Apply** | Update framework/docs/plan packets; add `playbooks/reconcile_netbox.yaml`, `bin/netbox-authority-gate.sh`, and static plan governance checks |
| **Verify** | Static packet gate, Ansible syntax/lint, read-only `bin/netbox-authority-gate.sh`, reconciliation artifacts |
| **Undo** | Revert the packet/rule/runtime additions; remove new gate/playbook surfaces |
| **Class** | Idempotent governance + read-only runtime verification |

## Plan verification receipt

**Slice:** umbrella introduction  
**Verified at:** 2026-05-28T17:00:26Z

| ID | Source | Obligation | In slice scope? | Status | Evidence |
|----|--------|------------|-----------------|--------|----------|
| O-01 | NF-1 | Umbrella + child packets exist | yes | complete | This packet plus `docs/plans/2026-05-28--netbox-authority-gate-implementation-incomplete/README.md` and `docs/plans/2026-05-28--netbox-inventory-root-compatibility-incomplete/README.md` |
| O-02 | NF-2 | Framework/rules use one NetBox-scoped blocking rule | yes | complete | `AGENTS.md`, `docs/plans/README.md`, `docs/codex_framework/partner_process.md`, `docs/codex_framework/plan-verification-receipt.md`, `.cursor/rules/framework-plan-governance.mdc`, `.cursor/rules/framework-partner-process.mdc` |
| O-03 | NF-3 | Authority gate and reconciliation playbook exist | yes | complete | `bin/netbox-authority-gate.sh`, `playbooks/reconcile_netbox.yaml`, `artifacts/netbox-reconciliation/latest.json` pass at `2026-05-28T16:59:22Z` |
| O-04 | NF-4 | Existing NetBox-scoped packets updated | yes | complete | Existing NetBox-scoped packets now carry Mandatory NetBox slice + Plan verification receipt sections, including `docs/plans/2026-05-28--homelab-dns-adguard-authority-incomplete/README.md` and `docs/plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md` |
| O-05 | NF-5 | Static CI/local enforcement exists | yes | complete | `scripts/check_netbox_plan_governance.sh`, `.github/workflows/netbox-authority-gate.yml`, `artifacts/netbox-reconciliation/latest.inventory-compatibility.json` |

## Diagram gate receipt

- [x] Architecture/Structure: repo paths, external resources, data/control flow, naming scheme, variable SSOT sources, tag/playbook wiring
- [x] Capability Routing: included
- [x] Naming/Modeling: included
- [x] Diagram Inventory lists every required section above, not only diagrams actually drawn

## Diagram Inventory

### Diagrams Included

- Architecture/Structure Diagram
- Capability Routing Diagram
- Naming/Modeling Diagram

### Additional Diagrams Available On Request

- Coverage metric flow for Declared / Applied / Verified receipts
- Inventory compatibility map from static groups to NetBox-derived groups
- CI lane split between static packet checks and live secret-backed reconciliation
