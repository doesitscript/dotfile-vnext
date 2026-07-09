# Connection paths — gateways, guests, API servers

Use during DNS/connection investigation when a hostname resolves but a service or API is unreachable.

## Guest subnets

| Lane | Hypervisor | Guest subnet | Route gateway |
|---|---|---|---|
| hvh-01 | `192.168.50.234` | `192.168.138.0/24` | `192.168.50.234` |
| hvh-02 | `192.168.50.158` | `192.168.137.0/24` | `192.168.50.158` |

## K3s API servers (connection probe, not kubeconfig management)

| Context | API server |
|---|---|
| `hom-lab-ctl-k3s-01` | `https://192.168.138.11:6443` |
| `hom-lab-ctl-k3s-02` | `https://192.168.137.11:6443` |

Probe: `nc -z -G 3 <guest-ip> 6443`

If API fails with correct DNS/route, the hypervisor gateway is likely down — not a naming issue.

## SSH fallbacks (hvh-02)

| Alias | When |
|---|---|
| `hom-lab-ctl-hvh-02-ipv6` | IPv4 SSH refused on `.158` |
| `hom-lab-ctl-hvh-02.local` | mDNS path to `.159` |

Kubeconfig refresh: `roles/k3s_mac_client/` via `playbooks/k3s_mac_client.yaml` — only after gateway path is proven up.
