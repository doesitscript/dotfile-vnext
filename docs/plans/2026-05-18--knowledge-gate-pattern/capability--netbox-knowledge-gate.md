# Capability: NetBox Knowledge Gate

## Purpose

Force NetBox-related work to follow NetBox-native modeling, source-of-truth
principles, and current product/docs guidance before planning or mutating code.

## Triggers

- NetBox objects, names, slugs, tags, platforms, roles, sites, clusters,
  devices, VMs, interfaces, IPs, prefixes, custom fields, or `nb_inventory`
- `netbox.netbox` Ansible collection usage
- broad project work routed here by `project-maturity-router`

## Required Authority

- existing repo NetBox plans, roles, inventory, and `framework-netbox-modeling`
  gates
- NetBox official docs, including LLM-friendly docs indexes when applicable
- NetBox API/schema docs when object shape or field behavior matters
- `netbox.netbox` module docs when Ansible is used to seed or manage NetBox

## Required Output

The gate requires a knowledge receipt before decision-complete plans or
implementation:

- repo NetBox surfaces checked
- NetBox docs/API checked
- native field/tag/custom field decision
- hierarchy placement
- `nb_inventory` implication
- open gaps
- apply/verify/undo/change class

## Non-Goals

- Do not own generic Ansible role or playbook design.
- Do not collapse Ansible and NetBox guidance into one shared blob.
