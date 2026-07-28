# GPU Afterburner Power Efficiency Patterns

> **Status: brainstorming / design exploration - NOT repo work**
>
> This packet captures the live MSI Afterburner undervolt curve currently used
> on the RTX 5090 host, and explores whether/how that behavior should become a
> project-owned capability. It is not approved implementation scope and not
> active automation behavior.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read this packet unless the task explicitly asks for GPU
  Afterburner, undervolt, or GPU power-efficiency design.
- Treat settings, host details, and automation ideas as candidates until
  promoted through `docs/intake/` or `docs/plans/`.
- Do not infer that Afterburner is already managed by Ansible from this packet.

## Packet Artifacts

| File | Role |
|------|------|
| [`gpu-afterburner-power-efficiency-plan.md`](./gpu-afterburner-power-efficiency-plan.md) | Goal, curve breakdown, profile facts, and project-integration brainstorm |
| [`vf-curve-profile1-undervolt.png`](./vf-curve-profile1-undervolt.png) | Screenshot of the Voltage/Frequency curve editor for the target undervolt |
| [`.aiignore`](./.aiignore) | Local advisory context boundary for AI agents |

## Related Packet

General tuning/validation patterns (not the project-integration focus):

- `docs/brainstorming_designs/2026-07-28--gpu-performance-tuning-patterns/`

## Intended Use

Use this packet for early thinking around:

- capturing the operator-made Afterburner undervolt as durable project knowledge
- deciding whether the curve should stay manual or become repo-managed
- validating “lower power, no noticeable performance loss”
- startup persistence requirements for MSI Afterburner

## Promotion Path

Move shaped, decision-ready material to `docs/intake/`. Move approved and
actionable work to a packet under `docs/plans/`.
