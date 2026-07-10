# router_local_dns

Desired-state contract for **stock ASUS GT6** local DNS via **LAN → DHCP Server →
Manually Assigned IP** (Option C). **Not implemented** on the router yet — tasks
are preview/assert only until SSH or API automation exists.

## SSOT

Canonical row data lives in:

`inventory/group_vars/all/homelab_router_gt6.yml`

Do not duplicate MAC/IP pairs in role defaults or playbooks.

## Stock GT6 limitation (guest subnets)

The GT6 UI only accepts manual-assignment **IPs inside the LAN DHCP pool**
(typically `192.168.50.2`–`.254`).

Hyper-V guest addresses such as `192.168.137.10` and `192.168.137.11` are
**outside** that pool. The UI rejection is **expected** — not operator error.

| Need | Approach |
|------|----------|
| Guest ↔ LAN by IP | Upstream static route `192.168.137.0/24` → `192.168.50.158` (Job 1) |
| LAN-wide name for Windows host | Router row: `HOM-LAB-HVH-02` → `192.168.50.158` |
| Name for guest VMs on GT6 | **Not supported** — use IP or mac `/etc/hosts` workaround |
| mac-dev guest hostnames | Future `homelab_hosts_file_mac` ← `homelab_router_gt6_mac_hosts_workaround` |

See [asus-gt6-guest-subnet-not-enterable-in-dhcp-manual-assign.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/networking/asus-gt6-guest-subnet-not-enterable-in-dhcp-manual-assign.md).

## Related networking (different jobs)

| Job | Owner | Doc |
|-----|-------|-----|
| Job 1 — guest subnet routing | Operator static route on GT6 | [hyperv-router-static-route-guide.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-router-static-route-guide.md) |
| mac-dev → guest routes | `hyperv_guest_route_mac` | [README](../hyperv_guest_route_mac/README.md) |
| Job 2 — LAN DNS names | This role (future) + operator UI today | [asus-gt6-stock-local-dns-option-c.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/asus-gt6-stock-local-dns-option-c.md) |

Routing and DNS are separate. Job 1 does not require manual DNS rows for `.137.x`.

## Lifecycle

```yaml
router_local_dns_state: present | absent   # default absent via homelab_router_gt6_state
```

When `present`, the role currently **fails** with a message to apply GT6 rows
manually until automation tasks are added.

## Variables

| Variable | Source | Purpose |
|----------|--------|---------|
| `router_local_dns_manual_assignments` | `homelab_router_gt6_manual_assignments` | Full table including non-enterable guest rows |
| `router_local_dns_router_enterable_assignments` | filtered | Rows safe to push to GT6 automation |
| `router_local_dns_mac_hosts_workaround` | `homelab_router_gt6_mac_hosts_workaround` | Guest names for future mac `/etc/hosts` |

Per-row fields: `client_name`, `mac`, `ip`, `inventory_host`, `router_enterable`,
`router_action`, optional `workaround`, `notes`.

## Playbook

`playbooks/router_dns.yaml` — tags: `router_dns`, `router_dns_preview`

Preview:

```bash
ansible-playbook playbooks/router_dns.yaml -i inventory/inventory.yaml \
  --tags router_dns_preview -e router_local_dns_state=present
```

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | Operator edits GT6 UI from SSOT; future: automation when `router_local_dns_state: present` |
| **Verify** | `nslookup <client_name>.hom.lab 192.168.50.1` from a LAN client |
| **Undo** | Remove manual rows in GT6 UI |
| **Class** | Operator-owned today; idempotent automation future |

## Merlin

ROG Rapture GT6 has **no** Asuswrt-Merlin build. Do not plan on `dnsmasq.conf.add`
on this hardware.
