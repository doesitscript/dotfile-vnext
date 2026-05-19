---
name: netbox-knowledge-gate
description: Ground NetBox modeling, naming, source-of-truth, nb_inventory, and netbox.netbox work in repo truth and current NetBox docs/API guidance before planning or changing objects.
---

# NetBox Knowledge Gate

Use this skill for work that touches NetBox objects, source-of-truth modeling,
names, slugs, tags, custom fields, devices, VMs, interfaces, IPs, platforms,
roles, sites, clusters, `nb_inventory`, or the `netbox.netbox` collection.

## Core Rule

Do not model NetBox objects from memory alone. First prove that the relevant
repo surfaces and NetBox authority were checked.

## Required Workflow

1. Inspect existing repo NetBox surfaces:
   - `roles/ipam_netbox/`
   - `inventory/netbox.yml`
   - active NetBox plans and rules
2. Check NetBox authority:
   - official NetBox docs and API docs when object shape matters
   - LLM-friendly NetBox docs indexes when useful
   - `netbox.netbox` module docs when Ansible manages NetBox
3. Apply the modeling gates:
   - native field before custom field
   - tag before custom field
   - object hierarchy before object creation
   - IPs belong to interfaces
   - `nb_inventory` grouping implications
4. Produce a knowledge receipt before decision-complete planning or
   implementation.

## Knowledge Receipt

Include these fields when the gate applies:

- Repo NetBox surfaces checked
- NetBox docs/API checked
- Native field / tag / custom field decision
- Hierarchy placement
- `nb_inventory` implication
- Open gaps
- Apply / Verify / Undo / Change class

## Boundaries

- Generic Ansible role/playbook design belongs to `ansible-knowledge-gate`.
- Broad project-maturity requests belong to `project-maturity-router`, which
  may route here when NetBox is materially involved.

## References

- `references/knowledge-receipt.md`
- `.cursor/rules/netbox-knowledge-gate.mdc`
- `.cursor/rules/framework-netbox-modeling.mdc`
