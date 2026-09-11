# 07 — Runtime surfaces: broker vs peer MCP

How local `multiagents` fits this design—and what Cursor’s peer MCP is for.

## Layers (do not collapse them)

| Layer | What it is | Cursor-dependent? |
| --- | --- | --- |
| **Broker** (`multiagents broker`, `:7899`) | Shared local orchestration daemon: sessions, slots, message queue | **No** — runs on the Mac as a reusable process |
| **Dashboard** (`:7900` / TUI) | Observation UI for sessions | No |
| **Parent harness** (`runtime/run-implementation.ts` or `multiagents orchestrator` MCP) | Creates teams, schedules Implementer/Evaluator passes | Parent chat may live in Cursor/Codex, but the **authority** is the harness + broker, not the peer tools |
| **`multiagents-peer` MCP** | Agent-side tools: `set_summary`, `send_message`, `check_messages`, `approve`, … | Connected IDE/agent process — a **peer**, not the orchestrator |

A connected MCP process is a **peer**, not a team. Peers join teams the
parent/orchestrator creates. See global skill `multiagents-runtime-contract`.

## Answer: should peer MCP be “the orchestration layer”?

**No.** Treat `multiagents-peer` as a **query / teammate communication surface**
into a broker you already run—not as the thing that owns scheduling, locks, or
campaign lifecycle.

Preferred shape for this project:

1. Keep **broker (+ dashboard) running on the Mac** (`multiagents broker start`
   once; reuse across Cursor windows and Codex parents).
2. Run campaign work through the **parent harness**
   (`paired-plan-orchestrator-beta` → `run-implementation.ts`), which talks to
   the existing broker and uses the **orchestrator** MCP path internally for
   `create_team` / session lifecycle.
3. Use **peer MCP** only when an agent *inside* a team (or a Cursor agent
   deliberately joining as a teammate) needs broker chat/status tools.

That matches what you already have: broker status today is independent of any
one Cursor chat; sessions persist after the parent exits.

## Configuring peer MCP against a pre-deployed broker

Yes—that is the normal model. Peer MCP clients connect to the **already
running** local broker (default `http://127.0.0.1:7899`). You are not supposed
to spin a new orchestration stack per Cursor window.

Practical rules:

- Prefer `multiagents broker status` / dashboard before launching a campaign.
- Do not run `multiagents setup` just to inspect state (side-effecting).
- Do not treat “Cursor has multiagents-peer tools” as “this chat is the parent
  orchestrator.” Parent = harness skill + runner (or explicit orchestrator MCP).
- A Cursor peer with no session is an unclaimed connection; it is not campaign
  authority.

## What stays in this design packet

- **Core:** refined handoff, Light Implementer/Evaluator skills, parent
  orchestrator skill, `run-implementation.ts`, consultation sidecar.
- **Not core:** `runtime/experimental/*` (parallel preflight, batch staging).

Authority map: [02-authority--who-to-call.md](02-authority--who-to-call.md)
