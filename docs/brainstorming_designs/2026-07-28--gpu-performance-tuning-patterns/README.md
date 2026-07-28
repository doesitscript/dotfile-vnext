# GPU Performance Tuning Patterns

> **Status: brainstorming / design exploration - NOT repo work**
>
> This packet captures ideas and operating patterns for GPU performance tuning
> using tools such as MSI Afterburner. It is not approved implementation scope,
> not active automation behavior, and not a deployable plan.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read this packet unless the task explicitly asks for GPU tuning
  design content.
- Treat all settings and values in this packet as candidate examples until
  promoted through `docs/intake/` or `docs/plans/`.
- Do not infer active host configuration from this packet alone.

## Packet Artifacts

| File | Role |
|------|------|
| [`gpu-performance-tuning-plan.md`](./gpu-performance-tuning-plan.md) | Plan-like brainstorm for tuning goals, validation loops, and rollback posture |
| [`.aiignore`](./.aiignore) | Local advisory context boundary for AI agents |

## Intended Use

Use this packet for early thinking around:

- safe GPU performance tuning approaches
- startup persistence behavior for user-space tuning tools
- repeatable test loops for stability and thermals
- rollback and troubleshooting patterns

## Promotion Path

Move shaped, decision-ready material to `docs/intake/`. Move approved and
actionable work to a packet under `docs/plans/`.
