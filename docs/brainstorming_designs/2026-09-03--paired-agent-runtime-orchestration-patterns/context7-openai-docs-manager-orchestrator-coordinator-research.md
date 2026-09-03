# Paired-agent runtime orchestration patterns

## Problem summary

The current paired-agent pattern broke in a predictable way:

- both sides could say "waiting on the other" without deriving that claim from
  one authoritative state source
- filesystem heartbeat files and prose were treated too much like control-plane
  truth
- local polling could keep a shell process alive, but it could not make a
  finished model turn in another conversation wake itself back up
- the user wanted visible, low-noise runtime status that said what was being
  checked, how often, and how long the system had been idle
- "sign off" semantics were overloaded and could sound like "I am done forever"
  instead of "the whole scenario is complete"

The design goal for the next iteration is not "make waiting look busier." It is
"move coordination authority into a real contract so an external orchestrator
can reliably decide who acts next."

## Confirmed constraints from this session

- A model can do long-running work during one active turn if it keeps using
  tools, polling processes, reading outputs, editing files, and testing.
- A model can also participate in a multi-hour workflow when some outside
  runtime re-enters it across turns.
- A finished model turn does not become active again just because a file changed
  on disk.
- A background shell loop is useful for visible status and within-turn parallel
  work, but it is not a substitute for cross-turn orchestration.
- This repository currently does not declare an OpenAPI MCP server in
  [`.cursor/mcp.json`](../../../.cursor/mcp.json).
- This repository does declare `openaiDeveloperDocs` in
  [`.cursor/mcp.json`](../../../.cursor/mcp.json), but this Codex runtime did
  not surface callable `openaiDeveloperDocs` search/fetch methods during this
  session.
- Because of that tool-surface gap, the OpenAI-side research below uses
  official OpenAI documentation and SDK material as the nearest authoritative
  fallback, alongside `context7` for current MCP and Agents SDK details.

## Research findings

### 1. OpenAI's own multi-agent guidance prefers a manager when one component should own progress and final outcome

The strongest OpenAI-side design signal is the distinction between:

- handoffs: a specialist takes over the rest of the turn
- agents as tools: a manager retains control and calls specialists

For this problem, the manager pattern fits better than peer-to-peer handoffs.
The user wants one authority to know:

- whose turn it is
- whether the scenario is actually done
- what status to display
- when to continue versus when to wait

That is exactly the manager/orchestrator responsibility.

Design implication:

- do not model implementer and evaluator as two symmetric peers that each
  decide they are "waiting on the other"
- model them as specialist roles behind one coordinator that owns the run state

### 2. Persisted run state is a first-class pattern; prose files are not a substitute

The OpenAI Agents SDK docs are explicit that conversation continuity can live in
durable session state, and that interrupted work can be serialized and resumed
with `RunState`.

That matters here because the missing piece in the broken design was not "more
file polling." It was lack of an authoritative state object with resume
semantics.

Useful patterns from the docs:

- shared `Session` when multiple agents need common context
- persisted `RunState` when a run pauses and must resume later
- explicit pending input / continuation boundaries instead of free-form prose

Design implication:

- durable state should live in a coordinator-owned state object or service
- markdown artifacts should remain audit evidence, not the runtime state machine

### 3. MCP lifecycle should be owned centrally, not ad hoc per waiting loop

The OpenAI Agents SDK MCP docs describe multiple integration modes:

- hosted MCP tools for publicly reachable MCP servers
- local streamable HTTP, SSE, or stdio MCP servers
- `MCPServerManager` to connect, expose only healthy servers, and clean up
  lifecycle on the same task

That maps directly onto prior failures around long-lived helpers and stale
background processes.

Design implication:

- if MCP is part of the solution, the coordinator should own MCP server
  lifecycle and cleanup explicitly
- background helper processes should be attached to a known lifecycle owner,
  not left running because the specialist role forgot to terminate them

### 4. OpenAI's Responses API already gives a better host-managed polling contract than "watch a markdown file"

The current Responses API and SDK material expose several useful primitives:

- `background` responses for long-running work
- response retrieval by `response_id`
- `previous_response_id` for server-managed continuation
- `metadata` for attaching structured run labels
- `phase` values and preambles for intermediate versus final updates
- `_and_poll` helper methods in SDKs for polling terminal completion

This is a much cleaner design language for the problem:

- the host stores IDs
- the host polls authoritative status
- intermediate commentary is separate from final completion
- state continuity is explicit instead of implied by whichever file changed last

Design implication:

- a real paired-agent runtime should store coordinator IDs and model response IDs
- visible status lines should reflect retrieved status, not inferred liveness

### 5. MCP Tasks and subscriptions help with long-running server work, but they do not create autonomous cross-turn reasoning

The `context7` MCP spec material confirms:

- tasks exist to represent long-running work with durable IDs and pollable
  status
- subscriptions/notifications are opt-in update channels
- newer MCP transport direction is stateless and treats notifications as
  optional rather than the required source of truth

That supports two important conclusions:

- task status is useful for truthful progress reporting
- notifications are hints and delivery channels, not the coordination authority

It does not support the idea that one finished conversation will self-reactivate
because another process changed a file or emitted a notification.

Design implication:

- use tasks and subscriptions for status transport if useful
- keep re-entry and actor selection in the host/coordinator layer

## What failed in the file-based design

The filesystem approach mixed three concerns that should be separate:

1. Audit trail
2. Status/heartbeat
3. Control-plane authority

Audit files are fine. Status files can also be fine. But once those become the
source of truth for ownership, race conditions and ambiguous prose start to
drive behavior.

Specific failure modes from the conversation:

- prose like "waiting on evaluator" was treated as if it were authoritative
- broad watch globs picked up transient status files as if they were new work
- completion logic allowed local approval language to sound final even though
  the whole scenario was not complete
- the user could not tell from the terminal whether anything real was still
  checking, how often it checked, or what condition it was waiting on

## Candidate architectures

### Option A: keep filesystem polling, just polish it

Description:

- continue using plan-folder artifacts as inbox plus status plus decision source
- improve file naming, narrowing watch globs, and terminal heartbeat output

Pros:

- lowest implementation cost
- no additional service required

Cons:

- still no authoritative coordination contract
- still no reliable cross-turn re-entry
- still easy to confuse heartbeat files with real work
- still couples logic to path conventions and local shell behavior

Verdict:

Useful as a temporary patch only. Not the design to invest in.

### Option B: single manager agent with implementer/evaluator specialists behind it

Description:

- one top-level orchestrator owns the run
- implementer and evaluator are exposed as sub-agents or tools
- specialist outputs are combined by the manager instead of creating two
  competing control planes

Pros:

- matches OpenAI's documented manager pattern
- eliminates "both peers think they are waiting" as a class of problem
- keeps final completion semantics in one place
- easier to present coherent terminal status

Cons:

- less literal fidelity if the goal is specifically "two independently surfaced
  terminal agents"
- still needs persisted state if the workflow spans multiple host invocations

Verdict:

Best design if separate peer terminals are not a hard requirement.

### Option C: external coordinator service plus specialists

Description:

- create a small local service whose authority is the run state
- describe that state and actions in OpenAPI
- let the coordinator track actor ownership, feedback, and completion
- specialists read/write through the coordinator instead of inferring from files

Pros:

- explicit contract for actor ownership
- natural bridge to MCP tools or future non-agent clients
- separates audit artifacts from control-plane state
- easier to test than shell glob logic

Cons:

- adds a service to operate
- still needs a host-level re-entry mechanism if specialists live in separate
  conversations

Verdict:

Good design when separate implementer/evaluator surfaces must remain real.

### Option D: coordinator service plus host supervisor

Description:

- a small supervisor process owns the timer and authoritative inbox resolution
- it polls coordinator state every N seconds
- when the next actor changes, it re-enters the correct specialist
- it also owns the concise terminal status surface and shutdown/cleanup

Pros:

- directly solves the wake-up problem
- makes the timer and ownership logic explicit
- makes "who acts next?" a host decision rather than a specialist guess
- can terminate background helpers when the scenario closes

Cons:

- more moving parts than a file watcher
- depends on a real re-entry hook in the surrounding client/runtime

Verdict:

This is the reliable end-state when multiple independent surfaces must
collaborate.

### Option E: task-oriented enhancements on top of the coordinator

Description:

- represent long review cycles or approvals as tasks
- return durable task IDs and recommended poll intervals
- use notifications as optional accelerators, not as the source of truth

Pros:

- honest progress model
- reconnect-safe semantics
- maps well to long review loops

Cons:

- depends on client/server support if using MCP Tasks directly
- still does not replace the host-level coordinator

Verdict:

Strong enhancement to Options C and D, not a substitute for them.

## Recommended design

### Recommendation

Build the next iteration around one of two deliberate shapes:

1. preferred when possible: one manager/orchestrator agent with implementer and
   evaluator as specialists behind it
2. preferred when separate agent surfaces are required: a thin coordinator
   service plus an external supervisor that owns polling, routing, and re-entry

In both cases:

3. persist authoritative run state outside markdown artifacts
4. retain plan-folder artifacts as audit evidence only
5. treat status lines and heartbeats as derived views, not control-plane truth

### Why this is the right split

- OpenAI's agent guidance already says a manager pattern is the right choice
  when one component should own orchestration and completion
- OpenAI's runtime guidance already gives persisted sessions, resumable run
  state, response IDs, and polling patterns
- the MCP spec supports task/status transport but does not change the need for
  a host-level owner
- the filesystem remains valuable, but only as evidence and history

This design follows the user's stated future direction: the next paired-agent
scenario should work because the skill/runtime contract is correct, not because
an invisible one-off patch happened to keep the current run moving.

## How MCP still fits

### Local MCP ownership

If the coordinator exposes tools or APIs through MCP:

- keep server lifecycle under one owner
- prefer an explicit manager like `MCPServerManager` when using the Agents SDK
- clean up servers/helpers when the scenario reaches terminal completion

### Hosted MCP option

If the coordinator becomes network-reachable and you want the Responses API to
call it directly:

- hosted MCP is a plausible fit
- approvals should remain explicit for write-capable operations
- connectors or deferred tool loading are useful only if they reduce complexity
  instead of hiding it

### OpenAPI-described coordinator option

If the user still wants an OpenAPI-described control plane, that remains a good
fit for the coordinator service. But the key insight from the OpenAI docs pass
is that the real design win is not "use MCP somewhere." The win is "put one
real orchestration owner above the specialists."

## Runtime contract ideas

### Authoritative state fields

The coordinator should hold at least:

- `run_id`
- `overall_status`
- `next_actor`
- `last_authoritative_event_at`
- `last_actor_check_at`
- `active_work_item_count`
- `latest_review_decision`
- `scenario_complete`

### Terminal status line

The user wanted something visible and low noise. The terminal surface should be
one concise line, for example:

```text
paired-run=<id> actor=evaluator next=implementer monitor=running poll=60s idle=03:12 last_check=2026-09-03T02:14:00-05:00
```

That line should be derived from authoritative coordinator state, not from a
free-form prose file.

### Naming fix

Do not use `sign off` as the main control-plane term.

Use terms such as:

- `approve_iteration`
- `request_changes`
- `scenario_complete`
- `close_run`

Those names better separate "my local review is done" from "the overall effort
is over."

## Minimal OpenAPI sketch

The coordinator does not need a big API. A small surface is enough:

```yaml
openapi: 3.1.0
info:
  title: Paired Agent Coordinator
  version: 0.1.0
paths:
  /runs/{run_id}:
    get:
      summary: Get authoritative run state
  /runs/{run_id}/work-items:
    get:
      summary: List work items for an actor
  /work-items/{work_item_id}/claim:
    post:
      summary: Claim work
  /work-items/{work_item_id}/complete:
    post:
      summary: Complete work
  /runs/{run_id}/decision:
    post:
      summary: Submit evaluator feedback or approval
  /runs/{run_id}/close:
    post:
      summary: Mark the whole scenario complete
```

If the runtime later needs long-running review cycles, add task-style responses
instead of rewriting the API around files.

## Suggested next experiment

1. Decide first whether separate peer terminals are actually required.
2. If not required, prototype a single manager agent with implementer and
   evaluator specialists behind it.
3. If separate surfaces are required, define a tiny coordinator state model and
   host supervisor before adding more file watchers.
4. Persist authoritative state with run IDs, response IDs, next actor, latest
   decision, and terminal completion fields.
5. Add a one-line status surface derived only from authoritative state.
6. Only after the authority model is working, decide whether an OpenAPI or MCP
   layer improves integration enough to justify itself.

## Source links

- OpenAI Agents SDK overview: https://openai.github.io/openai-agents-python/agents/
- OpenAI Agents SDK orchestration guide:
  https://openai.github.io/openai-agents-python/multi_agent/
- OpenAI Agents SDK sessions:
  https://openai.github.io/openai-agents-python/sessions/
- OpenAI Agents SDK MCP guide:
  https://openai.github.io/openai-agents-python/mcp/
- OpenAI Agents SDK tools guide:
  https://openai.github.io/openai-agents-python/tools/
- OpenAI API response creation/reference:
  https://developers.openai.com/api/reference/cli/resources/responses/methods/create
- OpenAI API response retrieval/reference:
  https://developers.openai.com/api/reference/cli/resources/responses/methods/retrieve
- OpenAI model guidance:
  https://developers.openai.com/api/docs/guides/latest-model
- MCP Tasks overview: https://modelcontextprotocol.io/extensions/tasks/overview
- MCP Tasks specification:
  https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks
