---
name: tool-role-docs-pack
description: "Use when a tool role needs the standard documentation pack after implementation shape is settled: README links, metadata, usage note, and integration guidance. Use for build the tool role docs pack, add upstream docs links, or package the managed usage note."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-usage-note-and-discoverability, single-host-ansible-rollout"
requires_summary: "Current upstream docs and role surfaces"
title: Tool Role Docs Pack
technology: documentation
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - documentation
  - tooling
related:
  - roles/*/README.md
  - roles/*/meta/main.yml
  - roles/*/meta/argument_specs.yml
tags:
  - skill
  - documentation
  - metadata
  - docs-pack
---

# Skill: Tool Role Docs Pack

Use the repo's standard documentation pack workflow for tool roles once the
install path is already known.

## When to use / not use

Use when the remaining work is metadata, README links, managed usage-note
content, or integration guidance for a tool role.

Do not use when install-path design is still open. Hand that to
`macos-tool-install-decider-and-scaffold`, `tool-capability-intake`, or
`github-release-binary-intake`.

## Inputs

- Current role README and metadata files
- Canonical upstream links
- Real repo-managed integration examples

## Workflow

1. Confirm the role install and verify surfaces are already settled.
2. Build the docs pack:
   - role metadata
   - argument specs
   - README Apply/Verify/Undo
   - managed usage note when helpful
   - upstream and integration links
3. Hand off to `tool-usage-note-and-discoverability` when the broader metadata workflow should carry the detailed edits.
4. Hand off to `single-host-ansible-rollout` if the user also requested live verification.

## Handoffs

- `tool-usage-note-and-discoverability`
- `single-host-ansible-rollout`

## Outputs

- Standardized tool-role docs pack
- Clear upstream and integration links
- Better discoverability for future operators and agents

## Validation

- README, metadata, and usage note agree on the actual role behavior
- Links point at real upstream sources

## Failure boundaries

- Stop when the install contract is still changing
- Stop when the integration example is not repo-backed

## Prohibited behavior

- Inventing integrations
- Treating placeholders as the delivered docs pack

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when choosing doc authority.
- Load `references/related-artifacts.md` for likely repo touch points.
