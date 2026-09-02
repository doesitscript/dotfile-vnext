---
title: Skills and evaluator-implementer loop -- implementer
plan: 2026-09-02--codex-multi-terminal-promotion
status: mirrored-pointer
source_authoring_role: implementer
canonical_source: docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/implementer-role-documentation.md
---

# Skills and evaluator-implementer loop -- implementer

This plan-local file exists so the plan packet contains the paired
`implementer` / `evaluator` documentation requested by the user.

The canonical implementer-authored documentation is:

- [implementer-role-documentation.md](../../../codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/implementer-role-documentation.md)
- [after-action-report-2026-09-02.md](../../../codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/after-action-report-2026-09-02.md)
- [AFTER-ACTION-REPORT-skills-and-evaluator-implementer-loop.md](../AFTER-ACTION-REPORT-skills-and-evaluator-implementer-loop.md)

## Implementer-side highlights

- Entry point: `multi-agent-implementer`
- Role boundary: implementer fixes repo state and receipts, but never authors
  evaluator sign-off
- Continuous loop: read newest evaluator artifact, correct, verify, update
  receipt, then wait for evaluator authority
- Failure encoded: implementer must never run `evaluator_simple_loop.sh`

Use the durable docs above as the source of truth if this plan-local pointer
and the framework docs ever diverge.
