# Skill Instruction Reduction Patterns

> **Status: brainstorming / design exploration - NOT repo work**
>
> This packet captures follow-on evaluation skills and prompts for reducing
> repeated instructions and framework token load after creating reusable
> skills (starting with brainstorm-design packet creation). It is not approved
> implementation scope and not active automation behavior.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read this packet unless the task explicitly asks for skill
  reduction, instruction-load, or framework token-budget design.
- Treat candidate skills and prompts as examples until promoted through
  `docs/intake/` or `docs/plans/`.
- Do not infer active rule/skill changes from this packet alone.

## Packet Artifacts

| File | Role |
|------|------|
| [`skill-instruction-reduction-plan.md`](./skill-instruction-reduction-plan.md) | Detailed evaluation skill set, prompts, and token-reduction levers |
| [`.aiignore`](./.aiignore) | Local advisory context boundary for AI agents |

## Intended Use

Use this packet when:

- a new reusable skill is created (for example brainstorm packet scaffolding)
- you want a post-creation evaluation loop for instruction/token reduction
- you need prompt examples for maturity, state-report, and coordinator skills

## Promotion Path

Move shaped, decision-ready material to `docs/intake/`. Move approved and
actionable work to a packet under `docs/plans/`.
