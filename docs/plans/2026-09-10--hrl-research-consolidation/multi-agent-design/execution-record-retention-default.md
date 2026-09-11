# Default end-of-run retention contract

This is the default for every managed multi-agent run that reaches an automatic,
error, limit, waiting, approved, or user-requested stop. It is deliberately
separate from a later cleanup decision.

## Capture before cleanup

Before any session archival or owned-process cleanup is requested, create one
timestamped execution record beneath the active plan's campaign folder:

```text
<plan_dir>/implementation-campaign/execution-records/
  YYYY-MM-DDTHHMMSSZ-<run-id>/
```

It must contain:

- an index/README with campaign, session, run, terminal state, next actor,
  Apply authority, and links to governing role artifacts;
- exact Implementer and Evaluator session transcripts when locally available;
- runtime event stream, orchestrator/watchdog logs, inputs, checkpoints,
  per-pass records, final result, archive state, and ownership/final-process
  observations;
- SHA-256 checksums and integrity verification;
- a concise continuation checkpoint when the outcome is not Evaluator-approved.

Raw transcripts are local evidence. Keep them compressed and session-scoped;
review them before sharing outside the authorized workspace. Do not capture
global configuration, broad environment dumps, credentials, unrelated broker
sessions, or shared-service logs.

## Cleanup is a later, explicit phase

After capture and verification, report an exact cleanup candidate list:

- the parent-owned runtime directory;
- its archived session record; and
- only processes registered in its ownership manifest.

Do not delete or stop any candidate until the user explicitly chooses cleanup.
Never include shared broker/dashboard processes, project plan artifacts, role
artifacts, receipts, skills, research, or execution records in that list.

## Current implementation status

The retention contract is now mandatory in the parent/Observer instructions.
The implementation runner already writes the underlying run evidence, but it
does **not yet** automatically copy Codex transcripts and materialize the
plan-owned execution-record directory. Until that small runner enhancement is
implemented and tested, the parent must perform this capture before offering
cleanup.
