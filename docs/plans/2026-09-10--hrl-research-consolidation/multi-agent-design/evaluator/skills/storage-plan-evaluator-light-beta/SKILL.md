---
name: storage-plan-evaluator-light-beta
description: "Review one frozen Implementer chunk against the refined technical handoff: design, ownership, naming, idempotence, modules, and targeted validation. Default evaluator lane; no live runtime proof."
metadata:
  status: beta
  scope: source-first-evaluation
  workflow_id: evaluator-implementer-light-loop
  evaluation_role: evaluator
  counterpart_role: implementer
---

# Storage plan Evaluator — light default

## Primary input (mandatory)

1. `refined_technical_handoff_path` (or newest
   `coordination/research-application/**/refined-technical-handoff.md`) — the
   area’s target state and hard corrections
2. The Implementer `review_ready_*` for **this** `chunk_id` only
3. Frozen owner diff / hashes / one validation bundle

Do **not** re-read the onsite transcript or reopen research. Do not expand into
a whole-campaign S1–S6 matrix in Light.

## Verdict order

1. Name the `chunk_id` / functional area and whether its **declared target
   state** is met in the declared owners.
2. Group corrections by owner/file with specific change language
   (“replace X with Y at path”).
3. Check hard corrections from the handoff only where those surfaces are
   touched.
4. State whether feedback creates a dependency that must pause another chunk.

Supporting evidence (`git status`, file reads, syntax) is not a separate
deliverable. Do not invent blockers with no tie to missing/incorrect target
state.

## Project-specific lab posture

Recreatable lab: cattle, not pets. Do not block Light chunks for backup
retention, reversal sequencing, outage authority, or failure-forensics unless
they expose a direct source defect in normal desired-state convergence.

Keep feedback short: wrong module, non-idempotent behavior, malformed
argument/variable contract, unsafe owner overlap, broken template/handler/tag
relationship, poor naming, failed bundled validation. Evaluate one bundled
source-quality package; do not split whitespace/syntax/lint into separate
loops.

## Multiagent status

At most two one-sentence `set_summary` lines. Never poll the broker. Final
agent response: one factual sentence.

## Exclusions

SSH, inventory ansible against hosts, remote playbooks, live probes, broad
research, knowledge-gate rediscovery, demands for retired safety-contract
fixtures, digest theater as the lead of the verdict.

Write one `feedback_*`, `waiting_*`, or `ready_*` artifact using the mature
evaluator filename contract (`ready_for_review_by_evaluator_*` — never
`*_by_coordinator_*`). `ready` means the chunk’s source package meets its
handoff target; it is not host deployment proof.

When consultation paths are supplied, check incorporation or valid deviation—
do not reopen settled research.
