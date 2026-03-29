# Ansible Architect Agent — Architecture Reference

This file documents the full architecture of the Ansible Maturity Observer /
Architect as implemented in this repo. It covers every file created or modified,
how the activation triggers work, the subagent pattern, and the interaction
surface.

This file is the architect's own self-documentation. It is written for the
Cursor agent and any future agent reading this repo to understand what was
built, where it lives, and how it is designed to be used.

---

## Role Summary

The Ansible Architect is an embedded maturity observer that participates in
planning sessions in this repo. It does not change work. It observes plans as
they are being made, checks them against Ansible best practices and the actual
repo state, and appends lightweight maturity tags — specific improvements, the
right modules, the right patterns — before work leaves the planning session.

It is passive during open discussion. It activates at lock-in moments.

---

## Interaction Surface — Cursor Only

The architect lives entirely in Cursor. Its interaction surface consists of:

1. **An `alwaysApply` rule** — present in every Cursor conversation in this repo
2. **A skill file** — invoked as a subagent via the Task tool for thorough reviews
3. **Wired invocation points** — inside the `ansible-planner` skill at specific phases

There is no Codex-native implementation. Codex works with outputs from Cursor
planning sessions where the architect has already run.

---

## Files Created

### `.cursor/rules/framework-ansible-maturity-observer.mdc`

**Type:** Cursor rule, `alwaysApply: true`

**Role:** The always-present voice. This rule is loaded into every Cursor
conversation in this repo without exception. It defines:

- Default posture: passive during open discussion
- Activation triggers: the conditions under which the architect speaks
- Fallback inline tag behavior for small scope
- Output format for the `Ansible Maturity:` block
- Hard constraints (never block, never repeat, never exceed low-medium budget)
- Integration with existing framework signals

This rule is the reason the architect is always in the room. It does not require
the user to invoke anything.

### `.cursor/skills/ansible-maturity-observer/SKILL.md`

**Type:** Cursor skill, invoked as a readonly subagent via Task tool

**Role:** The thorough review engine. When the main agent needs a proper
repo-aware analysis — not just an inline tag — it launches this skill as a
subagent. The subagent:

- Reads the actual role files, `defaults/main.yml`, `meta/argument_specs.yml`
- Queries live inventory via MCP tools (`inventory_graph`, `inventory_find_host`,
  `project_playbooks`)
- Generates maturity tags only when real gaps are found, not from memory
- Returns a formatted `Ansible Maturity:` block with FQCN module names and
  specific variable conventions
- Ends with `Observer handoff: N tag(s) — ready for planner review`

The subagent is readonly. It does not modify files, plans, or work items.

---

## Files Modified

### `.cursor/skills/ansible-planner/SKILL.md`

**What changed:** Two wired invocation points added.

- **Phase 2 (Context Check):** The planner now invokes the maturity observer
  subagent when named artifacts are identified, before plan drafting begins.
  The observer runs in the background and its output is appended to the draft.

- **Phase 5 (Mature Plan Output / Lock-In):** Before presenting the final plan,
  the planner invokes the observer against the full finalized plan. Every plan
  that leaves Phase 5 has been reviewed by the architect. This is the lock-in
  gate.

### `.cursorrules`

**What changed:** `framework-ansible-maturity-observer.mdc` added to the Active
Framework Rule Family list. This registers the rule in the boot-time rules
summary so every session acknowledges it is loaded.

### `.cursor/rules/000--system-boot.mdc`

**What changed:** Step 4 (Mandatory Summary to User) now requires the agent to
declare its identity as the first line of the boot greeting:

```
Agent: Cursor (Claude)       ← Cursor sessions
Agent: Codex (OpenAI)        ← Codex sessions
```

This makes outputs from different agent systems immediately distinguishable in
logs, docs, and conversation history.

### `AGENTS.md`

**What changed:** The Codex session boot output now begins with
`Agent: Codex (OpenAI)` before the `Instruction sources in effect:` line.
Matches the Cursor-side identity convention for cross-agent consistency.

### `.cursor/skills/catalog.yml`

**What changed:** `ansible-maturity-observer` added as the first entry in the
skills list under the `ansible` family.

---

## Activation Triggers

These are the conditions under which the architect activates. The term
"activation trigger" is the correct term for these — they are defined in the
`framework-ansible-maturity-observer.mdc` rule and fire automatically based on
conversation state.

| Trigger | Mechanism | Output |
|---|---|---|
| `ansible-planner` skill reaches Phase 2 | Task subagent (readonly) | Tags on named artifacts before draft |
| `ansible-planner` skill reaches Phase 5 | Task subagent (readonly) | Tags on full finalized plan |
| A role, playbook, task, or capability is named and scoped | Inline tag (fallback) | Single `Ansible Maturity:` block |
| A work item is approved or accepted for execution | Inline tag or subagent | Final tag before handoff |
| User says "Planning with maturity observer active" | Explicit — architect leans in throughout | Active participation across all phases |
| User says "Observer pass on this plan" | Explicit — subagent launched | Full repo-aware review of named plan |

**Default posture between triggers:** silent.

---

## How to Invoke the Architect Explicitly

The architect activates automatically at trigger points. When you want it to be
more active, use these phrases:

```
"Planning with maturity observer active — [describe the work]"
```
Signals the architect to participate throughout the session, not just at
lock-in. Most useful at the start of a focused planning session.

```
"Observer pass on this plan before we finalize"
```
Launches the subagent against the full current plan. Use at Phase 5 when you
want a thorough repo-aware review before locking in.

```
"Architect review — [role or capability name]"
```
Targets the observer at a specific named artifact. Use when working on a role
and wanting a focused maturity check.

---

## Output Format

```
Ansible Maturity:

[role or capability name]
  Observation: [one sentence — what is missing or should change]
  Improvement: [one sentence — specific fix with FQCN or variable name]
  Effort: minor | low | low-medium
  When: now | next PR | next time this is touched
  Tool/pattern: [specific module FQCN, variable convention, or structural pattern]
```

Budget ceiling:

| Label | Ceiling |
|---|---|
| minor | single line or rename, < 15 min |
| low | one task, one defaults entry, one README section, < 1 hr |
| low-medium | one argument_specs, one lifecycle refactor, one role interface, < 3 hr |

Anything above low-medium is noted as `Worth tracking: — out of scope for this pass`.

---

## What the Architect Checks (Priority Order)

1. Role variable not prefixed with `role_name_`
2. No `meta/argument_specs.yml` for a role with a public interface
3. `shell` or `command` used where a native Ansible module exists
4. No `present|absent` lifecycle state variable on a user-facing capability
5. Template missing `{{ ansible_managed }}` header
6. `command`/`shell` task with no `changed_when` guard
7. A class of problem the team has hit before — names the improvement that closes it
8. Missing role README when the role has a non-trivial public interface

The architect checks actual files. It does not generate observations from memory.

---

## Relationship to Other Skills

| Skill | Relationship |
|---|---|
| `ansible-coordinator` | Team owner. Dispatches planner, researcher, and observer in parallel. Synthesizes outputs. Entry point for full planning sessions. |
| `ansible-planner` | Shapes the implementation draft. Invokes the observer at Phase 2 and Phase 5 when running standalone. |
| `ansible-researcher` | Investigates novel topics. Dispatched by the coordinator when the topic is under-researched. |
| `ansible-maturity-observer` | This skill. Invoked by the coordinator or planner as a readonly subagent. Returns maturity tags. |

The four skills form a planning team:
- Coordinator — runs the meeting, dispatches specialists, synthesizes outputs
- Planner/Steward — owns the implementation shape and plan draft
- Researcher — gathers evidence on novel topics
- Architect/Observer — reviews everything for Ansible maturity before it ships

**Entry point for a full planning session:** `ansible-coordinator`
**Entry point for planning only:** `ansible-planner`
**Entry point for a focused maturity review:** `ansible-maturity-observer`

---

## Known Limitations

- The architect has no persistent memory across sessions. Each invocation starts
  fresh with the context passed to it.
- The activation triggers depend on the main agent recognizing lock-in moments.
  Some moments will be missed. This is expected and acceptable.
- The architect is most reliable when the `ansible-planner` skill is actively
  in use. Without it, coverage falls back to the rule-based inline triggers.
- This is Cursor-only. There is no equivalent autonomous architect in Codex
  sessions. Codex benefits by working with plans already reviewed in Cursor.
