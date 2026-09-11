# Light orchestration is the active path

## Current decision

This implementation campaign defaults to **Light Orchestration**: one grouped,
source-first Implementer package followed by one grouped Evaluator review.
The loop uses the multi-agent parent to route durable artifacts immediately,
rather than treating fixed pass limits as normal workflow timing. A checkpoint
is only a progress/failure safeguard; a worker that finishes early hands off
immediately.

Light work applies the settled research packet, On-site Expert decisions,
Ansible knowledge capability, and current Evaluator feedback to project-owned
roles, playbooks, inventory, templates, handlers, and validation. The Evaluator
focuses on native-module design, ownership, naming, idempotence, contracts,
tags, scalability, and grouped source quality. Targeted source validation is
expected; live deployment proof is not.

## Observed reason for the split

On 2026-09-11, attempted Full Orchestration runs in this campaign accumulated
more than 30 minutes of elapsed work. Multiple finite Implementer passes reached
their deadline before an accepted handoff, with runtime retention/recovery work
adding delay. None reached a completed campaign during that observed day. This
is evidence about this packet and runtime configuration, not a claim that Full
Orchestration can never complete elsewhere.

The heavy path repeatedly mixed source correction with SSH/live discovery,
runtime checks, process lifecycle recovery, and deployment-style proof. Those
are valuable when specifically required, but they obscured the ordinary goal:
integrating already-decided changes cleanly into the project.

## Full Orchestration remains available

Select `orchestration_profile: full` only for a named target-identity,
authority, destructive operation, or live-runtime/deployment contradiction.
It retains the deeper evidence, lifecycle, and recovery behavior. It is never
an automatic escalation from a Light source-quality finding.

## Optional Expert + Researcher sidecar

For one named unresolved technical fork, the Light parent accepts
`consultation_request_path`. It runs an On-site Expert pass and then a
Researcher evidence pass, preserves their responses under
`coordination/consultations/`, and supplies both to the normal
Implementer/Evaluator loop. The sidecar is intentionally optional: settled
decisions and ordinary module lookups stay in the fast loop.

See [the sidecar skill](skills/resident-expert-researcher-sidecar-light-beta/SKILL.md)
and the [implementation contract](implementation-beta-contract.md).
