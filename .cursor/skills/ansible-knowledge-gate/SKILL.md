---
name: ansible-knowledge-gate
description: Ground Ansible design and implementation in repo truth, current Ansible guidance, module discovery, and validation before planning or changing roles, playbooks, inventories, or variables. Also use when a host install/download/remove request might become ad-hoc SSH or pip — enter homelab-ansible-first-entry first, then route to present|absent capability intake (tool-capability-intake, windows-tool-capability-intake, or hf-model-weight-lifecycle). Also use when you do not know the module — force Context7 intent search and a module matrix before any win_shell.
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

## Intent → Context7 → module matrix (hard stop before shell)

When the needed FQCN is unknown, unclear, or “maybe shell is easier”:

Prefer skill **`ansible-surface-to-module-discovery`** for the findability
front-door (surfaces → Context7 → ansible-doc → matrix), then continue here for
the full knowledge receipt.

1. **List operational surfaces in plain language** (no FQCN required yet), e.g.
   - Windows background process at boot
   - Windows firewall allow TCP 11434
   - Windows machine environment variable
   - Download + silent install MSI/EXE
2. **Findability channel order** (do not invent FQCNs from memory):
   - Repo grep for existing role patterns
   - Context7 intent search (`resolve-library-id` + `query-docs`)
   - `bin/codex-env ansible-doc` / `ansible-doc -t module -l` for params/defaults
   - docs.ansible.com Collections + Modules indexes
   - Galaxy collection/role search only after modules are exhausted
3. **Intent search via Context7** (required when MCP is available):
   - `resolve-library-id` for `ansible.windows`, `community.windows`,
     Chocolatey collection, and any product-specific library
   - `query-docs` with **intent phrases**, not guessed module names — e.g.
     “scheduled task at startup SYSTEM”, “create Windows service”, “NSSM”,
     “firewall rule”, “machine environment”
   - Optional second pass: narrow to the candidate FQCN’s parameters
   - If Context7 fails: label the failure, then `ansible-doc` / docs.ansible.com;
     do not invent parameters
4. **Write a module matrix** before any `win_shell` / `win_powershell` /
   role `files/*.ps1` for install/runtime:

   | Surface (plain) | Candidate FQCN | Evidence (Context7 / ansible-doc) | Fit | Notes |
   | --- | --- | --- | --- | --- |
   | … | … | … | yes/partial/no | … |

4. Prefer modules inside the **owning role**. Typical Windows starters:
   - Package: `chocolatey.chocolatey.win_chocolatey`
   - File download: `ansible.windows.win_get_url` (checksum + timeout)
   - EXE/MSI: `ansible.windows.win_package` (silent args + `creates_path`)
   - Service: `ansible.windows.win_service`
   - NSSM-wrapped serve: `community.windows.win_nssm` (+ install nssm)
   - Scheduled task: `community.windows.win_scheduled_task` (set
     `execution_time_limit: PT0S` for long-running serve — docs default 72h)
   - Firewall: `community.windows.win_firewall_rule`
   - Env: `ansible.windows.win_environment`
5. **PROHIBITED** without explicit user `oneoffs` exception:
   - Reaching for `win_shell` because “I don’t know the module”
   - `playbooks/troubleshoot/_tmp_*` install playbooks
   - Invented curl/BITS/PowerShell download+install helpers when the matrix
     shows a module fit

If every candidate is `no`, document why in the receipt and escalate (Galaxy
role research, vendor installer contract, or user-approved one-off) — still do
not skip the matrix.

## Required Workflow

1. Inspect existing repo surfaces:
   - relevant roles, playbooks, inventory, docs, and active rules
   - steady-state automation before bootstrap helpers
2. Check Ansible authority:
   - `ansible.zen_of_ansible`
   - `ansible_content_best_practices`
   - Context7 / `ansible-doc` / official module docs when selecting modules
3. Run **Intent → Context7 → module matrix** (above) before shell.
4. If research findings must survive the chat, hand off to global skill
   `conversation-research-to-library` (plan intermission) before locking build.
5. Produce a knowledge receipt before decision-complete planning or
   implementation.

## Knowledge Receipt

Include these fields when the gate applies:

- Repo surfaces checked
- Ansible authority checked
- Operational surfaces (plain language)
- Context7 / docs passes run (library ids + intents)
- Module matrix (or link to plan section)
- Module/tool discovery conclusion
- Design impact
- Open gaps / Research Needed
- Apply / Verify / Undo / Change class

## Boundaries

- NetBox object modeling belongs to `netbox-knowledge-gate`.
- Broad project-maturity requests belong to `project-maturity-router`, which
  may route here when Ansible is materially involved.
- Wide install/mutate entry belongs to `homelab-ansible-first-entry`.
- Chat/plan research persistence belongs to `conversation-research-to-library`.

## References

- `references/knowledge-receipt.md`
- `references/intent-to-module-matrix.md`
- `.cursor/rules/ansible-knowledge-gate.mdc`
- `.cursor/rules/ansible-coding-standards.mdc`
- `.cursor/skills/homelab-ansible-first-entry/SKILL.md`
- `docs/codex_framework/plan-research-intermission.md`
