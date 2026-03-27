# Research Summary For Subagents v1

This note bundles the evidence behind the `Subagents v1 With Critic
Checkpoints` plan.

## Repo State

### Current Codex config

The repo already enables subagent tooling and maps the built-in roles:

- `.codex/config.toml`
  - `features.multi_agent = true`
  - `agents.max_threads = 6`
  - `agents.max_depth = 1`
  - `default`, `explorer`, and `worker` all point at project-scoped role files

Relevant file:
- [config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml)

### Current agent files

These already exist:

- [default.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/default.toml)
- [explorer.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/explorer.toml)
- [worker.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/worker.toml)

Current mapping:

- `default` -> Planner/Steward in the main thread
- `explorer` -> Researcher
- `worker` -> Executor

### Current documented gap

The framework docs still correctly say that configured support is not the same
as runtime-validated separate-agent execution.

Relevant files:

- [README.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/README.md)
- [partner_process.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/partner_process.md)

### Current conflict

One active rule still behaves like a persona-first single-agent source of truth
and conflicts with the partner-process direction:

- [framework-agent-role-and-persona.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-agent-role-and-persona.mdc)

Why it is a problem:

- it centers a hard single-agent "Senior Engineer" identity
- it says "Not a collaborator"
- it is broader and more assertive than the later partner-process rules
- it does not fit a narrow, matter-of-fact subagent model with bounded duties

## Official Documentation Findings

### 1. Subagents are a first-class supported workflow

Source:
- https://developers.openai.com/codex/subagents

Key findings:

- subagent workflows are currently enabled by default in Codex
- Codex can spawn specialized agents in parallel and collect their results
- subagent activity is surfaced in the Codex app and CLI
- Codex only spawns subagents when explicitly asked

Implication for this repo:

- stop treating subagents as purely future/hypothetical capability
- keep treating runtime validation as necessary
- encode explicit delegation triggers instead of implying ambient auto-spawn

### 2. The right pattern is bounded delegation

Sources:
- https://developers.openai.com/codex/learn/best-practices/#organize-long-running-work-with-session-controls
- https://developers.openai.com/codex/concepts/subagents

Key findings:

- keep one thread per coherent unit of work
- keep the main agent focused on the core problem
- use subagents for bounded work like exploration, tests, triage, and
  summarization
- subagents reduce context pollution and context rot by moving noisy work off
  the main thread
- parallel read-heavy work is a better starting point than parallel write-heavy
  workflows

Implication for this repo:

- do not start with many writing agents
- do start with read-only evidence and validation roles
- use a checker/critic role as a good first custom agent

### 3. Project-scoped custom agents fit this repo well

Source:
- https://developers.openai.com/codex/subagents

Key findings:

- custom agents can live under `.codex/agents/`
- each standalone custom agent file must define:
  - `name`
  - `description`
  - `developer_instructions`
- optional settings like `model`, `model_reasoning_effort`, `sandbox_mode`,
  MCP config, and skills inherit from the parent when omitted
- custom agents can override built-ins if names collide

Implication for this repo:

- adding a single `critic.toml` is a low-effort, source-backed next step
- the role can stay narrow and read-only

### 4. Global subagent settings are already mostly sane

Sources:
- https://developers.openai.com/codex/subagents
- https://developers.openai.com/codex/config-reference/#configtoml

Key findings:

- `agents.max_threads` defaults to `6`
- `agents.max_depth` defaults to `1`
- default depth of `1` is a good starting point because deeper recursive
  delegation increases cost and unpredictability

Implication for this repo:

- the existing `max_threads = 6` and `max_depth = 1` are already reasonable
- v1 should not start by increasing depth or building recursive fan-out

### 5. Troubleshooting support should be a checker pattern, not another fixer

Source basis:
- bounded delegation guidance from `Subagents` and `Subagent concepts`
- repo troubleshooting requirements from
  [partner_process.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/partner_process.md)

Synthesis:

- troubleshooting mode in this repo already requires evidence surfaces,
  collected output, and missing-output reporting
- the best small subagent addition is an independent evidence auditor that checks
  whether a troubleshooting pass is good enough to trust
- that fits the documented subagent guidance better than creating a second
  write-capable fixer

## Recommended Repo Pattern

### Main thread

- owns user alignment
- owns planning and synthesis
- decides whether to delegate
- does not offload the entire task

### `explorer`

- read-only evidence gathering
- repo inspection
- docs checks
- logs and output interpretation

### `worker`

- bounded implementation
- bounded verification slice
- no open-ended replanning

### `critic`

- read-only post-change checker
- read-only troubleshooting evidence auditor
- reports:
  - missing evidence
  - weak verification
  - assumption drift
  - concrete risks

## Why `critic` Instead Of A Broader Planning Persona

- it is narrow and testable
- it matches the official bounded-delegation pattern
- it improves troubleshooting mode directly
- it reuses the existing Planner/Steward main-thread role instead of creating
  another fuzzy planner surface
- it reduces the chance of agent sprawl before the first runtime validation

## Risks And Tradeoffs

### Risk: too much delegation theater

If the framework adds many role names without real spawned threads, it becomes
more presentation than execution.

Mitigation:

- require runtime validation
- record separate-agent evidence
- keep v1 limited to one new custom agent

### Risk: write-heavy multi-agent conflicts

Parallel write-heavy work can create coordination problems.

Mitigation:

- keep `critic` read-only
- keep `explorer` read-only
- let `worker` own the bounded write slice

### Risk: old persona-first rules override the new model

If the older role/persona rule remains dominant, the framework will continue to
send mixed signals.

Mitigation:

- rewrite or retire the conflicting rule as part of v1

## Recommended Next Move

Implement `Subagents v1` as:

1. rule/doc alignment away from persona-first conflict
2. one new custom `critic` agent
3. explicit troubleshooting checkpoint guidance
4. one real runtime validation artifact
