# NetBox Knowledge Gate Capability

This skill keeps NetBox-related work grounded in repo truth and current NetBox
authority before design or implementation.

It is intentionally separate from the Ansible gate. NetBox owns infrastructure
identity and source-of-truth modeling: object hierarchy, names, slugs, tags,
native fields, custom fields, interfaces, IPs, and inventory derivation.

## Owned Files

- `.cursor/skills/netbox-knowledge-gate/SKILL.md`
- `.cursor/skills/netbox-knowledge-gate/README.md`
- `.cursor/skills/netbox-knowledge-gate/capability.yml`
- `.cursor/skills/netbox-knowledge-gate/references/knowledge-receipt.md`
- `.cursor/rules/netbox-knowledge-gate.mdc`

## Update Rule

Update the skill, manifest, reference, and companion rule together. The
`owned_files` list in `capability.yml` is the update/remove source of truth.
