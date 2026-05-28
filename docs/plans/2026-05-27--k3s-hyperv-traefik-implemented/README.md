---
name: K3s Hyper-V Traefik ingress v1
overview: >-
  Umbrella implemented: Traefik on k3s-02, hvh-02 :80 portproxy, mac homelab hosts
  interim DNS, NetBox ingress metadata. Deferred work split to 2026-05-28 plans.
scope: implementation
lifecycle: implemented
completion_percent: 100
implemented_date: 2026-05-28
archive_candidate: true
netbox_scope: true
promoted_from: docs/intake/k3s-hyperv-traefik-blueprint.md
depends_on_plans:
  - docs/archive/wsl-deprecating/plans/2026-05-20--hyper-v-bridge-networking-role-deprecating/README.md
child_plans:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md
  - docs/plans/2026-05-27--k3s-hyperv-traefik-lan-http-portproxy-implemented/README.md
deferred_plans:
  - docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md
  - docs/plans/2026-05-28--homelab-dns-adguard-authority-incomplete/README.md
  - docs/plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md
---

# K3s Hyper-V Traefik ingress (v1) — implemented

Intake: [docs/intake/k3s-hyperv-traefik-blueprint.md](../../intake/k3s-hyperv-traefik-blueprint.md)

| Child plan | Status |
|------------|--------|
| [homelab-hosts-file-implemented](../2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md) | **100%** (mac + NB-4 v1) |
| [lan-http-portproxy-implemented](../2026-05-27--k3s-hyperv-traefik-lan-http-portproxy-implemented/README.md) | **100%** |

**Deferred (separate `-incomplete` packets):**

| Plan | Was |
|------|-----|
| [homelab-hosts-file-linux-windows](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) | DNS-3 Ansible roles on guests/dev Windows |
| [homelab-dns-adguard-authority](../2026-05-28--homelab-dns-adguard-authority-incomplete/README.md) | AdGuard / authoritative DNS (OP-1/OP-2 cancelled) |
| [k3s-vllm-service-publication](../2026-05-28--k3s-vllm-service-publication-incomplete/README.md) | DNS-3e service publication |

**Superseded monolith:** [2026-05-27--k3s-hyperv-traefik-incomplete](../2026-05-27--k3s-hyperv-traefik-incomplete/README.md)

---

## Mandatory NetBox slice

### Objects affected

- Traefik-routed service metadata, operator DNS intent rows, umbrella receipt links to NetBox-scoped child work

### Declared / Applied / Verified

- **Declared:** the umbrella delegates NetBox-scoped work to child packets instead of leaving it as advisory prose.
- **Applied:** the in-scope live NetBox mutation for v1 is carried by the implemented hosts-file child packet.
- **Verified:** the child packet evidence plus `scripts/validate_netbox_repo_consistency.sh` and `artifacts/netbox-service-inventory/latest.json`.

### Artifact references

- `artifacts/netbox-service-inventory/latest.json`
- `scripts/validate_netbox_repo_consistency.sh`

## P0-remove-iis-hvh-02 — pass

- [x] **P0-remove-iis-hvh-02** — [one-off doc](../../one_off_tasks/remove_iis_hom-lab-ctl-hvh-02.md); reboot + portproxy re-apply
- [x] **P0-gate** — children unblocked

---

## LAN architecture (implemented)

- **Portproxy:** `k3s-traefik-http` → NodePort **31461**
- **K3s ingress:** `k3s_traefik_routes`
- **Interim DNS (mac):** `homelab_hosts_file_mac` + [matrix](../../diagnostics/k3s-hyperv-traefik-interim-dns-matrix.md)
- **Guest service comms:** [lesser solution](../../lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md) — no linux/windows hosts roles required for v1

---

## Locked decisions

| Topic | Decision |
|-------|----------|
| P0 | One-off IIS removal — done |
| DNS v1 | mac hosts file + portproxy |
| OP-1/OP-2 | Cancelled → AdGuard deferred plan |
| DNS-3 OS roles | Deferred — not NetBox host roles; Ansible `/etc/hosts` roles |

---

## Plan verification receipt

**Slice:** umbrella v1  
**Verified at:** 2026-05-28

| ID | Source | Obligation | Status | Evidence |
|----|--------|------------|--------|----------|
| O-01 | P0 | IIS one-off | pass | P0 receipt; LA-5b no IIS |
| O-02 | Child portproxy | LA-2b, LA-5b | pass | [portproxy-implemented](../2026-05-27--k3s-hyperv-traefik-lan-http-portproxy-implemented/README.md) receipt |
| O-03 | Child hosts | mac DNS + NB-4 | pass | [hosts-file-implemented](../2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md) receipt |
| O-04 | Parent gate | both children complete | pass | both 100% |
| O-05 | DNS-3 linux/win | guest hosts roles | moved | [linux/windows incomplete](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) |
| O-06 | AdGuard | authoritative DNS | moved | [AdGuard incomplete](../2026-05-28--homelab-dns-adguard-authority-incomplete/README.md) |
| O-07 | vLLM | service publication | moved | [vLLM incomplete](../2026-05-28--k3s-vllm-service-publication-incomplete/README.md) |
| O-08 | OP-1/OP-2 | GT6 DHCP rows | cancelled | matrix + AdGuard plan |

**Completion gate:** umbrella v1 obligations `pass` or `moved`/`cancelled`; no open rows on this packet.

---

## Diagram inventory

- Child plan diagrams + [cst-hom-lab-ctl-dia-homelab-hosts-file-01.md](../../diagrams/cst-hom-lab-ctl-dia-homelab-hosts-file-01.md)
