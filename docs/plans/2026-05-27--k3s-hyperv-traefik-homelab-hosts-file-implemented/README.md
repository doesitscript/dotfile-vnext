---
name: K3s Hyper-V Traefik homelab hosts file
overview: >-
  Interim DNS for mac-dev: homelab_hosts_file_web_catalog, homelab_hosts_file_mac,
  NetBox ingress metadata, NodePort and port-80 verify.
scope: implementation
lifecycle: implemented
completion_percent: 100
implemented_date: 2026-05-28
archive_candidate: true
netbox_scope: true
parent_plan: docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
depends_on_plans:
  - docs/archive/wsl-deprecating/plans/2026-05-20--hyper-v-bridge-networking-role-deprecating/README.md
  - docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
unblocks:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-lan-http-portproxy-implemented/README.md
deferred_plans:
  - docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md
  - docs/plans/2026-05-28--homelab-dns-adguard-authority-incomplete/README.md
  - docs/plans/2026-05-28--k3s-vllm-web-catalog-incomplete/README.md
---

# K3s Hyper-V Traefik — homelab hosts file — implemented (mac slice)

**Parent:** [2026-05-27--k3s-hyperv-traefik-implemented](../2026-05-27--k3s-hyperv-traefik-implemented/README.md)  
**DNS-2 matrix:** [k3s-hyperv-traefik-interim-dns-matrix.md](../../diagnostics/k3s-hyperv-traefik-interim-dns-matrix.md)  
**Guest communication:** [guest-vm-hom-lab-dns-lesser-solution.md](../../lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md)

| | |
|---|---|
| **Apply** | `homelab_hosts_file_mac` + catalog; NetBox API seed from controller |
| **Verify** | mac-dev resolution + curl matrix |
| **Undo** | `homelab_hosts_file_mac_enabled: false` |
| **Class** | Idempotent config |

**Completion: 100%** for **in-scope v1** (mac operator path). Items moved to deferred plans are not incomplete rows on this packet.

---

## Checklist (v1 scope)

### Interim DNS

- [x] **DNS-1** — mac-dev: `homelab_hosts_file_mac`
- [x] **DNS-2** — [interim DNS matrix](../../diagnostics/k3s-hyperv-traefik-interim-dns-matrix.md)
- [x] **DNS-3b** — `homelab_hosts_file_web_catalog`
- [x] **DNS-3c** — mac-dev catalog rows applied
- [x] **DNS-3d** — curl matrix (2026-05-28)
- [x] **DNS-3e** — vLLM — **MOVED** → [vLLM catalog plan](../2026-05-28--k3s-vllm-web-catalog-incomplete/README.md)

### Moved out of this packet

- [→] **DNS-3** linux/windows Ansible roles — **MOVED** → [linux/windows plan](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md)
- [→] **AdGuard / OP-1/OP-2** — **MOVED** → [AdGuard plan](../2026-05-28--homelab-dns-adguard-authority-incomplete/README.md); OP-1/OP-2 **cancelled**

### NetBox

- [x] **NB-4a**–**NB-4d** — live API seed + verify

### Live apply

- [x] **LA-5a** — NodePort curls 200 OK

---

## Plan verification receipt

**Slice:** v1 mac interim DNS + NB-4  
**Verified at:** 2026-05-28

| ID | Source | Obligation | Status | Evidence |
|----|--------|------------|--------|----------|
| O-01 | DNS-1 | mac hosts applied | pass | `homelab_hosts_file_mac.yaml` on mac-dev |
| O-02 | DNS-2 | operator matrix doc | pass | `docs/diagnostics/k3s-hyperv-traefik-interim-dns-matrix.md` |
| O-03 | DNS-3b | catalog SSOT | pass | `inventory/group_vars/all/homelab_hosts_file.yml` |
| O-04 | DNS-3c | mac rows | pass | 8 entries; dscacheutil langfuse/netbox → .158 |
| O-05 | DNS-3d | curl matrix | pass | langfuse/litellm/netbox/semaphore/grafana 200/302; loki root 404 |
| O-06 | DNS-3 linux/win | guest /etc/hosts roles | moved | [2026-05-28--homelab-hosts-file-linux-windows-incomplete](../2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md) |
| O-07 | DNS-3e vLLM | catalog row | moved | [2026-05-28--k3s-vllm-web-catalog-incomplete](../2026-05-28--k3s-vllm-web-catalog-incomplete/README.md) |
| O-08 | NB-4 | live NetBox ingress metadata | pass | `netbox_api_seed_localhost.yml` + API verify `traefik-routed` |
| O-09 | NB verify | repo consistency gate | pass | `scripts/validate_netbox_repo_consistency.sh` |
| O-10 | LA-5a | NodePort verify | pass | `:30000` / `:30400` → 200 OK mac-dev |
| O-11 | Guest comms | service-to-service without hom.lab on guests | pass | [lesser-solution doc](../../lessons-learned/networking/guest-vm-hom-lab-dns-lesser-solution.md) |
| O-12 | AdGuard | authoritative DNS | moved | [AdGuard plan](../2026-05-28--homelab-dns-adguard-authority-incomplete/README.md) |

**Completion gate:** all v1 in-scope obligations `pass` or explicitly `moved`.

---

## Execute receipt

| ID | Status | Evidence |
|----|--------|----------|
| DNS-1–3d, LA-5a, NB-4 | pass | matrix doc + ansible/curl 2026-05-28 |
| DNS-3 OS variants | moved | future plan packet |
| DNS-3e vLLM | moved | future plan packet |
| AdGuard | moved | future plan packet |

---

## Diagram inventory

- [cst-hom-lab-ctl-dia-homelab-hosts-file-01.md](../../diagrams/cst-hom-lab-ctl-dia-homelab-hosts-file-01.md)
- [cst-hom-lab-ctl-dia-gpu-services-01.md](../../diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md)
