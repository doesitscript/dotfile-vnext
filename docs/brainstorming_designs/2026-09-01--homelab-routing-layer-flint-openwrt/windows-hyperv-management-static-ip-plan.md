---
title: "Windows Hyper-V management static IPv4 — implementation plan"
status: brainstorm
created: 2026-09-01
packet: 2026-09-01--homelab-routing-layer-flint-openwrt
execution_status: pending
executed_at: null
depends_on_packets:
  - flint-openwrt-routing-layer-plan.md
related:
  - windows-hyperv-management-static-ip-ai-brief.md
---

# Windows Hyper-V management static IPv4 — implementation plan

Pin **`host_ip`** on each Hyper-V host’s **management vNIC** (`vEthernet (External)`)
using **static IPv4 inside Windows**, with router DHCP reservations kept as
documentation. Stops DHCP drift (e.g. HVH-02 `.159` vs `.158`) and stabilizes
portproxy `listen_address` bindings.

**Part of packet:** [README.md](README.md) — runs **before or in parallel with**
[Flint routing cutover](flint-openwrt-routing-layer-plan.md); independent of Flint
hardware arrival.

**Do not execute Ansible phases until operator completes Phase 0 (BIOS).**

---

## Execution marking

When this plan is **fully executed** (all phases verified):

1. Set `execution_status: executed` and `executed_at: YYYY-MM-DD` in this file’s frontmatter.
2. Rename: `windows-hyperv-management-static-ip-plan.md` →
   `windows-hyperv-management-static-ip-plan.executed.md`
3. Rename companion AI brief the same way if it was used during execution.

Convention started **2026-09-01** — see
[brainstorming_designs README](../../README.md#executed-plan-marking).

---

## Target addresses

| Host | `host_ip` | Management vNIC | Physical uplink | Gateway | DNS (today) |
| --- | --- | --- | --- | --- | --- |
| `HOM-LAB-HVH-02` | `192.168.50.158` | `vEthernet (External)` | RZ608 Wi‑Fi 6E (single radio) | `192.168.50.1` | `192.168.50.1` |
| `HOM-LAB-HVH-01` | `192.168.50.234` | `vEthernet (External)` | TP-Link Wi‑Fi 6 PCIe only | `192.168.50.1` | `192.168.50.1` |

Prefix: `/24` (`255.255.255.0`). Router reservations unchanged (same MAC/IP).

---

## Phase 0 — Operator (BIOS / hardware) — **in progress**

**Goal:** One Wi‑Fi uplink on HVH-01; no competing onboard radio.

| Step | Owner | Status |
| --- | --- | --- |
| Schedule shutdown `HOM-LAB-HVH-01` | Agent / operator | **done** — `shutdown /s /t 120` via `ssh HOM-LAB-HVH-01` (2026-09-01) |
| Disable **onboard Wi‑Fi** in BIOS (HVH-01) | Operator | **pending** |
| Confirm **PCIe TP-Link** remains enabled; External switch uplink unchanged | Operator | pending after reboot |
| Delete stale GT6 row `AI-NET-SERVER` @ `192.168.50.233` when convenient | Operator | pending (Flint migration may supersede GT6) |
| Power on; verify SSH `HOM-LAB-HVH-01` on `.234` only | Operator | pending |

**HVH-02:** No onboard-Wi‑Fi disable required (single RZ608 adapter in inventory).

---

## Phase 1 — Repo: extend `roles/hyperv_networking` (not executed)

### Ansible module research (2026-09-01)

Searched **installed collections** (`requirements.yml`: `ansible.windows` ≥3.3,
`community.windows` ≥2.0, `gocallag.hyperv`), **Context7** (`/ansible-collections/ansible.windows`,
`/ansible-collections/community.windows`, `/ansible/ansible-documentation`),
**Galaxy** (`ansible-galaxy collection search`), **HRL** (no Windows static-IP
module notes), and **existing repo** `roles/hyperv_networking`.

| Capability | Recommended module / surface | Galaxy / community? | Notes |
| --- | --- | --- | --- |
| Disable DHCP on management vNIC | `ansible.windows.win_powershell` → `Set-NetIPInterface -Dhcp Disabled` | **No** dedicated module | No `win_ipaddress` / `win_net_ipaddress` in `ansible.windows` or `community.windows` (verified `ansible-doc -l`). Community pattern is `win_shell`/`win_powershell` + `New-NetIPAddress` ([Stack Overflow / Ansible docs consensus](https://stackoverflow.com/questions/60181867/ansible-is-there-a-way-to-change-a-windows-server-ip-address-using-ansible)). |
| Assign static IPv4 + prefix on `vEthernet (External)` | `ansible.windows.win_powershell` → `New-NetIPAddress` | **No** | **Extend** existing idempotent block in `routed_private_subnet.yml` (~line 250) — today adds alias IP only when portproxy probe fails; static mode must run **unconditionally** and disable DHCP first. |
| Default gateway (`0.0.0.0/0`) on named interface | `ansible.windows.win_powershell` → `New-NetRoute` / `Remove-NetRoute` | Partial: `ansible.windows.win_route` exists | **Keep PowerShell** — `win_route` has no `interface_alias` / `InterfaceIndex`; unsafe if multiple adapters share a subnet. Repo already has interface-scoped gateway block (~line 303). |
| DNS servers on management vNIC | **`ansible.windows.win_dns_client`** | **Yes** — first-party | Replace inline `Set-DnsClientServerAddress` in the gateway/DNS block when refactoring; params: `adapter_names`, `dns_servers`. |
| Boot DHCP recovery (`ipconfig /release` / `/renew`) | Existing `management_os_boot_recovery_*.yml` | **Repo-owned** | Set `management_os_boot_recovery_state: absent` on static hosts (Phase 4). |
| Hyper-V switch / VM NIC | `gocallag.hyperv.*` | Installed | `vm_nwadapter` is **guest** scope only — not management OS. |
| Onboard Wi‑Fi disable (HVH-01) | **BIOS** (Phase 0) | N/A | `community.windows.win_net_adapter_feature` can disable `ms_tcpip` binding but does not replace BIOS disable for a second physical radio. |
| `netsh interface portproxy` | `ansible.windows.win_powershell` | **No** | Unchanged; out of scope for this plan. |

**Conclusion:** Do **not** add a third-party Galaxy role for static IP — none found,
and the repo already owns the right `win_powershell` idiom. Phase 1 is a **refactor +
mode gate**, not a greenfield custom script: reuse `host_ip`, `public_gateway_ipv4`,
`public_dns_servers_ipv4`, and `_hyperv_routed_public_adapter_alias`; adopt
`win_dns_client` where it replaces duplicated DNS PowerShell.

### Inventory contract

Add under `hyperv_config`:

```yaml
management_os_ipv4_mode: static   # dhcp | static (default dhcp)
management_os_ipv4_address: "{{ host_ip }}"
management_os_ipv4_prefix_length: 24
```

### Implementation shape

- New include: `tasks/management_os_static_ipv4.yml` — orchestrates static path;
  delegates IP/DHCP to `win_powershell`, DNS to `win_dns_client`, gateway via
  shared interface-scoped `win_powershell` (or extracted from existing block).
- Wire in `main.yml` **after** External switch creation when
  `management_os_ipv4_mode == static` (not only inside portproxy recovery).
- Refactor `routed_private_subnet.yml` gateway/DNS task to call `win_dns_client`
  and share logic with static include (avoid two divergent copies).
- **No** `ipconfig /release` / `/renew` on static path.
- Update `meta/argument_specs.yml` and role README (note: no upstream module for
  IP assignment — PowerShell is the evidence-based choice).

Agent detail: [windows-hyperv-management-static-ip-ai-brief.md](windows-hyperv-management-static-ip-ai-brief.md).

---

## Phase 2 — Apply HVH-02 (not executed)

**Inventory** (`inventory/host_vars/hom-lab-hvh-02.yaml`):

```yaml
hyperv_config:
  management_os_ipv4_mode: static
  management_os_boot_recovery_state: absent
```

**Apply / verify:**

```bash
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml \
  --limit HOM-LAB-HVH-02 --tags hyperv_windows_host_preview

ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml \
  --limit HOM-LAB-HVH-02 --tags hyperv_networking
```

**Evidence:** `PrefixOrigin Manual` on `vEthernet (External)`; IP `192.168.50.158`;
preview `missing_listen_addresses: []`; `nc` key portproxy ports from `mac-dev`.

---

## Phase 3 — Apply HVH-01 (not executed — after Phase 0 complete)

**Precondition:** Onboard Wi‑Fi disabled in BIOS; only TP-Link PCIe present.

**Inventory** (`inventory/host_vars/hom-lab-hvh-01.yaml`):

```yaml
hyperv_config:
  management_os_ipv4_mode: static
  management_os_boot_recovery_state: absent
  # clarify comments: onboard Wi-Fi disabled BIOS 2026-09-01; uplink TP-Link PCIe
```

**Apply / verify:** same playbooks with `--limit HOM-LAB-HVH-01`.

**Evidence:** static `.234` on `vEthernet (External)`; storage portproxy listeners;
`nc 192.168.50.234 5432` from `mac-dev` after stack up.

---

## Phase 4 — Retire DHCP boot recovery (both hosts, after Phases 2–3)

| Item | Action |
| --- | --- |
| `management_os_boot_recovery_state` | `absent` on both hosts |
| Scheduled task `\Ansible\HyperV\HyperVManagementOsBootRecovery` | Removed by role cleanup |
| Manual `ipconfig /release` / `/renew` for LAN stability | Drop operational habit |
| Router DHCP reservation | **Keep** (belt + suspenders) |

**Still required:** `configure_hyperv_windows_hosts` after reboot for portproxy,
forwarding, guest gateway — static IP does not replace that.

---

## Relationship to Flint packet

| Concern | Static IP plan | Flint plan |
| --- | --- | --- |
| Stop `.158` / `.234` drift on Windows | **This plan** | No |
| LAN-wide routes to `137.x` / `138.x` | Helps once IP is stable | **Flint static routes** |
| Portproxy / `iphlpsvc` | Unchanged | No |
| Gateway `192.168.50.1` → Flint LAN IP later | Update static gateway at Flint cutover | **Flint Phase 2** |

Recommended order: **Phase 0 (BIOS) → Phases 1–3 (static IP) → Flint cutover**
(update gateway on both hosts when Flint becomes `.1`).

---

## Change class

| | |
| --- | --- |
| **Apply** | `configure_hyperv_windows_hosts.yaml` per host |
| **Verify** | Preview receipt + `PrefixOrigin Manual` + portproxy probe |
| **Undo** | Re-enable DHCP on vNIC; `management_os_boot_recovery_state: present` |
| **Class** | Idempotent host networking |

---

**Sources:** `inventory/host_vars/hom-lab-hvh-{01,02}.yaml`;
`docs/plans/2026-07-09--homelab-lan-edge-drift-remediation-incomplete/findings.md`;
`docs/lessons-learned/hyper-v/network-ip-address-investigation.md`;
`roles/hyperv_networking/tasks/routed_private_subnet.yml`;
`requirements.yml` (`ansible.windows`, `community.windows`);
Context7 `/ansible-collections/ansible.windows`,
`/ansible-collections/community.windows`;
`ansible-doc ansible.windows.win_dns_client`,
`ansible-doc ansible.windows.win_route`.
