---
name: project-maturity-router
description: Route broad project improvement, maturity, or best-practice requests to the appropriate modular knowledge gates without merging Ansible and NetBox into one capability.
---

# Project Maturity Router

Use this skill when the user asks to improve, mature, harden, professionalize,
or align the project with best practices and the request is broader than a
single implementation detail.

## Core Rule

Do not collapse project maturity into one generic blob. Classify which domain
gates apply, then use those gates separately.

## Routing

- Use `ansible-knowledge-gate` when the work involves automation shape:
  roles, playbooks, inventories, variables, modules, idempotence, lifecycle, or
  validation.
- Use `netbox-knowledge-gate` when the work involves infrastructure modeling:
  source-of-truth, names, slugs, tags, object hierarchy, IPAM, or inventory
  derived from NetBox.
- Use both when both domains materially shape the project direction.

## Required Output

For broad project-maturity requests, state:

- domains considered
- gates activated
- gates intentionally not activated and why
- combined recommendation, keeping each domain's receipt separate when both
  gates apply

## Boundaries

The router owns composition only. It does not duplicate Ansible or NetBox
domain rules.

## References

- `references/routing-matrix.md`
- `.cursor/rules/framework-project-maturity-router.mdc`
