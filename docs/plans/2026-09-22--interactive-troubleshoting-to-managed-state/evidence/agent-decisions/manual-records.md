# One-off request: manual runtime repair

- Date / target: 2026-09-22; fixture runtime.json.
- Request and explicit authorization: "Fix runtime.json manually for now. Do not change desired.json or automate this yet. I explicitly accept temporary drift and defer reconciliation. This is an authorized one-off request."
- Reason: Not specified.
- Owner / direct inputs: Project desired.json owns desired state; local SKILL.md, docs/one_off_tasks/README.md, and manage.py define this workflow and acceptance.
- Acceptance: python3 manage.py probe must exit 0 with mode ready and ok true.
- Baseline: runtime.json contains {"mode": "broken"}; desired.json also has mode broken.
- Undo: Restore only runtime.json mode to broken; preserve other fields and concurrent work. Not executed because the requested repair is to remain active.
- Action and result: python3 manage.py probe before repair exited 1 with state mode broken and ok false. A one-time Python 3 edit set runtime.json mode to ready. python3 manage.py probe after repair exited 0 with state mode ready and ok true. Raw probe evidence: ../../../events.jsonl. No apply was run.
- Remaining state: runtime.json mode ready persists; desired.json remains mode broken. Temporary drift is explicitly accepted. manage.py, concurrent.txt, and production.json were not modified.
- Disposition: deferred (manual repair executed and behavior verified; reconciliation deferred by user).
- User decision on debt or deferral: "I explicitly accept temporary drift and defer reconciliation."
- Reconciliation or follow-up link: None supplied.
