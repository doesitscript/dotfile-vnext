# Skill Instruction Reduction Patterns

> **Status: brainstorming / design exploration - NOT repo work**
>
> Post-skill evaluation prompts for reducing repeated instructions and
> framework token load. Not approved implementation scope.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read unless the task is about skill reduction, instruction load,
  or framework token budget.
- Treat candidates as examples until promoted through `docs/intake/` or
  `docs/plans/`.

## Packet Artifacts

| File | Role |
|------|------|
| [`skill-instruction-reduction-plan.md`](./skill-instruction-reduction-plan.md) | Skills, prompts, and reduction levers |
| [`first-pass-receipt-2026-07-28.md`](./first-pass-receipt-2026-07-28.md) | First execution receipt |
| [`.aiignore`](./.aiignore) | Local advisory context boundary |

## Intended Use

- After creating a reusable skill
- When always-on rules feel heavy vs local context budgets
- When the same process text is rewritten into prompts repeatedly

## Promotion Path

Move shaped material to `docs/intake/`. Move approved work to `docs/plans/`.
