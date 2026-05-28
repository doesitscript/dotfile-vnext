# homelab_hosts_file_mac

Thin wrapper that feeds **mac-dev** `/etc/hosts` via Git-installed **`hosts_file`**
([loz-hurst/ansible-role-hosts_file](https://github.com/loz-hurst/ansible-role-hosts_file) v1.0.0).

## Upstream chain (no silent gaps)

| Layer | Owner | Required for full path |
|-------|--------|----------------------|
| L1 Routing | GT6 static route Job 1 | Guest `.137.x` reachable from LAN |
| L2 LAN DNS | GT6 DHCP domain `hom.lab` + manual rows | `langfuse.hom.lab` / `litellm.hom.lab` → `.158` |
| L3 Portproxy | `hyperv_networking` on hvh-02 | `:80` → `192.168.137.11:80` (`k3s-traefik-http`) |
| L4 Ingress | `k3s_traefik_routes` | Ingress CR host = registry `hostname` |
| L5 mac hosts | **this role** | Guest VM names (`.137.x`); service names if GT6 rows missing |

**Disable only when:** `homelab_hosts_file_mac_enabled: false` (user opt-out) or role not in play.

**Not disabled** because Traefik is absent — guest workaround rows still apply. Service
hostname rows duplicate GT6 when both exist (harmless); primary LAN DNS is
`hom.lab` per [homelab_router_gt6.yml](../../inventory/group_vars/all/homelab_router_gt6.yml).

## Data sources

1. `homelab_hosts_file_web_catalog` (`inventory/group_vars/all/homelab_hosts_file.yml`) —
   Traefik ingress names, portproxy web UIs, guest-direct HTTP; filtered by `mac_hosts_enabled`
2. `homelab_router_gt6_mac_hosts_workaround` → guest inventory hostnames → `.137.x`

## Guest VMs (v1 lesser solution)

Service-to-service on k3s-02 / dkr-02 does **not** require hom.lab names — see
[guest-vm-hom-lab-dns-lesser-solution.md](../../docs/lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md).

## Follow-up: other OS variants

| Role | Status | Playbook |
|------|--------|----------|
| `homelab_hosts_file_mac` | **implemented** | `playbooks/homelab_hosts_file_mac.yaml` |
| `homelab_hosts_file_linux` | **implemented** | `playbooks/homelab_hosts_file_linux.yaml` |
| `homelab_hosts_file_windows` | scaffolded | `playbooks/homelab_hosts_file_windows.yaml` (desktop hosts when commissioned) |

Deprecated: `.local` pilot hostnames — replaced after GT6 `hom.lab` enabled.

## Lifecycle

`homelab_hosts_file_mac_enabled: true` on mac-dev when commissioned (user enable-when-built default).

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | `playbooks/site.yaml` / `homelab_hosts_file.yaml`, or `deploy_development_nodes.yaml --tags homelab_hosts_file_mac` |
| **Verify** | `grep hom.lab /etc/hosts` on mac-dev |
| **Undo** | `homelab_hosts_file_mac_enabled: false` |
| **Class** | Idempotent config |
