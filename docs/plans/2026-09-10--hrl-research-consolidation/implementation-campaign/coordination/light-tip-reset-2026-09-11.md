# Light tip reset — 2026-09-11

## Status

**Superseded for Light:** any Full-era tip that resumes from
`feedback_for_review_by_evaluator_*134911Z` (and the related safety-fixture /
reversal feedback loop). Do not treat those artifacts as the next Implementer
input under `orchestration_profile: light`.

## Why

That tip chain demanded retired S3/S4 safety-contract fixtures and kept the
Light parent resuming Full-era feedback instead of the research queue. Runtime
now hard-refuses Full-era `feedback` / `waiting` tip resume under Light unless
`allow_full_tip_resume: true`.

## Next Light start inputs (only)

1. `multi-agent-design/orchestration/examples/storage-layout-research-transforms/implementation-work-queue.md`
   → first ready row: `FA-hf-cache-desired-state` / alias `S3-cache-idempotence`
2. `.../performance-layout-adoption.md` (placement ledger; secondary)
3. Hard corrections **C1–C3** from
   `multi-agent-design/multi-agent-onsite-expert/examples/storage-performance-research-application.md`
4. Primary decision package:
   `multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md`

## Evaluator scope for that chunk

Ansible-clean check that S3 / FA-hf-cache target state lands in
`roles/k3s_vllm_runtime/**` owners only. No SSH, no S1–S6 matrix, no safety
playbooks.

## Quarantine note

Unaccepted Full-era coordinator/evaluator filenames under
`coordination/unaccepted-runtime-events/` remain historical evidence only.
