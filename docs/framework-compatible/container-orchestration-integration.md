# Container Orchestration Integration

This document defines the framework-compatible contract for importing and
normalizing Kubernetes and Docker guidance into an existing repo without
letting source vocabulary silently replace local runtime truth.

It is intentionally broader than one intake note and narrower than the whole
project framework. The capability family is about container orchestration
integration work, not about the provenance of any one note.

## Capability Boundary

This capability family covers:

- Kubernetes/K3s runtime guidance
- Docker runtime guidance
- NetBox source-of-truth bridging for those runtime domains
- Ansible translation and orchestration guidance for those runtime domains

It does not own:

- general Ansible design outside container-orchestration integration
- general NetBox modeling unrelated to these runtime domains
- Codex-only runtime setup details

## Packet Taxonomy

The family stays modular through packet types:

- `source-packets`
  Provenance-only captures of imported guidance.
- `kubernetes-runtime-integration`
  K3s/Kubernetes runtime normalization.
- `docker-runtime-integration`
  Docker runtime normalization and exception tracking.
- `netbox-model-bridge`
  Source-of-truth and inventory bridging.
- `ansible-translation-bridge`
  Role/playbook/module/lifecycle translation.
- `decision-crosswalk`
  Shared per-item decision map.

The packet split is the compatibility contract. Implementations can render it
differently, but should not collapse the domains into one opaque blob.

## Decision Model

Each imported item is classified exactly once as:

- `accept`
- `adapt`
- `documented_exception`
- `future_replacement_path`
- `reject`

The decision label is only valid when paired with the implementation's current
authority source.

## Portability Contract

Compatible implementations should preserve these behaviors:

- imported guidance is provenance, not automatic authority
- local naming schema outranks generic imported vocabulary
- runtime drift is separated from diagnostic-only or intentionally retained
  exceptions
- schema updates happen when imported vocabulary exposes a missing role or
  resource boundary

## Current Codex/OpenAI Mapping

The Codex/OpenAI implementation in this repo consumes this family through:

- `AGENTS.md`
- `.cursor/rules/framework-container-orchestration-integration.mdc`
- `.cursor/skills/container-orchestration-integration/`
- `docs/codex_framework/container-orchestration-integration.md`

Future implementations should prefer keeping the packet taxonomy and decision
model intact rather than renaming the capability around the source of the note.
