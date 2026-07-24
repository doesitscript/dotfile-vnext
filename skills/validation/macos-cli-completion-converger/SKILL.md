---
name: macos-cli-completion-converger
description: "Use when Bash completion for repo-managed macOS CLI tools on mac-dev is missing, partial, or suspicious, especially for Gonzo, Dstl8, kubectl, kubectx, kubens, k9s, stern, and future tools that join the same shared loader path. Use to diagnose file-vs-runtime-vs-loader failures before changing shell config."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "ansible-cli-surface-auditor, interactive-shell-completion-proof"
requires_summary: "Repo root; mac-dev shell-completion issue"
title: MacOS CLI Completion Converger
technology: shell
document_type: skill
status: draft
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - bash
  - mac-dev
  - tooling
  - validation
related:
  - roles/common/bash_completion
  - roles/common/shell_config
  - roles/gonzo_cli
  - roles/dstl8_cli
  - roles/k3s_mac_client
  - roles/k8s_cli_tools
tags:
  - skill
  - shell
  - completion
  - troubleshooting
---

# Skill: MacOS CLI Completion Converger

Diagnose and converge repo-managed CLI completions on macOS without guessing.

## When to use / not use

Use when:

- a tool is installed but completion is missing or partial
- you need to separate missing files from missing runtime registration
- the fix should generalize to future CLI tools, not only today's case

Do not use when:

- the only ask is a final PTY proof after rollout
- the problem is clearly unrelated to repo-managed shell surfaces

## Inputs

- Repo root
- Tool names in scope
- Current shell-completion symptom

## Workflow

1. Run `ansible-cli-surface-auditor` first when the owning role is not already clear.
2. Read `references/patterns.md`.
3. Run:

```bash
bin/codex-env python skills/validation/macos-cli-completion-converger/scripts/audit_completions.py --repo-root "$PWD"
```

4. Classify the failure:
   - binary missing
   - completion file missing
   - loader/runtime mismatch
   - direct-completion optional wrapper case
5. Hand off to `single-host-apply-and-receipt` or `single-host-ansible-rollout` when a role fix should be applied live.
6. Hand off to `interactive-shell-completion-proof` when the question is final operator-visible proof in a real PTY.

## Handoffs

- `single-host-apply-and-receipt`
- `single-host-ansible-rollout`
- `interactive-shell-completion-proof`

## Outputs

- Completion audit table
- Runtime shell snapshot
- Failure-class hints

## Validation

- Shared memory is populated with role ownership and audit results
- Runtime registration uses the repo-managed completion loader, not README guesses

## Failure boundaries

- Stop when the active shell is not one the repo manages and that mismatch is the real blocker
- Stop when the failure depends on an operator-local terminal customization outside repo ownership

## Prohibited behavior

- Editing `~/.bashrc` by hand as the first response
- Declaring success from file presence alone

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/patterns.md` for failure classes and July 24, 2026 lessons.
- Shared helper: `skills/_shared/automation-memory/shared_automation.py`
