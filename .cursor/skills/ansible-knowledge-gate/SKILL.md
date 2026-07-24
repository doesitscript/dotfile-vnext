---
name: ansible-knowledge-gate
description: Ground Ansible design and implementation in repo truth, current Ansible guidance, module discovery, and validation before planning or changing roles, playbooks, inventories, or variables. Also use when a host install/download/remove request might become ad-hoc SSH or pip — enter homelab-ansible-first-entry first, then route to present|absent capability intake (tool-capability-intake, windows-tool-capability-intake, or hf-model-weight-lifecycle).
---

# Ansible Knowledge Gate

Use this skill for Ansible work that affects roles, playbooks, inventories,
variables, tags, modules, collections, lifecycle state, idempotence, validation,
or troubleshooting.

## Entry door (install / mutate)

If the user request is install, download, configure, remove, or “get X working”
on a managed host, **first** run:

```bash
bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py
```

Follow `homelab-ansible-first-entry`, then return here for module discovery.
Do not invent custom install scripts before that door.

## Core Rule

Do not design or implement Ansible changes from memory alone. First prove that
the relevant repo surfaces and Ansible authority were checked.

## Ansible-first / anti-ad-hoc (AGENTS.md §32)

Before any host mutation (SSH, WinRM, `pip`, `choco`, scp scripts):

1. Interpret install/download/remove as **Ansible capability work** unless the
   user explicitly marked a one-off / `oneoffs` exception, or you are already
   debugging Ansible task code interactively.
2. If no owner role with `*_state: present|absent` exists, stop and hand off:
   - macOS CLI → `macos-tool-install-decider-and-scaffold` / `tool-capability-intake`
   - Windows tool/package → `windows-tool-capability-intake`
   - HF **weights** on the share → `hf-model-weight-lifecycle`
3. Do not “just install it” to unblock a later role.

## Module-before-script (hard stop)

Before adding `win_shell` / `win_powershell` / role `files/*.ps1` for
download or install:

1. Write a short module matrix with evidence (`ansible-doc` or Context7):
   - Windows package: `chocolatey.chocolatey.win_chocolatey`
   - Windows file: `ansible.windows.win_get_url` (checksum + timeout)
   - Windows exe/msi: `ansible.windows.win_package` (silent args + `creates_path`)
2. Prefer those modules inside the **owning role**.
3. **PROHIBITED** without explicit user `oneoffs` exception:
   - `playbooks/troubleshoot/_tmp_*` install playbooks
   - Invented curl/BITS/PowerShell download+install helpers for cases the
     modules above cover

## Required Workflow

1. Inspect existing repo surfaces:
   - relevant roles, playbooks, inventory, docs, and active rules
   - steady-state automation before bootstrap helpers
2. Check Ansible authority:
   - `ansible.zen_of_ansible`
   - `ansible_content_best_practices`
   - `ansible-doc` or official module docs when selecting modules
3. Discover the module or tool contract before choosing shell or PowerShell.
4. Produce a knowledge receipt before decision-complete planning or
   implementation.

## Knowledge Receipt

Include these fields when the gate applies:

- Repo surfaces checked
- Ansible authority checked
- Module/tool discovery
- Design impact
- Open gaps
- Apply / Verify / Undo / Change class

## Boundaries

- NetBox object modeling belongs to `netbox-knowledge-gate`.
- Broad project-maturity requests belong to `project-maturity-router`, which
  may route here when Ansible is materially involved.
- Wide install/mutate entry belongs to `homelab-ansible-first-entry`.

## References

- `references/knowledge-receipt.md`
- `.cursor/rules/ansible-knowledge-gate.mdc`
- `.cursor/rules/ansible-coding-standards.mdc`
- `.cursor/skills/homelab-ansible-first-entry/SKILL.md`
