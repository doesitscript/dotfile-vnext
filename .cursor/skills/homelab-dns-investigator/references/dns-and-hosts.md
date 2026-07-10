# DNS and hosts — homelab name resolution

Mac-dev resolver: search domain `hom.lab`, router DNS `192.168.50.1`.

## Suffix behavior

| Suffix | Mechanism | What resolves |
|---|---|---|
| *(bare)* | search `hom.lab` + hosts | hvh hosts via router; services via `/etc/hosts`; some guests via hosts |
| `.hom.lab` | Router DHCP/DNS (GT6) | `HOM-LAB-HVH-01` → `50.234`, `HOM-LAB-HVH-02` → `50.158` |
| `.local` | mDNS/Bonjour | `HOM-LAB-HVH-02.local` → often `50.159` (may differ from inventory `.158`) |
| `.lab` | — | Nothing in this homelab |

## Inventory LAN + guest map

### HOM-LAB-HVH-01 lane (storage / control)

| Name | LAN IP | Guest / service |
|---|---|---|
| `HOM-LAB-HVH-01` | `192.168.50.234` | Hyper-V host |
| `hom-lab-ctl-dkr-01` | — | guest `192.168.138.10` |
| `hom-lab-ctl-k3s-01` | — | guest `192.168.138.11` |
| Guest subnet | — | `192.168.138.0/24` via gateway `192.168.50.234` |

Port proxies on `50.234` → `138.10`: postgres `5432`, redis `6379`, clickhouse `8123`/`9004`, minio `9000`/`9001`.

### HOM-LAB-HVH-02 lane (GPU)

| Name | LAN IP | Guest / service |
|---|---|---|
| `HOM-LAB-HVH-02` | `192.168.50.158` | Hyper-V host (inventory) |
| `HOM-LAB-HVH-02.local` | `192.168.50.159` | mDNS alternate |
| `HOM-LAB-HVH-02-ipv6` | `fdfa:7038:521c:...` | IPv6 SSH fallback |
| `hom-lab-ctl-dkr-02` | — | guest `192.168.137.10` |
| `hom-lab-ctl-k3s-02` | — | guest `192.168.137.11` |
| Guest subnet | — | `192.168.137.0/24` via gateway `192.168.50.158` |

## `/etc/hosts` on mac-dev

Ansible SSOT: `inventory/group_vars/all/homelab_hosts_file.yml` → `homelab_hosts_file_mac`

hvh-02 lane only in hosts today; hvh-01 guests use static route `192.168.138.0/24 → 192.168.50.234`.

## Legacy — do not use

`network-server`, `HOM-LAB-HVH-01`, `nsrv-k3s-01` — not active DNS.

## Diagnosis patterns

```text
192.168.138.11 timeout → check route via 50.234 → ping/ssh hvh-01
HOM-LAB-HVH-02 SSH refused on .158 → try HOM-LAB-HVH-02-ipv6 or .local (.159)
```
