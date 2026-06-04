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
