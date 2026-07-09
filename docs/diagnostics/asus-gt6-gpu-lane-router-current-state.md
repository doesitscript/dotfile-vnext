# ASUS GT6 GPU Lane Router Current State

## Purpose

Capture the current operator-applied ASUS router state for the GPU Hyper-V lane
and record what has already been verified from the repo side.

This is a current-state note, not an automation implementation.

## Scope

This note covers:

- the upstream ASUS router static route for the GPU guest subnet
- the current verification status for routed guest access
- the next repo-owned follow-up surfaces for local DNS and future SSH-driven
  router automation

It does not claim that router SSH access is enabled yet.

## Current manual router change

The upstream router now has a manually added static route for the GPU lane guest
subnet.

### ASUS GT6 row entered

Per ASUS FAQ 1011706-style field names:

| Field | Value |
|---|---|
| Network/Host IP | `192.168.137.0` |
| Netmask | `255.255.255.0` |
| Gateway | `192.168.50.158` |
| Metric | `1` |
| Interface | `LAN` |

### What this route means in repo terms

| Repo concept | Value |
|---|---|
| Windows Hyper-V host | `HOM-LAB-HVH-02` |
| Windows host LAN IP | `192.168.50.158` |
| Routed guest subnet | `192.168.137.0/24` |
| Guest gateway on Windows host | `192.168.137.1` |
| Active guest VM examples | `hom-lab-ctl-dkr-02` (`192.168.137.10`), `hom-lab-ctl-k3s-02` (`192.168.137.11`) |

## Follow-on router state

Since this note was first written, the storage lane route has also been added
on the GT6:

| Field | Value |
|---|---|
| Network/Host IP | `192.168.138.0` |
| Netmask | `255.255.255.0` |
| Gateway | `192.168.50.234` |
| Metric | `1` |
| Interface | `LAN` |

That means the current router target state is now:

- `192.168.137.0/24 -> 192.168.50.158`
- `192.168.138.0/24 -> 192.168.50.234`

The remaining convergence work is host-side symmetry and DNS/service-entry
design, not adding more router routes.

## Current verified behavior

The repo-side checks confirmed:

- `mac-dev` can still reach `192.168.137.10`
- TCP `:22` on `192.168.137.10` succeeds
- `http://192.168.137.10:8000/api/status/` returns `200`
- `hom-lab-ctl-dkr-02` regained outbound internet access
- `hom-lab-ctl-k3s-02` is reachable again on the routed subnet
- Windows `HyperVGuestNat` on `HOM-LAB-HVH-02` is `absent`

That combination matches the intended final routed-subnet design:

- no host NAT
- upstream router knows `192.168.137.0/24`
- guest outbound internet works
- direct guest-subnet reachability works

## Important verification caveat

`mac-dev` still has its own explicit local route for `192.168.137.0/24` via
`192.168.50.158`.

That means:

- Mac-to-guest success alone is not proof of the ASUS route
- the stronger proof is guest outbound internet working again after
  `HyperVGuestNat` was removed

## Current repo status

### Done now

- routed guest subnet design is active for the GPU lane
- upstream router static route is manually applied
- behavior-based verification succeeded from the repo side

### Not done yet

- router SSH access is not yet documented as enabled
- router automation against GT6 is not implemented (operator applies UI rows)
- Traefik / service hostnames on router DNS remain deferred

### Repo SSOT and scaffold (in progress)

| Surface | Purpose |
|---------|---------|
| [inventory/group_vars/all/homelab_router_gt6.yml](../../inventory/group_vars/all/homelab_router_gt6.yml) | Canonical manual-assignment rows, static route, mac workaround list |
| [roles/router_local_dns/README.md](../../roles/router_local_dns/README.md) | Role contract and GT6 pool limitation |
| [docs/diagnostics/asus-gt6-stock-local-dns-option-c.md](asus-gt6-stock-local-dns-option-c.md) | Operator walkthrough for Option C |
| `playbooks/router_dns.yaml` | Preview entrypoint (`router_dns_preview` tag) |
| [docs/plans/2026-05-28--hyperv-routed-subnet-convergence-and-traefik-name-bridge/README.md](../plans/2026-05-28--hyperv-routed-subnet-convergence-and-traefik-name-bridge/README.md) | official convergence + immediate name-bridge plan |
| [docs/intake/future-state-dns-authority-and-service-entry-architecture.md](../intake/future-state-dns-authority-and-service-entry-architecture.md) | proper long-term DNS/service-entry direction |

When `homelab_router_gt6_state` / `router_local_dns_state` remain `absent`, no
router mutation runs from Ansible.

## Next planned operator milestone

Job 2 is local DNS for LAN-wide service hostnames required for the Traefik name
path.

Initial target names expected from current repo direction:

| Hostname | Current target |
|---|---|
| `langfuse.hom.lab` | `192.168.50.158` |
| `litellm.hom.lab` | `192.168.50.158` |

These names are currently planning-level service-entry names tied to the
Traefik direction in the K3s intake work. The final DNS authority and record
ownership model are not locked yet.

## Future repo-owned surfaces

These are the intended future implementation surfaces once router SSH or other
automation access is proven:

| Surface | Purpose | Status |
|---|---|---|
| `docs/intake/asus-gt6-router-ssh-ddns-routing-intake.md` | planning and phased direction | active |
| `docs/plans/YYYY-MM-DD--asus-gt6-router-automation/README.md` | approved implementation plan packet | future |
| `inventory/host_vars/<router-host>.yaml` | router-specific connection and desired-state vars | future |
| `playbooks/router_access_validate.yaml` | read-only connectivity and feature validation | future |
| `playbooks/router_dns.yaml` | local DNS record management or validation | future |
| `roles/router_local_dns` | DNS record lifecycle | future |
| `roles/router_stock_ssh_access` | SSH enablement/validation if the product supports it cleanly | future |

## Stub values — moved to inventory SSOT

Static route and manual-assignment rows now live in
[inventory/group_vars/all/homelab_router_gt6.yml](../../inventory/group_vars/all/homelab_router_gt6.yml).

Deferred Traefik service names (`langfuse`, `litellm`, etc.) stay in the K3s
Traefik blueprint until that slice runs; they are not duplicated in the router
SSOT yet.

## Related repo surfaces

- [hyperv-router-static-route-guide.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-router-static-route-guide.md)
- [hyper-v-routed-subnet-needs-router-route-or-host-nat.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/networking/hyper-v-routed-subnet-needs-router-route-or-host-nat.md)
- [k3s-hyperv-traefik-blueprint.md](/Users/joshc/develop/dotfile-vnext/docs/intake/k3s-hyperv-traefik-blueprint.md)
- [2026-05-27--service-identity-phases-2-4-incomplete/README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-05-27--service-identity-phases-2-4-incomplete/README.md)
