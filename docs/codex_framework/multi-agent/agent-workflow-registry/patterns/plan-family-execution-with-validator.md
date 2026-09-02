---
status: trial
owner: codex-framework
applies_to:
  - docs/plans plan families
  - AI infrastructure intake execution
  - multi-plan implementation
---

# Plan Family Execution With Validator

## Purpose

Coordinate a related set of plan packets through research, implementation,
validation, and completion without letting the coordinator silently narrow the
target or quit at a convenient boundary.

## Triggers

Use this pattern when:

- the user says to build or execute multiple related plans;
- a plan family has cross-plan dependencies;
- implementation includes both docs/framework changes and Ansible/runtime
  changes;
- the user asks for multi-agent coordination, a coordinator, or an independent
  validator;
- prior work stopped early or reported incomplete work as complete.

## Roles

### Coordinator

- Owns plan-family scope, dependency order, and send/receive handoffs.
- May edit plans, framework docs, Ansible entrypoints, inventory, and receipts.
- Must preserve the user's full target and capture new user decisions in
  on-deck sections before build proceeds.
- Must not report completion until the validator gate is satisfied or explicitly
  unsigned with evidence.

Handoff artifact: plan-family execution receipt or plan verification receipt.

### Slice Worker

- Owns one implementation slice such as storage, model catalog, vLLM, LiteLLM,
  Langfuse, NetBox, client profiles, or framework repair.
- May edit only the slice's owned files unless the coordinator assigns a shared
  surface.
- Must record Apply / Verify / Undo / Change class for meaningful changes.

Handoff artifact: slice notes in the receipt plus changed file list.

### Researcher

- Owns source-backed uncertainty: official docs, MCP checks, repo probes, and
  current resource comparison.
- Runs before exact model IDs, provider routes, hardware placement, NetBox
  objects, or downloads are treated as selected.
- Can run in parallel with other read-only research.

Handoff artifact: concise evidence summary and selected/pending status.

### Independent Validator

- Reviews the full obligation inventory, not only checklist rows.
- Verifies every in-scope obligation is implemented, blocked with evidence, or
  moved to a named future plan with `moved_to_plan`.
- Sends the packet back if open in-scope work lacks evidence.

Handoff artifact: validator row in the receipt with pass/fail/unsigned status.

### Permission Grantor / Release Gate

- Final status gate before the coordinator reports implemented or complete.
- Can be a human approval, a dedicated validator subagent, or an explicitly
  documented direct audit when subagents are unavailable.
- Must not be skipped because the coordinator thinks the work is mostly done.

Handoff artifact: release-gate entry in the receipt.

## Parallel Work

These can run in parallel:

- official documentation research;
- repo search over plans, roles, playbooks, inventory, and rules;
- read-only inventory and NetBox probes;
- model/resource candidate comparison;
- independent receipt review after the coordinator creates the receipt.

## Serialized Work

These must be ordered:

- shared file edits;
- inventory or registry writes;
- NetBox seed/apply work;
- playbook execution against hosts;
- dependency-sensitive automation such as storage/catalog before GPU probing,
  GPU prerequisites before vLLM runtime, runtime before LiteLLM gateway, gateway
  before IDE client profiles.

## Gates

### On-Deck Capture Gate

Input: user decisions made while plans are active.

Pass: each decision is integrated into the plan body/checklist/receipt, moved
to a named sibling plan, or rejected by later user correction.

Send-back: a decision remains only in chat or in an unresolved on-deck section.

### Research And Probe Gate

Input: novel or under-defined resource choices.

Pass: current source-backed research and live/read-only probes justify the
chosen resource, or the row remains `pending_research` /
`provisional_example`.

Send-back: exact resources are pinned, downloaded, or marked selected without
current research and probe evidence.

### Dependency Execution Gate

Input: plan-family dependency order.

Pass: order is represented in an Ansible entrypoint or explicit playbook chain
and the first safe preview/read-only gate ran.

Send-back: dependency order exists only as README prose once implementation has
begun.

### Plan Receipt Gate

Input: plan packet and changed implementation surfaces.

Pass: receipt covers prose obligations, reference tables, checklists,
dependencies, NetBox slice when applicable, and runtime/client verification.

Send-back: checklist-only receipt, missing NetBox Declared/Applied/Verified
evidence, or runtime artifact treated as an example instead of managed output.

### Independent Validator Gate

Input: coordinator receipt.

Pass: validator confirms all in-scope work is pass, evidence-backed block, or
properly moved to a named future plan.

Send-back: in-scope work is still open, weakened, undocumented, or claimed
complete without evidence.

Fallback: if the subagent or MCP validator is unavailable, narrow the prompt and
retry. If it remains unavailable, run a direct repo audit. If that still cannot
complete, leave the validator gate unsigned and do not claim completion.

### Release Gate

Input: validator result plus final coordinator summary.

Pass: no unsigned validator gate, no open on-deck items, no blocked in-scope
work left inside a plan claimed as implemented, and no live-apply gap hidden as
operator-controlled.

Send-back: any of those conditions remain true.

## Artifacts

- plan verification receipt
- plan-family execution notes
- validator gate status
- direct-audit notes when subagents are unavailable
- troubleshooting artifacts for failed apply or validation

## Completion Rule

The coordinator may report complete only when:

- the selected workflow gates pass;
- the independent validator gate is signed, or the work is explicitly reported
  incomplete because validation could not complete;
- all in-scope obligations are implemented, evidence-backed blocked, or moved
  out of scope to named future plans with dependency linkage and user
  acceptance.

## Failure Rule

Failure to spawn a subagent, MCP timeout, or usage-limit failure is not a
completion condition. It is a validation failure mode. The coordinator must
retry narrower, perform direct audit, or leave the release unsigned.
