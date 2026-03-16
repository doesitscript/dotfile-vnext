Below is a **clean documentation snippet** you can drop directly into your project docs. I wrote it in a style that reads like **engineering guidance**, not chat explanation. It captures the core idea you were pushing on: **one capability, one state interface**, and when Ansible playbooks fall back to multiple tasks.

---

# Idempotency Design Pattern for Ansible Tasks

## Principle: Model Capabilities as State

When designing Ansible automation, treat each capability as a **resource with a state**, rather than as a sequence of commands.

The ideal interface for a capability looks like:

```
capability_name:
  state: present | absent
```

This mirrors how Ansible modules are designed internally. If a module can represent both states, a **single task** is the correct abstraction.

Example conceptual interface:

```yaml
- name: Manage capability
  module_name:
    ...
    state: present | absent
```

This ensures:

* rerunning playbooks is safe
* teardown is predictable
* the resource lifecycle is explicit

---

# Pattern 1: Preferred (Single Task with State)

If the module supports `state: present|absent`, use a **single task with a variable-driven state**.

Example using `lineinfile`.

```yaml
my_setting:
  enabled: true
```

```yaml
- name: Manage my_setting capability
  ansible.builtin.lineinfile:
    path: /etc/app.conf
    regexp: '^my_setting='
    line: 'my_setting=true'
    state: "{{ 'present' if my_setting.enabled else 'absent' }}"
```

Behavior:

| State   | Result                      |
| ------- | --------------------------- |
| present | line is inserted or updated |
| absent  | matching line is removed    |

Why this works:

* the module owns both lifecycle states
* the task describes the desired final state
* rerunning the playbook will not create duplicates

Important note on idempotency:

Your `regexp` should match both the **existing state and the desired state** so the module can correctly detect when no change is needed.

---

# Pattern 2: Fallback (Two Tasks)

If a module **cannot cleanly represent both states**, split the lifecycle into two tasks.

This is a **playbook-level workaround**, not the ideal resource abstraction.

Example:

```yaml
- name: Ensure setting exists
  ansible.builtin.lineinfile:
    path: /etc/app.conf
    regexp: '^my_setting='
    line: 'my_setting=true'
    state: present
  when: my_setting.enabled

- name: Ensure setting removed
  ansible.builtin.lineinfile:
    path: /etc/app.conf
    regexp: '^my_setting='
    state: absent
  when: not my_setting.enabled
```

Use this pattern when:

* setup and teardown require different logic
* the module interface cannot represent both states
* the underlying command/API is asymmetric

---

# Pattern 3: CLI Fallback (When No Module Exists)

When interacting with a CLI tool that lacks an Ansible module, idempotency must be implemented by **checking current state before acting**.

General structure:

```
1. Query resource state
2. Execute creation only if absent
3. Execute deletion only if present
```

Example structure:

```yaml
- name: Query resource
  command: tool inspect resource
  register: resource_state
  changed_when: false
  failed_when: false

- name: Create resource
  command: tool create resource
  when:
    - desired_state == 'present'
    - resource_state.rc != 0

- name: Remove resource
  command: tool delete resource
  when:
    - desired_state == 'absent'
    - resource_state.rc == 0
```

Important distinction:

Even though this uses **two tasks**, the conceptual resource is still **one capability** with a state interface.

---

# Design Rule Summary

| Situation                      | Recommended Pattern       |
| ------------------------------ | ------------------------- |
| Module supports `state`        | Single task               |
| Module lifecycle is asymmetric | Two tasks                 |
| No module exists (CLI tool)    | Query + conditional tasks |

---

# Practical Guidance for Homelab Automation

For homelab infrastructure:

Prefer simplicity over full enterprise generalization.

Follow these rules:

1. Model every capability as `present` or `absent`
2. Prefer modules over shell/command
3. Prefer `template` or `copy` when managing full files
4. Use `lineinfile` or `blockinfile` only for partial ownership
5. Use CLI commands only when no module exists
6. Ensure playbooks can run twice with zero changes

---

# Mental Model

Think in terms of **resource state**, not **procedural steps**.

Instead of:

```
add line
delete line
```

Think:

```
ensure capability exists
ensure capability absent
```

This approach is what makes Ansible idempotent.

---

If you'd like, I can also give you a **small “homelab Ansible patterns” page** that covers the 6 most common resources:

* files
* packages
* services
* config blocks
* users
* containers

That tends to become the **cheat sheet people actually reference daily** when writing playbooks.
