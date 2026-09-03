# Paired-agent runtime orchestration: OpenAPI + LiteLLM + Firebase patterns

## Status

- advisory brainstorm / research-backed exploration
- drafted on 2026-09-03
- shaped for later promotion into `docs/plans/` if implementation is approved

## Problem restatement

The failure mode is not "the agents need to poll harder." The failure mode is
that two agents can each claim they are waiting, while no single control-plane
object authoritatively answers:

- whose turn it is
- what state the run is in
- whether a wait is legitimate or stale
- what event should wake the next actor
- whether the overall scenario is actually complete

The user also wants:

- visible status
- low-noise progress reporting
- room for long-running work
- good fit with existing homelab infrastructure

## Verification boundary

- The requested OpenAPI MCP server was not surfaced as a callable MCP tool in
  this Codex runtime.
- Research therefore used the official `openapi/mcp-server` repository, its
  code, official LiteLLM docs, official Firebase docs, Context7, and repo-local
  infrastructure evidence.
- The conclusions below are source-backed design recommendations, not live
  runtime validation of a new coordinator service.

## Confirmed repo-local context

- `.cursor/mcp.json` already declares `context7`, `firebase`, and
  `openaiDeveloperDocs`, plus the current workstation-side MCP layout.
- Firebase MCP is already repo-managed and was validated on `mac-dev` on
  2026-09-01 using `npx -y firebase-tools@latest mcp`.
- The repo already treats `http://litellm.hom.lab` as an active LiteLLM gateway
  surface for client and acceptance probes.
- The homelab already uses a LiteLLM- and Langfuse-oriented architecture, so a
  new coordinator should reuse that observability/control plane instead of
  inventing a second model-routing stack.

## Research findings

### 1. OpenAPI MCP servers are strongest when they expose a real coordination API, not when they replace the coordinator

The official `openapi/mcp-server` package is useful here because it is both:

- a ready-to-run remote MCP server
- a Python SDK for building a custom MCP server around your own API logic

The most relevant design signals from the official repo:

- async flows are explicit: the server has `/callbacks` and `/status/{request_id}`
  endpoints, and its core polling logic returns a durable request ID when work
  is not yet finished
- multi-instance async sharing is explicit: callback results can be shared
  through Redis or Memcached instead of in-process memory only
- token handling is pass-through, which is good for least-knowledge gateway
  behavior
- tool growth is modular: new tool families are added by API modules rather than
  by rewriting one giant dispatcher

Design implication:

- use OpenAPI/MCP as the agent-facing surface for a coordinator service
- do not make markdown files or shell loops the control plane
- put run ownership, state transitions, and resumable status behind explicit API
  endpoints

### 2. LiteLLM already matches the "one gateway owns routing, budgets, and exposure" part of the problem

The strongest LiteLLM finding is its documented "single control plane" model:

- LLMs
- MCP servers
- agents

can all sit behind one gateway with shared auth, rate limits, and discovery.

The most relevant LiteLLM capabilities for this problem:

- a documented single-gateway topology for LLMs, MCP, and A2A agents
- an alternative split topology when MCP exposure should be separable from the
  LLM lane
- MCP gateway support, including calling MCP tools through the gateway or
  exposing LiteLLM itself as an MCP endpoint to clients like Cursor
- agent-level and session-level controls:
  - `tpm_limit`
  - `rpm_limit`
  - `session_tpm_limit`
  - `session_rpm_limit`
  - `max_iterations`
  - `max_budget_per_session`
- routing/fallback patterns for keeping one logical agent or role available even
  when the preferred model/provider/host is unavailable
- observability hooks and Langfuse integration for seeing who called what and
  how much it cost

Design implication:

- LiteLLM should own model routing, budgets, and externalized tool/agent access
- the paired-agent problem should not be solved inside per-client config only
- the coordinator should record the role and state, while LiteLLM enforces lane,
  budget, and routing policy

### 3. Firebase is the best fit here for shared run-state, presence, and low-noise subscriptions

Firebase provides two useful primitives that complement each other:

- Cloud Firestore for durable structured run state and transactions
- Realtime Database for presence and connection-aware status

The most important Firebase findings:

- Firebase's own Firestore presence guidance says Firestore does not natively
  solve presence; the recommended pattern is Realtime Database presence mirrored
  into Firestore via Cloud Functions
- Realtime Database gives explicit connection state via `.info/connected` and
  `onDisconnect()` cleanup, which is exactly the missing truth source for "is a
  worker/agent actually still live?"
- Firestore transactions fit lease/claim semantics for "who owns the next turn"
- Cloud Functions document triggers are a clean place to mirror state,
  normalize events, or launch side effects without teaching every agent the full
  transition logic
- Firebase MCP already exposes practical tooling for project setup, auth users,
  Firestore data work, rules understanding, and other operator-facing Firebase
  tasks

Design implication:

- use Firestore as the authoritative run ledger
- use Realtime Database presence for operator-visible liveness and idle timers
- use Functions for state projection and event normalization
- keep file artifacts as audit evidence only

## Recommended architecture

### Recommendation: coordinator API + Firebase state + LiteLLM gateway

This is the best fit for the problem as stated.

#### Core split

- Coordinator API:
  authoritative state machine and run actions
- Firebase Firestore:
  durable run, turn, and decision records
- Firebase Realtime Database:
  presence, heartbeats, idle timestamps, active-worker view
- Firebase Functions:
  mirroring, notifications, escalation, cleanup, scheduled stale-run sweeps
- LiteLLM:
  model routing, budgets, fallbacks, MCP/agent exposure, Langfuse callbacks
- MCP surface:
  OpenAPI-described coordinator endpoints exposed to agents as tools

#### Why this is better than file polling

- one source of truth for next actor
- one source of truth for completion
- lease and claim semantics can be transactional
- stale waits can be detected by presence timeout instead of prose interpretation
- terminal status can be rendered from structured state instead of inferred from
  changed files
- agents can stop and re-enter without losing run ownership semantics

## Concrete implementation shape

### Firestore collections

```text
runs/{run_id}
runs/{run_id}/events/{event_id}
runs/{run_id}/artifacts/{artifact_id}
runs/{run_id}/leases/{lease_id}
```

Suggested `runs/{run_id}` fields:

- `status`: `queued | active | waiting_on_agent | waiting_on_user | blocked | complete | failed`
- `current_actor`: `coordinator | implementer | evaluator | operator`
- `goal`
- `next_action`
- `next_action_due_at`
- `last_state_change_at`
- `active_lease_id`
- `scenario_complete`
- `final_outcome`

Suggested lease fields:

- `actor`
- `claimed_at`
- `expires_at`
- `heartbeat_source`
- `trace_id`
- `response_id`

### Realtime Database presence

```text
presence/{agent_id}/{session_id}
run_presence/{run_id}/{agent_id}/{session_id}
```

Suggested presence fields:

- `state`: `online | busy | idle | offline`
- `last_seen`
- `current_run_id`
- `current_step`
- `poll_interval_seconds`

This gives the operator a truthful answer to:

- is the worker connected
- what run is it attached to
- when was the last live heartbeat
- how long has it been idle

### Coordinator API endpoints

Expose these through an OpenAPI spec, then surface them to agents through an
OpenAPI-derived MCP server or a custom MCP wrapper:

- `POST /runs`
- `GET /runs/{run_id}`
- `POST /runs/{run_id}/claim`
- `POST /runs/{run_id}/heartbeat`
- `POST /runs/{run_id}/events`
- `POST /runs/{run_id}/feedback`
- `POST /runs/{run_id}/artifacts`
- `POST /runs/{run_id}/complete`
- `POST /runs/{run_id}/handoff`
- `POST /runs/{run_id}/requeue`
- `GET /runs/{run_id}/status`
- `GET /runs/{run_id}/pending-actions`

Important contract rule:

- completion is a coordinator decision, not a specialist sentence

### LiteLLM role model

Keep the agent roles, but stop letting each role own the global lifecycle.

- implementer:
  works the requested slice
- evaluator:
  validates or requests changes
- coordinator:
  owns transitions, timeouts, final completion, and re-entry targets

Practical LiteLLM use:

- register implementer and evaluator lanes separately if they need different
  models or budgets
- set `max_iterations` and `max_budget_per_session` so one stuck loop cannot
  burn the whole run
- use fallbacks so one agent role can degrade to a backup model or host
- attach `trace_id` / response metadata so Firebase state, LiteLLM logs, and
  Langfuse traces can all join on the same run

## Best design variants

### Option A: LiteLLM-centric coordinator with Firebase state

Shape:

- LiteLLM is the primary runtime gateway
- coordinator API lives beside it
- Firebase stores truth
- agents call coordinator actions as tools

Why choose it:

- best fit with current homelab
- preserves your existing LiteLLM lane investment
- easiest path to reuse Langfuse and model-lane acceptance work

### Option B: OpenAPI-first coordinator service with thin LiteLLM use

Shape:

- coordinator service is the center
- LiteLLM is only a model gateway under the coordinator
- OpenAPI/MCP surface is the main agent contract

Why choose it:

- strongest if you want the control plane to be productized independently of the
  current model gateway

Tradeoff:

- more custom coordinator logic to own directly

### Option C: Firebase-first event bus with minimal coordinator API

Shape:

- most transitions happen through Firestore writes and Functions
- the coordinator API becomes a thin mutation facade

Why choose it:

- best when you want strong serverless/evented behavior

Tradeoff:

- harder to reason about if too much business logic is split across triggers

### Option D: improved filesystem approach

Shape:

- keep folder artifacts
- add stricter filenames, leases, and status files

Verdict:

- acceptable only as a temporary bridge
- not recommended as the long-term coordination contract

## Specific ideas worth implementing

### 1. Separate audit artifacts from control-plane state

Keep the existing plan or brainstorm folders, but demote them to:

- evidence
- human-readable summaries
- exported artifacts

Do not let them decide turn ownership.

### 2. Make "waiting" a typed state

Do not allow free-form "waiting on X" to control behavior.

Use explicit fields:

- `waiting_reason`
- `waiting_on_actor`
- `waiting_since`
- `wake_condition`
- `wake_deadline`

### 3. Represent "sign off" and "scenario complete" separately

Use two distinct concepts:

- specialist approval:
  "my slice is acceptable"
- scenario completion:
  "the coordinator sees no remaining required actions"

### 4. Put operator-visible status behind one read model

A terminal or web view should read one aggregated status object, for example:

- `current_actor`
- `current_step`
- `last_heartbeat_at`
- `idle_for_seconds`
- `next_wake_check_at`
- `blocking_condition`
- `latest_artifact`

That is far more useful than watching arbitrary files change.

### 5. Use OpenAPI tool filtering aggressively

If the coordinator API grows, do not expose every endpoint to every agent.

Research from alternative OpenAPI-to-MCP implementations shows the same
repeated lesson:

- large tool catalogs degrade model accuracy
- curated allowlists and dynamic/meta-tools are often better than dumping
  hundreds of tools into one client

For this project, that means:

- implementer gets only work-execution and artifact endpoints
- evaluator gets feedback and validation endpoints
- coordinator/operator gets admin endpoints

## Named follow-up solutions for later passes

These are worth a dedicated follow-up pass even where I did not exhaustively
evaluate them here.

- AWS Labs OpenAPI MCP Server
- `techcto/openapi-mcp-server`
- Stainless MCP generation / dynamic-tools mode
- LiteLLM A2A Agent Gateway deeper evaluation
- LiteLLM MCP semantic tool filtering
- Letta + LiteLLM persistent-memory orchestration
- LangGraph + Firebase checkpointing
- Temporal for coordinator ownership and retries
- Inngest for evented orchestration and retry policy
- Convex as an alternative real-time state backend
- Supabase Realtime as a Firebase alternative
- NATS or Redis Streams for a slimmer event bus

## Recommended next build order

1. Define the coordinator state model and OpenAPI contract.
2. Implement only `create run`, `claim`, `heartbeat`, `feedback`, `complete`,
   and `status`.
3. Back those endpoints with Firestore transactions plus Realtime Database
   presence.
4. Put the coordinator behind a minimal MCP surface.
5. Route implementer/evaluator model traffic through existing LiteLLM lanes.
6. Add one aggregated terminal status view.
7. Only then decide whether two separate surfaced agents are still worth
   keeping versus collapsing them behind a single manager.

## Recommended path

Recommended path:

- keep the paired roles
- stop using filesystem artifacts as the control plane
- add a small coordinator API with a strict OpenAPI contract
- store run truth in Firestore
- store presence in Realtime Database
- use Functions for mirroring and cleanup
- front model/tool/agent access through existing LiteLLM infrastructure

If you want the shortest path to something reliable on your current homelab,
this is the design to prototype first.

## Sources checked:

- repo: `.cursor/mcp.json` - current MCP server surfaces
- repo: `docs/reports/mcp_server_validations/firebase/README.md` - Firebase MCP validation and auth boundaries
- repo: `model-lane-acceptance/README.md` - LiteLLM gateway acceptance surface
- repo: `scripts/validate_continue_extension_cli_probes.py` - active LiteLLM gateway root and client-style probes
- repo: `docs/brainstorming_designs/2026-09-03--paired-agent-runtime-orchestration-patterns/context7-openai-docs-manager-orchestrator-coordinator-research.md` - existing paired-agent problem summary
- Context7: LiteLLM docs (`/websites/litellm_ai`) - routing, MCP deployment, budgets
- Context7: Firebase docs (`/websites/firebase_google`) - transactions, Functions, presence primitives
- Context7: MCP spec (`/websites/modelcontextprotocol_io_specification_2026-07-28`) - tools, progress, subscriptions
- official docs: https://docs.litellm.ai/docs/mcp_deployment
- official docs: https://docs.litellm.ai/docs/integrations/letta
- official docs: https://docs.litellm.ai/docs/proxy/users
- official docs: https://firebase.google.com/docs/ai-assistance/mcp-server
- official docs: https://firebase.google.com/docs/firestore/solutions/presence
- official repo: https://github.com/openapi/mcp-server
- official repo code inspected via Morph: `src/openapi_mcp_sdk/main.py`, `src/openapi_mcp_sdk/mcp_core.py`
- alternative OpenAPI/MCP references: https://github.com/awslabs/mcp/blob/main/src/openapi-mcp-server/README.md
- alternative OpenAPI/MCP references: https://github.com/techcto/openapi-mcp-server
- additional OpenAPI/MCP reference: https://www.stainless.com/blog/generate-mcp-servers-from-openapi-specs/
