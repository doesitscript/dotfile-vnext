# Skill Instruction Reduction Plan

> Plan-like brainstorm - not an approved `docs/plans/` packet or repo authority.
> Parent packet: [README.md](./README.md)

---

## Purpose

After creating a reusable skill (especially a brainstorm-design packet skill),
run a short evaluation loop that finds where repeated instructions can move
into skills and where always-on framework text can shrink.

This packet records:

- which skills to run next
- what each skill should produce
- copy-paste prompt examples
- general framework token-reduction levers

---

## Trigger

Use this evaluation loop when any of these happen:

- a new project skill is created under `.cursor/skills/`
- brainstorm packet creation becomes a recurring prompt pattern
- always-on rules feel heavy relative to local model context budgets
- the same process text is rewritten into prompts repeatedly

---

## Post-Creation Skill Runs

### 1. `generate-project-state-report`

**What it should do**

- Inventory current project instruction surfaces (skills, rules, AGENTS, plans
  docs, intake patterns).
- Call out **Instruction Repetition Hotspots**: exact files/workflows where
  prompts or rules repeat the same guidance.
- Rank hotspots by frequency and token cost class (`small` / `medium` /
  `large`).

**Prompt example**

```text
Use skill generate-project-state-report and include a section:
"Instruction Repetition Hotspots" with exact files/workflows where prompts
repeat. For each hotspot, return: current repeated instruction, exact location,
candidate skill name, expected token reduction class (small/medium/large), and
migration risk.
```

### 2. `project-maturity-router`

**What it should do**

- Route maturity questions to the correct knowledge gates (Ansible and/or
  NetBox) without merging them into one blob.
- Identify where reusable skills can replace repeated planning or
  implementation guidance across those surfaces.
- Prefer skill entry doors over restating gate procedure in every prompt.

**Prompt example**

```text
Use skill project-maturity-router to assess where reusable skills can replace
repeated planning/implementation guidance across Ansible and NetBox surfaces.
For each hotspot, return: current repeated instruction, exact location,
candidate skill name, expected token reduction class (small/medium/large), and
migration risk.
```

### 3. `ansible-coordinator`

**What it should do**

- Run a structured multi-role analysis (planner/researcher/observer style)
  focused on process load, not a new capability deploy.
- Produce a **skill-first reduction map**: which Ansible process instructions
  should become reusable skills, with expected token savings by area.
- Keep recommendations bounded to entry doors and micro-skills; avoid turning
  the whole framework into always-on text.

**Prompt example**

```text
Use skill ansible-coordinator to produce a "skill-first reduction map": where
current Ansible process instructions can become reusable skills, with expected
token savings by area. For each hotspot, return: current repeated instruction,
exact location, candidate skill name, expected token reduction class
(small/medium/large), and migration risk.
```

### 4. `generate-mcp-briefing`

**What it should do**

- Refresh the MCP tool mode map.
- Identify MCP/tool-selection instructions that currently live as repeated
  prose and could become concise reusable skill entry doors.
- Separate mode-specific required tools from narrative that can stay out of
  always-on context.

**Prompt example**

```text
Use skill generate-mcp-briefing and identify MCP/tool selection instructions
that can be replaced by concise reusable skill entry doors. For each hotspot,
return: current repeated instruction, exact location, candidate skill name,
expected token reduction class (small/medium/large), and migration risk.
```

### 5. `create-skill`

**What it should do**

- Convert the highest-frequency findings from the evaluation runs into 2–3
  micro-skills.
- Prefer narrow trigger descriptions and short workflows over large
  always-loaded guidance.
- Keep each micro-skill discoverable by WHAT + WHEN in the description.

**Prompt example**

```text
Use skill create-skill to scaffold 2-3 micro-skills that eliminate the
highest-frequency repeated instructions discovered in the report. Prefer
entry-door skills with specific trigger terms and progressive disclosure.
```

---

## Shared Output Contract

Ask every evaluation skill to return this shape per hotspot:

| Field | Meaning |
|-------|---------|
| current repeated instruction | What text/process is being restated |
| exact location | File, rule, skill, or prompt pattern |
| candidate skill name | Proposed reusable skill |
| expected token reduction class | `small` / `medium` / `large` |
| migration risk | What could break if moved out of always-on |

Add-on line for any prompt:

```text
For each hotspot, return: current repeated instruction, exact location,
candidate skill name, expected token reduction class (small/medium/large),
and migration risk.
```

---

## General Framework Token-Reduction Levers

Speaking generally (not project-locked):

1. Move heavy recurring guidance from always-on rules into opt-in skills.
2. Keep skill `description` trigger-specific so only relevant skills load.
3. Prefer short entry-door skills for common workflows.
4. Standardize one canonical prompt per repeat workflow.
5. Keep packet templates tiny; link out for deep details instead of embedding
   everywhere.
6. Treat brainstorm packets as low-context by default (`.aiignore` + thin
   README), then promote only shaped material into intake/plans.

---

## Suggested Sequence

1. Create the brainstorm-design skill (or other new reusable skill).
2. Run `generate-project-state-report` for hotspot inventory.
3. Run `project-maturity-router` and/or `ansible-coordinator` for domain-specific
   reduction maps.
4. Run `generate-mcp-briefing` if tool-selection prose is a known tax.
5. Use `create-skill` to scaffold the top micro-skills from the findings.
6. Re-measure later with the same shared output contract.

---

## Apply / Verify / Undo / Change Class

| | |
|--|--|
| **Apply** | Run evaluation skills with the prompts above; optionally scaffold micro-skills from findings |
| **Verify** | Hotspot list exists with locations, candidate skills, reduction class, and risk |
| **Undo** | Discard unused candidate skill scaffolds; keep always-on rules unchanged until promotion |
| **Change class** | Brainstorm / evaluation runbook (not active framework mutation) |

---

## Related Context

- Brainstorm packet conventions: `docs/brainstorming_designs/README.md`
- Context budget policy: `.cursor/rules/framework-context-budget.mdc`
- Tracking note: `IN-PROGRESS.md` (skill follow-up checklist)
