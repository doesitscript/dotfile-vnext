---
title: Red Hat COP Automation Good Practices (Ansible GPA)
technology: ansible
document_type: generated-context7
status: reviewed
authority: mixed
source_type: generated
upstream_url: "https://github.com/redhat-cop/automation-good-practices"
upstream_repository: "https://github.com/redhat-cop/automation-good-practices"
source_version: "main"
retrieved_at: "2026-09-11"
last_reviewed_at: "2026-09-11"
context7_library_id: "/redhat-cop/automation-good-practices"
published_docs: "https://redhat-cop.github.io/automation-good-practices/"
applies_to:
  - ansible
  - roles
  - playbooks
  - inventories
  - multi-agent-evaluator
related:
  - implementation-guides/ansible/scalable-playbook-and-role-organization.md
  - generated/context7/ansible/role-interface-contracts
tags:
  - ansible
  - gpa
  - redhat-cop
  - good-practices
  - evaluator
---

# Ansible GPA — evaluator-oriented digest

**Alias:** `ANSIBLEGPA` / Red Hat COP Automation Good Practices  
**Authority:** opinionated *good* practices (not blind “best”), from
[redhat-cop/automation-good-practices](https://github.com/redhat-cop/automation-good-practices)
([published HTML](https://redhat-cop.github.io/automation-good-practices/)).

This pack is the durable library entry for multi-agent **Evaluator** review of
Ansible adaptations. Project rules (e.g. `role_name_` prefix, `.yml`,
`present|absent`) still win when they are stricter; GPA fills gaps and
cross-checks design quality on touched owners.

## Sources checked

| Channel | Result |
| --- | --- |
| Context7 `/redhat-cop/automation-good-practices` | Primary — roles, playbooks, naming, coding style, testing, security snippets |
| Firecrawl `https://redhat-cop.github.io/automation-good-practices/` | Confirmed published GPA structure (Parts I–IV) |
| HRL existing ansible scalability packs | Complementary; do not replace this GPA entry |

## Evaluator checklist (chunk-local)

Use only against owners the Implementer changed. Short, actionable findings.

### Roles

- [ ] User-facing vars / defaults prefixed with **role name**; internals `__` prefix
- [ ] `meta/argument_specs.yml` documents public options (types/defaults/choices)
- [ ] Defaults in `defaults/main.yml`; `vars/main.yml` for static internals only
- [ ] Do **not** `set_fact` to override role defaults/inputs
- [ ] No hardcoded inventory group names inside roles (parameterize)
- [ ] Role names without dashes (collection-safe)
- [ ] Tags prefixed / meaningful standalone

### Playbooks & reuse

- [ ] Prefer thin playbooks (list of roles / imports)
- [ ] Tagged `include_role` uses `apply: { tags: [...] }` (or `import_role`) so tags enter the role
- [ ] Each tag remains a complete, usable result

### Coding style

- [ ] **FQCN** modules (`ansible.builtin.*`, collection modules)
- [ ] snake_case identifiers; named tasks/plays in imperative form
- [ ] Prefer specific modules over `command`/`shell`; `changed_when` when shell is required
- [ ] Idempotent desired state (`state: present|absent` patterns)

### Inventories

- [ ] Structured inventory dirs; desired state in inventory/group_vars/host_vars
- [ ] Avoid baking host lists into roles

### Validation / security (Light)

- [ ] One bundled source-quality check (lint/syntax/argument contract) when claimed
- [ ] No secrets in cleartext; vault_/env patterns for credentials
- [ ] Do not demand full GPA CI/AAP/promotion theater for a single Light chunk

## Explicit non-goals for Light Evaluator

- Rewriting the refined technical handoff
- Whole-repo GPA conformance audits
- AAP configuration-as-code or promotion pipeline redesign unless that is the chunk

## Upstream map

| GPA section | Path in upstream repo |
| --- | --- |
| Foundations / structures | `structures/`, `naming_conventions/` |
| Roles | `roles/README.adoc` |
| Playbooks | `playbooks/README.adoc` |
| Inventories | `inventories/README.adoc` |
| Coding style | `coding_style/README.adoc` |
| Collections / plugins | `collections/`, `plugins/` |
| Testing / security / git | `testing/`, `security/`, `git_workflow/` |
| AAP CaC | `aap_configuration/` |

## decision.yaml companion

See `decision.yaml` in this directory.
