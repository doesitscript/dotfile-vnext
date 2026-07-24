---
name: ansible-cli-surface-auditor
description: "Use when dotfile-vnext needs a reusable inventory of repo-managed CLI tools, their owning Ansible roles, completion paths, verification commands, and playbook surfaces on mac-dev. Use for Gonzo, Dstl8, kubectl, kubectx, k9s, stern, or future tool-role audits before rollout or troubleshooting."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: "Repo root; role/playbook inventory surfaces"
title: Ansible CLI Surface Auditor
technology: ansible
document_type: skill
status: draft
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - mac-dev
  - tooling
  - validation
related:
  - roles/gonzo_cli
  - roles/dstl8_cli
  - roles/k3s_mac_client
  - roles/k8s_cli_tools
  - playbooks/deploy_development_nodes.yaml
  - playbooks/deploy_k8s_cli_tools.yaml
tags:
  - skill
  - ansible
  - tooling
  - audit
---

# Skill: Ansible CLI Surface Auditor

Build a reusable inventory of repo-managed CLI surfaces from Ansible-owned data.

## When to use / not use

Use when:

- the question is which role owns a CLI
- completion paths, verify commands, or playbook tags must be discovered
- a completion or rollout skill needs upstream role ownership first

Do not use when:

- the user only wants live apply or direct verification
- the task is only interactive shell proof

## Inputs

- Repo root
- Relevant roles and playbooks

## Workflow

1. Read `references/context7-ansible-notes.md`.
2. Run:

```bash
bin/codex-env python skills/validation/ansible-cli-surface-auditor/scripts/audit_cli_surfaces.py --repo-root "$PWD"
```

3. Treat role defaults and task files as the primary truth for binary and completion ownership.
4. Store the discovered surfaces in shared runtime memory for downstream skills.
5. Hand off to `macos-cli-completion-converger` when the next step is completion diagnosis.
6. Hand off to `single-host-apply-and-receipt` or `single-host-ansible-rollout` when live execution is requested.

## Handoffs

- `macos-cli-completion-converger`
- `single-host-apply-and-receipt`
- `single-host-ansible-rollout`

## Outputs

- CLI surface table
- Owning role per tool
- Completion-path hints
- Verify-command hints

## Validation

- The table cites real role-owned sources
- Multi-tool roles emit one row per user-facing CLI
- Shared memory is refreshed for downstream skills

## Failure boundaries

- Stop when a claimed role surface does not exist on disk
- Stop when a CLI cannot be mapped honestly to a repo-owned role

## Prohibited behavior

- Guessing ownership from README prose alone
- Mutating host state from this skill

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/context7-ansible-notes.md` for current Ansible module and CLI behavior.
- Shared helper: `skills/_shared/automation-memory/shared_automation.py`
