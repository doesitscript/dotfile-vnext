---
title: Phase 1 minimal harness — Codex app-server + multiagents
created_at: 2026-09-03
status: draft
---

# Phase 1 minimal harness

Narrow validation harness for `skill-upgrade-first-pass.md`. Not the full
scenario pack (Phase 2).

## Goals

- Local Mac hosts Codex app-server over the **stdio** transport (Phase 1 path)
- Smallest `multiagents` slice that can route implementer ↔ evaluator
- Staged ping-pong with output-backed receipts
- Operator has a working dashboard surface on the local Mac laptop

## Prerequisites (already scaffolded)

- `roles/multiagents/` installed on mac-dev (`multiagents` + Bun under `~/.bun/bin`)
- Skills upgraded for single-pass + `review_ready_for_evaluator_*`
- Codex CLI available on PATH (stdio app-server does not require the managed
  standalone package)

## Deferred (come back after stdio path is proven)

Managed standalone Codex (`~/.codex/packages/standalone/current/`) and
`codex app-server daemon` lifecycle are **out of the active Phase 1 critical
path**. Revisit and tighten plan wording once stdio handshake + ping-pong
receipts exist. Daemon-backed claims stay unverified until then.

Operator dashboard baseline (still in Phase 1):

- minimum: `multiagents dashboard`
- preferred when supported: `multiagents web` on `localhost:7900`

## Operator PATH

```bash
export PATH="$HOME/.bun/bin:$PATH"
# or: source ~/.bashrc
multiagents help
bun --version
```

## Codex app-server (local Mac) — stdio first

Authority: HRL
`homelab-reference-library/vendor/mcp/context7-style/codex-app-server-protocol-and-setup.md`
and OpenAI Learn app-server docs.

**Active Phase 1 startup:**

```bash
codex app-server --stdio
# equivalent default: codex app-server --listen stdio://
```

Harness helper: `validation/stdio_handshake.py`.

Minimum proof for Phase 1:

1. Start `codex app-server --stdio` on this Mac (exact argv in the validation
   receipt).
2. Complete `initialize` / `initialized`.
3. Show `thread/start` for implementer and evaluator roles (or reuse).
4. Show `turn/start` or `turn/steer` advancing at least one handoff.

Until those four are evidenced, ping-pong stages stay **unverified**.

Do **not** block Phase 1 progress on `codex app-server daemon start` or the
standalone installer while the stdio path is under active validation.

## multiagents slice (minimal)

Defer full `scenarios/codex-paired-evaluator-implementer/` rendering to Phase 2.
For Phase 1, record in each validation receipt:

- session id (if any)
- how implementer/evaluator peers were started
- which broker signals mirrored durable artifacts (`signal_done` /
  `submit_feedback` / `approve` — optional if artifacts alone drive a manual
  harness)

If `multiagents` cannot yet drive Codex turns automatically, document that as a
**problem** in `progress-report.md` and fall back to operator-invoked skill
passes while still using durable artifacts — but do **not** mark orchestrated
ping-pong as passed without turn evidence.

## Operator UI target

The phase-1 harness should not treat the dashboard as optional.

- Minimum acceptable operator UI: `multiagents dashboard`
- Preferred operator UI when supported by the installed build:
  `multiagents web` on `http://127.0.0.1:7900` or `http://localhost:7900`
- **2026-09-03 evidence:** both surfaces work on this Mac — TUI via
  `multiagents dashboard`, browser via `multiagents web` → HTTP 200 on
  `http://127.0.0.1:7900/` (title `multiagents dashboard`).
- If a later build lacks browser UI, record the exact command result and keep
  the gap open as a version/package follow-up rather than silently shrinking
  the requirement.

## Validation receipts location

```text
docs/plans/2026-09-03--multi-agent-orchestration-plan/validation/
  smoke-receipt.md
  stability-receipt.md
  acceptance-receipt.md
```

Create when stages run. Link from `progress-report.md`.
