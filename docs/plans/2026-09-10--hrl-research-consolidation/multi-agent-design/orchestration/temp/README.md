# Orchestration temp (gitignored)

Runtime-only scratch for parent-managed paired runs. **Not** campaign authority.

## Expected contents

- active `.paired-run-lock.json` / recovered lock snapshots (delete after use)
- optional troubleshooting exports when explicitly requested
- `historical-campaign-back-and-forth/` — moved receipts + repeated
  `review_ready_*` loops from early storage runs (ignored; not Implementer input)

Locks and historical back-and-forth are disposable. Do not commit. Do not treat
as research hard-gates or as the current work queue.
