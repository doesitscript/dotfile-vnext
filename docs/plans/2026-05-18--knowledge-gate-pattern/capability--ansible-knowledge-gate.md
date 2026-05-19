# Capability: Ansible Knowledge Gate

## Purpose

Force Ansible design and implementation work to be grounded in repo truth,
Ansible best practices, and current module/tool capability before planning or
mutating code.

## Triggers

- roles, playbooks, inventories, variables, tags, modules, collections, or
  execution environments
- idempotence, check mode, lifecycle state, validation, or troubleshooting
- broad project work routed here by `project-maturity-router`

## Required Authority

- existing repo roles, playbooks, inventories, docs, and rules
- `ansible.zen_of_ansible`
- `ansible_content_best_practices`
- `ansible-doc` or official module/collection docs when choosing modules
- repo-local wrapper expectations for Python, Ansible, and WinRM-sensitive work

## Required Output

The gate requires a knowledge receipt before decision-complete plans or
implementation:

- repo surfaces checked
- Ansible authority checked
- module/tool discovery result
- design impact
- open gaps
- apply/verify/undo/change class

## Non-Goals

- Do not own NetBox object-modeling decisions.
- Do not route broad project-maturity requests directly; the router owns
  composition.
