---
name: NetBox WIP Finish Roadmap
lifecycle: incomplete
overview: Active finish path for NetBox WIP — IPAM prefixes, storage-lane services, config contexts, H5 static inventory retirement, ops blockers. Edge dev hosts are explicitly out of scope.
related_plans:
  - docs/plans/2026-05-27--netbox-ipam-completion-incomplete/README.md
  - docs/plans/2026-05-27--name-alignment-netbox-metadata-incomplete/README.md
out_of_scope_plans:
  - docs/plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md
todos:
  - id: prefixes
    content: "seed_prefixes.yml + three /24 prefixes"
    status: completed
  - id: storage-services
    content: "hvh-01 model services when dkr-01 stacks deployed"
    status: pending
  - id: config-contexts
    content: "seed_config_contexts.yml"
    status: completed
  - id: doc-refresh
    content: "netbox-value-roadmap + WIP doc refresh"
    status: completed
  - id: h5-static-inventory
    content: "Retire inventory/inventory.yaml; NetBox-derived group_vars"
    status: pending
isProject: false
---

# NetBox WIP Finish Roadmap

This is the **working finish plan** for NetBox remainder work after Hyper-V lane alignment.

## Out of scope

**Edge dev hosts** (`mac-dev`, `dev-3090-win`, `dev-workstation-win`) are **not** part of this roadmap. They are tracked separately and deferred:

→ [`docs/plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md`](../2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md)

## In scope (execute in this order)

1. **IPAM prefixes** — [`netbox-ipam-completion-incomplete`](../2026-05-27--netbox-ipam-completion-incomplete/README.md) Phase 1
2. **Storage-lane services** — same plan Phase 2 (when stacks on `hom-lab-ctl-dkr-01`)
3. **Config contexts** — same plan Phase 3
4. **Doc refresh** — same plan Phase 4
5. **H5 static inventory retirement** — [name-alignment plan](../2026-05-27--name-alignment-netbox-metadata-incomplete/README.md) open_work (after prefixes + stable 6-host `nb_inventory`)

**Parallel ops:** LAN NetBox portproxy; vault-backed `nb_inventory` token ([`docs/one_off_tasks/investigate_networking_issue.md`](../../one_off_tasks/investigate_networking_issue.md)).

## Done (do not repeat)

- Hyper-V compact names seeded; 6 hosts in `nb_inventory`
- GPU-lane service objects (9 services)
- `ansible.cfg` NetBox-first

## Cursor working copy

Same content (no edge dev): `.cursor/plans/netbox_wip_finish_roadmap_2c692012.plan.md`
