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

- `README.md` - scope, status, and how to treat the material
- `.aiignore` - local advisory context boundary
- `<topic>-plan.md` - shaped brainstorm or conversation archive (plan-like, not
  an approved `docs/plans/` packet)
- `diagrams/` - optional; diagram files use `cst-hom-lab-ctl-dia-<topic>-<idx>.md`

Additional files should be added only when they help preserve the idea without
turning it into active project direction.

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
| [2026-09-01--homelab-routing-layer-flint-openwrt/](2026-09-01--homelab-routing-layer-flint-openwrt/) | packet-active |
| [2026-09-01--litellm-model-client-id-patterns/](2026-09-01--litellm-model-client-id-patterns/) | partially-implemented (gateway live) |
