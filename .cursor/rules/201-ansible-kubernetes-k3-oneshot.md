---
description: Declarative discovery and enforcement workflow for Ansible resource and system management. Applies to all Ansible work involving Kubernetes, K3s, and any multi-resource orchestration.
alwaysApply: true
---

# Ansible Declarative Enforcement — Resource and System Discovery

## Phase 0 — Identify the Resource or System

Before writing any task, state clearly:

> I am managing a `<resource or system>` to ensure it is `<desired state>`.

This determines whether to search for a **module** (single resource) or a **role** (full system).

| Problem type | Example | Search for |
|---|---|---|
| Single resource | Kubernetes Node taint, Windows firewall rule | Module |
| Multi-resource system | K3s cluster install, WireGuard router, NVIDIA toolkit | Role |

---

## Phase 1 — Galaxy Search (System-Level Problems)

If the problem is a system (multi-resource orchestration), search Galaxy first:

```bash
ansible-galaxy search <keyword>
ansible-galaxy collection search <keyword>
```

Then inspect what the role/collection provides:

```bash
ansible-doc -l -t role <namespace>.<collection>
ansible-doc -l -t module <namespace>.<collection>
```

Check bundled examples:

```
~/.ansible/roles/<namespace>.<role>/examples/
~/.ansible/collections/ansible_collections/<ns>/<collection>/playbooks/
```

If a maintained role covers ≥80% of the problem — use it. Do not reimplement orchestration.

---

## Phase 2 — Module Namespace Search (Resource-Level Problems)

Search installed modules before writing any task:

```bash
ansible-doc -l | grep <keyword>
ansible-doc -l -t module <namespace>.<collection>
```

Examples by platform:

```bash
ansible-doc -l | grep k8s      # Kubernetes
ansible-doc -l | grep win_     # Windows
ansible-doc -l | grep docker   # Docker
ansible-doc -l | grep file     # Linux files
ansible-doc -l | grep service  # Linux services
```

If a module exists → use it. Shell or command in its place is a violation.

---

## Phase 3 — Installed Collection Inspection

Before writing tasks, check what is already available:

```bash
ansible-doc -l -t module kubernetes.core   # if kubernetes.core is installed
ansible-doc -l -t module community.windows # if community.windows is installed
```

---

## Phase 4 — Idempotent Expression

All tasks must express **state**, not action.

**Allowed:**
- `state: present`
- `state: absent`
- `ensure: configured`
- `ensure: ready`

**Disallowed mindset:** run, execute, call, invoke

---

## Phase 5 — Scripted Fallback (Last Resort Only)

Only use `command` or `shell` if no module and no maintained role exists. When used:

- Must include justification comment explaining why no module exists
- Must include `changed_when`
- Must include `creates` or `removes` where applicable

Missing any of those → violation.

---

## Kubernetes Hard Rule

If `kubernetes.core` is installed:

- `kubectl` is **disallowed in production roles**
- Allowed for diagnostics only
- All Kubernetes resource operations must use `kubernetes.core.*` modules
- Node labels: use `apply: true` to enforce full declarative state; use `merge_type: strategic` only when removal of existing labels is not desired
