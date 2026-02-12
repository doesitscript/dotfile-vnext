# Instructions: Adding Ansible Docs to Cursor

This document explains how to add the following Ansible documentation links and titles to **Cursor Docs** (Cursor’s indexed documentation) so that Cursor understands this project’s Ansible usage. Use these steps when setting up the project or onboarding other developers.

## Why This Matters

Indexing these docs in Cursor gives the AI:

- Correct playbook and inventory patterns
- Up-to-date module syntax (especially from collections)
- Best-practice guidance instead of outdated or hallucinated examples

---

## Links and Titles to Add to Cursor Docs

Add each of these as a **doc source** in Cursor (e.g. **Settings → Cursor Settings → Docs**, or equivalent “Add documentation” / “Index URL” flow). Use the **Title** as the display name and the **URL** as the source.

### 1. The Core "Blueprint" (Essential)

**Title:** `Ansible Core – Index (Blueprint)`  
**URL:** https://docs.ansible.com/ansible/latest/index.html  

*Architect note:* This is the main reference for playbooks, inventory, and the standard library. Indexing it ensures Cursor understands how tasks are orchestrated.

---

### 2. The Developer’s Framework (For Custom Extensions)

**Title:** `Ansible Developer Guide`  
**URL:** https://docs.ansible.com/ansible/latest/dev_guide/index.html  

*Architect note:* Use this when writing custom modules or plugins. It covers the Python API and how Ansible executes code.

---

### 3. Collections & Community Modules

**Title:** `Ansible Collections`  
**URL:** https://docs.ansible.com/projects/ansible-collections/  

*Architect note:* Modern Ansible is collection-based. Indexing this reduces wrong or old module syntax and helps with multi-cloud and vendor integrations (e.g. AWS, Cisco, VMware).

---

### 4. The Ansible "Best Practices" Guide

**Title:** `Ansible Tips and Tricks (Best Practices)`  
**URL:** https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html  

*Architect note:* Use this so generated or edited code follows recommended patterns, not just “working” ones.

---

## Optiontional

Use these additional official Ansible sources when you want deeper structure and precedence coverage.

### Optional Sources


- name: ansible-inventory-guide
  url: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

- name: ansible-host-group-vars
  url: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#splitting-out-vars

- name: ansible-var-merge
  url: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-we-merge

- name: ansible-variable-precedence
  url: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

- name: ansible-general-precedence
  url: https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html

- name: ansible-roles
  url: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

- name: ansible-yaml-syntax
  url: https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html

- name: ansible-builtin-collection
  url: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

Behavioral requirements:

1. When assisting with anything related to Ansible, inventory structure, host_vars, group_vars, variable merging, precedence, roles, YAML syntax, or module usage, automatically consult the relevant @doc sources without requiring me to tag them manually.

2. When I explicitly reference one of these documents using @doc <name>, you must load and incorporate the content from that remote source into your reasoning.

3. When analyzing or generating Ansible code, inventories, roles, or variable structures, you must align your recommendations with the authoritative behavior described in these registered documentation sources.

4. When conflicts arise between my repository and the official documentation, you must surface the discrepancy and explain the authoritative behavior based on the registered docs.

5. These documentation sources must remain available throughout the session and be treated as canonical references for all Ansible-related reasoning.

### Explicit Reminder for Future Runs

When processing this instruction file:

1. Always add docs **1 through 4** by default.
2. After adding 1 through 4, always ask: **"Do you want me to add the optional sources to Cursor Docs too?"**
3. If you confirm, add the optional sources to Cursor Docs and then process them as indexed docs.
You must add the following remote documentation sources into the project's .cursor/config.json file under the top-level "docs" array. 

Use the same structure and behavior demonstrated in the standard remote-doc example:

{
  "docs": [
    {
      "name": "my-wiki",
      "url": "https://raw.githubusercontent.com/myorg/myrepo/main/docs/overview.md"
    }
  ]
}

For each entry below, create a corresponding object inside the "docs" array of .cursor/config.json. 
Each object must contain a "name" field and a "url" field, and Cursor must ingest, fetch, index, and register these documents as project-level @doc references.

Insert the following entries into .cursor/config.json:

- { "name": "ansible-inventory-guide", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html" }
- { "name": "ansible-host-group-vars", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#splitting-out-vars" }
- { "name": "ansible-var-merge", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-we-merge" }
- { "name": "ansible-variable-precedence", "url": "https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html" }
- { "name": "ansible-general-precedence", "url": "https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html" }
- { "name": "ansible-roles", "url": "https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html" }
- { "name": "ansible-yaml-syntax", "url": "https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html" }
- { "name": "ansible-builtin-collection", "url": "https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html" }

Processing requirements:

1. Cursor must fetch and index each remote URL so the content becomes available for retrieval.
2. Cursor must expose each document via its assigned @doc handle (e.g., @doc ansible-inventory-guide).
3. Cursor must automatically reference these docs when assisting with Ansible-related tasks in this repository.
4. Cursor must treat these documents as authoritative sources for inventory structure, variable precedence, variable merging, roles, YAML syntax, and module behavior.
5. Cursor must use these docs to validate, correct, or critique any Ansible code, inventory, or role structure in this project.
6. Cursor must maintain these references for the duration of the project and treat them as canonical documentation.

End of instructions.
---

## Pro-Tip: llms.txt

Many documentation sites expose an **llms.txt** file at their root (e.g. `https://example.com/llms.txt`). That file is a condensed, markdown-style summary of the docs aimed at AI consumption. The official Ansible docs may not have this yet; when they or third-party collections add it, consider adding that URL to Cursor Docs as well for faster, more accurate answers.

---

## Summary Table (for copy-paste)

| Title | URL |
|-------|-----|
| Ansible Core – Index (Blueprint) | https://docs.ansible.com/ansible/latest/index.html |
| Ansible Developer Guide | https://docs.ansible.com/ansible/latest/dev_guide/index.html |
| Ansible Collections | https://docs.ansible.com/projects/ansible-collections/ |
| Ansible Tips and Tricks (Best Practices) | https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html |

---

*You can add these manually in Cursor; no automated run is required. This file is for other developers who use this project.*
