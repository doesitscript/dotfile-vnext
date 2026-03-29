# Codex — Suggested Use: Ansible Architect

This file is written for Codex (OpenAI) sessions in this repo.

The Ansible Architect is a consulting role embedded in the Cursor agent side of
this project. It is not a Codex-native agent. You do not run it. You benefit
from its outputs when you work with plans and documents produced in Cursor
planning sessions.

This file tells you what the architect produces, when it fires, what its output
looks like, and how you can request its review when you need it.

---

## What the Architect Is

The Ansible Architect is an embedded maturity observer. Its job is to ensure
that every piece of work leaving a planning session is slightly more mature than
it would have been without it — without adding process overhead to the team.

It does not change work. It tags work. It identifies what Ansible pattern,
module, or structural improvement fits the thing being planned, and appends that
recommendation before the work ships.

Think of it as a consulting firm you brought in. You do not need to understand
how they work internally. You call them into planning meetings and they give you
recommendations. Then you decide what to do with those recommendations.

---

## How the Architect Is Summoned

### Automatic activation (Cursor side)

The architect activates automatically in Cursor planning sessions when any of
these conditions are met. These are called **activation triggers**:

| Trigger | What fires |
|---|---|
| A role, playbook, task, or capability is named and scoped | Inline maturity tag appended to the plan |
| The `ansible-planner` skill reaches Phase 2 (context check) | Subagent scans named artifacts before plan drafting |
| The `ansible-planner` skill reaches Phase 5 (plan lock-in) | Subagent reviews the full finalized plan before it ships |
| A work item is approved or accepted for execution | Final maturity tag before handoff |

You do not trigger these. The Cursor agent handles them.

### Explicit invocation in Cursor

When you want the architect to be more active during planning — not just tagging
at the end but participating in the shaping — use one of these phrases at the
start of a Cursor planning session:

> "Planning with maturity observer active — [describe the work]"

> "Observer pass on this plan before we finalize"

> "Architect review — [role or capability name]"

### From Codex

When you are working in Codex and want an architect review of a plan you have
drafted, bring the plan into a Cursor planning session using one of the explicit
invocation phrases above. The architect lives in Cursor. Codex sends work to
Cursor for architect review when needed.

---

## When to Call the Architect In

The architect is most valuable at these moments in a planning session:

| Planning moment | Why call the architect |
|---|---|
| Phase 2 — scoping a role or capability | Catches structural gaps before any code is written |
| Phase 3 — drafting implementation shape | Identifies the right Ansible module or pattern for what you are building |
| Phase 5 — locking in the final plan | Ensures everything shipping has a maturity tag and nothing obvious is missed |
| Any time you name a new role | The architect checks variable naming, argument_specs, README, lifecycle state |

If you are unsure, call the architect in at Phase 5 at minimum. That is the
lock-in gate — the last chance to catch something before work begins.

---

## What the Architect's Output Looks Like

The architect produces an `Ansible Maturity:` block appended to the plan:

```
Ansible Maturity:

access_identity_windows
  Observation: shell task using net user where ansible.windows.win_user module exists
  Improvement: replace with ansible.windows.win_user — handles idempotency natively
  Effort: low | When: now
  Tool/pattern: ansible.windows.win_user state=present
```

One block per artifact. Skips anything with nothing real to tag. Never produces
the block just to show presence.

---

## What the Architect Does Not Do

- Does not block or gate work
- Does not create sub-projects
- Does not repeat the same observation twice in the same session
- Does not suggest improvements to things not in scope
- Does not produce recommendations above low-medium effort in a planning pass

Anything above low-medium budget is noted once as `Worth tracking` and handed
off for future planning — not added to the current work.

---

## Interaction Surface

The architect's interaction surface is **Cursor only**. It is implemented as:

1. An `alwaysApply` Cursor rule that is present in every Cursor session
2. A skill file invoked as a subagent via the Cursor Task tool
3. Wired invocation points inside the `ansible-planner` skill at Phase 2 and Phase 5

Codex does not load these automatically. Codex benefits from the architect by
working with plans that passed through Cursor planning sessions.
