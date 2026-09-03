---
title: Discussion — how to view paired-agent skills vs orchestration
created_at: 2026-09-03
status: active
authority: internal
document_type: discussion-note
related:
  - ../README.md
  - ../UML-sequence-diagram.md
  - ../ChatGPT-guidance-multiagents-github-reference.md
  - roles/multiagents/README.md
---

# How to view paired-agent skills vs orchestration

This note captures the working mental model for the multi-agent effort in this
plan packet. It is discussion / alignment truth, not an Ansible or skill-edit
checklist yet. It exists so later implementation (including Ansible scenario
wiring and skill reconfiguration) stays oriented correctly.

## The short version

**Separate three layers and do not collapse them:**

| Layer | What it owns | What it does *not* own |
| --- | --- | --- |
| **Role skills** (evaluator, implementer) | How the two agents expect to work through an effort together: review vs build, quality gates, what “done / feedback / approve” *means* | Which tool wakes the next agent |
| **Durable artifacts** (plan folder) | Evidence, handoff record, audit trail humans and agents can re-read | Scheduling / turn advancement |
| **Orchestration** (`multiagents` today; others later) | Wake-up, messaging, session continuity, turn start/steer, task-state plumbing | Role judgment and “what good looks like” |

The **source of truth for cooperation** is the skills’ mutual contract — how
they know they must work with each other to get the job done. Orchestration is
whatever feature or pattern makes that contract run without a human typing
`continue`. If that layer changes, the skills should still make sense.

## Why this framing is the right one

### 1. Orchestration is swappable

`multiagents` is a strong first control plane (broker, peers, review signals,
CodexDriver / app-server turns). It is **not** the identity of the paired-agent
system.

The same role skills should remain adaptable to other orchestrators later
(n8n, LangGraph, a custom coordinator, etc.). Binding role logic forever into
one product’s API would be the wrong dependency direction.

### 2. Skills are solid cores, not throwaways

Evaluator and implementer already encode a clear split:

- one side reviews and produces feedback / wait / ready outcomes
- the other side implements and produces results / re-review requests

Today that often looks like a metaphorical **inbox / outbox** over plan-folder
artifacts. That metaphor describes *cooperation*, not a sacred transport.

Skills will need **reconfiguration** so they emit and consume the signals the
chosen orchestrator understands (for `multiagents`: things like summaries,
`signal_done`, feedback/approve-shaped actions, peer messages). That is
integration work. It is not a rewrite of the roles.

### 3. Stay open on the handoff mechanism

Do not lock early into one story such as:

- “only filesystem watches,” or
- “only multiagents MCP tools,” or
- “only Codex steer,” or
- “artifacts *are* the scheduler”

Pick the orchestration **feature or pattern** that best enables the skills’
already-known workflow. Implementation detail follows the contract; the
contract does not follow a favorite tool.

### 4. Plan folders remain evidence, not the orchestrator

Keeping artifacts as the durable record is still correct. Treating those files
as the primary wake-up loop is what forced the user to be the scheduler.
Orchestration advances turns; artifacts prove what happened.

## Working relationship (inbox / outbox as metaphor)

```text
Implementer skill                     Evaluator skill
      │                                      │
      │  does work                           │
      ▼                                      │
  “outbox” (results / review-ready)          │
      │                                      │
      └──────── orchestration ──────────────►│
                                             │  reviews
                                             ▼
                                        “inbox” for implementer
                                        (feedback / approve / wait)
                                             │
      ◄──────── orchestration ───────────────┘
      │
      continues until approved
```

“Inbox / outbox” here means **role expectation**, not a requirement that a
specific filename or poller be the control plane. `multiagents` (or another
layer) can carry the wake and message path while the plan folder still stores
the durable copies.

## Implications for upcoming work

### Skill upgrades (in progress)

- Reconfigure skills so they properly use the orchestrator’s capabilities.
- Keep role judgment and quality gates inside the skills.
- Treat multiagents-specific calls as an integration adapter, not as the
  definition of “evaluator” or “implementer.”

### Codex-first client wiring

- First target client is Codex (app-server threads/turns).
- Other clients (Cursor, Claude, Gemini) can wait; do not design the role
  contract around them yet.

### Ansible / repo scaffolding (come back to this)

The install scaffold (`roles/multiagents/`, version contracts, host layout,
scenario placeholders) should stay aligned with this split:

- Ansible owns **install, layout, pins, present|absent, scenario *surfaces***
- Skills own **how roles cooperate**
- `multiagents` config/scenarios own **how that cooperation is advanced**

When Ansible grows scenario packs or MCP wiring, document them as
orchestration enablement — not as a second copy of role policy. Settings stay
in structured inventory/role locations so scale-out does not invent one-off
install paths.

## What we already learned in-repo (context)

- mac-dev has a **scaffold-only** multiagents install (Bun release binary +
  pinned package + managed layout). Broker/MCP/scenario usage wiring deferred.
- Settings ownership: version contract in
  `inventory/group_vars/all/multiagents_tooling.yml`, lifecycle in host_vars,
  behavior in `roles/multiagents/`, entry via
  `deploy_development_nodes.yaml --tags multiagents`.
- Homelab Reference Library has multiagents/Codex-oriented reference material
  (e.g. indexed under multiagents Codex CLI orchestration) — consult that when
  configuring the client, without letting vendor docs redefine the skill roles.
- ChatGPT intake and the UML sequence diagram in this packet are useful
  *candidate* flows for a multiagents-backed path; they remain subordinate to
  the skill cooperation contract above.

## Non-goals of this discussion note

- Does not freeze a final multiagents scenario schema.
- Does not claim skill reconfiguration is finished.
- Does not authorize Ansible live apply beyond what the plan packet already
  scopes when implementation resumes.

## Bottom line

**Skills know how they must work together. Orchestration is the replaceable
machinery that lets them do that without a human in the loop. Stay agnostic on
the machinery; stay strict on the role contract.**
