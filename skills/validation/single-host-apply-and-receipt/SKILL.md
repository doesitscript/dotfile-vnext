---
name: single-host-apply-and-receipt
description: "Use when a tool role should be previewed, applied, verified, and summarized with a lightweight receipt for one host. This is the designated repo path for mac-dev apply receipts. Use for run single host apply and receipt, apply this only to mac-dev, or capture the rollout receipt after a fix."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "single-host-ansible-rollout"
requires_summary: "Scoped playbook command; verify command; receipt surface"
title: Single Host Apply And Receipt
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - validation
  - mac-dev
related:
  - playbooks/deploy_development_nodes.yaml
  - skills/_shared/verification-receipt-template.md
tags:
  - skill
  - ansible
  - validation
  - receipt
---

# Skill: Single Host Apply And Receipt

Use the repo's standard one-host execution path when the main need is a clean
receipt after preview, apply, and verification.

## When to use / not use

Use when the design is already done and the remaining work is scoped execution
plus a lightweight receipt for one host.

Do not use when the task is still architecture-only.

## Inputs

- Target host and scoped playbook/tags
- Direct verification command
- Receipt template

## Workflow

1. Run the scoped preview path first.
2. Run check mode when feasible.
3. Apply the live change.
4. Verify the real installed surface directly.
5. Record the receipt.
6. When a reusable preview/apply receipt artifact is preferred, use the bundled helper:

```bash
bin/codex-env python skills/validation/single-host-apply-and-receipt/scripts/run_apply_receipt.py \
  --repo-root "$PWD" \
  --playbook playbooks/deploy_development_nodes.yaml \
  --limit mac-dev \
  --tags your_tag_here
```
7. Hand off to `single-host-ansible-rollout` when broader rollout/failure-triage workflow is needed.

## Handoffs

- `single-host-ansible-rollout`

## Outputs

- Preview/apply/verify sequence
- Lightweight receipt
- Smaller rerun surface after a fix

## Validation

- The host scope is explicit
- The receipt reflects direct verification, not recap counts alone

## Failure boundaries

- Stop when a prerequisite failure blocks meaningful apply
- Stop when broader triage is required and no direct verification path exists yet

## Prohibited behavior

- Calling repo-only edits complete after an execute request
- Skipping the receipt after a scoped rollout

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking rollout evidence.
- Load `references/related-artifacts.md` for the receipt surfaces.
