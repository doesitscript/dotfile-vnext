# K3s Hyper-V Traefik — interim DNS matrix (DNS-2)

Operator-facing map for the homelab hosts-file slice. Canonical SSOT:
`inventory/group_vars/all/homelab_hosts_file.yml` → `homelab_hosts_file_web_catalog`.

| Host / target | Operator names | Method | IP in `/etc/hosts` | Verify URL (2026-05-28) |
|---------------|----------------|--------|--------------------|-------------------------|
| mac-dev | `langfuse.hom.lab`, `litellm.hom.lab`, `netbox.hom.lab`, `semaphore.hom.lab`, `loki.hom.lab` | `homelab_hosts_file_mac` playbook | `192.168.50.158` (LAN publish) | See DNS-3d receipt in child plan |
| mac-dev | `grafana.hom.lab` | same | `192.168.137.10` (dkr guest direct) | `http://grafana.hom.lab:3000/` → 302 |
| mac-dev | `hom-lab-ctl-dkr-02`, `hom-lab-ctl-k3s-02` | `homelab_router_gt6_mac_hosts_workaround` | guest `.137.x` | SSH (not HTTP) |
| hom-lab-ctl-k3s-02 | Traefik ingress hostnames | K3s `k3s_traefik_routes` | — | NodePort `:30000` / `:30400` interim |
| hom-lab-ctl-hvh-02 | LAN `:80` Traefik front door | `hyperv_networking` portproxy `k3s-traefik-http` | — | `http://langfuse.hom.lab/` → 200 (mac-dev) |
| hom-lab-ctl-dkr-02 | Docker UIs via portproxy on hvh-02 | `guest_published_tcp_ports` | — | `:8000` netbox, `:3001` semaphore, `:3100` loki |
| Linux guests (k3s-02, dkr-02) | service-to-service | **lesser solution:** K8s/compose DNS + `.137.x` IPs — hom.lab not required on guest | — | [guest-vm-hom-lab-dns-lesser-solution.md](../lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md) |
| Linux guests (operator curl on guest) | catalog hostnames | `homelab_hosts_file_linux` | `192.168.50.158` (LAN publish) / guest IP for grafana | Applied 2026-05-28 on k3s-02, dkr-02 |
| Windows dev hosts | catalog hostnames | **future** `homelab_hosts_file_windows` | — | [plan](../plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) |
| GT6 router | guest/service DHCP rows | **cancelled** (OP-1/OP-2) | — | use hosts-file + future AdGuard |
| AdGuard Home | `*.hom.lab` authoritative | **future** intake plan | — | out of scope for v1 |

## DNS-3d evidence (mac-dev, controller ansible)

```
http://langfuse.hom.lab:30000/  → HTTP/1.1 200 OK
http://litellm.hom.lab:30400/   → HTTP/1.1 200 OK
http://netbox.hom.lab:8000/     → HTTP/1.1 200 OK
http://semaphore.hom.lab:3001/  → HTTP/1.1 200 OK
http://loki.hom.lab:3100/       → HTTP/1.1 404 (root); /ready → 405 Method Not Allowed on HEAD
http://grafana.hom.lab:3000/    → HTTP/1.1 302 Found
http://langfuse.hom.lab/        → HTTP/1.1 200 OK (LA-5b)
http://litellm.hom.lab/         → HTTP/1.1 200 OK (LA-5b)
```

## NetBox (NB-4)

Seeded from controller via `playbooks/troubleshoot/netbox_api_seed_localhost.yml` (localhost API to `http://192.168.50.158:8000`):

- Services `langfuse-k3s-web`, `litellm-k3s-gateway` with ingress custom fields
- Tag `traefik-routed`, ingress CFs on Service objects
- `scripts/validate_netbox_repo_consistency.sh` passed
