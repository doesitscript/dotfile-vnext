---
name: macos-shell-truth-and-alignment
description: "Use when macOS shell behavior is inconsistent across login shell, interactive shell, Homebrew Bash, shared completion runtime, or repo-managed shell settings. Use for bash 5.x alignment, /etc/shells drift, shell_config login shell checks, or completion-runtime mismatch before deeper troubleshooting."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "interactive-shell-completion-proof, single-host-ansible-rollout"
requires_summary: "Symptom or transcript; target host; repo-managed shell and completion surfaces"
title: MacOS Shell Truth And Alignment
technology: shell
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - macos
  - bash
  - validation
  - shell
related:
  - inventory/host_vars/mac-dev.yaml
  - roles/common/shell_config
  - roles/common/bash_completion
  - playbooks/deploy_development_nodes.yaml
tags:
  - skill
  - macos
  - shell
  - validation
---

# Skill: MacOS Shell Truth And Alignment

Diagnose shell truth first, then align the repo-managed surfaces before deeper
completion or terminal troubleshooting continues.

## When to use / not use

Use when login shell, interactive shell, Bash version, completion runtime, or
repo-managed shell expectations appear out of sync on macOS.

Do not use when the issue is already isolated to one CLI's completion body with
no shell-runtime mismatch.

## Inputs

- The observed symptom or transcript
- Target host, usually `mac-dev`
- Repo-managed shell/completion surfaces already in play

## Workflow

1. Run the bundled shell-truth collector before changing config.
2. Compare the observed shell truth against repo intent:
   - login shell path
   - interactive Bash path and version
   - `/etc/shells` registration
   - shared completion loader path
   - managed completion directory presence
3. Classify the mismatch as one of:
   - login-shell drift
   - interactive-shell drift
   - completion-loader drift
   - formula/runtime mismatch
   - terminal-specific behavior beyond repo ownership
4. Prefer repo-managed fixes through `common/shell_config` and `common/bash_completion` instead of manual dotfile edits.
5. Hand off to `interactive-shell-completion-proof` when the shell surfaces now look aligned and working proof is needed.
6. Hand off to `single-host-ansible-rollout` when the fix requires a scoped playbook apply.

## Handoffs

- `interactive-shell-completion-proof`
- `single-host-ansible-rollout`

## Outputs

- Shell-truth snapshot
- Mismatch classification
- Recommended repo-owned alignment path

## Validation

- The diagnosis uses direct shell-truth evidence, not only remembered prior state
- Repo-managed shell settings are compared to the live host truth
- Interactive proof is used before the problem is declared solved

## Failure boundaries

- Stop when the shell in use is intentionally outside repo ownership
- Stop when terminal-specific preferences are the likely root cause and the repo-managed shell state is already aligned

## Prohibited behavior

- Guessing from `$SHELL` alone
- Editing user dotfiles manually when `common/shell_config` or `common/bash_completion` owns the surface
- Declaring the shell aligned without checking `/etc/shells`, login shell, and active Bash runtime together

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/validation/macos-shell-truth-and-alignment/scripts/collect_shell_truth.py`
- Load `references/sources-and-precedence.md` when shell signals disagree.
- Load `references/related-artifacts.md` for the repo-owned shell and completion surfaces.
