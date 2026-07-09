# Report output example — homelab-dns-investigator

Example `report.md` shape after a full investigation. Service endpoint detail lives in the published-endpoints subskill section (linked, not duplicated).

---

# DNS and Connection Investigation Report

**Generated:** 2026-07-09T10:00:00Z  
**Investigator:** homelab-dns-investigator  
**Artifact dir:** `artifacts/troubleshooting/dns-investigation/20260709-100000/`

## Executive summary

`.hom.lab` router DNS is correct for both hypervisors. hvh-01 (`192.168.50.234`) is down, blocking the entire `192.168.138.0/24` lane including k3s-01 — gateway outage, not a DNS typo. hvh-02 is reachable; IPv4 SSH on `.158` refuses but `.local` (`.159`) and IPv6 aliases work.

## Lane inventory truth

See [lane-inventory-truth-example.md](lane-inventory-truth-example.md) for full validation source matrix.

### hvh-01 — declared

| Name | IP | Role |
|---|---|---|
| `HOM-LAB-HVH-01` | `192.168.50.234` | Hyper-V host (primary) |
| `HOM-LAB-HVH-01` | `192.168.50.233` | Secondary Wi‑Fi (inventory: temporarily down) |
| `hom-lab-ctl-dkr-01` / `nsrv-dkr-01` | `192.168.138.10` | Docker VM |
| `hom-lab-ctl-k3s-01` / `nsrv-k3s-01` | `192.168.138.11` | K3s control plane |
| Guest subnet | `192.168.138.0/24` | Gateway `192.168.138.1` on hvh-01 |

Port proxies on `50.234` → `138.10`: postgres `5432`, redis `6379`, clickhouse `8123`/`9004`, minio `9000`/`9001`.

### hvh-01 — reconciliation (this run)

| Name | Declared | Verified | Status |
|---|---|---|---|
| `HOM-LAB-HVH-01` | `50.234` | ping/SSH fail | DOWN |
| `hom-lab-ctl-k3s-01` | `138.11` | timeout via dead gateway | BLOCKED_UPSTREAM |

## Scope

- Hosts: hvh-01, hvh-02, k3s-01, k3s-02, dkr-01, dkr-02, legacy names
- Suffixes: bare, `.hom.lab`, `.local`, `.lab`
- Lanes: hvh-01 (`192.168.138.0/24`), hvh-02 (`192.168.137.0/24`)

## DNS resolution matrix

See `dns-matrix.txt`. Summary tables in [what-to-collect.md](what-to-collect.md).

### Takeaways

- `.hom.lab` is the real LAN DNS zone (router DHCP domain). Works for hvh-01/02 only.
- `.local` is mDNS only — hvh-02 advertises at `.159` (SSH works); hvh-01 has no `.local` record.
- `.lab` does nothing in this setup.
- Bare names with search domain `hom.lab`: hvh hosts → router DNS; services → `/etc/hosts`; guests → hosts file only for 02 lane.
- **No DNS/hosts mismatch explains k3s-01 timeout** — `HOM-LAB-HVH-01.hom.lab` correctly points to `50.234`, which is down.

## Connection evidence

| Target | Ping | SSH | API :6443 | Notes |
|---|---|---|---|---|
| `192.168.50.234` | fail / down | timeout | — | hvh-01 gateway |
| `192.168.50.158` | OK | refused IPv4 | — | inventory primary |
| `192.168.50.159` | OK | OK | — | mDNS `.local` path |
| `192.168.138.11` | timeout | — | timeout | route via dead `50.234` |
| `192.168.137.11` | OK | — | OK | k3s-02 API up |

Raw: `connection-probes.txt`

## Hosts file vs router DNS vs mDNS

| Name | Router DNS | Mac resolver | `/etc/hosts` | Mismatch |
|---|---|---|---|---|
| `HOM-LAB-HVH-02` | `50.158` | `50.158` | — | `.local` → `50.159` |
| `hom-lab-ctl-k3s-02` | none | `137.11` (hosts) | `137.11` | expected — no router row |
| `hom-lab-ctl-k3s-01` | none | none | missing | expected — 01 lane uses route not hosts |

## Published endpoints (subskill)

Invoked: `homelab-dns-investigator/subskills/published-endpoints`

See `published-endpoints.md` for service `*.hom.lab` resolution and HTTP/TCP probe results.

## Working management paths (this run)

| target | working path |
|---|---|
| hvh-02 | `HOM-LAB-HVH-02-ipv6`, `HOM-LAB-HVH-02.local` (`50.159`), or `192.168.50.159` |
| k3s-02 | `hom-lab-ctl-k3s-02` (hosts → `137.11`) or IP directly |
| hvh-01 / k3s-01 | **blocked** until `50.234` is back — DNS already correct |

## Assessment

DNS naming is consistent with inventory. Primary blocker is physical/network availability of `HOM-LAB-HVH-01` at `192.168.50.234`, not resolver configuration.

## Next required step

Restore or power on `HOM-LAB-HVH-01` and re-run connection probes to `192.168.50.234` before expecting k3s-01 or `192.168.138.x` services.

## Sources checked

- `/etc/hosts`, `scutil --dns`, `dig @192.168.50.1`, `dscacheutil`, `dns-sd`
- Live ping/SSH to `192.168.50.158` vs `192.168.50.159`
- `inventory/hosts_mapping.yaml`, `homelab_hosts_file.yml`, `homelab_router_gt6.yml`
