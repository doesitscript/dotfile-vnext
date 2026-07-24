---
name: macos-ansible-install-validator
description: "Use when a macOS tool install role needs pre-apply validation for check-mode safety, archive extraction assumptions, target paths, and post-install verification commands. Use for why did unarchive fail on macOS, validate tar behavior, or catch check-mode path issues before rollout."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "single-host-ansible-rollout"
requires_summary: "Target role tasks; expected archive format; verify command"
title: MacOS Ansible Install Validator
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - macos
  - validation
related:
  - playbooks/deploy_development_nodes.yaml
  - roles/gonzo_cli/tasks/mac.yml
tags:
  - skill
  - ansible
  - macos
  - validation
---

# Skill: MacOS Ansible Install Validator

Catch macOS install-role problems before they become noisy rollout failures.

## When to use / not use

Use when a macOS install role has been designed and the risk is in task
behavior, extractor assumptions, check mode, or verify commands.

Do not use when the install path decision itself is still unsettled.

## Inputs

- Role task flow
- Archive format and extractor path
- Install destination and direct verify command

## Workflow

1. Read the macOS task flow end to end before running anything.
2. Check for `--check` hazards such as downloads or unarchives that assume future directories already exist.
3. Check extractor assumptions:
   - whether `unarchive` is safe on the target
   - whether native `/usr/bin/tar` or another tool should be pinned explicitly
   - whether zip vs tarball behavior changes the task path
4. Confirm the install destination, file mode, and final binary path are explicit.
5. Confirm there is a direct post-install verify command, not just a play recap.
6. Hand off to `single-host-ansible-rollout` for preview, apply, and receipt capture.

## Handoffs

- `single-host-ansible-rollout`

## Outputs

- Check-mode risk notes
- Extractor compatibility notes
- Binary-path verification contract
- Smallest-fix-first validation guidance

## Validation

- The role can be previewed without avoidable task-path failures
- Archive handling matches the actual target platform
- Post-install verification checks the real binary path

## Failure boundaries

- Stop when the target archive format is still unknown
- Stop when the role has no stable verify command yet

## Prohibited behavior

- Assuming Linux archive behavior on macOS
- Treating `changed` counts as proof of a working install
- Fixing rollout failures before reading the failing task output

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when deciding whether to trust task logic or failure evidence.
- Load `references/related-artifacts.md` for common validation surfaces.
