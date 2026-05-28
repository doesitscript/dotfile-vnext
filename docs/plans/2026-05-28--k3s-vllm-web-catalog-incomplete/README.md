---
name: K3s vLLM web catalog row
overview: >-
  Add homelab_hosts_file_web_catalog and NetBox service rows for vLLM when
  k3s_vllm_runtime is deployed and exposes a stable operator URL.
scope: implementation
lifecycle: incomplete
completion_percent: 0
netbox_scope: true
promoted_from: docs/plans/2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md
depends_on_plans:
  - docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md
moved_from:
  - DNS-3e (2026-05-27--k3s-hyperv-traefik-homelab-hosts-file)
---

# K3s vLLM — hosts catalog + NetBox (DNS-3e follow-on)

**Moved from:** homelab hosts-file plan — **DNS-3e** (no catalog row until runtime exists).

## Checklist

- [ ] **VLLM-1** — Deploy `k3s_vllm_runtime` and confirm NodePort or Traefik hostname
- [ ] **VLLM-2** — Add row to `homelab_hosts_file_web_catalog`
- [ ] **VLLM-3** — NetBox Service + ingress metadata when endpoint is stable
- [ ] **VLLM-4** — mac-dev curl verify

## Diagram inventory

- N/A until runtime exists
