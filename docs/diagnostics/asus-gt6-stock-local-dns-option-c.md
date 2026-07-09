# ASUS GT6 Stock Local DNS — Option C (Manual DHCP Assignments)

## Purpose

Operator walkthrough for **stock GT6** LAN hostnames using **DHCP domain +
Manually Assigned IP** rows. This is **Job 2** (optional names). **Job 1**
(routed guest subnet) is separate and already documented in
[asus-gt6-gpu-lane-router-current-state.md](asus-gt6-gpu-lane-router-current-state.md).

**SSOT for row data:** [inventory/group_vars/all/homelab_router_gt6.yml](../../inventory/group_vars/all/homelab_router_gt6.yml)

## When to use this

| Do | Skip |
|----|------|
| Job 1 static route (guest ↔ LAN by IP) | Merlin on GT6 (unsupported model) |
| Option C if you want `*.hom.lab` for LAN hosts | Option C for `192.168.137.x` guests on stock GT6 |
| Nothing if IPs are enough | Pi-hole / separate DNS VM (out of scope) |

## What a “row” means

One line in **Manually Assigned IP** with:

- **Client name** → becomes `clientname.hom.lab`
- **MAC address** (real or `00:00:00:00:00:00` for fixed-IP hosts)
- **IP address** (must be in the LAN DHCP pool for stock firmware)

## Part 1 — DHCP domain and DNS

1. Open `http://192.168.50.1` or `http://www.asusrouter.com`
2. **Advanced Settings → LAN → DHCP Server**
3. **Enable DHCP Server** = Yes
4. **Domain Name** = `hom.lab`
5. **DNS Server 1** = blank (clients use router) or `192.168.50.1`
6. **Apply** if changed

References: [ASUS FAQ — manually assign LAN IP](https://rog.asus.com/support/faq/1000906/), [ASUS FAQ — DHCP server](https://rog.asus.com/support/faq/1011703/).

## Part 2 — Enable manual assignment

1. **Enable Manual Assignment** = Yes
2. Add each row from SSOT where `router_enterable: true`
3. **Apply**

## GPU lane — enter on GT6 now

| Client name | MAC | IP | Notes |
|-------------|-----|-----|--------|
| `HOM-LAB-HVH-02` | `B4:B5:B6:94:5A:BD` | `192.168.50.158` | Rename from `DESKTOP-VLLM` |
| `Joshs-MBP` or `mac-dev` | `A4:5E:60:DB:AE:BF` | `192.168.50.33` | Optional rename |
| `HOM-LAB-HVH-01` | `B8:86:87:F7:C8:6F` | `192.168.50.234` | Rename from `AI-NET-SERVER` @ .234 |

**Delete:** `AI-NET-SERVER` / `9C:C7:D3:10:68:5A` / `192.168.50.233`

## GPU guests — do not enter on GT6

| Client name | MAC | IP | Why |
|-------------|-----|-----|-----|
| `hom-lab-ctl-dkr-02` | `00:15:5D:32:9E:1A` | `192.168.137.10` | Outside 50.x pool |
| `hom-lab-ctl-k3s-02` | `00:15:5D:32:9E:1B` | `192.168.137.11` | Outside 50.x pool |

See [asus-gt6-guest-subnet-not-enterable-in-dhcp-manual-assign.md](../lessons-learned/networking/asus-gt6-guest-subnet-not-enterable-in-dhcp-manual-assign.md).

## Verify

```bash
nslookup HOM-LAB-HVH-02.hom.lab 192.168.50.1
```

Expect `192.168.50.158`.

## Merlin

GT6 is **not** on the [Asuswrt-Merlin supported list](https://www.asuswrt-merlin.net/).
Use stock Option C only.

## Ansible preview (when scaffold is applied)

```bash
ansible-playbook playbooks/router_dns.yaml -i inventory/inventory.yaml \
  --tags router_dns_preview -e router_local_dns_state=present
```

## Related

- [hyperv-router-static-route-guide.md](hyperv-router-static-route-guide.md) — Job 1 routing
- [roles/router_local_dns/README.md](../../roles/router_local_dns/README.md)
