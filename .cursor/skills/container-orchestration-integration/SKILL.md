---
name: container-orchestration-integration
description: Normalize imported Kubernetes and Docker guidance into the repo's existing K3s, Docker, NetBox, Ansible, and naming authorities without letting source terminology become active repo truth by accident.
---

# Container Orchestration Integration

Use this skill when the user wants to integrate, compare, extract, or normalize
outside guidance about Kubernetes, Docker, NetBox, or Ansible into the repo's
existing runtime and framework patterns.

## Core Rule

Treat imported guidance as provenance, not authority.

Do not let source vocabulary such as generic `k8s-control`, `docker-host`, or
top-level `policy/` trees become active repo truth unless the repo explicitly
promotes them through naming/schema work.

## Packet Taxonomy

Keep imported material modular:

- `source-packets`
  Raw or normalized provenance from intake notes or other external guidance.
- `kubernetes-runtime-integration`
  K3s/Kubernetes runtime guidance, labels, taints, manifests, Helm, ingress,
  and related cleanup or exception decisions.
- `docker-runtime-integration`
  Docker runtime guidance, compose/context exceptions, and Docker-specific
  lifecycle boundaries.
- `netbox-model-bridge`
  NetBox source-of-truth and inventory-bridge guidance.
- `ansible-translation-bridge`
  Role/playbook/module/lifecycle translation into the repo's Ansible patterns.
- `decision-crosswalk`
  The shared classification map tying source items to packets and repo
  authorities.

## Required Workflow

1. Identify the imported source packet and assign stable item IDs.
2. Route each imported item to exactly one packet.
3. Classify each item using one of:
   - `accept`
   - `adapt`
   - `documented_exception`
   - `future_replacement_path`
   - `reject`
4. Cite the current repo authority that controls the settled decision.
5. If imported terms imply naming or role-boundary changes, update the naming
   schema in the same work slice instead of leaving the vocabulary half-mapped.
6. Keep cleanup follow-ups explicit when the repo already has active drift.

## Required Boundaries

- Preserve compact repo runtime names such as `k3s`, `dkr`, and `hvh` unless a
  schema update explicitly changes them.
- Preserve Docker and K3s as separate runtime lanes.
- Preserve NetBox as source of truth while keeping `inventory/netbox.yml` in
  shadow/comparison mode until the repo intentionally promotes it.
- Treat AWX as future alignment work unless the user explicitly moves it into
  active runtime scope.

## References

- `references/source-packets/ai-upgrade-kubernetes-raw.yml`
- `references/decision-crosswalk.yml`
- `references/kubernetes-runtime-integration.yml`
- `references/docker-runtime-integration.yml`
- `references/netbox-model-bridge.yml`
- `references/ansible-translation-bridge.yml`
- `.cursor/rules/framework-container-orchestration-integration.mdc`
