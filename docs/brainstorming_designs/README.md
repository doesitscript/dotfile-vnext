# Brainstorming Designs

This folder is for flexible idea work. Content here is not active repo truth,
not approved implementation scope, and not a queue of work unless it is promoted
through `docs/intake/` or `docs/plans/`.

## Context Boundary

The repo root `.aiignore` marks this folder as advisory low-context material.
Agents should read this README and any folder-local `.aiignore`, then stop
unless the user explicitly asks for a specific brainstorm packet or the current
task directly depends on it.

## Folder Naming

Use folder packets for new brainstorms:

```text
YYYY-MM-DD--<domain>-<capability>-patterns/
```

Examples:

- `2026-06-04--data-protection-recovery-patterns/`
- `2026-06-04--service-publication-patterns/`

Keep the slug product-neutral when possible. Product names such as Zerto can
appear inside the packet, but the folder name should describe the capability
family unless the product itself is the subject.

## Packet Shape

Each packet should start with:

- `README.md` - scope, status, packet file table, and how to treat the material
- `.aiignore` - local advisory context boundary (copy from a recent packet)
- at least one plan-shaped markdown file (see naming below)
- `diagrams/` - optional; diagram files use `cst-hom-lab-ctl-dia-<topic>-<idx>.md`

Additional files should be added only when they help preserve the idea without
turning it into active project direction.

## Creating a new packet (agent checklist)

Use when the user asks to capture an idea, brainstorm, “put this in brainstorming
designs,” or split **operator proposal** vs **AI assessment**. Skill:
`brainstorm-design-packet-scaffold` (authority: this README).

1. **Confirm destination** — `docs/brainstorming_designs/` only. Do **not** create
   a governed `docs/plans/` packet unless the user asked to promote/execute.
2. **Name the folder** — `YYYY-MM-DD--<domain>-<capability>-patterns/` (today’s
   date; product-neutral slug when possible).
3. **Scaffold minimum files** — `README.md`, `.aiignore`, and the plan file(s)
   below.
4. **Preserve operator voice separately** when the user asked for “my idea” vs
   “your assessment” (or similar). Default dual-file pattern:

   | File | Role |
   | --- | --- |
   | `operator-proposal-<short-slug>.md` | Operator-stated idea; light cleanup only; do not silently rewrite intent |
   | `<topic>-wip-ai-human-plan.md` | AI assessment + WIP plan shape (Apply/Verify/Undo draft OK); not execute-complete |

   Single-file packets remain valid: `<topic>-plan.md` when there is no split.
5. **Frontmatter** on plan-like files: `status: brainstorm`,
   `execution_status: not_started`, `created_at: YYYY-MM-DD`. Mark
   `resource_selection_status: pending_research` when exact resources are unset.
6. **Packet README** — short intent, file table, “not approved scope,” links to
   related live surfaces if known.
7. **Index** — add a row to **Active packet index (recent)** in this README.
8. **Stop** — do not implement, Ansible-apply, or promote unless the user asks.

Voice-to-text note: `wip-ai-human-plan` is the canonical suffix (not
`wip-ai-humuan`).

Example dual-file packet:
`2026-09-23--vllm-idle-desktop-usability-patterns/`.

## Executed plan marking

**Started:** 2026-09-01 (packet
`2026-09-01--homelab-routing-layer-flint-openwrt`).

When a brainstorm **executable plan** in a packet folder is fully carried out
and verified, mark it executed:

1. **Frontmatter:** set `execution_status: executed` and `executed_at: YYYY-MM-DD`.
2. **Rename:** insert `.executed` before the extension:
   - `my-topic-plan.md` → `my-topic-plan.executed.md`
   - `my-topic-ai-brief.md` → `my-topic-ai-brief.executed.md`

Rules:

- Do **not** rename until all phases in that file are verified (or explicitly
  deferred with a note in the packet README).
- **Reference / supplement** docs may stay unsuffixed unless the whole packet is
  archived.
- Update the packet `README.md` status table when renaming.
- Promoting to `docs/plans/` is separate; the `.executed.md` suffix means
  “operator/agent completed this brainstorm plan,” not “governed plan lifecycle
  implemented.”

Going forward, use this suffix for executed brainstorm plans in new packet
folders unless a packet README defines a different convention.

## Partially-implemented marking

When a brainstorm design is **started in repo and live** but not fully converged
(docs, catalog, optional follow-up migrations), use:

```text
<topic>.partially-implemented.md
```

Example packet: `2026-09-01--litellm-model-client-id-patterns/`.

## Active packet index (recent)

| Packet | Status |
| --- | --- |
| [2026-09-23--vllm-idle-desktop-usability-patterns/](2026-09-23--vllm-idle-desktop-usability-patterns/) | brainstorm (idle watcher / sleep vs scale-to-0; dual-file proposal + WIP AI–human plan) |
| [2026-09-09--continue-mac-local-model-patterns/](2026-09-09--continue-mac-local-model-patterns/) | brainstorm (Mac-local autocomplete A/B test, embeddings, optional reranking, edits) |
| [2026-09-03--paired-agent-runtime-orchestration-patterns/](2026-09-03--paired-agent-runtime-orchestration-patterns/) | brainstorm (OpenAPI/MCP coordinator patterns) |
| [2026-09-01--homelab-routing-layer-flint-openwrt/](2026-09-01--homelab-routing-layer-flint-openwrt/) | packet-active |
| [2026-09-01--litellm-model-client-id-patterns/](2026-09-01--litellm-model-client-id-patterns/) | partially-implemented (gateway live) |
| [2026-09-01--homelab-local-ai-clients-patterns/](2026-09-01--homelab-local-ai-clients-patterns/) | brainstorm (Continue, OpenCode, Codex CLI) |
