# Execution evidence map

| Question | Durable location | Limitation |
| --- | --- | --- |
| Planned/authorized work | `implementation-campaign/README.md`, `coordination/`, `upstream/` | Upstream is provenance, not current runtime state. |
| Role claims and handoffs | Top-level role artifacts and `receipts/` | A written artifact is not approved until parent acceptance. |
| Parent routing and acceptance | Per-run `pass-*.json`, `checkpoint.json`, `result.json`, `events.jsonl` under `/Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-*/run/` | Raw traces remain outside the plan folder. |
| Stop reason and applied fix | `observer/observation-reports/orchestration-stop-*.md` | Concise summary, not full transcript. |
| Owned runtime processes | Matching run's ownership/cleanup records | Shared broker/dashboard are external to a run. |
| Chat commentary | Conversation/application history | Not automatically materialized into the plan packet. |

## Current gap

There is no single plan-owned normalized trace joining runs, artifact acceptance,
dashboard-safe summaries, decisions, and chat observations. Most raw evidence
exists, but it is split across campaign artifacts and isolated `oneoffs` runs.

## Future-compatible trace shape

Use append-only records with `campaign_id`, `run_id`, `session_id`, timestamp,
role, event type, artifact path/digest, gate before/after, authority state,
runtime disposition, and a redacted operator summary. This extends the current
evidence model without reinterpreting existing artifacts.
