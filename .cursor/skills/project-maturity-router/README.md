# Project Maturity Router Capability

This skill decides whether broad project-improvement work should activate the
Ansible gate, the NetBox gate, or both.

The router is intentionally small. It owns composition and trigger logic, not
domain expertise. Keeping it small prevents the Ansible and NetBox capabilities
from becoming one hard-to-service blob.

## Owned Files

- `.cursor/skills/project-maturity-router/SKILL.md`
- `.cursor/skills/project-maturity-router/README.md`
- `.cursor/skills/project-maturity-router/capability.yml`
- `.cursor/skills/project-maturity-router/references/routing-matrix.md`
- `.cursor/rules/framework-project-maturity-router.mdc`

## Update Rule

Update the skill, manifest, reference, and companion rule together. The
`owned_files` list in `capability.yml` is the update/remove source of truth.
