# Homelab local AI clients (Continue, OpenCode, Codex CLI)

**Status:** partially-implemented (Cursor slice in progress)

## Promoted plans

| Agent | Plan |
| --- | --- |
| Cursor | [docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/](../../plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/README.md) |
| Codex | [docs/plans/2026-09-01--homelab-local-ai-clients-codex/](../../plans/2026-09-01--homelab-local-ai-clients-codex/README.md) |

## Scope

Configure three homelab-connected coding surfaces with **researched** model lanes
(not training-memory guesses). Agents pick models independently; lanes are tested
separately, not concurrently.

| Agent | Deliverables |
| --- | --- |
| **Cursor** (`-cursor-kilo` promoted plan) | Continue extension (full `config.yaml`), OpenCode install + project config |
| **Codex** (`-codex` promoted plan) | Codex CLI homelab profile / template to switch to local models |

**Out of scope here:** Kilo Code (prior work; see HRL
`implementation-guides/kilo-code/homelab-litellm-provider.md`).

## Packet files

| File | Purpose |
| --- | --- |
| [local-ai-clients-brainstorm-plan.md](local-ai-clients-brainstorm-plan.md) | Master brainstorm + promotion instructions |
| `draft_vllm_considerations.md` (repo root sibling) | vLLM format constraints — both agents must honor |

## Promotion (on execute)

When either agent starts implementation:

1. Keep this brainstorm packet **unchanged** as the shared intake source.
2. Copy into `docs/plans/` as a governed packet (folder + `README.md`).
3. Use **two sibling plan folders** (same date slug, different suffix):

```text
docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/
docs/plans/2026-09-01--homelab-local-ai-clients-codex/
```

4. Each promoted copy inherits scope for **one agent only**; cross-link the sibling.
5. Add HRL implementation guides as research lands (Context7-backed).
6. Mark brainstorm plan `execution_status` / `.partially-implemented.md` when live.

## Handoff

- **Codex:** start from promoted `…-codex/README.md` (or this brainstorm if not yet promoted).
- **Cursor:** start from promoted `…-cursor-kilo/README.md`.
