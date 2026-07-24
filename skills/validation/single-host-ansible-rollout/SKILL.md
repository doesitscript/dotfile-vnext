---
name: single-host-ansible-rollout
description: "Use when a repo-managed capability needs preview-first Ansible execution against one host, with target scope proof, check-mode output, live apply, direct post-apply verification, and failure evidence. This is also the project's single-host apply-and-receipt workflow. Use for mac-dev rollout, list-hosts preview, check diff, rerun after a fix, or capture the exact failure before changing strategy."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "bin/codex-env; ansible-playbook; direct verification commands"
title: Single Host Ansible Rollout
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - validation
  - mac-dev
related:
  - AGENTS.md
  - playbooks/deploy_development_nodes.yaml
  - skills/_shared/verification-receipt-template.md
tags:
  - skill
  - ansible
  - validation
  - rollout
---

# Skill: Single Host Ansible Rollout

Execute preview, apply, verify, and failure triage for one host without
guessing. This is the project's apply-and-receipt path for one host.

## When to use / not use

Use when the user said to execute, deploy, apply, or verify a repo-managed
capability on one host such as `mac-dev`.

Do not use when the task is still design-only.

## Inputs

- Target playbook, limit, and tags
- The host in scope
- Direct verification commands for the capability

## Workflow

1. Run a read-only target preview such as `--list-hosts`.
2. Run `--check --diff` for the scoped capability when possible.
3. Inspect the actual failure output before changing strategy.
4. Apply the live run with the same scoped host and tags.
5. Run direct post-apply verification commands on the target surface.
6. Record a lightweight receipt using `skills/_shared/verification-receipt-template.md`.
7. If rollout fails, fix the smallest evidenced cause and rerun from preview or apply as appropriate.

## Handoffs

- none

## Outputs

- Scope proof
- Read-only preview output
- Live apply result
- Direct verification result
- Failure evidence when needed

## Validation

- The preview shows what host is in scope
- The check-mode run is captured when feasible
- Direct verification confirms the installed surface, not just play recap counts

## Failure boundaries

- Stop when the user would incur destructive cleanup not already approved
- Stop when a prerequisite failure blocks meaningful progress and the evidence is captured

## Prohibited behavior

- Calling repo-only edits execute-complete after an execute request
- Guessing at failure causes without reading output
- Re-running broad playbooks when a smaller scoped rerun is available

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking evidence.
- Load `references/related-artifacts.md` for common rollout commands and surfaces.
- Receipt template: `skills/_shared/verification-receipt-template.md`
