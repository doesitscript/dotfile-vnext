---
name: interactive-shell-completion-proof
description: "Use when shell completion or other interactive shell behavior must be proven in a real TTY instead of inferred from installed files, completion functions, or synthetic calls. Use for stern tab-completion proof, gonzo completion proof, bash completion troubleshooting, or to confirm helper errors like _get_comp_words_by_ref are truly gone in the interactive shell the user actually runs."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "Real shell binary; PTY transcript; expected completion candidates or error absence"
title: Interactive Shell Completion Proof
technology: shell
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - bash
  - zsh
  - validation
  - mac-dev
related:
  - roles/common/bash_completion
  - roles/common/shell_config
  - playbooks/deploy_development_nodes.yaml
  - playbooks/deploy_k8s_cli_tools.yaml
tags:
  - skill
  - validation
  - shell
  - completion
  - tty
---

# Skill: Interactive Shell Completion Proof

Prove shell completion in the same kind of interactive shell the operator uses.
Use a real PTY transcript, not a synthetic completion-function invocation.

## When to use / not use

Use when the question is whether completion or prompt-time shell behavior
actually works in an interactive terminal.

Do not use when file presence alone is enough, or when the task is only to
design an install role without live validation.

## Inputs

- The shell binary or shell family in scope
- The exact probe text to type before pressing `Tab`
- Expected completion candidates, or specific helper errors that must be absent

## Workflow

1. Confirm shell truth first: login shell path, `command -v` result, and shell version.
2. Prefer the bundled PTY helper so the proof runs in a real interactive shell.
3. Capture the transcript for the exact probe, typically a double-Tab completion listing.
4. Compare the transcript against expected candidates and forbidden helper errors.
5. If proof fails, inspect the transcript before changing completion code, shell config, or package choices.
6. Hand off to rollout or validator skills only after the failure is classified.

## Handoffs

- `macos-ansible-install-validator`
- `single-host-apply-and-receipt`
- `single-host-ansible-rollout`

## Outputs

- Real PTY transcript
- Shell-truth snapshot
- Pass/fail result for expected completion behavior

## Validation

- The transcript comes from a real interactive PTY
- Success is based on visible completion behavior or absence of the known helper error
- Installed completion files or direct function calls are treated only as supporting evidence

## Failure boundaries

- Stop when the issue only reproduces in a user-specific terminal preference that requires an operator choice
- Stop when the shell in use is not the one the repo is managing and that mismatch is the real blocker

## Prohibited behavior

- Declaring success from `complete -p` or file presence alone
- Treating a direct completion-function call as proof of terminal behavior
- Making shell-config edits before reading the actual PTY transcript

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Run `bin/codex-env python skills/validation/interactive-shell-completion-proof/scripts/probe_completion_pty.py ...`
- Load `references/sources-and-precedence.md` when ranking conflicting evidence.
- Load `references/related-artifacts.md` for common probe commands and shell-truth checks.
