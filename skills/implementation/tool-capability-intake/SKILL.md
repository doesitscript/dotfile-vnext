---
name: tool-capability-intake
description: "Use when adding, replacing, or refactoring a repo-managed tool capability in dotfile-vnext, especially when the work must choose between extending an existing role, creating a new role, or changing install strategy. Use for install tool X, add CLI role, convert package-manager installs to a better lifecycle contract, or when an ad-hoc host install must become present|absent Ansible first. Do not use for rollout-only execution after the design is already settled; for Windows HVH tools prefer windows-tool-capability-intake; for HF weight trees prefer hf-model-weight-lifecycle."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "upstream-release-binary-installer, tool-usage-note-and-discoverability, single-host-ansible-rollout, windows-tool-capability-intake, hf-model-weight-lifecycle"
requires_summary: "AGENTS.md; bin/codex-env for repo-local Python and Ansible commands"
title: Tool Capability Intake
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - tooling
related:
  - AGENTS.md
  - playbooks/deploy_development_nodes.yaml
  - inventory/host_vars/mac-dev.yaml
  - roles
tags:
  - skill
  - ansible
  - tooling
  - intake
---

# Skill: Tool Capability Intake

Shape the repo contract for a new tool capability before implementation starts.

## When to use / not use

Use when adding a new CLI/tool role, changing install strategy, or deciding
whether work belongs in an existing role, a new role, or a composed playbook.

Do not use when only the rollout remains. Hand that to
`single-host-ansible-rollout`.

Hand off early when the OS or artifact is specialized:
- Windows HVH tool/package → `windows-tool-capability-intake`
- HF model **weights** on the share → `hf-model-weight-lifecycle`
- macOS default stack → `macos-tool-install-decider-and-scaffold`

## Inputs

- User target and target host
- Existing roles, playbooks, inventory, and docs
- Official upstream docs for the tool and installer path

## Workflow

1. Inspect the nearest existing role/playbook surfaces before proposing structure.
2. Decide whether to extend an existing role, add a new role, or compose roles in a playbook.
3. Define the lifecycle interface, preferably `*_state: present|absent`.
4. State `Apply / Verify / Undo / Change class` before meaningful edits.
5. If package-manager installs look fragile, hand off to `upstream-release-binary-installer`.
6. If operator docs, links, or role discoverability matter, hand off to `tool-usage-note-and-discoverability`.
7. Once the design is implemented, hand off to `single-host-ansible-rollout`.
8. Never satisfy “install X on the host” with ad-hoc SSH/pip/scp when Ansible should own it (AGENTS.md §32).

## Handoffs

- `windows-tool-capability-intake`
- `hf-model-weight-lifecycle`
- `macos-tool-install-decider-and-scaffold`
- `upstream-release-binary-installer`
- `tool-usage-note-and-discoverability`
- `single-host-ansible-rollout`

## Outputs

- Clear capability shape
- Chosen repo placement
- Lifecycle interface
- Apply/Verify/Undo/Change-class summary

## Validation

- The chosen structure matches existing repo patterns
- The lifecycle interface is explicit
- The implementation path is backed by repo inspection and upstream docs

## Failure boundaries

- Stop when the upstream install path is still under-researched
- Stop when the requested capability conflicts with existing repo policy and no narrower path is agreed

## Prohibited behavior

- Skipping repo inspection
- Treating repo-only edits as execute-complete after an execute request
- Introducing one-off shell installers when an idempotent Ansible path is clear
- Ad-hoc host mutation before a `present|absent` owner exists

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when source ranking matters.
- Load `references/related-artifacts.md` for likely repo touch points.
