# Orchestration stop reports

This append-only directory is the durable, plan-owned record for a stopped
implementation orchestration attempt and any fix made because of it.

Create exactly one initial report per stop under this name:

```text
orchestration-stop-YYYY-MM-DDTHH-MM-SSZ.md
```

Use UTC. Do not overwrite reports. A later report is permitted only when it
adds materially new evidence. Keep each report concise and include: campaign,
session and run identity; observed stop trigger/time; artifact and approval
gate state; named changed files and validation (or `No fix applied`); owned
process/session disposition; and the next owner/action.

The parent orchestrator writes the initial report. The read-only Observer may
write a report only at a stop boundary, and only when it has material new
evidence. Reports are evidence and recovery guidance, not evaluator approval.

Operator monitoring feedback that does not describe a stop uses the parallel,
also timestamped form `operator-monitoring-feedback-YYYY-MM-DDTHH-MM-SSZ.md`.
It records a future enhancement only; it does not alter an active run.
