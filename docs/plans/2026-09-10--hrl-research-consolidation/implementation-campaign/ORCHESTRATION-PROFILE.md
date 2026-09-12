# Active orchestration profile: Light

This campaign now defaults to the Light Implementer/Evaluator loop: group
related source and Ansible-owner changes, run targeted source validation, and
exchange one durable review package and one grouped Evaluator response as soon
as each turn finishes.

The queue's defined implementation target comes from the **refined technical
handoff**
([`orchestration/05-refined-technical-handoff--storage-layout.md`](../multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md)).
Implementer derives dynamic queue chunks from that handoff’s functional areas;
Evaluator decides whether each chunk’s target state is correctly realized.
File reads, diffs, `git status`, syntax, and argument inspection are supporting
evidence only. Light does not create separate process, hygiene, documentation,
or investigation work merely because those checks are available.

Do not use Full Orchestration, remote Apply, deployment proof, or
runtime-recovery loops for ordinary source/design work. **Implementer and
Evaluator** stay controller-local (no inventory-targeted SSH/Apply). When a
named fork needs exact host/disk identity, summon the **On-site Expert**
sidecar to obtain it read-only (inventory/receipts → Ansible → SSH bash or
Windows PowerShell helpers)—never invent by-id and never ask the human for a
probeable fact. Full remains the lane for named Apply/attach/mutate.

## Lab cattle posture

This project is a recreatable lab. The Light loop treats workloads, cache data,
local storage state and service instances as cattle: implement desired state so
it converges on repeat runs, but do not block source integration on bespoke
backup/restore flows, outage approval, forensic receipts, or hypothetical early
migration rollback paths. The Light Evaluator checks Ansible design, native
module use, role ownership, naming, argument contracts, templates/handlers,
tags, and idempotence. It gives one short chunk-local correction only when
normal desired-state convergence or source quality is wrong.

Production-style data preservation, reversal sequencing, target identity,
live Apply, and deployment proof remain available in Full Orchestration. They
are not default Light feedback and are not grounds to halt a recreatable-lab
source chunk.

## Retired S3/S4 safety-contract fixtures

The On-site Expert's settled layout/performance recommendation and this lab
posture are the active technical decision input for S3 and S4. The former
`verify_k3s_storage_offload_safety.yaml` and
`verify_vllm_cache_migration_safety.yaml` fixtures are retired from future
Light work: they checked production-style migration/reversal conditions rather
than normal desired-state convergence. Historical receipts that cite them stay
intact as evidence of the prior Full-style attempts. Light validates each
owner chunk once as a bundled source-quality package and routes design
questions to the Expert only when the settled decision does not cover them.

The prior Full attempts on 2026-09-11 accumulated over 30 minutes and did not
finish the campaign that day; their retention evidence remains useful, but they
are not the default development workflow. See the detailed rationale in
[`multi-agent-design/orchestration/light-profile-rationale-2026-09-11.md`](../multi-agent-design/orchestration/light-profile-rationale-2026-09-11.md).

For one named unresolved technical fork, add a bounded request under
`coordination/requests/` and pass its absolute path as
`consultation_request_path`. The Light parent runs an On-site Expert then
Researcher sidecar while unrelated source work continues.

## Interrupted Light recovery

When a prior run left partial source work but no fresh accepted handoff, resume
from the last governed artifact only. Treat partial edits as one unreviewed
working batch. The first Implementer pass must reduce that batch to the smallest
coherent owner group, run its targeted source validation, and write a fresh
review-ready handoff; only then does Evaluator run. Use a fresh run ID and
`--recover-lock` after exact owner absence is verified (locks live under
`multi-agent-design/orchestration/temp/`). A 900-second pass ceiling is a stall
guard, not a reason to wait or continue expanding the batch.

Light parents refuse Full-era `feedback` / `waiting` tip resume unless
`allow_full_tip_resume: true`. See
[`coordination/light-tip-reset-2026-09-11.md`](coordination/light-tip-reset-2026-09-11.md)
for the S3 queue restart after the 134911Z safety-fixture loop.
