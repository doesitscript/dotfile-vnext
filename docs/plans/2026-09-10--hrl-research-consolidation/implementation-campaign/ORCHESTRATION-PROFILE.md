# Active orchestration profile: Light

This campaign now defaults to the Light Implementer/Evaluator loop: group
related source and Ansible-owner changes, run targeted source validation, and
exchange one durable review package and one grouped Evaluator response as soon
as each turn finishes.

Do not use Full Orchestration, SSH/live discovery, remote Apply, deployment
proof, or runtime-recovery loops for ordinary source/design work. Full is an
explicit exception for a named target-identity, authority, destructive-action,
or live-runtime contradiction.

The prior Full attempts on 2026-09-11 accumulated over 30 minutes and did not
finish the campaign that day; their retention evidence remains useful, but they
are not the default development workflow. See the detailed rationale in
[`multi-agent-design/orchestration/light-profile-rationale-2026-09-11.md`](../multi-agent-design/orchestration/light-profile-rationale-2026-09-11.md).

For one named unresolved technical fork, add a bounded request under
`coordination/requests/` and pass its absolute path as
`consultation_request_path`. The Light parent runs an On-site Expert then
Researcher sidecar while unrelated source work continues.
