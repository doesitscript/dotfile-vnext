# Skill Pattern

This folder holds repo-local Codex/Cursor skills.

Global personal-portable skills that should survive workstation rebuilds but
are not project behavior live under `roles/common/agent_skills/` and are linked
into the home directory by that role. Vendor/system-managed skills, such as
Codex `.system` skills, stay outside repo ownership.

Use this structure for new or meaningfully updated skills:

- `SKILL.md`
  Portable workflow logic for the capability.
- `capability.yml`
  Small machine-readable manifest for discovery, suggested roles, companion
  surfaces, and owned-file inventory.
- `README.md`
  Human-facing companion note when the skill owns more than `SKILL.md` alone or
  when update/remove guidance should be easy to find.
- `references/`
  Optional examples or supporting material.

## Discovery Order

Framework surfaces should discover skill context in this order:

1. `.cursor/skills/catalog.yml`
2. `<skill>/capability.yml`
3. `<skill>/SKILL.md`
4. companion rule(s) listed by the manifest
5. `docs/codex_framework/*` for explanation and capability inventory

The goal is:

- machine-readable discovery first
- portable workflow logic second
- repo-specific ambient behavior after that
- longer explanation last

## Domain Skills And Router Skills

Keep domain expertise modular.

- Domain skills own one capability area, such as Ansible automation design or
  NetBox source-of-truth modeling.
- Router skills own composition only. They decide which domain skills apply to
  broad requests, but they do not duplicate the domain rules.

For this repo, the current knowledge-gate family is:

- `ansible-knowledge-gate`
  Ansible roles, playbooks, modules, inventory, lifecycle, idempotence, and
  validation.
- `netbox-knowledge-gate`
  NetBox object modeling, source-of-truth hierarchy, naming, tags, fields,
  interfaces, IPs, and `nb_inventory`.
- `project-maturity-router`
  Broad project-improvement routing to one or both domain gates.

Do not merge these into one combined "NetBox/Ansible" skill. The router may
activate both, but each domain gate must remain independently serviceable.

## Update And Removal Pattern

For manifest-backed skills, `capability.yml` is the source of truth for:

- owned files
- companion rule files
- update strategy
- removal expectations

Default rule:

- re-dropping an updated version of a skill should replace the files listed
  under `owned_files`
- removing a skill should start from the same `owned_files` list instead of
  making the agent rediscover every companion file

This keeps skill updates and removal predictable instead of implicit.

## Transitional Status

Not every existing skill in this folder has a `capability.yml` yet.

Current standard:

- new skills should include a manifest and a catalog entry
- any skill receiving meaningful structural work should be migrated to the
  manifest-backed pattern
