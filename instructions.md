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
