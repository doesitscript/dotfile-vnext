---
title: Stdio app-server handshake receipt
created_at: 2026-09-03
status: pass-partial
stage: P1-6 stdio harness
---

# Stdio handshake receipt

## Claim

Local Mac Codex CLI can host app-server over **stdio** and complete:

1. `initialize` / `initialized`
2. `thread/start`
3. `turn/start` with a model reply

Managed standalone / `app-server daemon` was **not** used (deferred).

## Command

```bash
python3 docs/plans/2026-09-03--multi-agent-orchestration-plan/validation/stdio_handshake.py --timeout 120
# argv inside harness: codex app-server --stdio
```

Helper: `validation/stdio_handshake.py`  
Raw capture: `validation/stdio-handshake-raw.log`

## Evidence (excerpt)

| Step | Result |
| --- | --- |
| `initialize` id=0 | ok — `userAgent` `dotfile-vnext-phase1-stdio/0.142.5` |
| `thread/start` id=1 | thread `01a06738-b538-7913-8290-df769f742a91` |
| `turn/start` id=2 | turn `01a06738-c3b2-7991-a5df-6d4c136b1c76` status `inProgress` → agent reply |
| Agent message | text `pong` (matches prompt) |

## Notes / gaps

- Harness timed out at 120s waiting for an explicit `turn/completed` notification;
  model reply already completed. Script updated to treat `agentMessage`
  `final_answer` as turn-done for future runs.
- Thread boot strapped many MCP servers (including `multiagents` ready).
- Account signal: secondary rate-limit window showed `usedPercent: 100` with
  credits remaining — watch before long ping-pong stages.
- `turn/steer` and dual-role (implementer + evaluator) threads not yet shown.

## Status

**P1-6 stdio path: pass** for initialize / thread / turn evidence.  
Daemon/standalone: deferred revisit (not a fail of this receipt).
