---
name: tool-usage-note-and-discoverability
description: "Use when a tool role needs a durable docs pack: discoverability metadata, upstream links, managed usage notes, or integration context in README and Ansible role metadata. Use for meta/main.yml, meta/argument_specs.yml, README links, usage note templates, or Stern plus Gonzo style integration guidance."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "single-host-ansible-rollout"
requires_summary: "Current upstream docs and role surfaces"
title: Tool Usage Note And Discoverability
technology: documentation
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - documentation
  - tooling
related:
  - roles/gonzo_cli/README.md
  - roles/gonzo_cli/meta/main.yml
  - roles/gonzo_cli/meta/argument_specs.yml
  - roles/gonzo_cli/templates/gonzo-ai-usage.md.j2
tags:
  - skill
  - documentation
  - metadata
  - discoverability
---

# Skill: Tool Usage Note And Discoverability

Make new tool capabilities easy to find, understand, and verify after install.
This is the project's docs-pack workflow for tool roles.

## When to use / not use

Use when a role needs clear metadata, upstream links, README guidance, a
managed usage note, or explicit integration context with another repo-managed
tool.

Do not use when install-path design is still the missing piece.

## Inputs

- Current upstream documentation and canonical URLs
- The role README and metadata files
- Known repo integration points such as Stern, K3s contexts, or related CLIs

## Workflow

1. Update `meta/main.yml` so description, platforms, and tags reflect the real capability.
2. Update `meta/argument_specs.yml` so the lifecycle interface and important options are documented.
3. Add or refresh the role README with upstream links and apply/verify/undo guidance.
4. Render a managed usage note when operator or AI workflows benefit from a durable local guide.
5. Include integration context only when it is real and repo-backed.
6. Hand off to `single-host-ansible-rollout` if the user also requested live execution.

## Handoffs

- `single-host-ansible-rollout`

## Outputs

- Better role metadata
- Upstream links in durable docs
- Managed usage-note template when needed
- Clear verification commands
- A consistent docs pack for future tool-role requests

## Validation

- Links point at real upstream docs
- Role metadata matches the actual install surface
- Usage-note paths and verify commands match the live role behavior

## Failure boundaries

- Stop when upstream links are unverified
- Stop when integration examples depend on tools or contexts the repo does not actually manage

## Prohibited behavior

- Inventing integrations
- Leaving README apply/verify/undo guidance out of sync with the role
- Treating placeholders as delivered operator guidance

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when choosing authority for docs and metadata.
- Load `references/related-artifacts.md` for likely files to update.
