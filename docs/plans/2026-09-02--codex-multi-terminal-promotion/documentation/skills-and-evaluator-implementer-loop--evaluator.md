---
title: Skills and evaluator-implementer loop -- evaluator
plan: 2026-09-02--codex-multi-terminal-promotion
status: final
authoring_role: evaluator
related_durable_docs: docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/
---

# Skills and evaluator-implementer loop -- evaluator

## What the user instruction implied

The instruction to the implementer had two concrete documentation targets:

1. keep an after-action report in the plan folder
2. create a `documentation/` folder inside the plan packet with paired
   `implementer` and `evaluator` documents

The implementer satisfied the durable-doc side under
`docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/`,
but did not create the plan-local `documentation/` packet. This file closes
that placement gap.

## Evaluator findings on documentation placement

- The durable framework home is correct for reuse:
  `docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/`
- The literal plan instruction also required plan-local paired docs
- A plan packet should therefore keep:
  - one plan-root after-action report
  - one plan-local `documentation/` folder with paired role docs
  - one durable framework home when the workflow is worth reusing

## Evaluator findings on new project capability

This work is now a real project capability, not just a one-off recovery trick.

Capability statement:
- `dotfile-vnext` can run a paired evaluator/implementer plan-correction loop
  with:
  - a repo-owned implementer skill family
  - evaluator-owned feedback/sign-off artifacts
  - durable framework docs
  - a reusable workflow pattern

This is proven by the reference run in this plan packet and should be advertised
as such in framework-facing docs.

## Scaffolding improvements that reduce future setup cost

1. Add a machine-readable capability manifest to the parent implementer skill.
2. Keep a standard plan-local `documentation/` folder in future paired-agent
   plan packets.
3. Keep the durable framework docs as the reusable home, not the plan packet.
4. When an evaluator-side global skill family exists, reference it from the
   project docs without making the project depend on it.

## Evaluator recommendation

For future reuse, the simplest startup contract should be:

- implementer: `Use skill multi-agent-implementer on docs/plans/<slug>/`
- evaluator: use the paired evaluator workflow/capability against the same plan
  folder

That preserves one obvious entry point per role while keeping the workflow
artifacts easy to audit.
