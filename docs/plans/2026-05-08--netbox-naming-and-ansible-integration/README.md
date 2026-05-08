# NetBox Naming And Ansible Integration Plan

Date: 2026-05-08

## Purpose

Use NetBox to improve the repo's source-of-truth model without trying to
migrate everything at once. The first useful slice is to test the existing VM
naming schema against NetBox's native model, then seed a small `server-225`
object set that Ansible can later consume.

This plan builds on:

- `docs/plans/2026-05-08--netbox-transition.md`
- `docs/ansible/vm-naming.md`
- `roles/ipam_netbox/README.md`
- `docs/ansible/ansible_capability_maturity_report_card.md`

## Current Ground Truth

- NetBox is deployed by `roles/ipam_netbox`.
- The owning playbook is `playbooks/deploy_ipam_netbox.yaml`.
- NetBox is reachable through the Windows LAN portproxy at
  `http://192.168.50.158:8000/`.
- Semaphore is reachable at `http://192.168.50.158:3001/`.
- The NetBox Ansible collection is declared in `requirements.yml`.
- Dynamic inventory should wait until a small, trusted NetBox object model
  exists.

## Recommended Path

Start with a tiny `server-225` modeling slice:

1. Map the repo's VM naming pattern to NetBox-native fields.
2. Decide which parts of the schema stay in the object name and which move to
   NetBox fields.
3. Seed only the minimum objects required for `server-225`.
4. Validate the model by comparing NetBox output against the current static
   inventory.
5. Add dynamic inventory only in shadow mode, not as a playbook dependency yet.

## Option 1: Naming Schema Fit Check

Goal: decide whether the current naming pattern fits NetBox cleanly.

Current repo pattern:

```text
<host-scope>-<role>-<nn>
```

Examples:

- `s225-dkr-01`
- `nsrv-dkr-01`
- `s225-k3s-01`

Initial mapping hypothesis:

| Naming part | Example | Candidate NetBox home | Notes |
| --- | --- | --- | --- |
| host scope | `s225`, `nsrv` | Site, device, cluster, or custom field | Decide whether this means physical host scope or broader site/location scope. |
| role code | `dkr`, `k3s` | VM role plus optional tag | Prefer NetBox VM role for primary function. Tags can express secondary automation intent. |
| sequence | `01` | VM name | Keep as part of the scoped identity. |
| OS/platform | `ubuntu`, `windows-server-2025` | Platform | Do not encode this in new VM names unless it is part of a legacy hostname. |
| IP address | `192.168.137.10` | VM interface and primary IP | Should be NetBox data, not name text. |
| host placement | `server-225` | Device or cluster relation | NetBox supports VMs assigned to a site, cluster, or device. |

Decision rule:

- Keep the VM name compact and stable.
- Put durable facts in native NetBox fields first.
- Use custom fields only when NetBox has no native model for the fact.
- Do not enforce a regex against legacy names until exceptions are retired
  intentionally.

Deliverable:

- `docs/plans/2026-05-08--netbox-naming-and-ansible-integration/naming-fit.md`

## Option 2: Model One Slice

Goal: seed only the `server-225` world in NetBox.

Candidate objects:

- Site: homelab or a chosen site name
- Device: `server-225`
- Platform: Windows Server 2025
- Cluster: `server-225-hyperv`
- VM: current `server-225-ubuntu` and/or future `s225-dkr-01`
- VM platform: Ubuntu
- IPs:
  - `192.168.50.158` for the Windows/LAN surface
  - `192.168.137.10` for the Ubuntu VM surface
- Tags:
  - `ansible-managed`
  - `homelab`
  - `hyperv`
  - `docker`

Deliverable:

- `roles/ipam_netbox/tasks/seed_server_225_model.yml`
- preview tag: `ipam_netbox_seed_server_225_model_preview`
- apply tag: `ipam_netbox_seed_server_225_model`

Current implementation note:

- The preview path is available now.
- The apply path requires `vault_netbox_api_token` in `vault.yml`.
- The current vault contains NetBox database/superuser secrets but not the API
  token yet.
- NetBox currently has an existing write-enabled admin token in the database,
  but it should not be adopted as the repo integration token. Create a
  dedicated Ansible/API token and store that encrypted as
  `vault_netbox_api_token` before running the apply tag.

## Option 3: Controlled Vocabulary First

Goal: seed tags, platforms, and roles before creating devices/VMs.

This is useful if naming decisions need one more pass before object creation.

Candidate vocabulary:

- Tags: `ansible-managed`, `homelab`, `hyperv`, `docker`, `k3s`, `infra`
- Platforms: Windows Server 2025, Ubuntu 24.04
- VM roles: Docker engine, k3s node
- Device roles: Hyper-V host, GPU host, storage/observability node

Deliverable:

- A repeatable `ipam_netbox_seed_*` path that creates the vocabulary by API.

## Option 4: Shadow Dynamic Inventory

Goal: prove NetBox can produce useful Ansible inventory without switching
playbooks to it.

Only after Option 1 and a minimal Option 2/3 model:

```bash
NETBOX_TOKEN=... ansible-inventory -i inventory/netbox.yml --graph
NETBOX_TOKEN=... ansible-inventory -i inventory/netbox.yml --host server-225-ubuntu
```

Expected grouping candidates:

- `device_roles`
- `platforms`
- `tags`
- selected composed vars for `ansible_host`

Deliverable:

- `inventory/netbox.yml` plus a comparison note against `inventory/inventory.yaml`.

## First Slice To Execute

Start with Option 1 + Option 2.

### Apply

Create `naming-fit.md`, map the current repo naming fields against NetBox
native fields, and stage the first `server-225` seed path behind a preview tag.

### Verify

Check the proposed mapping against:

- `docs/ansible/vm-naming.md`
- current `inventory/host_vars/server-225-win.yaml`
- current `inventory/host_vars/server-225-ubuntu.yaml`
- NetBox's VM, device, platform, role, tag, and custom-field model

### Undo

Remove the mapping note or seed task before any NetBox objects are created.

### Change Class

Planning and idempotent NetBox source-of-truth modeling. The current committed
slice does not mutate NetBox until an API token is added and the apply tag is
run.

## Open Questions

- Should `s225` represent the physical host, a site/location scope, or an
  operator shorthand only?
- Should current `server-225-ubuntu` remain the NetBox VM name until the VM is
  intentionally rebuilt, or should NetBox track a future intended name now?
- Should repo-specific automation intent live mostly in tags, custom fields, or
  config context?
- Which object should own the LAN published service endpoints: the Windows
  host device, the Ubuntu VM, or service records associated with the VM?

## Execution Status

- Option 1 mapping artifact created in `naming-fit.md`.
- Option 2 seed path staged in `roles/ipam_netbox/tasks/seed_server_225_model.yml`.
- No NetBox object mutation has been performed yet because the repo does not
  currently contain `vault_netbox_api_token`.
- Live inspection found an existing write-enabled admin API token, but it is
  not vault-backed for this project and should be treated as a bootstrap or
  throwaway token until rotated or replaced.

## Guardrails

- Do not switch playbook targeting to NetBox inventory until shadow inventory
  produces stable, understandable groups.
- Do not encode transient bootstrap details as durable NetBox facts.
- Do not create custom fields for data NetBox already models natively.
- Do not make NetBox the executor. NetBox owns facts; Ansible executes changes.
