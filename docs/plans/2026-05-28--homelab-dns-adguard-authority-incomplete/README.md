---
name: Homelab DNS authority — AdGuard Home
overview: >-
  Replace long-term reliance on mac /etc/hosts and GT6 manual rows with a LAN DNS
  authority (default AdGuard Home on an always-on Ubuntu VM).
scope: implementation
lifecycle: incomplete
completion_percent: 0
netbox_scope: true
promoted_from: docs/intake/future-state-dns-authority-and-service-entry-architecture.md
depends_on_plans:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
unblocks: []
moved_from:
  - OP-1/OP-2 cancelled; AdGuard out of umbrella (2026-05-27--k3s-hyperv-traefik)
---

# Homelab DNS authority — AdGuard (future)

**Moved from:** K3s Hyper-V Traefik umbrella — **OP-1/OP-2 cancelled**; authoritative DNS was explicitly out of v1 scope.

**Intake:** [future-state-dns-authority-and-service-entry-architecture.md](../../intake/future-state-dns-authority-and-service-entry-architecture.md)

## Lesser solution in place (v1)

| Need | v1 workaround | Plan |
|------|---------------|------|
| mac operator browsers | `homelab_hosts_file_mac` + portproxy on hvh-02 | [implemented Traefik hosts-file](../2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md) |
| Guest VM SSH names | `homelab_router_gt6_mac_hosts_workaround` on mac only | [linux/windows incomplete](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) |
| Guest service-to-service | IPs, K8s DNS, compose names — no hom.lab required | [lesser-solution doc](../../lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md) |

## Checklist

- [ ] **DNS-A1** — Choose placement VM (utility guest on hvh-01 or hvh-02 LAN IP)
- [ ] **DNS-A2** — Ansible role/playbook for AdGuard Home `present`
- [ ] **DNS-A3** — Publish `*.hom.lab` from `homelab_hosts_file_web_catalog` + Traefik registry
- [ ] **DNS-A4** — Point LAN clients (mac-dev, Windows dev) at AdGuard; retire mac-only hosts rows when stable
- [ ] **DNS-A5** — NetBox document DNS authority object / service

## Diagram inventory

- See intake Architecture section; expand when role placement is chosen
