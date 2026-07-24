---
name: macos-tool-install-decider-and-scaffold
description: "Use when a macOS developer tool should be added to dotfile-vnext with the right install path chosen before implementation, plus the role/playbook surfaces scaffolded in the repo pattern. Use for install this tool on mac-dev, choose brew vs release binary, or scaffold the role before rollout."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "github-release-binary-intake, tool-role-docs-pack, macos-ansible-install-validator, single-host-ansible-rollout"
requires_summary: "AGENTS.md; current repo role/playbook patterns; official upstream install docs"
title: MacOS Tool Install Decider And Scaffold
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
related:
  - AGENTS.md
  - playbooks/deploy_development_nodes.yaml
  - inventory/host_vars/mac-dev.yaml
  - roles
tags:
  - skill
  - ansible
  - macos
  - scaffold
---

# Skill: MacOS Tool Install Decider And Scaffold

Choose the install strategy early, then scaffold the repo surfaces in the
pattern this project already uses.

## When to use / not use

Use when a new macOS CLI or developer tool should be added to `mac-dev` and
the main unknown is the install path or role shape.

Do not use when release-asset intake is already settled. Hand that to
`github-release-binary-intake`.

## Inputs

- User target and target host
- Existing repo role/playbook patterns
- Official upstream install and release docs

## Workflow

1. Inspect the nearest existing role, playbook, and host-vars surfaces first.
2. Decide whether the tool belongs in an existing role, a new role, or a composed playbook tag path.
3. Choose the install family before editing:
   - Homebrew or cask when it is stable, binary-backed, and operationally right
   - upstream release binary when package-manager paths are slow, source-built, or weakly controlled
   - another repo-backed path only when upstream docs make it clearly better
4. State `Apply / Verify / Undo / Change class` before meaningful edits.
5. Scaffold the expected surfaces: defaults, tasks, metadata, README, playbook wiring, and host-vars gate when commissioned.
6. Hand off to `github-release-binary-intake` when a GitHub release binary should be pinned.
7. Hand off to `tool-role-docs-pack` for metadata, README links, and usage-note packaging.
8. Hand off to `macos-ansible-install-validator` and then `single-host-ansible-rollout` for execution.

## Handoffs

- `github-release-binary-intake`
- `tool-role-docs-pack`
- `macos-ansible-install-validator`
- `single-host-ansible-rollout`

## Outputs

- Early install-strategy decision
- Repo-aligned role and playbook shape
- Lifecycle control point
- Apply/Verify/Undo/Change-class summary

## Validation

- Existing repo patterns were inspected before structure was chosen
- The install strategy is justified from upstream evidence
- The scaffolded surfaces match the repo lifecycle pattern

## Failure boundaries

- Stop when upstream install paths remain ambiguous
- Stop when the requested install path conflicts with explicit user direction

## Prohibited behavior

- Starting a long package-manager build before deciding whether that path is acceptable
- Treating bootstrap installer scripts as the default steady-state role path
- Skipping the lifecycle interface because the tool looks simple

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking install-path authority.
- Load `references/related-artifacts.md` for likely repo touch points.
