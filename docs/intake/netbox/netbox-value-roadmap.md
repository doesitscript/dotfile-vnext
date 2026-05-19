# NetBox Value Roadmap

Captured: 2026-05-08

Status: active planning — baseline seeding complete, pipeline not yet proven

## Baseline (completed as of 2026-05-08)

- NetBox running on `server-225-ubuntu` via Docker Compose
- `server-225` model seeded: site `homelab`, device `server-225`, cluster
  `server-225-hyperv`, VM `server-225-ubuntu`, primary IP, tags
  `ansible-managed homelab hyperv docker infra`
- `pg_dump` + media archive backup wired, contract-compliant paths verified
- Shadow dynamic inventory at `inventory/netbox.yml` — not yet proven or primary
- All static inventory files still drive playbooks

---

## Tier 1 — Prove the pipeline (this week)

Goal: confirm NetBox can produce correct Ansible inventory from what is already
seeded, without changing how any playbook runs.

### Step 1: Activate shadow inventory

Run `nb_inventory` against the seeded data and inspect the groups produced.

Expected groups from current seed:

| Group | Source |
|---|---|
| `site_homelab` | site tag |
| `tag_ansible_managed` | tag |
| `tag_docker` | tag |
| `tag_hyperv` | tag |
| `device_role_hyperv_host` | device role |
| `platform_ubuntu_2404` | platform |
| `cluster_server_225_hyperv` | cluster |
| `is_virtual_true` | VM type |

Verify: groups are present, `ansible_host` resolves from primary IP,
`server-225-ubuntu` appears in the correct groups.

Apply: `ansible-inventory -i inventory/netbox.yml --list`
Verify: group names match expectations above
Undo: nothing to undo — read-only operation
Change class: read-only verification

### Step 2: Seed remaining live hosts into NetBox

Add the rest of the live fleet so `nb_inventory` sees the full set:

| Host | Type | Role | Platform |
|---|---|---|---|
| `nsrv-dkr-01` | Virtual Machine | `docker-engine` | `ubuntu-24-04` |
| `dev-3090-win` | Device | TBD | `windows-*` |
| `dev-workstation-win` | Device | TBD | `windows-*` |

Approach: one seed task file per host following the `seed_server_225_model.yml`
pattern. Add a play per host in `deploy_ipam_netbox.yaml` with a scoped tag.

### Step 3: Fix nb_inventory token source

Current `inventory/netbox.yml` reads `NETBOX_TOKEN` from env. This is fragile
in different shell contexts. Replace with a consistent path that works
identically with `--vault-password-file` so no manual environment setup is
needed.

---

## Tier 2 — Extract real value (1–2 weeks after Tier 1 proves out)

Goal: make NetBox the authoritative source for data that currently lives in
static `host_vars` files.

### Step 4: IP management — add subnets as prefixes

Add known subnets to NetBox IPAM:

| Subnet | Use |
|---|---|
| `192.168.50.0/24` | LAN — primary management |
| `192.168.137.0/24` | Hyper-V internal switch |

With prefixes in place: NetBox tracks used vs available addresses per subnet.
`nb_inventory` derives `ansible_host` from the primary IP automatically
(already wired in `compose: ansible_host: primary_ip4`).

Apply: seed prefix objects via `netbox.netbox.netbox_prefix`
Verify: prefixes visible in NetBox UI under IPAM
Undo: delete via API or UI (no downstream breakage until Step 5)
Change class: idempotent seed

### Step 5: Remove duplicated IPs from static host_vars

Once IPs live in NetBox, the copies in `inventory/host_vars/*.yaml` are noise.
For each host covered by `nb_inventory`, delete `ansible_host` from the static
file and let NetBox own it.

Requires: Step 4 complete and Step 1 confirmed working.

Apply: remove `ansible_host` lines from host_vars for NetBox-managed hosts
Verify: `ansible-inventory --host <hostname>` shows correct IP from either source
Undo: restore static host_vars line
Change class: idempotent config — static inventory still present as fallback

### Step 6: Service objects

NetBox has a `Services` model: name, protocol, port, assigned to a VM or
device. Wire the known running services:

| Service | Host | Port | Protocol |
|---|---|---|---|
| netbox | `server-225-ubuntu` | 8000 | TCP |
| ansible-semaphore | `server-225-ubuntu` | 3000 | TCP |
| TBD (nsrv-dkr-01 services) | `nsrv-dkr-01` | TBD | TCP |

Once seeded, NetBox becomes a lightweight service registry queryable via API.
No more SSHing to check what's listening where.

Apply: seed via `netbox.netbox.netbox_service` module
Verify: services visible in NetBox UI on the VM detail page
Undo: delete via API
Change class: idempotent seed

---

## Tier 3 — Architecture shift (when Tier 2 is stable)

Goal: NetBox is the primary source of truth. Static inventory is a fallback or
retired for managed hosts.

### Step 7: Switch primary inventory to nb_inventory

When shadow inventory groups match static inventory groups, retire static files
for NetBox-managed hosts and make `nb_inventory` the primary source.

Milestone signal: running the same playbook against both `-i inventory/inventory.yaml`
and `-i inventory/netbox.yml` produces identical task targets.

### Step 8: Pre-provision workflow

Model a new VM in NetBox before deploying it. Assign cluster, role, platform,
and planned IP. The deploy playbook reads config from NetBox rather than from a
static `host_vars` file.

This is the full "NetBox as desired state" pattern. The VM does not exist yet
in Ansible inventory until it is added to NetBox. Adding it to NetBox is the
trigger.

### Step 9: Tags as playbook selectors

Target playbooks by NetBox tag instead of static inventory group name. Add a
tag to a host in NetBox (`k3s`, `monitoring`, etc.) and that host automatically
picks up the right playbook run. No inventory file edits required.

---

## Open Questions

- Should `s225` be a NetBox custom field, derived from cluster slug, or
  operator-shorthand only? (See `naming-fit.md` — deferred.)
- Should `server-225-ubuntu` be renamed in NetBox to the compact target name
  (`s225-dkr-01`) now, or only at the next VM rebuild?
- How should service endpoints with port proxies (non-standard ports on shared
  IPs) be modeled — NetBox Service objects, or stay in Ansible inventory as
  host vars?

---

## Reference

- Active seeding role: `roles/ipam_netbox/`
- Naming and fit check: `docs/plans/2026-05-08--netbox-naming-and-ansible-integration/`
- Naming contract: `.cursor/rules/framework-netbox-modeling.mdc`
- Backup: `roles/ipam_netbox/tasks/backup_db.yml` + `docs/backup/backup-naming-contract.md`
- Shadow inventory: `inventory/netbox.yml`
