# Project Maturity Routing Matrix

## Ansible Gate Only

Use `ansible-knowledge-gate` for:

- role or playbook design
- inventory structure and variable placement
- module or collection choice
- lifecycle variables such as `present` / `absent`
- idempotence, check mode, lint, syntax, or validation

## NetBox Gate Only

Use `netbox-knowledge-gate` for:

- NetBox object modeling
- source-of-truth boundaries
- names, slugs, tags, platforms, roles, sites, clusters
- devices, VMs, interfaces, IP addresses, prefixes
- custom field decisions
- `nb_inventory` grouping or adoption

## Both Gates

Use both gates for:

- Ansible-managed NetBox seeding
- project maturity work that affects both automation and infrastructure truth
- inventory migration from static Ansible inventory toward NetBox
- naming or metadata decisions that must be represented in both Ansible and
  NetBox

## Router Only

Use only the router when the immediate task is classification or plan shaping
and no domain-specific decision has been reached yet.
