# Recovery UX feedback — 2026-09-11T07:45:09Z

When a parent-managed campaign ends as `incomplete`, times out, or is
interrupted after owned cleanup, the parent should automatically present a
short plain-language explanation of session archival, lock recovery, artifact
state, and a ready-to-paste continuation prompt. The prompt must distinguish a
fresh parent/chat invocation from a fresh broker session/run ID, preserve work,
and name the causal next role.

The existing runtime documents recovery in `implementation-runner.md` and the
parent skill, but does not yet generate this operator-facing prompt
automatically. Implement this as a later UX/runtime enhancement without
changing the active campaign.
