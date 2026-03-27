# Subagents v1 With Critic Checkpoints

Canonical approved plan for moving the Codex framework from role-signaling
toward explicit subagent delegation with narrow duties, hard role boundaries,
and runtime validation.

Tracked in GitHub issue #10.

## Summary

Implement a minimal true-subagent pattern in this repo without rewriting the
rest of the framework.

The chosen v1 model is:

- main thread keeps `Planner / Steward` ownership
- `explorer` stays the read-only evidence collector
- `worker` stays the bounded implementation agent
- a new hard `critic` agent becomes the validation and evidence-audit surface

Troubleshooting mode is part of this plan, not an afterthought. In v1, the
`critic` role is also the repo's first explicit troubleshooting checker: it
does not fix the problem, it checks whether the evidence, verification, and
reported gaps are good enough to trust the troubleshooting pass.

This keeps the next step small:

- reuse the current `.codex/config.toml` and built-in role mapping
- add one custom agent instead of a full agent zoo
- tighten rule/doc language that still assumes persona-only operation
- prove the workflow with one real runtime validation

## Research-Backed Decisions

- Codex subagents are now a real supported workflow, not a hypothetical future
  feature.
- Codex only spawns subagents when explicitly asked, so the framework should
  define when to delegate rather than implying automatic background spawning.
- The strongest official pattern is bounded delegation:
  - main thread owns the core problem
  - subagents handle exploration, tests, triage, and other noisy side work
- This repo already has real role config for `default`, `explorer`, and
  `worker`, so the main gap is not feature enablement. The gap is explicit
  delegation behavior plus validation.
- The current `framework-agent-role-and-persona.mdc` surface is misaligned with
  the repo's partner-process direction and with a matter-of-fact subagent
  model. That conflict should be resolved before claiming the framework is
  truly multi-agent.

See [research.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/research.md)
for the detailed evidence summary and sources.

## Chosen Pattern

### Role model

- `default`
  Main-thread orchestrator. Owns user alignment, plan shape, delegation
  choices, and final synthesis.
- `explorer`
  Read-only research and repo-evidence collector.
- `worker`
  Bounded implementation or bounded verification executor.
- `critic`
  Read-only checker for:
  - evidence completeness
  - verification quality
  - troubleshooting completeness
  - post-change risk review

### Delegation rule

Delegate only bounded sidecar work.

Good fits:

- evidence collection
- focused repo exploration
- tool or docs verification
- post-change critique
- troubleshooting evidence audit

Bad fits:

- handing off the entire task
- recursive open-ended planning
- multiple write-heavy agents changing overlapping files at once
- pretending subagents are active when no agent threads were actually spawned

### Troubleshooting interpretation

Troubleshooting in this framework should become a defined loop rather than just
"try more fixes."

In v1, troubleshooting means:

- identify evidence surfaces first
- collect actual output from the current run
- report what is still missing
- use `critic` to check whether the run produced enough evidence to justify the
  next fix attempt

The `critic` agent should not become a second fixer. Its job is to challenge
missing evidence, weak verification, or assumption drift.

## Scope

### In scope

- add a custom `critic` agent under `.codex/agents/`
- document the repo's explicit subagent workflow and checkpoints
- align framework wording away from vague persona-first framing where it
  conflicts with hard role boundaries
- define how troubleshooting mode uses the `critic` role
- produce one runtime validation artifact that shows separate agent threads were
  used intentionally

### Out of scope

- automatic background spawning
- a large custom-agent catalog
- multi-level recursive delegation
- replacing all current rule surfaces in one pass
- broad framework redesign outside the subagent and troubleshooting path

## Proposed Implementation Steps

1. Align the framework wording.
   - Rewrite or retire the rule surface that still acts like a single-agent
     "Senior Engineer" persona source of truth.
   - Keep collaboration and planning language in the partner-process surfaces.

2. Add the `critic` custom agent.
   - Make it read-only and validation-focused.
   - Keep the role narrow and matter-of-fact.
   - Prevent it from drifting into replanning or broad implementation.

3. Define the troubleshooting checkpoint pattern.
   - Document what counts as a good troubleshooting pass.
   - State when `critic` should be invoked in troubleshooting mode.
   - Require `critic` to report missing evidence explicitly.

4. Define the general subagent checkpoint pattern.
   - `explorer` before novel execution when evidence is thin
   - `worker` for bounded implementation or bounded verification
   - `critic` after implementation or during troubleshooting when work needs an
     independent check

5. Validate the pattern with one real task.
   - Spawn real separate agent threads.
   - Capture the agent roles used, the bounded assignments, and the returned
     summaries.
   - Save the result as runtime evidence in the repo.

## Apply / Verify / Undo / Change Class

Apply:
- update `.codex/agents/`
- update framework docs and active rule surfaces
- run one explicit subagent validation exercise and store the artifact

Verify:
- inspect the resulting `.codex/config.toml` and `.codex/agents/*.toml`
- confirm the framework docs describe explicit delegation and troubleshooting
  checkpoints
- run a real subagent workflow and confirm:
  - separate agent threads were spawned
  - the work was bounded by role
  - the main thread synthesized the result

Undo:
- remove the `critic` agent file
- revert the doc and rule changes
- remove the runtime validation artifact if the pattern is abandoned

Change class:
- idempotent repo/framework configuration

## Immediate Next Step

Implement `Subagents v1` in this repo with `critic` as the first custom agent,
then validate it on a real bounded task before expanding to any broader
multi-agent design.
