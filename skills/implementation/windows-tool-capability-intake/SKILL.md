---
name: windows-tool-capability-intake
description: "Use when adding or changing a Windows-host tool capability in dotfile-vnext (HVH-01/HVH-02), especially Chocolatey, py -m pip, WinRM/OpenSSH PowerShell surfaces, or present|absent role scaffolding before any host mutation. Use for install this on HOM-LAB-HVH-01, Windows pip package role, Chocolatey CLI role, or scaffold Windows tool lifecycle. Do not use for mac-dev tools (use macos-tool-install-decider-and-scaffold) or for HF weight trees (use hf-model-weight-lifecycle)."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-capability-intake, tool-role-docs-pack, single-host-ansible-rollout"
requires_summary: "AGENTS.md §32; roles/python Windows pattern; roles/huggingface_hub; inventory host_vars for HVH hosts"
title: Windows Tool Capability Intake
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - windows
  - tooling
related:
  - AGENTS.md
  - roles/python/tasks/windows.yml
  - roles/huggingface_hub/
  - playbooks/deploy_huggingface_hub.yaml
  - inventory/host_vars/hom-lab-hvh-01.yaml
tags:
  - skill
  - ansible
  - windows
  - intake
---

# Skill: Windows Tool Capability Intake

Shape and scaffold Windows tool capabilities with `present|absent` before any
host mutation. Mirrors the macOS tool intake pattern for HVH / PowerShell hosts.

## When to use / not use

Use when installing or removing a Windows CLI/package on `HOM-LAB-HVH-01` /
`HOM-LAB-HVH-02` (Chocolatey, `py -m pip`, scheduled tasks, Win services).

Do not use for mac-dev (hand to `macos-tool-install-decider-and-scaffold`).
Do not use for Hugging Face **weight trees** on the share (hand to
`hf-model-weight-lifecycle`). This skill may own the Hub **client** package
pattern (`roles/huggingface_hub`).

## Inputs

- Target Windows inventory hostname and connection surface
- Existing Windows roles (`python`, `windows_ollama_runtime`, `huggingface_hub`, Chocolatey roles)
- Upstream install docs (Firecrawl / Context7 / HRL)

## Workflow

1. Run `ansible-knowledge-gate` / inspect repo Windows roles before proposing structure.
2. Decide extend vs new role vs playbook composition with tags.
3. Choose install family (module matrix — no invented scripts first):
   - `chocolatey.chocolatey.win_chocolatey` when a stable community package exists
     and is healthy on the target
   - `ansible.windows.win_get_url` + `ansible.windows.win_package` for pinned
     upstream Setup.exe / MSI (checksum, long timeout, silent args, `creates_path`)
   - `py -m pip` via `ansible.windows.win_command` when the tool is a PyPI
     package (see `roles/huggingface_hub`)
   - custom shell/PowerShell download+install only after the matrix shows no
     module fit, and only inside the owning role (never `_tmp_` playbooks)
4. Require `*_state: present|absent`, `meta/argument_specs.yml`, README Apply/Verify/Undo.
5. Wire playbook + host_vars gate to `present` when commissioned.
6. Hand off to `tool-role-docs-pack` then `single-host-ansible-rollout`.

## Entry

For new install/mutate requests, enter via `homelab-ansible-first-entry` first.

## Handoffs

- `tool-capability-intake` (generic shape when OS-agnostic)
- `tool-role-docs-pack`
- `single-host-ansible-rollout`
- `hf-model-weight-lifecycle` when the request is model weights, not the Hub client

## Outputs

- Install-family decision
- Role/playbook/host_vars scaffold plan
- Lifecycle control point
- Apply/Verify/Undo/Change-class summary

## Validation

- No ad-hoc SSH/`pip install`/`choco` outside role tasks
- Connection surface is PowerShell (`ansible_shell_type=powershell`)
- Present and absent paths both reachable from the owning playbook

## Failure boundaries

- Stop when upstream Windows install path is still under-researched
- Stop when user asked for an explicit one-off and Ansible must not own it

## Prohibited behavior

- scp + temp script installs on HVH hosts
- Installing packages before the role/`present|absent` surface exists
- Skipping undo (`absent`) because “we only need install”

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking install authority.
- Load `references/related-artifacts.md` for likely repo touch points.
