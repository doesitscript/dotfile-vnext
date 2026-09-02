# 2026-05-29 AI Intake Validator Gap

## What Happened

The AI infrastructure intake work introduced a coordinator and independent
validator concept, but the validator was not yet a hard release gate. The
coordinator could stop after repo edits or a partial status summary before the
validator had reviewed every in-scope obligation.

A later validator attempt also hit a tool usage limit. That exposed another
gap: validator/tool failure needed a fallback path, not a quiet stop.

## Structural Mistakes

- Validator role existed as intent, not as an always-required pre-final gate.
- The permission grantor/release-gate concept was not separated from the
  coordinator.
- Missing scaffolding could be treated as a blocker before the
  research/scaffold/probe loop completed.
- A targeted development-node run was unblocked with role-local fallback
  defaults instead of first fixing the parent play's path contract.

## Corrections

- Reusable workflow patterns now live under
  `docs/codex_framework/multi-agent/agent-workflow-registry/`.
- The plan-family workflow now includes coordinator, slice worker, researcher,
  independent validator, and release-gate roles.
- Validator/tool failure now requires narrower retry, direct repo audit, or an
  unsigned validator gate.
- Development-node shared paths are established by the play before dependent
  roles run, rather than hidden inside `common/agent_skills`.

## Reuse Guidance

When a future plan family needs multi-agent execution, select a pattern from the
workflow registry before implementation begins. Do not recreate the workflow in
the plan packet itself unless the plan is proposing a new reusable pattern.
