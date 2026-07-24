---
name: tool-playbook-placement-advisor
description: "Use when a new or refactored tool capability needs a clear home in dotfile-vnext before implementation: deploy_development_nodes.yaml, deploy_k8s_cli_tools.yaml, another existing playbook, or a composed tag path. Use for should this tool live with k8s cli tools, where should this role be wired, or does this belong in a shared substrate role."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-capability-intake, macos-tool-install-decider-and-scaffold"
requires_summary: "Target host; tool family; adjacent managed tools or playbooks already in scope"
title: Tool Playbook Placement Advisor
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - macos
  - tooling
  - playbooks
related:
  - playbooks/deploy_development_nodes.yaml
  - playbooks/deploy_k8s_cli_tools.yaml
  - playbooks/role_only.yaml
  - roles/k8s_cli_tools
tags:
  - skill
  - ansible
  - routing
  - playbooks
---

# Skill: Tool Playbook Placement Advisor

Decide where a tool capability belongs before implementation starts so the repo
does not grow accidental wrapper logic or mismatched playbook homes.

## When to use / not use

Use when a tool is being added, moved, or split and the open question is which
playbook or role lane should own it.

Do not use when the playbook home is already settled and the remaining work is
install-path design or rollout.

## Inputs

- Target host and operator workflow
- Tool family and primary neighbors
- Current playbook and role surfaces already touching the tool

## Workflow

1. Inspect the nearest existing playbooks, roles, and tags first.
2. Classify the tool by operational lane:
   - general controller-local development tooling
   - K8s operator tooling that assumes kubeconfig and cluster-facing workflows
   - shared shell/completion substrate
   - another clearly existing repo capability lane
3. Prefer an existing playbook home when the lifecycle, dependencies, and tags already fit.
4. Prefer playbook composition with meaningful tags over merging unrelated tools into one role.
5. Recommend a new role only when the tool has a distinct lifecycle or install contract but still name the owning playbook lane.
6. If the tool is shell/completion substrate rather than an operator-facing CLI, route it to the shared roles instead of a tool bundle role.
7. Hand off to `tool-capability-intake` or `macos-tool-install-decider-and-scaffold` once the home is clear.

## Handoffs

- `tool-capability-intake`
- `macos-tool-install-decider-and-scaffold`

## Outputs

- Recommended owning playbook
- Recommended role home or substrate owner
- Tag and dependency guidance for the capability

## Validation

- The chosen home matches the tool's real operator workflow and dependencies
- The recommendation avoids wrapper-filtering lifecycle or verification paths
- Existing playbook composition is reused when it already fits

## Failure boundaries

- Stop when two playbook homes are equally plausible and the difference is a real operator-facing choice
- Stop when the tool spans multiple lanes and the repo has no established composition pattern yet

## Prohibited behavior

- Creating a new playbook just because a tool is new
- Merging unrelated tools into one role only to share a tag
- Treating shell/completion substrate work as if it were an independent operator tool

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when placement signals disagree.
- Load `references/related-artifacts.md` for the current playbook and role homes.
