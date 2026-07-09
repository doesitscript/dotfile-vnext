# Homelab Naming Breakdown

This document captures the active naming schema and examples for the homelab inventory.

## Base patterns

`<tenant>-<environment>-<domain>-<role>-<idx>`

Example:

`hom-lab-ctl-dkr-02`

Physical Hyper-V Windows hosts and their matching Hyper-V cluster names now use:

`<tenant>-<environment>-<role>-<idx>`

Example:

`hom-lab-hvh-01`

## Field meanings

- `tenant`: hom-lab
- `environment`: lab or similar environment scope; currently implicit in the baseline schema
- `domain`: `ctl` — the current control-plane or management domain code for VM
  and service-layer identities
- `role`: runtime or identity role code such as `hvh`, `dkr`, `k3s`
- `idx`: two-digit ordinal index (canonical)

## Key domain/role codes

- `ctl`: control-plane / management domain
- `hvh`: Hyper-V host device
- `dkr`: Docker-engine VM runtime host
- `k3s`: K3s VM runtime host
- `k3c`: future control-plane semantic role for K3s control-plane identity
- `k3n`: future worker/node semantic role for K3s
- `ctr`: generic container host (candidate role)
- `ing`: ingress-controller semantic role (service-layer only)

## Current live names

| Name | Type | Lane | Notes |
|---|---|---|---|
| `hom-lab-hvh-01` | device | `hyperv_lane_storage` | Hyper-V storage lane, LAN `192.168.50.234`, guests `192.168.138.0/24` |
| `hom-lab-hvh-02` | device | `hyperv_lane_gpu` | Hyper-V GPU lane, LAN `192.168.50.158`, guests `192.168.137.0/24` |
| `hom-lab-ctl-dkr-01` | vm | storage | Docker VM on `hvh-01`, IP `192.168.138.10` |
| `hom-lab-ctl-dkr-02` | vm | GPU | Docker VM on `hvh-02`, IP `192.168.137.10` |
| `hom-lab-ctl-k3s-01` | vm | storage | K3s VM on `hvh-01`, IP `192.168.138.11` |
| `hom-lab-ctl-k3s-02` | vm | GPU | K3s VM on `hvh-02`, IP `192.168.137.11` |

## Naming guidance

- Keep context codes compact (2-3 characters).
- Use `idx` as the canonical two-digit ordinal field.
- Normalize any imported `seq` or `sequence` fields to `idx`.
- Keep friendly names longer only in descriptions; rendered hostnames should remain compact.
- Do not mix host/VM identity codes with service-layer role codes.

## Host / VM identity codes

- `hvh`, `dkr`, `k3s`, `k3c`, `k3n`

## Service identity codes

- `nbx`, `lfs`, `llm`, `sem`, `log`, `grf`, `red`

## Important notes

- `ctl` remains the active management/control domain code for VM and service-layer identities.
- Physical Hyper-V Windows hosts intentionally omit the domain segment in the current schema.
- `ing` is a semantic ingress-controller role and should not be used as a VM hostname role unless the host intentionally models ingress as its own identity.
- Hostnames are separate from service-layer names, DNS service names, and NetBox object names.
- The authoritative live map is `docs/reference/naming-standards/live-object-registry.yml`.

## Recommended reference files

- `docs/reference/naming-standards/live-object-registry.yml`
- `docs/reference/naming-standards/context.yml`
- `docs/reference/naming-standards/render-patterns.yml`
- `docs/reference/naming-standards/resource-roles.yml`
- `docs/reference/naming-standards/README.md`
