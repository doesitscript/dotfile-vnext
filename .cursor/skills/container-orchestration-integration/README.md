# Container Orchestration Integration Capability

This capability turns imported Kubernetes and Docker guidance into durable
repo-local framework intelligence.

The capability boundary is the runtime integration family itself, not the
origin of any one note. A source packet may come from an intake doc, outside
brainstorming, or future research, but the active repo contract lives in the
modular packet set under this folder.

## Packet Layout

- `references/source-packets/`
  Provenance-only source captures.
- `references/kubernetes-runtime-integration.yml`
  K3s/Kubernetes runtime normalization and cleanup decisions.
- `references/docker-runtime-integration.yml`
  Docker runtime normalization and documented exceptions.
- `references/netbox-model-bridge.yml`
  NetBox source-of-truth bridging decisions.
- `references/ansible-translation-bridge.yml`
  Role/playbook/module translation into repo Ansible patterns.
- `references/decision-crosswalk.yml`
  Shared per-item decision map.

## Owned Files

- `.cursor/skills/container-orchestration-integration/SKILL.md`
- `.cursor/skills/container-orchestration-integration/README.md`
- `.cursor/skills/container-orchestration-integration/capability.yml`
- `.cursor/skills/container-orchestration-integration/references/source-packets/ai-upgrade-kubernetes-raw.yml`
- `.cursor/skills/container-orchestration-integration/references/decision-crosswalk.yml`
- `.cursor/skills/container-orchestration-integration/references/kubernetes-runtime-integration.yml`
- `.cursor/skills/container-orchestration-integration/references/docker-runtime-integration.yml`
- `.cursor/skills/container-orchestration-integration/references/netbox-model-bridge.yml`
- `.cursor/skills/container-orchestration-integration/references/ansible-translation-bridge.yml`
- `.cursor/rules/framework-container-orchestration-integration.mdc`
- `docs/framework-compatible/container-orchestration-integration.md`
- `docs/codex_framework/container-orchestration-integration.md`

## Update Rule

Update the skill, manifest, packet refs, companion rule, and companion docs
together. The `owned_files` list in `capability.yml` is the update/remove
source of truth.

## Removal Rule

If this capability is removed, start from `owned_files` so the rule, docs, and
packet refs leave the repo together instead of orphaning partial governance.
