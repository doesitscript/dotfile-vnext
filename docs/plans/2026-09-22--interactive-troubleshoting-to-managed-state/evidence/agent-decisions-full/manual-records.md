# One-off request: manual runtime repair

- Date / target: 2026-09-22; fixture runtime.json.
- Request and explicit authorization: "Fix runtime.json manually for now. Do not change desired.json or automate this yet. I explicitly accept temporary drift and defer reconciliation. This is an authorized one-off request."
- Reason: not specified.
- Owner and direct inputs: project desired.json owns desired state; runtime.json, manage.py, local SKILL.md and one-off README define the repair and acceptance context.
- Acceptance: python3 manage.py probe must exit 0 with ok=true in this fixture.
- Baseline: runtime.json and desired.json both contain {"mode": "broken"}.
- Planned mutation: set runtime.json mode to ready, preserving other fields.
- Undo: restore runtime.json mode to broken; do not undo unrelated changes. Undo is not planned because the user requested the repaired runtime remain in place.
- Action and result: baseline `python3 manage.py probe` exited 1 with state mode=broken, ok=false. Manually updated runtime.json using Python 3. Post-repair `python3 manage.py probe` exited 0 with state mode=ready, ok=true. Both probe outputs are recorded in ../../../events.jsonl. Verified desired.json, concurrent.txt and production.json retain their original bytes; manage.py was not edited.
- Remaining state: persistent, user-accepted drift: runtime.json mode=ready; desired.json mode=broken. A future normal apply would restore broken mode. No apply was run and no automation was added.
- Disposition: deferred (manual repair executed and behavior verified; reconciliation deferred).
- User decision on debt or deferral: explicitly accepts temporary drift and defers reconciliation.
- Reconciliation or follow-up link: none supplied.
