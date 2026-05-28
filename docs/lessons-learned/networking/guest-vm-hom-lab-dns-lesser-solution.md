# Guest VM hom.lab DNS — lesser solution (v1)

## Question

Do k3s-02 and dkr-02 need `homelab_hosts_file_linux` for services to talk to each other?

## Answer for v1

**No.** Inter-service traffic on guests does not use operator hostnames (`langfuse.hom.lab`, `netbox.hom.lab`). It uses:

| Layer | k3s-02 (hom-lab-ctl-k3s-02) | dkr-02 (hom-lab-ctl-dkr-02) |
|-------|-----------------------------|-----------------------------|
| In-cluster | Kubernetes Service DNS (`*.svc.cluster.local`) | — |
| Compose / host | — | Docker compose service names, container IPs, `127.0.0.1` bindings |
| Cross-guest | Routed `.137.x` IPs via Hyper-V (GT6 static routes + hvh portproxy for **LAN clients**, not guest DNS) | Same |
| Operator / mac browser | **Not on guest** — mac-dev uses `homelab_hosts_file_mac` → `.158` portproxy | — |

## What v1 implemented instead of linux/windows hosts roles

1. **`homelab_hosts_file_mac`** — mac-dev resolves hom.lab names to LAN publish IP (`.158`) or guest IP (grafana → `.137.10`).
2. **`guest_published_tcp_ports`** on hvh-02 — LAN reaches Docker/K3s services without guests knowing hom.lab.
3. **`k3s_traefik_routes`** — ingress inside cluster; NodePort + portproxy for external operators.
4. **NetBox `primary_access_point` / `fallback_access_point`** — documents both Traefik :80 and NodePort paths.

## When linux/windows hosts roles matter

- Curl/scripts **on** k3s-02 or dkr-02 using `http://langfuse.hom.lab/`
- SSH from guest using friendly names (optional; inventory_hostname still works)
- Windows dev workstations without mac hosts file

**Follow-on plan:** [2026-05-28--homelab-hosts-file-linux-windows-incomplete](../../plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md)

## Authoritative DNS (not v1)

AdGuard / LAN DNS authority — [2026-05-28--homelab-dns-adguard-authority-incomplete](../../plans/2026-05-28--homelab-dns-adguard-authority-incomplete/README.md)
