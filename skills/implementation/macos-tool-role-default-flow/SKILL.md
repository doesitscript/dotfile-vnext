---
name: macos-tool-role-default-flow
description: "Use when a macOS CLI or developer tool should follow the repo's default end-to-end workflow on mac-dev: choose the install family, scaffold the role/playbook surfaces, package the docs, then preview/apply/verify with a single-host receipt. Use for the usual mac tool stack, default mac tool flow, or install this tool the standard way."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "macos-tool-install-decider-and-scaffold, tool-role-docs-pack, single-host-apply-and-receipt"
requires_summary: "User target tool; preferred install family when already stated; mac-dev scope"
title: MacOS Tool Role Default Flow
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - macos
  - tooling
  - mac-dev
related:
  - skills/catalog.yaml
  - playbooks/deploy_development_nodes.yaml
  - inventory/host_vars/mac-dev.yaml
tags:
  - skill
  - ansible
  - macos
  - workflow
  - entrypoint
---

# Skill: MacOS Tool Role Default Flow

Use the repo's normal end-to-end macOS tool workflow as one entrypoint instead
of remembering the usual three-skill stack separately.

## When to use / not use

Use when a new or changed macOS CLI or developer tool on `mac-dev` should go
through the standard repo flow:

- install-family decision and scaffolding
- docs-pack and discoverability work
- scoped preview, apply, verify, and receipt

Do not use when only one slice remains clearly isolated, such as docs-only
updates or rollout-only verification after the design is already settled.

## Inputs

- User target tool and desired outcome
- Upstream install/docs sources
- Current repo role and playbook pattern

## Workflow

1. Start with `macos-tool-install-decider-and-scaffold` to choose the install family early and shape the repo surfaces.
2. Prefer Homebrew when it is the user's preference and the package path is operationally sound.
3. Hand off to `tool-role-docs-pack` for README links, metadata, usage note, and integration guidance.
4. Hand off to `single-host-apply-and-receipt` for preview, apply, direct verification, and receipt capture on `mac-dev`.
5. If the install family changes midstream, return to the decider skill rather than patching around the old assumption.

## Handoffs

- `macos-tool-install-decider-and-scaffold`
- `tool-role-docs-pack`
- `single-host-apply-and-receipt`

## Outputs

- One reusable entrypoint for the repo's standard macOS tool workflow
- Lower memory burden than recalling the skill sequence ad hoc
- A stable prompt pattern for future requests

## Validation

- The install-family decision happened before heavy implementation
- Docs-pack work matches the final role behavior
- Live rollout evidence exists when the user asked to execute

## Failure boundaries

- Stop when the user explicitly wants a different lifecycle than the default flow
- Stop when upstream install evidence is still too weak to choose a path

## Prohibited behavior

- Treating this wrapper as permission to skip the narrower skills
- Replacing user install preferences with a default without saying so
- Calling source-only edits complete after an execute request

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Use `macos-tool-install-decider-and-scaffold` for the install-path decision and repo scaffolding details.
- Use `tool-role-docs-pack` for the docs-pack surfaces.
- Use `single-host-apply-and-receipt` for the preview/apply/verify receipt flow.
