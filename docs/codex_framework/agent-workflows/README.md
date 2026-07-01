# Agent Workflow Registry

This folder is the reusable home for multi-agent and role-split workflow
patterns used by this repo.

The goal is to keep coordination behavior out of one-off plan packets. A plan
may select a workflow pattern, but the reusable pattern lives here so it can be
audited, improved, and reused later.

## Why This Exists

The AI intake work exposed a real process gap: the coordinator and independent
validator existed as plan language, but the validator was not wired as a hard
release gate before final status. That meant the coordinator could summarize
too early, and a validator/tool failure could become a quiet end point instead
of a send-back condition.

This registry fixes the ownership boundary:

- plan packets describe the work
- workflow patterns describe how agents coordinate the work
- receipts record whether the workflow gates actually ran
- validators can send work back before the coordinator reports completion

## Structure

- `workflow-schema.md` defines the required fields for a reusable workflow
  pattern.
- `patterns/` stores reusable workflow patterns.
- `learnings/` stores incidents and improvements that changed the workflow
  contract.

## Pattern Lifecycle

Use one of these statuses in each pattern:

- `draft`: documented but not yet used for real work.
- `trial`: used in active work, still being corrected.
- `active`: approved for reuse as a default pattern.
- `retired`: preserved for history, not recommended for new work.

## Current Patterns

- [Plan family execution with validator](patterns/plan-family-execution-with-validator.md)
- [Doc collection coordinator + per-page workers](patterns/doc-collection-coordinator.md)

## Rules

- Do not bury reusable multi-agent behavior only inside `docs/plans/`.
- Do not call a coordinator summary complete until the selected workflow's
  validation gate is satisfied or explicitly unsigned with evidence.
- If a validator, MCP tool, or subagent is unavailable, narrow and retry before
  falling back to direct repo audit.
- If validation still cannot run, leave the validator gate unsigned. Unsigned is
  not complete.
