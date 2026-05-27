# Container Orchestration Integration Capability

This document records how the Codex/OpenAI implementation in this repo uses the
container-orchestration-integration capability family.

The capability exists so imported Kubernetes and Docker guidance can become
modular framework intelligence instead of staying as disposable intake prose or
turning into a second competing policy tree.

## Codex/OpenAI Implementation Role

In this repo, Codex uses this capability to:

- normalize imported runtime guidance into existing K3s and Docker lanes
- bridge imported NetBox and Ansible terms into current repo authorities
- keep source provenance separate from active repo truth
- surface active cleanup items, documented exceptions, and future replacement
  paths in one reusable packet family

## Active Surfaces

- `.cursor/rules/framework-container-orchestration-integration.mdc`
- `.cursor/skills/container-orchestration-integration/SKILL.md`
- `.cursor/skills/container-orchestration-integration/capability.yml`
- `.cursor/skills/container-orchestration-integration/references/*.yml`
- `docs/framework-compatible/container-orchestration-integration.md`

## Local Authority Mapping

This capability does not invent new runtime truth. It maps imported guidance
onto current repo authorities such as:

- naming and resource roles under `docs/reference/naming-standards/`
- K3s runtime playbooks and roles
- Docker runtime playbooks and stack roles
- NetBox modeling rules and shadow inventory posture
- Ansible gates and framework composition rules

## Default Repo Posture

When this capability is active, the expected Codex posture is:

- preserve compact repo naming such as `k3s`, `dkr`, and `hvh`
- preserve Docker and K3s as separate runtime lanes
- preserve NetBox source-of-truth posture while keeping dynamic inventory in
  shadow/comparison mode
- track active drift, documented exceptions, and future replacement paths as
  separate outcomes

## Current Imported Source

The first imported source packet for this capability family is:

- `docs/intake/ai-upgrade-kubernetes-raw.md`

That file is provenance only. The active implementation surfaces live in the
capability packet, rule, and naming/schema updates.
