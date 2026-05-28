---
name: Homelab hosts file — Linux and Windows targets
overview: >-
  homelab_hosts_file_linux applied on k3s-02 and dkr-02; windows role scaffolded
  for future desktop commissioning.
scope: implementation
lifecycle: implemented
completion_percent: 100
netbox_scope: false
depends_on_plans:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md
unblocks: []
moved_from:
  - DNS-3 (2026-05-27--k3s-hyperv-traefik-homelab-hosts-file)
---

# Homelab hosts file — Linux and Windows (DNS-3) — implemented

**Applied:** 2026-05-28 — `playbooks/homelab_hosts_file_linux.yaml` on `hom-lab-ctl-k3s-02`, `hom-lab-ctl-dkr-02`.

**Windows:** `homelab_hosts_file_windows` role + playbook exist; `dev-workstation-win` not in active deploy scope (deferred).

## Plan verification receipt

| ID | Obligation | Status | Evidence |
|----|------------|--------|----------|
| O-01 | CONN prerequisites | pass | SSH config re-rendered; ProxyJump verified |
| O-02 | linux role + apply | pass | `getent hosts langfuse.hom.lab` → `192.168.50.158` on both guests |
| O-03 | windows role | pass (scaffold) | `playbooks/homelab_hosts_file_windows.yaml`; no commissioned desktop host |
| O-04 | catalog flags | pass | `linux_hosts_enabled` / `windows_hosts_enabled` in `homelab_hosts_file.yml` |

## Checklist

- [x] **CONN-0–CONN-3**
- [x] **DNS-3-L** — `roles/homelab_hosts_file_linux` + playbook
- [x] **DNS-3-W** — `roles/homelab_hosts_file_windows` + playbook (apply when desktop commissioned)
- [x] **DNS-3-SSOT** — catalog flags
- [x] **DNS-3-apply** — k3s-02, dkr-02
- [x] **DNS-3-verify** — `getent` on guests 2026-05-28

## Diagram inventory

- [cst-hom-lab-ctl-dia-homelab-hosts-file-01.md](../../diagrams/cst-hom-lab-ctl-dia-homelab-hosts-file-01.md)
