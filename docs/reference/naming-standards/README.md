# Naming Standards Schema

This directory is the active naming schema registry for this repo.

Use these machine-readable files first when creating, renaming, reviewing, or
reevaluating infrastructure resources. Longer research notes live in
`archive/` and are source material only until integrated here.

## Active Schema Files

| File | Purpose |
|---|---|
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

## Required Workflow

1. Check this schema before naming or renaming any resource.
2. Use NetBox native fields before tags, and tags before custom fields.
3. If the resource family is missing, record a schema gap and use the
   `critical-naming-analysis` skill to research approved references.
4. Any override must include a short rationale and cleanup plan.
5. Any replacement name requires a repo-wide stale-name search and NetBox seed
   reconciliation.

## Retired Names (do not use for new objects)

| Retired | Replacement |
|---------|-------------|
| `server-225`, `server_225` | `hyperv_lane_gpu` group; control host `hom-lab-ctl-hvh-02` |
| `server-225-ubuntu` | inventory host `hom-lab-ctl-dkr-02` |
| `network_server`, `network-server` | `hyperv_lane_storage` group; control host `hom-lab-ctl-hvh-01` |
| `server-225-hyperv` (NetBox cluster) | `hom-lab-ctl-hvh-02-hyperv` |

## Ansible Inventory Group Conventions

- **Capability groups** (`windows_hosts`, `linux_vm_hosts`, `logging_server`) —
  group by what automation is doing.
- **Physical Hyper-V lanes** (`hyperv_lane_gpu`, `hyperv_lane_storage`) — group
  by lane purpose (GPU execution vs storage/observability), not hostname copies.
- **Host identity** uses compact schema hostnames (`hom-lab-ctl-hvh-02`), not
  group names.

## Research Archive

Older prose-heavy research files were moved under `archive/` with status
suffixes:

- `*-integrated.md`: useful rules have been captured in active schema files.
- `*-not-yet-integrated.md`: source material remains under review.
- `*-tbd.md`: not implemented; revisit when that resource family becomes active.
