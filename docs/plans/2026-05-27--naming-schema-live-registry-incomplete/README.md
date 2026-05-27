# Naming schema live registry

**Status:** Implemented 2026-05-27

**Cursor plan:** `.cursor/plans/schema_live_naming_map_fe625d78.plan.md`

## Outcome

Reconciled [`docs/reference/naming-standards/`](../../reference/naming-standards/) with live homelab naming from the NetBox/name-alignment workstream.

### Created

- [`live-object-registry.yml`](../../reference/naming-standards/live-object-registry.yml) — machine-readable live map + `retired_aliases` quarantine

### Updated

- `README.md`, `netbox.yml`, `render-patterns.yml`, `context.yml`, `resource-roles.yml`, `ansible.yml`, `enforcement.yml`, `source-reconciliation.yml`

### Doc hygiene

- Banner on [name-alignment plan](../2026-05-27--name-alignment-netbox-metadata-incomplete/README.md)
- Pointer on [netbox WIP brainstorming](../../brainstorming_designs/netbox_wip_capabiilty_usage_planning.md)

## Retired-name quarantine

Current names only in `live_hosts` and README “Live object map”. Old names only in `retired_aliases` and README “Retired names”.

## Apply / Verify / Undo

| | |
|--|--|
| **Apply** | Documentation committed |
| **Verify** | Quarantine grep on naming-standards (excl. archive + retired_aliases) |
| **Undo** | Revert doc commit |
| **Class** | Idempotent documentation |

## Related work (not in this packet)

- [Service identity Phases 2–4](../2026-05-27--service-identity-phases-2-4-incomplete/README.md) — L4 in NetBox, DNS, TLS
- [Service identity future-state](../2026-05-27--service-identity-dns-future-state/README.md) — layer model (Phase 0–1)
- [Edge dev naming](../2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md) — candidate hostnames only
