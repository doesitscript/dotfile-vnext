---
title: "GL.iNet Flint / OpenWrt — routing layer plan"
status: brainstorm
created: 2026-09-01
execution_status: pending
executed_at: null
prerequisite_plans:
  - windows-hyperv-management-static-ip-plan.md
---

# GL.iNet Flint / OpenWrt — routing layer plan

Pure plan for what the new router **will** own, what **stays** on Hyper-V/K3s/Ansible,
and how to migrate without double-NAT or premature cleanup.

**Prerequisite (same packet):** Complete
[windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md)
Phases 0–3 so `192.168.50.158` and `192.168.50.234` are stable on Windows before
Flint cutover. Update static gateway on both hosts when Flint replaces GT6 as
`192.168.50.1`.

---

## Execution marking

When this plan is fully executed:

1. Set `execution_status: executed` and `executed_at: YYYY-MM-DD` in frontmatter.
2. Rename → `flint-openwrt-routing-layer-plan.executed.md`

See [packet README](README.md) and
[brainstorming_designs README](../../README.md#executed-plan-marking).

---

## 1. Target topology

```text
AT&T Fiber Gateway (passthrough or DMZ to Flint WAN — verify during cutover)
        │
        ▼
GL.iNet Flint / OpenWrt          ← PRIMARY L3 (new)
  WAN · NAT · firewall · DHCP
  static routes · DHCP reservations
  DNS option advertisement (DNS-01 + DNS-02 when live)
        │
        ▼
ASUS ROG Rapture GT6             ← AP / AiMesh only (no router/NAT)
  existing SSIDs · mesh · radios
        │
        ├── 192.168.50.0/24 clients (unchanged addressing)
        ├── HOM-LAB-HVH-01 @ 192.168.50.234  (storage lane)
        ├── HOM-LAB-HVH-02 @ 192.168.50.158  (GPU lane)
        └── other reserved LAN hosts
```

**Non-goals for Flint:** VPN, AdGuard-on-router, QoS experiments, traffic
inspection, or making Flint the authoritative DNS platform. Keep it boring.

---

## 2. What Flint realistically offloads from the current design

These are **Category A (router responsibility)** items today forced onto the GT6
UI or operator memory. Flint becomes SSOT for them.

| Responsibility | Today (GT6) | After Flint |
| --- | --- | --- |
| Default gateway for LAN | `192.168.50.1` on GT6 | Flint LAN IP (preserve `.1` on Flint if practical) |
| DHCP pool + reservations | GT6 manual assign (`.50.x` only) | Flint static leases — same MAC/IP pairs |
| Static route `192.168.137.0/24` | GT6 → `192.168.50.158` | Flint → `192.168.50.158` |
| Static route `192.168.138.0/24` | GT6 → `192.168.50.234` | Flint → `192.168.50.234` |
| DHCP DNS options | GT6 default / ad hoc | Advertise DNS-01 + DNS-02 when commissioned |
| LAN firewall policy | GT6 (limited) | Flint (explicit allow LAN ↔ guest subnets) |

**Immediate wins:**

- Programmable static routes without ASUS UI friction.
- DHCP reservations in one place; retire stale GT6 rows during migration.
- Every LAN client (including `k3s-02` on `137.11`) gets guest-subnet routes
  **without** Mac-only static routes or per-host workarounds.
- GT6 limitation “cannot DHCP-assign `137.x` / `138.x`” stops mattering for
  **routing** — guests stay on Hyper-V subnets; Flint routes to them.

---

## 3. What Flint does **not** replace (keep on hosts)

| Layer | Owner | Examples |
| --- | --- | --- |
| Hyper-V virtualization | Windows + Ansible | Guest switches, `192.168.137.1` / `192.168.138.1` gateways, guest forwarding |
| Guest subnet mode | `hyperv_networking` | `guest_network_mode: routed_private_subnet`, `guest_outbound_nat_enabled: false` |
| Windows portproxy | Ansible (transition) | `guest_published_tcp_ports` on `.158` / `.234` — **retain until validated removable** |
| Langfuse data plane | dkr-01 + inventory | Postgres/Redis on `192.168.138.10`; stack via `deploy_network_stacks` |
| K3s / CNI / Traefik | Cluster roles | Service networking, ingress, NodePorts |
| Docker bridge | dkr VMs | Container ports on guest IPs |
| Authoritative DNS | DNS-01 / DNS-02 (future) | `hom.lab` records, filtering — Flint only **advertises** resolvers |
| NetBox / Ansible SSOT | Repo | Intent in inventory; Flint config manual first, automate later |

**Portproxy specifically:** Flint routing lets cluster consumers use
`192.168.138.10:5432` directly. Portproxy on `.234` is a **publish convenience**
for the inventory contract (`langfuse_platform_storage_windows_publish_host`).
Do **not** remove portproxy rows in the same weekend as Flint install. Sequence:

1. Flint routes live and verified.
2. Move in-cluster DB URLs to guest IP (inventory change).
3. Prove no consumer needs `.234:5432`.
4. Then shrink or remove storage-lane portproxy entries.

---

## 4. Responsibility matrix (post-Flint steady state)

```text
Flint          → L3 control: WAN, NAT, DHCP, static routes, LAN firewall, DNS option 6
GT6            → Wi‑Fi / mesh AP only
HVH-01 / -02   → Hyper-V, guest gateways, optional portproxy during transition
dkr-* / k3s-*  → Workloads on 137.x / 138.x
DNS-01 / -02   → hom.lab + filtering (Flint does not replace)
NetBox         → infrastructure intent (add Flint device/site when modeled)
Ansible        → host + cluster converge; router automation later
```

---

## 5. Migration phases

### Phase 0 — Before hardware arrives (repo, no Flint)

- [ ] Complete [windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md) (BIOS + static `.158` / `.234`)
- [ ] Export GT6 DHCP reservations + static routes from
      `homelab_router_gt6.yml` as Flint config checklist
- [ ] Confirm AT&T gateway mode (passthrough vs DMZ) for single-NAT path

### Phase 1 — Flint on bench / parallel (minimal risk)

- [ ] Flash/verify OpenWrt; set LAN `192.168.50.0/24` (same subnet — no renumber)
- [ ] Enter static leases (HVH-01 `.234`, HVH-02 `.158`, mac-dev `.33`, etc.)
- [ ] Enter static routes (`137.0/24` → `.158`, `138.0/24` → `.234`)
- [ ] Allow forward: LAN ↔ `137.0/24`, LAN ↔ `138.0/24` (firewall zones)

### Phase 2 — Cutover (maintenance window)

- [ ] Put GT6 in AP mode (or equivalent); disable GT6 DHCP/NAT/routing
- [ ] Wire: AT&T → Flint WAN; Flint LAN → GT6 uplink
- [ ] Verify: `ping 192.168.50.1` (Flint), guest `nc 192.168.138.10 5432` from mac-dev
- [ ] Verify: guest outbound internet from `hom-lab-ctl-dkr-01` / `dkr-02`
- [ ] Verify: LiteLLM / Langfuse recover without Mac-only `137.x` route

### Phase 3 — Validate then simplify (weeks, not day one)

- [ ] Remove `hyperv_guest_route_mac` from mac-dev if redundant
- [ ] Point `langfuse_platform_external_*` cluster consumers at `192.168.138.10`
- [ ] Reduce `guest_published_tcp_ports` on HVH-01 for DB ports if unused
- [ ] Add Flint to NetBox; add `inventory/group_vars/all/homelab_router_flint.yml` (future)
- [ ] Retire or archive `homelab_router_gt6.yml` operator rows

### Phase 4 — DNS (separate track)

- [ ] Commission DNS-01 / DNS-02
- [ ] Flint DHCP option 6 → both resolvers
- [ ] Replace `homelab_hosts_file_mac` guest hostname hacks with real `hom.lab` records
- [ ] Defer Traefik name-bridge on GT6 stock DNS (obsolete once DNS servers live)

---

## 6. GT6 after Flint

| GT6 today | After cutover |
| --- | --- |
| Router + DHCP + static routes | **AP / AiMesh node only** |
| Manual assign UI | **Unused** for infra (Flint owns leases) |
| Stale rows (`.70`, `.233`) | **Delete during GT6 demotion**, not migrated |
| `langfuse` / `litellm` fake MAC rows | **Cancel** — use DNS-01/02 + Traefik plan instead |

Verify exact GT6 “Access Point / AiMesh” mode in ASUS docs before cutover so
mesh backhaul and SSIDs survive.

---

## 7. Ansible / NetBox follow-ups (post-cutover, not blocking)

| Item | Priority | Notes |
| --- | --- | --- |
| `homelab_router_flint.yml` inventory SSOT | medium | Mirror `homelab_router_gt6.yml` shape |
| `roles/router_openwrt` or extend `router_local_dns` | low | Only after manual config is stable |
| `playbooks/router_access_validate.yaml` | low | SSH/uci read-only probes |
| Update `hyperv-router-static-route-guide.md` | medium | Point to Flint as operator surface |

**Rule:** manual Flint UI first; automate when the config has been stable for
one full infra event (reboot + guest egress test).

---

## 8. Problems Flint solves vs problems it does not

| Problem | Flint helps? |
| --- | --- |
| LAN clients cannot reach `137.x` / `138.x` without Mac static route | **Yes** |
| GT6 cannot DHCP-assign guest IPs | **Irrelevant** (routing, not DHCP on guest subnet) |
| `iphlpsvc` / portproxy wedge on HVH-01 | **Partially** — cluster can bypass via guest IP; portproxy still host-owned |
| dkr-01 stack down | **No** — still `deploy_network_stacks` |
| HVH reboot without Ansible converge | **No** — Hyper-V role still required |
| Prisma `ConnectError` when publish path dead | **Partially** — move contract to `138.10` |
| hom.lab DNS on LAN | **No** — DNS-01/02 track |
| K3s Traefik / ingress | **No** |
| `recover_ai_inference_lane` ordering gaps | **No** — repo orchestration |

---

## 9. Success criteria (Flint migration complete)

- [ ] Single NAT path (no double-NAT through GT6)
- [ ] All `homelab_router_gt6_static_routes` replicated on Flint
- [ ] All `router_enterable: true` leases on Flint with same IPs
- [ ] mac-dev reaches `192.168.137.10` and `192.168.138.10` **without** local static route
- [ ] AI stack recover playbook succeeds after cold HVH-01 reboot (with Ansible converge)
- [ ] GT6 serves Wi‑Fi only; no DHCP conflicts on `.50.0/24`

---

**Sources:** operator GT6 screenshots 2026-08-31;
`inventory/group_vars/all/homelab_router_gt6.yml`;
`inventory/host_vars/hom-lab-hvh-01.yaml`;
draft router considerations intake (2026-09-01).
