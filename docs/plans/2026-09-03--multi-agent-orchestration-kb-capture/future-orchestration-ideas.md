# Future Orchestration Ideas

Extracted from `chatgpt-ideas.md` on 2026-09-03. These were assessed as too
lofty for the current iteration — they depend on infrastructure we don't have
yet (multiple proven topologies, pattern library, tested scaffolders). Save for
when more patterns have been exercised.

---

## 1. `multiagent-orchestration-architect` skill

**What it would do:** Given any immature/new skill, evaluate whether multi-agent
orchestration helps, select an appropriate interaction topology from a catalog,
define roles/ownership/handoffs, and write an orchestration design contract into
the skill before implementation begins.

**Why lofty now:** The architect is only valuable when the pattern catalog has
depth. Right now we have one proven topology (paired review). Building an
architect that chooses between one option is ceremony. Revisit when we have
2–3 more patterns exercised.

**Required before building:**
- At least 2–3 more topologies tested end-to-end with real skills
- A formal pattern catalog file the architect can reason against
- Clear selection rules for when each topology earns its complexity

---

## 2. Pattern scaffolders for unproven topologies

ChatGPT listed seven topologies worth scaffolding:

1. **Sequential pipeline** — A → B → C with transforms
2. **Parallel specialists → Integrator** — fan-out then merge
3. **Supervisor → Workers → Supervisor** — dynamic delegation
4. **Parallel implementations → Judge** — agents solve same problem, judge selects
5. **Iterative specialist loop** — roles exchange until convergence
6. **Batch/map-reduce** (implied) — large input partitioned across workers

None of these have been tested with our multiagents runtime. Scaffolders for
untested patterns would be guesswork.

**Required before building:** Each topology needs a working smoke run proving
the broker routing, artifact handoffs, and termination signal before we codify
it into a scaffolder.

---

## 3. Full three-layer hierarchy (`runtime-contract → architect → scaffolders`)

**What it would be:**

```
multiagents-runtime-contract
          ↑
multiagent-orchestration-architect
          ↑
paired-review-designer / pipeline-designer / fanout-designer / ...
```

This is the right long-term direction. The foundation layer
(`multiagents-runtime-contract`) is being built now. The architect and additional
scaffolders depend on the pattern library having enough depth to be worth routing.

**Status:** `runtime-contract` → built. Architect + additional scaffolders → future.

---

## 4. "Enrichment mode" — auto-enriching a bare skill

**What it would do:** Agent encounters a bare-bones `SKILL.md` (just purpose +
inputs + outputs), invokes the orchestration-architect, which writes a full
`# Orchestration Design` section into the skill before normal skill planning
continues.

**Why lofty now:** This requires the architect skill to exist first, which
requires the pattern library to have depth first (see above). The enrichment
mode is the UX on top of the architect.

**Revisit:** After the architect is built.

---

## 5. Top-level "orchestration doesn't help" rule as a skill constraint

ChatGPT suggested a hard rule for the architect:

```
Prefer the smallest agent topology that creates a meaningful
coordination, context-isolation, specialization, validation,
or parallelism advantage. Do not introduce an agent whose only
purpose could be accomplished by another agent executing an
additional deterministic step.
```

**Not lofty — this should be added now** to the `multiagents-runtime-contract`
references or as a front-matter constraint in the paired-review-designer skill.
This is a rule, not a new capability.

> Note: Add this to `multiagent-paired-review-designer/SKILL.md` guard rails.

---

## Notes on the ChatGPT suggestions overall

ChatGPT was directionally correct: the layered architecture it described (
runtime knowledge → topology selection → pattern scaffolders) will age well.

However it assumed we'd implement the full stack in one pass. In practice:

- We have one topology proven
- We have one scaffolder built (paired review designer)
- We now have the knowledge layer (`multiagents-runtime-contract`)

The right sequence is: add topologies as we *need* them, not as theory suggests
we might. Each new pattern gets a smoke run first, then a scaffolder.
