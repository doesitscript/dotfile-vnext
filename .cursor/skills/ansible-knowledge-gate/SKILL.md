---
name: ansible-knowledge-gate
description: Ground Ansible design and implementation in repo truth, current Ansible guidance, module discovery, and validation before planning or changing roles, playbooks, inventories, or variables.
---

# Ansible Knowledge Gate

Use this skill for Ansible work that affects roles, playbooks, inventories,
variables, tags, modules, collections, lifecycle state, idempotence, validation,
or troubleshooting.

## Core Rule

Do not design or implement Ansible changes from memory alone. First prove that
the relevant repo surfaces and Ansible authority were checked.

## Required Workflow

1. Inspect existing repo surfaces:
   - relevant roles, playbooks, inventory, docs, and active rules
   - steady-state automation before bootstrap helpers
2. Check Ansible authority:
   - `ansible.zen_of_ansible`
   - `ansible_content_best_practices`
   - `ansible-doc` or official module docs when selecting modules
3. Discover the module or tool contract before choosing shell or PowerShell.
4. Produce a knowledge receipt before decision-complete planning or
   implementation.

## Knowledge Receipt

Include these fields when the gate applies:

- Repo surfaces checked
- Ansible authority checked
- Module/tool discovery
- Design impact
- Open gaps
- Apply / Verify / Undo / Change class

## Boundaries

- NetBox object modeling belongs to `netbox-knowledge-gate`.
- Broad project-maturity requests belong to `project-maturity-router`, which
  may route here when Ansible is materially involved.

## References

- `references/knowledge-receipt.md`
- `.cursor/rules/ansible-knowledge-gate.mdc`
- `.cursor/rules/ansible-coding-standards.mdc`
