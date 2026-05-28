---
name: K3s Hyper-V Traefik LAN HTTP portproxy
overview: >-
  LAN :80 front door on hom-lab-ctl-hvh-02: Traefik NodePort connect_port,
  hyperv_networking portproxy, verify http://*.hom.lab/ on port 80.
scope: implementation
lifecycle: implemented
completion_percent: 100
implemented_date: 2026-05-28
archive_candidate: true
netbox_scope: false
parent_plan: docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
depends_on_plans:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
  - docs/plans/2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md
unblocks: []
---

# K3s Hyper-V Traefik — LAN HTTP portproxy (:80) — implemented

**Parent:** [2026-05-27--k3s-hyperv-traefik-implemented](../2026-05-27--k3s-hyperv-traefik-implemented/README.md)  
**Sibling:** [homelab-hosts-file-implemented](../2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md)

| | |
|---|---|
| **Apply** | `k3s-traefik-http` `connect_port: 31461`; `playbooks/hyperv_networking.yaml` on hvh-02 |
| **Verify** | LA-5b curls on port 80; no `Microsoft-IIS` header |
| **Undo** | Revert inventory portproxy row |
| **Class** | Idempotent config |

**Completion: 100%**

---

## Checklist

- [x] **LA-2b** — `connect_port: 31461`; portproxy `192.168.50.158:80 → 192.168.137.11:31461`
- [x] **LA-2** — Row `k3s-traefik-http` in inventory
- [x] **LA-5b** — mac-dev `curl -sI http://langfuse.hom.lab/` and `http://litellm.hom.lab/` → **200 OK**

---

## Plan verification receipt

**Slice:** v1 portproxy  
**Verified at:** 2026-05-28

| ID | Source | Obligation | Status | Evidence |
|----|--------|------------|--------|----------|
| O-01 | P0 (parent) | IIS removed before :80 use | pass | Parent P0 receipt |
| O-02 | LA-2b | NodePort 31461 in inventory | pass | `inventory/host_vars/hom-lab-ctl-hvh-02.yaml` |
| O-03 | LA-2b Apply | `hyperv_networking` on hvh-02 | pass | ok=30 changed=2 post-reboot |
| O-04 | LA-5b Verify | mac-dev port-80 curls | pass | `HTTP/1.1 200 OK` both hostnames 2026-05-28 |
| O-05 | Verify contract | No Microsoft-IIS | pass | Langfuse HTML headers; no IIS server header |

**Completion gate:** all in-scope obligations `pass`.

---

## Execute receipt

| ID | Status | Evidence |
|----|--------|----------|
| LA-2b | pass | portproxy row + ansible apply |
| LA-5b | pass | mac-dev curl output in parent/hosts verification |

---

## Diagram inventory

- LAN HTTP portproxy — parent/hosts diagrams
- [cst-hom-lab-ctl-dia-gpu-services-01.md](../../diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md)
