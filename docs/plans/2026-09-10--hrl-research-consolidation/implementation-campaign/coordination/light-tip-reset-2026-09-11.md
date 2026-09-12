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

## How decisions work here (lab, not “serious enterprise”)

This campaign is a recreatable homelab. Research and Expert Best are already
done by the other roles. Implementer should **not** ask the human which option
to pick.

Decision order:

1. **Adopt** the settled Best / Preference already in the packet
   (`coordination/expert-best-recommendations--storage-layout.md` + refined
   handoff + operator resolution).
2. If Implementer still cannot decide a **named technical fork**, **defer to
   the On-site Expert** (not the human): write
   `coordination/requests/<short-id>.md` and pass it as
   `consultation_request_path` so the Light parent runs the Expert → Researcher
   sidecar (`resident-expert-researcher-sidecar-light-beta` /
   `onsite-expert-consultation-light-beta`).
3. Expert re-reads the settled research + its own recommendations + the current
   project owners, returns a Best recommendation, and the pair continues.
   When the fork needs disk/host identity, Expert **finds** it (inventory,
   Ansible, SSH/bash or Windows PowerShell via project helpers)—never guesses
   and never asks the human for a by-id the lab can probe.
4. Human is only for explicit Apply/destructive authority the packet does not
   already grant — not for “which researched layout option?” and not for
   “what is the disk by-id?”

The file
`05-refined-technical-handoff--storage-layout.md` is **not** a heavy ceremony.
It is the short memo of what research already decided so Implementer does not
re-ingest the whole transcript. Queue + Expert Best + Expert-on-call are enough
to keep moving.

## Next Light start inputs

1. Work queue → first ready row (`FA-hf-cache-desired-state` /
   `S3-cache-idempotence`, then the other ready FA rows)
2. Compacted research decisions (optional short memo):
   `05-refined-technical-handoff--storage-layout.md`
3. Materialized Best list:
   `coordination/expert-best-recommendations--storage-layout.md`
4. Operator binding: offload everywhere / don’t ask which slice
   (`operator-resolution-2026-09-11-offload-everywhere.md`)
5. On stuck choices: Expert consultation request under
   `coordination/requests/` (see that folder’s README)

## Evaluator scope for a chunk

Chunk-local Ansible-clean check on the named owners. Do not expand into a
whole-campaign S1–S6 scorecard or retired safety playbooks. Do not ask the
human which slice is next.

## Hands-free config (every Light parent)

Wire all of these (see `runtime/implementation-config.example.json`):

- `expert_recommendation_path` → materialized Best list above
- `decision_authority_profile_path` → `lab_recreatable_autonomy` pin
- `operator_resolution_path` → offload-everywhere resolution
- `implementation_work_queue_path` → examples work queue
- `refined_technical_handoff_path` → short research memo (handoff)
- `allow_full_tip_resume: false`
- When Implementer opens a fork: set `consultation_request_path` to the request
  file so Expert is actually deployed for that pass

Leaving Expert/authority null is what causes the parent to ask the human.
Leaving Expert off-call when Implementer is stuck is the other failure mode —
summon Expert, don’t escalate to chat questions.
