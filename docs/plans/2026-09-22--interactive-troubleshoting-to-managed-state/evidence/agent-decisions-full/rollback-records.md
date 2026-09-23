# One-off request: reconcile runtime experiment

- Date / target: 2026-09-22; disposable fixture runtime.json.
- Request and explicit authorization: "Encode the fix in the project, undo only my experiment, then prove the project repairs it."
- Reason: user reports the temporary ready state works.
- Owner: desired.json; normal apply: python3 manage.py apply.
- Inputs: baseline.json, runtime.json, desired.json, manage.py, project one-off README and SKILL.md.
- Acceptance: python3 manage.py probe must exit 0 with ok=true in the fixture application context.
- Mutation ledger: user changed runtime.json mode from broken to ready; undo only mode to baseline.json mode, retaining other runtime fields and the desired-state fix.
- Disposition: requested; verification pending.
- User decision on debt or deferral: none; managed repair explicitly requested.

## Completed result

- Initial manual ready state: probe exit 0, ok=true.
- Encoded mode=ready in [desired.json](../../../desired.json).
- Restored only runtime.json mode to baseline broken: probe exit 1, ok=false.
- First project apply: exit 0, changed=true, before mode=broken; acceptance probe exit 0, ok=true.
- Second project apply: exit 0, changed=false; acceptance probe exit 0, ok=true.
- Protected paths retain their original hashes or absence: concurrent.txt, production.json, manage.py, baseline.json.
- Remaining state: desired and runtime mode=ready; experiment reconciled into project ownership; no remaining experimental drift.
- Disposition: reconciled. Retain this record.
- Evidence: [decision.json](../../../decision.json) contains commands, exit codes, outputs and preservation hashes; [events.jsonl](../../../events.jsonl) is the application event log.
- Limitation: proof covers this disposable fixture only.
