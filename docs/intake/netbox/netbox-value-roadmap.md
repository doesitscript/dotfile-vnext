# NetBox Value Roadmap

Captured: 2026-05-08  
Updated: 2026-05-27

Status: Tier 1 largely complete for Hyper-V lane; Tier 2 in progress (prefixes + config contexts seeded)

## Baseline (completed)

- NetBox on `hom-lab-ctl-dkr-02` via Docker Compose
- Compact schema seeded: `hom-lab-ctl-hvh-01/02`, `hom-lab-ctl-dkr-01/02`, `hom-lab-ctl-k3s-01/02`
- Nine GPU-lane application services on dkr-02 / k3s-02
- `ansible.cfg` lists `inventory/netbox.yml` first; six `ansible-managed` hosts in `nb_inventory`
- `pg_dump` backup wired
- IPAM prefixes: `192.168.50.0/24`, `192.168.138.0/24`, `192.168.137.0/24` (tag `ipam_netbox_seed_prefixes`)
- Config contexts: `homelab-naming-context`, `homelab-hyperv-guest-routing` (tag `ipam_netbox_seed_config_contexts`)

Active plans:

- Finish roadmap (no edge dev): [`docs/plans/2026-05-27--netbox-wip-finish-roadmap-incomplete/README.md`](../../plans/2026-05-27--netbox-wip-finish-roadmap-incomplete/README.md)
- Edge dev hosts (deferred): [`docs/plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md`](../../plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md)

---

## Tier 1 — Prove the pipeline

### Step 1: Activate shadow inventory — DONE

`nb_inventory` returns six hosts with `ansible_host` from `primary_ip4`. Use tunnel API when LAN portproxy is down: `http://127.0.0.1:18000`.

### Step 2: Seed remaining live hosts — PARTIAL

Hyper-V lane complete. Edge dev hosts (`mac-dev`, `dev-3090-win`, `dev-workstation-win`) are a **separate deferred plan**, not this roadmap.

### Step 3: Fix nb_inventory token source — OPEN

`inventory/netbox.yml` still uses `lookup('env', 'NETBOX_TOKEN')`. Prefer vault-backed or `.envrc`-loaded token without manual export.

---

## Tier 2 — Extract real value

### Step 4: IP management — prefixes — DONE

| Subnet | Use |
|---|---|
| `192.168.50.0/24` | LAN management |
| `192.168.138.0/24` | hom-lab-ctl-hvh-01 guest network |
| `192.168.137.0/24` | hom-lab-ctl-hvh-02 guest network |

Apply: `--tags ipam_netbox_seed_prefixes`  
Verify: NetBox IPAM → Prefixes (count 3)

### Step 5: Remove duplicated IPs from static host_vars — OPEN (H5)

Requires stable `nb_inventory` and agreement on which hosts are NetBox-only. Tracked as H5 in name-alignment plan.

### Step 6: Service objects — PARTIAL

| Scope | Status |
|---|---|
| GPU lane (dkr-02, k3s-02) | Done — 9 services |
| Storage lane (dkr-01) | Open — when stacks deploy on dkr-01 |

---

## Tier 3 — Architecture shift

### Step 7: Primary inventory — PARTIAL

NetBox-first in `ansible.cfg`; static `inventory/inventory.yaml` still present as fallback.

### Steps 8–9 — OPEN

Pre-provision workflow and tag-based playbook selectors remain future work.

---

## Reference

- Seeding role: `roles/ipam_netbox/` — tasks `seed_prefixes.yml`, `seed_config_contexts.yml`
- Naming: `docs/plans/2026-05-08--netbox-naming-and-ansible-integration/`
- Shadow inventory: `inventory/netbox.yml`
- Networking: `docs/one_off_tasks/investigate_networking_issue.md`
