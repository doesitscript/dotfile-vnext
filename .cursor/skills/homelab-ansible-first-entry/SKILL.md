---
name: homelab-ansible-first-entry
description: >-
  Wide entry door for any homelab install, download, configure, remove, or
  host-mutation request in dotfile-vnext. Use immediately before inventing an
  approach — forces Ansible-first routing to the correct intake skill and
  prohibits custom install scripts, temp playbooks, and ad-hoc choco/pip/ssh
  installs. Use for install X, fix hung Chocolatey, download Setup.exe, add
  Windows/macOS tool, or when tempted to write a one-off .ps1/.sh installer.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "ansible-knowledge-gate, tool-capability-intake, windows-tool-capability-intake, macos-tool-install-decider-and-scaffold, hf-model-weight-lifecycle, homelab-ssh-alias-connect"
requires_summary: "AGENTS.md §32 Ansible-first; skills/catalog.yml routing"
title: Homelab Ansible-First Entry
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - windows
  - macos
  - tooling
related:
  - AGENTS.md
  - .cursor/skills/ansible-knowledge-gate/SKILL.md
  - .cursor/skills/catalog.yml
tags:
  - skill
  - ansible
  - entry
  - routing
  - anti-ad-hoc
---

# Skill: Homelab Ansible-First Entry

This is the **wide front door**. For host install/download/configure/remove
work, do **not** invent a starting approach. Run the entry script, pick a door,
then hand off. Thinking up custom curl/BITS/`.ps1` installers is out of order.

## When to use / not use

**Use first** when the user asks to install, download, configure, remove, repair,
or “just get X working” on a managed host — including recovery after a hung
package manager.

**Do not use** for pure docs/planning with no host mutation, or when the user
explicitly marks a `oneoffs` exception.

## Entry script (run immediately)

```bash
bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py
```

Print that output (or summarize the chosen door) before implementing.

## Nested skill scope (stay until exit)

Once you enter this skill for a task, **do not freestyle outside skill scope**
until the work is done and you exit this entry skill:

1. Stay in this skill or **nest** into a door skill (and further nested skills).
2. Interactive SSH → nest `homelab-ssh-alias-connect` (`ssh <inventory_hostname>`).
3. Return to the parent skill after each nested step.
4. Exit this entry skill only when the user task is complete or explicitly deferred.

## Nested SSH (no invented connections)

```bash
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --host <inventory_hostname>
ssh <inventory_hostname>
```

## Hard stop — PROHIBITED until a door is chosen

- New `playbooks/troubleshoot/_tmp_*` install playbooks
- New role `files/*.ps1` / shell installers for downloads community modules cover
- Ad-hoc `choco install`, `pip install`, `scp` of installers, interactive
  one-liner installers as the **primary** install path
- Skipping `ansible-knowledge-gate` module discovery when choosing install tech

**Allowed carve-outs (not install substitutes):** stop hung processes / clear
`.chocolateyPending` via Ansible ad-hoc; interactive SSH `-File` on a
**role-staged** script the role already owns.

## Doors (pick one; then stop and open that skill)

| If the request looks like… | Enter this skill next |
| --- | --- |
| Windows tool/package / Chocolatey / Setup.exe / HVH or AMD desktop | `windows-tool-capability-intake` |
| macOS CLI / Homebrew vs release binary | `macos-tool-install-decider-and-scaffold` then `tool-capability-intake` |
| HF **model weights** on the share | `hf-model-weight-lifecycle` |
| Generic tool capability / unclear OS | `tool-capability-intake` |
| Ansible role/playbook design already in scope | `ansible-knowledge-gate` (module matrix required) |
| Broad “make the project better” | `project-maturity-router` |

Windows upstream `.exe` install default after Chocolatey is wrong/hung:

1. `ansible.windows.win_get_url` (checksum + long timeout)
2. `ansible.windows.win_package` (silent args + `creates_path`)
3. Inside the **owning role**, inventory `install_method` — never a temp playbook

## Minimal entry receipt (required before mutate)

```text
Entry door: <skill name>
Owner role/playbook: <path or "needs intake">
Install family candidates: <modules — not shell>
One-off exception?: no | user-explicit oneoffs
Next skill: <handoff>
```

## Handoffs

Always continue into the chosen door skill; this entry skill does not implement
the capability itself.

## References

- `references/doors.md`
- `scripts/print_entry_doors.py`
- AGENTS.md §32 Ansible-first
