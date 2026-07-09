# ASUS GT6 Guest Subnet Not Enterable in DHCP Manual Assign

## Symptom

On stock ASUS ROG Rapture GT6 firmware, **Advanced Settings → LAN → DHCP Server →
Manually Assigned IP** rejects IP addresses such as `192.168.137.10` and
`192.168.137.11` even when the MAC and client name are correct.

## Root cause

The manual-assignment UI only accepts IPs inside the **LAN DHCP pool** (typically
`192.168.50.2`–`192.168.50.254`). Hyper-V guest VMs on the routed private subnet
(`192.168.137.0/24`) are **not** LAN DHCP clients. The router does not treat
those addresses as assignable pool entries.

This is a **product rule**, not operator error and not a guest misconfiguration.

## What still works without those rows

| Need | Mechanism |
|------|-----------|
| Guest ↔ LAN by IP | Upstream static route `192.168.137.0/24` → `192.168.50.158` (Job 1) |
| Windows host LAN name | Manual row for `HOM-LAB-HVH-02` @ `192.168.50.158` |
| Mac controller names for guests | Future `homelab_hosts_file_mac` from `homelab_router_gt6_mac_hosts_workaround` |
| SSH / Ansible | Inventory hostnames over SSH; use guest IPs |

Changing guest DNS or netplan does **not** make the GT6 UI accept `.137.x` rows.
Moving guests to `192.168.50.x` would break the routed-subnet design.

## Repo SSOT

Canonical MAC/IP/name rows (including `router_enterable: false` guests):

`inventory/group_vars/all/homelab_router_gt6.yml`

## Related docs

- [asus-gt6-stock-local-dns-option-c.md](../../diagnostics/asus-gt6-stock-local-dns-option-c.md)
- [asus-gt6-gpu-lane-router-current-state.md](../../diagnostics/asus-gt6-gpu-lane-router-current-state.md)
- [roles/router_local_dns/README.md](../../../roles/router_local_dns/README.md)
