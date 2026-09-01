---
title: "GL.iNet Flint / OpenWrt — routing layer supplement"
status: brainstorm
created: 2026-09-01
companion: flint-openwrt-routing-layer-plan.md
scope: routing-layer-only
execution_status: reference
---

# GL.iNet Flint / OpenWrt — routing layer supplement

**Packet:** [README.md](README.md). **Windows host prerequisite:**
[windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md).

**Execution marking:** Reference doc; executable plans in this packet use
`.executed.md` suffix when complete — see
[brainstorming_designs README](../../README.md#executed-plan-marking).

**Scope boundary — read this first**

This file covers only problems and analysis where the **routing layer** (today:
ASUS GT6; target: GL.iNet Flint) is the owner, the blocker, or what **incoming
hardware fixes**.

| Belongs **here** (supplement) | Belongs in [ansible-repo-actions-now.md](ansible-repo-actions-now.md) |
| --- | --- |
| Static routes to `137.x` / `138.x` | Portproxy / `iphlpsvc` on Windows |
| DHCP reservations on `.50.x` | dkr-01 stack uptime, Ansible converge |
| Default gateway / single NAT | Traefik, K3s ingress, HTTP publication |
| Mac-only static route workaround | Inventory DB URL / Path A vs B **decision** |
| GT6 UI limits (guest IPs not enterable) | Orchestration gates in recover playbook |
| Flint cutover checklist for routes & leases | DNS-01/02 design, long-term data-plane options |
| “Did routing work during the incident?” | “Why did `.234:5432` fail when `138.10` worked?” |

Migration phases: [flint-openwrt-routing-layer-plan.md](flint-openwrt-routing-layer-plan.md).

---

## 1. Routing baseline (unchanged addressing; new control point)

| Surface | Address | Routing role |
| --- | --- | --- |
| Main LAN | `192.168.50.0/24` | Flint becomes default gateway + DHCP |
| GPU guests | `192.168.137.0/24` | Reachable via static route → `192.168.50.158` (HVH-02) |
| Storage guests | `192.168.138.0/24` | Reachable via static route → `192.168.50.234` (HVH-01) |

Hyper-V still owns guest gateways (`137.1`, `138.1`) and forwarding on the
Windows hosts. Flint does **not** replace that — it only tells the **rest of
the LAN** how to reach those subnets.

---

## 2. Aug 2026 incident — **routing layer only**

Full symptom chain, portproxy analysis, and server actions:
[ansible-repo-actions-now.md](ansible-repo-actions-now.md) § Problems we hit.

What mattered **for routing** during that incident:

| Routing check | Result |
| --- | --- |
| GT6 static route `138.0/24` → `192.168.50.234` | **Present** — routing was not the primary failure |
| k3s-02 → `192.168.138.10:5432` (Path A, uses route) | **Worked** |
| k3s-02 → `192.168.50.234:5432` (Path B, Windows publish) | **Failed** — not fixable by router hardware |

**Takeaway for Flint:** the incident did **not** show “GT6 routes are wrong.” It
showed the **inventory default (Path B)** depended on Windows portproxy, while
**Path A already worked** with existing GT6 routes. Flint makes Path A reliable
for **all LAN clients** (no Mac static route) but does **not** fix Path B or
remove the need to change server-side connection strings.

---

## 3. What Flint fixes vs what it does not

### Fixed or improved by Flint (routing layer)

| Problem | How Flint helps |
| --- | --- |
| Guest subnets only reachable with per-host static routes | Flint static routes apply LAN-wide |
| GT6 as awkward SSOT for infra routes & DHCP | Programmable OpenWrt; migrate from `homelab_router_gt6.yml` |
| GT6 cannot DHCP-assign `137.x` / `138.x` | **Irrelevant** — guests are not LAN DHCP clients; Flint routes to them |
| Double-NAT / router role on GT6 | GT6 → AP mode; single NAT on Flint |
| Stale GT6 manual route drift | Flint becomes route SSOT after cutover |

### Not fixed by Flint (see actions-now)

| Problem | Owner |
| --- | --- |
| `iphlpsvc` / portproxy wedge on HVH-01 | Windows + `hyperv_networking` |
| Apps using `.234:5432` in connection strings | Inventory / Ansible decision |
| dkr-01 Docker stack down | `deploy_network_stacks` |
| Traefik / HTTP ingress | K3s roles |
| Authoritative `hom.lab` DNS | DNS-01 / DNS-02 |
| Recover playbook ordering | Repo orchestration |

---

## 4. GT6 → Flint: config to replicate

SSOT: `inventory/group_vars/all/homelab_router_gt6.yml`. Verified GT6 UI
2026-08-31.

### 4.1 Static routes (enable on Flint)

| Destination | Netmask | Gateway | Lane |
| --- | --- | --- | --- |
| `192.168.137.0` | `255.255.255.0` | `192.168.50.158` | GPU |
| `192.168.138.0` | `255.255.255.0` | `192.168.50.234` | Storage |

### 4.2 DHCP static leases (migrate to Flint)

| Client | MAC | IP | Inventory host |
| --- | --- | --- | --- |
| Joshs-MBP | `A4:5E:60:DB:AE:BF` | `192.168.50.33` | mac-dev |
| fiberBottleneck | `C8:94:02:15:DA:2F` | `192.168.50.38` | — |
| DESKTOP-C1ACPUM | `9C:C7:D3:88:BB:F0` | `192.168.50.133` | dev-workstation-win |
| hom-lab-ctl-hvh-02 | `B4:B5:B6:94:5A:BD` | `192.168.50.158` | HOM-LAB-HVH-02 |
| Gaming-Desktop | `14:F6:D8:7B:29:C9` | `192.168.50.191` | dev-3090-win |
| hom-lab-ctl-hvh-01 | `B8:86:87:F7:C8:6F` | `192.168.50.234` | HOM-LAB-HVH-01 |

**Do not migrate:** stale `DESKTOP-C1ACPUM` @ `.70`; `AI-NET-SERVER` @ `.233`
(delete at GT6 demotion).

**Do not add on Flint:** fake-MAC `langfuse` / `litellm` rows — HTTP names belong
on DNS-01/02 (server track in actions-now).

### 4.3 DHCP DNS option (Flint advertises; servers are separate)

When DNS-01/02 are live, Flint DHCP option 6 points clients at those resolvers.
Flint is **not** the authoritative DNS platform.

---

## 5. Workarounds retired by Flint (routing only)

| Workaround | Today | After Flint cutover |
| --- | --- | --- |
| `hyperv_guest_route_mac` on mac-dev | Static route `137.0/24` → `.158` | **Remove** after verify |
| GT6 static route maintenance | Manual UI | Flint SSOT |
| GT6 `router_local_dns` / Option C | Stock DNS hacks | Cancelled — DNS servers |
| Per-client “how do I reach `138.x`?” | Depends on GT6 + maybe Mac route | Flint routes for everyone |

Portproxy on HVH-01/HVH-02 is **not** a routing-layer workaround in this sense —
it is host publish logic. Retiring it is a **server/inventory** decision
(actions-now), not a Flint install task.

---

## 6. Routing-layer verification (post-Flint)

From any LAN client (e.g. mac-dev):

```bash
# Guest subnets reachable without host-local static route?
nc -zv 192.168.137.10 22
nc -zv 192.168.138.10 5432

# Default gateway is Flint?
route -n get default    # macOS — gateway should be Flint LAN IP
```

From a guest VM — return path / internet (proves route + Windows forwarding):

```bash
ping -c 1 192.168.50.1
nc -zvw3 1.1.1.1 443
```

Failure on guest egress after Flint routes exist → check Windows forwarding /
guest gateway (host), not Flint static route rows alone.

---

## 7. Routing-layer Q&A

| Question | Answer (routing scope only) |
| --- | --- |
| Was GT6 routing broken in Aug 2026? | **No** — `138.10` worked; publish path failed elsewhere |
| Will Flint fix Prisma `ConnectError`? | **Only if** apps already use Path A (`138.10`); not if they still use `.234` portproxy |
| Do I still need GT6 static routes until cutover? | **Yes** — keep GT6 rows until Flint is live |
| Can I delete Windows portproxy when Flint arrives? | **No** — not a routing-layer change; see actions-now |
| Mac static route needed after Flint? | **No** (verify, then remove `hyperv_guest_route_mac`) |

---

**Sources:** GT6 screenshots 2026-08-31;
`inventory/group_vars/all/homelab_router_gt6.yml`;
`docs/diagnostics/hyperv-router-static-route-guide.md`;
`docs/diagnostics/asus-gt6-gpu-lane-router-current-state.md`.

Server-side incident detail:
[ansible-repo-actions-now.md](ansible-repo-actions-now.md).
