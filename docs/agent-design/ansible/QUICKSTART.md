# Ansible Architect — Quickstart

Everything you need to start using the architect in planning sessions.

---

## What You Have

A four-skill planning team embedded in this repo:

| Skill | What it does |
|---|---|
| `ansible-coordinator` | Runs the planning meeting. Entry point for full sessions. |
| `ansible-planner` | Shapes the implementation plan. |
| `ansible-researcher` | Investigates novel topics before you commit to an approach. |
| `ansible-maturity-observer` | Reviews Ansible artifacts and tags improvements. |

You talk to the coordinator. It manages the rest.

---

## How to Start a Planning Session

### Full session — coordinator drives

Use this when you are planning something real and want the full team engaged:

```
Use the ansible-coordinator — we're planning [describe the work]
```

The coordinator decides which specialists to engage, dispatches them in
parallel, synthesizes the outputs, and presents one integrated response.
You do not manage the specialists yourself.

### Planning only — no specialist dispatch needed

Use this when the topic is well-understood and you just need a plan:

```
Use the ansible-planner — [describe what you want to build]
```

The planner shapes the implementation draft and automatically invokes the
observer at Phase 2 and Phase 5.

### Focused maturity review only

Use this when you have a specific role or capability and want a maturity check:

```
Architect review — [role or capability name]
```

or

```
Observer pass on this plan before we finalize
```

---

## What to Expect

### During a coordinated session

The coordinator runs silently in the background. You will see one integrated
response, not three separate reports. It looks like:

```
Coordinator view:

[Short recap of what was planned and what the team found]

Plan:
  Apply: ...
  Verify: ...
  Undo: ...
  Change class: ...

Maturity:
  [role name]
    Observation: shell task using net user where win_user module exists
    Improvement: replace with ansible.windows.win_user state=present
    Effort: low | When: now
    Tool/pattern: ansible.windows.win_user

Research findings:
  [only present when a novel topic was investigated]
```

### What the observer tags look like

The observer only tags real gaps it finds in the actual files. It will not
produce output just to show it ran. When it finds something:

```
Ansible Maturity:

[role or capability name]
  Observation: [one sentence — what is missing]
  Improvement: [one sentence — specific fix with module FQCN or variable name]
  Effort: minor | low | low-medium
  When: now | next PR | next time this is touched
  Tool/pattern: [the specific Ansible module or pattern]
```

Effort ceiling: nothing above low-medium is proposed as actionable work.
Bigger improvements are noted once as `Worth tracking` and left for future
planning.

---

## When Each Specialist Gets Dispatched

The coordinator makes these decisions automatically. For your reference:

| Condition | Who gets dispatched |
|---|---|
| Any planning session with named Ansible artifacts | Observer — always |
| Topic is novel, right approach is unclear | Researcher + Observer in parallel |
| Implementation shape is needed | Planner |
| All three conditions are true | All three in parallel |

---

## Imperfection Is Expected

The team will miss some moments. The specialist dispatch depends on the
coordinator recognizing context correctly. It will not be perfect on the first
use.

When it misses something, use an explicit invocation phrase to call the
specialist in directly. The more you use it the better you will understand
where the triggers fire reliably.

---

## Files in This Folder

| File | What it is |
|---|---|
| `QUICKSTART.md` | This file |
| `codex_suggested_architect_use.md` | How to work with the architect from Codex |
| `ansible_architect_agent.md` | Full architecture reference — all files, triggers, design decisions |

## Skill Files

| File | What it is |
|---|---|
| `.cursor/skills/ansible-coordinator/SKILL.md` | Coordinator — entry point, dispatches team |
| `.cursor/skills/ansible-planner/SKILL.md` | Planner — implementation shape |
| `.cursor/skills/ansible-researcher/SKILL.md` | Researcher — evidence gathering |
| `.cursor/skills/ansible-maturity-observer/SKILL.md` | Observer — maturity tags |
