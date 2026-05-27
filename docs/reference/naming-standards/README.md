# Naming Standards Schema

This directory is the active naming schema registry for this repo.

Use these machine-readable files first when creating, renaming, reviewing, or
reevaluating infrastructure resources. Longer research notes live in
`archive/` and are source material only until integrated here.

## Active Schema Files

| File | Purpose |
|---|---|
| `live-object-registry.yml` | **Live map** — current homelab hosts, clusters, prefixes, services, groups, and quarantined retired aliases. |
| `context.yml` | Canonical context fields, codes, aliases, and index rules. |
| `render-patterns.yml` | Rendered naming patterns for hosts, VMs, services, storage, and canonical IDs. |
| `resource-roles.yml` | Compact resource role codes grouped by resource family. |
| `ansible.yml` | Ansible collection, role, variable, tag, and preflight naming rules. |
| `netbox.yml` | NetBox field mapping, compact slugs, config context, tags, and future enforcement fields. |
| `azure-ai.yml` | Azure AI resource naming family for upcoming AI work. |
| `enforcement.yml` | Enforcement maturity levels and rename cleanup requirements. |
| `source-reconciliation.yml` | What was captured from intake and old reference files. |

## Current Baseline

```text
<tenant>-<environment>-<domain>-<role>-<idx>
```

Example:

```text
hom-lab-ctl-hvh-01
```

Rules:

- Context codes are normally 2-3 characters.
- `idx` is the canonical two-digit ordinal field.
- Imported `seq` or `sequence` fields normalize to `idx`.
- `ctl` is the current control-plane or management domain code.
- Friendly names and descriptions may be longer; slugs, codes, and rendered
  resource names stay compact.
- NetBox must be consulted for infrastructure facts, but live NetBox naming is
  not authoritative until reconciled to this schema.

## Live object map (current names)

Authoritative detail: [`live-object-registry.yml`](live-object-registry.yml).

| Name | Type | Lane | Guest / LAN |
|------|------|------|-------------|
| `hom-lab-ctl-hvh-01` | device | `hyperv_lane_storage` | LAN `192.168.50.234`, guests `192.168.138.0/24` |
| `hom-lab-ctl-hvh-02` | device | `hyperv_lane_gpu` | LAN `192.168.50.158`, guests `192.168.137.0/24` |
| `hom-lab-ctl-dkr-01` | vm | storage | `192.168.138.10` |
| `hom-lab-ctl-dkr-02` | vm | GPU | `192.168.137.10` |
| `hom-lab-ctl-k3s-01` | vm | storage | `192.168.138.11` |
| `hom-lab-ctl-k3s-02` | vm | GPU | `192.168.137.11` |

Clusters: `hom-lab-ctl-hvh-01`, `hom-lab-ctl-hvh-02`.

IPAM prefixes: `192.168.50.0/24`, `192.168.138.0/24`, `192.168.137.0/24`.

Config contexts: `homelab-naming-context`, `homelab-hyperv-guest-routing`.

**Naming layers** (do not mix): `inventory_hostname` (Ansible/NetBox), `os_hostname`
(on-machine), `router_hostname` (LAN DNS), `ansible_connect_target` (`ansible_host`),
`host_ip`, `physical_node` (metadata only), `ansible_group` (targeting). See
`inventory/hosts_mapping.yaml` and `live-object-registry.yml` → `naming_layers`.

**Not in NetBox yet:** `mac-dev`, `dev-3090-win`, `dev-workstation-win` — see edge-dev plan.

**Candidate names only:** `hom-lab-exe-mac-01`, `hom-lab-aix-gpu-01`, `hom-lab-dev-wks-01`.

## Service identity and DNS (Phase 0)

NetBox services use **layers** — not one name for everything:

| Layer | Example (NetBox UI) | Purpose |
|-------|---------------------|---------|
| L1 slug | `netbox-web` | NetBox `service.name`, compose/stack identity |
| L2 VM | `hom-lab-ctl-dkr-02` | Parent machine |
| L3 access | `http://192.168.50.158:8000/` | How you reach it **today** (`primary_access_point`) |
| L4 logical | `hom-lab-ctl-nbx-01` | DNS/cert/ingress stem **before** a zone exists |
| L5 fqdn | *(unset)* | When you add internal or public DNS |
| L6 canonical | `cst-hom-lab-ctl-service-netbox-01` | Docs/diagrams only |

- **Registry:** `live-object-registry.yml` → `service_identities` (L1→L4 map; not in seeds yet).
- **Patterns:** `render-patterns.yml` → `service_identity_layers`; `service` pattern = **L4 only**.
- **Context vocabulary:** `netbox.yml` / `context.yml` → `value_by_surface` (`cst` vs `castle`, `hom` vs `home`).
- **Future work:** [`docs/plans/2026-05-27--service-identity-phases-2-4-incomplete/README.md`](../plans/2026-05-27--service-identity-phases-2-4-incomplete/README.md) (Phase 1 apply, Phases 2–4: NetBox L4, DNS, TLS/LB).
- **Background:** [`docs/plans/2026-05-27--service-identity-dns-future-state/README.md`](../plans/2026-05-27--service-identity-dns-future-state/README.md).

Do **not** rename `netbox-web` to `hom-lab-ctl-nbx-01` in NetBox without an explicit migration; assign L4 alongside L1 when Phase 2 is approved.

## Retired names (do not use for new objects)

Full quarantine list: `live-object-registry.yml` → `retired_aliases`.

| Retired alias | Replacement |
|---------------|-------------|
| Retired: `server-225`, `server_225` | `hom-lab-ctl-hvh-02` / group `hyperv_lane_gpu` |
| Retired: `server-225-ubuntu` | `hom-lab-ctl-dkr-02` |
| Retired: `network_server`, `network-server`, `network-server-win` | `hom-lab-ctl-hvh-01` / group `hyperv_lane_storage` |
| Retired: `server-225-hyperv` (NetBox cluster) | `hom-lab-ctl-hvh-02` |
| Retired: `hvh_02` (inventory group) | `hyperv_lane_gpu` |
| Retired: `auth`, `aut` (domain codes) | `ctl` |
| Retired: `home-lab-auth-hvh-01`, `home-lab-auth-hvh-02` | `hom-lab-ctl-hvh-01`, `hom-lab-ctl-hvh-02` |

## Diagram IDs

Diagram files are their own schema family. They intentionally keep a reserved
`dia` marker in the identifier so documentation artifacts are easy to spot and
do not get confused with hostnames, NetBox object names, or service logical
hostnames.

- Pattern: `cst-hom-lab-ctl-dia-<name>-<idx>`
- Example: `cst-hom-lab-ctl-dia-gpu-topology-01`
- Rationale:
  - diagrams are documentation artifacts, not infrastructure objects
  - `dia` is a family marker, not an accidental static token
  - the marker improves scanability in `docs/diagrams/` and the live registry

By contrast, Hyper-V cluster names do **not** keep a `-hyperv` suffix. The
virtualization layer belongs in NetBox `cluster_type`, while the cluster name
stays on the compact baseline schema.

## Ansible Inventory Group Conventions

- **Capability groups** (`windows_hosts`, `linux_vm_hosts`, `logging_server`) —
  group by what automation is doing.
- **Physical Hyper-V lanes** (`hyperv_lane_gpu`, `hyperv_lane_storage`) — group
  by lane purpose (GPU execution vs storage/observability), not hostname copies.
- **Host identity** uses compact schema hostnames (`hom-lab-ctl-hvh-02`), not
  group names.

## Schema gaps (candidate only)

| Code | Status | Notes |
|------|--------|-------|
| `exe` | candidate | execution-plane Mac (`hom-lab-exe-mac-01`) |
| `wks` | candidate | dev workstation role |
| `gpu` | candidate | dedicated GPU Windows host role |
| `sem`, `log`, `grf`, `red` | candidate | L4 service codes (see `service_identities`) |

## Required Workflow

1. Check this schema and `live-object-registry.yml` before naming or renaming.
2. Use NetBox native fields before tags, and tags before custom fields.
3. If the resource family is missing, record a schema gap and use the
   `critical-naming-analysis` skill to research approved references.
4. Any override must include a short rationale and cleanup plan.
5. Any replacement name requires a repo-wide stale-name search and NetBox seed
   reconciliation.

## Research Archive

Older prose-heavy research files were moved under `archive/` with status
suffixes:

- `*-integrated.md`: useful rules have been captured in active schema files.
- `*-not-yet-integrated.md`: source material remains under review.
- `*-tbd.md`: not implemented; revisit when that resource family becomes active.
