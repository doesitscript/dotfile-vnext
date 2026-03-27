# Runtime Validation Evidence For Subagents v1

This note promotes local Codex session evidence into the repo so the current
subagent enablement state is visible without digging through `~/.codex/sessions/`.

## Summary

On 2026-03-27, a real `explorer` subagent was spawned successfully from a local
Codex session while working in this repo.

What this proves:

- the project-scoped `.codex/config.toml` role mapping is usable at runtime
- `spawn_agent` accepted `agent_type = "explorer"`
- the child ran as a separate agent thread with its own agent id
- the child completed independently and returned a result back to the parent

What this does not prove:

- that subagents are spawned automatically in normal repo work
- that a `critic` agent exists yet
- that the full `Subagents v1 With Critic Checkpoints` plan is implemented

## Runtime Source

Local session file:

- `~/.codex/sessions/2026/03/27/rollout-2026-03-27T01-29-32-019d2dfb-d76f-7861-8eac-3db9bc6079cd.jsonl`

Relevant observed entries:

- parent requested `spawn_agent` with `agent_type: "explorer"`
- spawned child agent id:
  - `019d2dfd-463c-7d23-b17e-cdc723a18d3d`
- child nickname:
  - `Leibniz`
- the child returned a read-only repo-bootstrap summary and reported successful
  completion as an explorer-style subagent

## Key Evidence Excerpt

Parent spawn call:

```text
spawn_agent
agent_type: "explorer"
```

Observed result summary from that same session:

```text
Spawn succeeded. `spawn_agent` accepted `agent_type: "explorer"` and returned a
dedicated agent id (`019d2dfd-463c-7d23-b17e-cdc723a18d3d`) plus nickname
(`Leibniz`).
```

```text
It looked like a real separate subagent thread, not just a conceptual handoff.
That is an inference from runtime behavior: the child had its own agent id,
completed independently via `wait`, and returned a separate result payload.
```

## Repo State This Validates

This runtime evidence lines up with the current project-scoped config:

- [config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml)
- [default.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/default.toml)
- [explorer.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/explorer.toml)
- [worker.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/worker.toml)

Validated pieces:

- `features.multi_agent = true`
- `agents.max_threads = 6`
- `agents.max_depth = 1`
- built-in role remapping for `default`, `explorer`, and `worker`

## Remaining Gaps

Still not implemented in the repo:

- custom `critic` agent file
- repo rule/doc alignment for the persona-first conflict
- a broader repeatable checkpoint pattern using `critic`

So the honest current state is:

- project-scoped subagent support is configured
- at least one real `explorer` subagent spawn has been runtime-validated
- `Subagents v1` is partially implemented, not complete
