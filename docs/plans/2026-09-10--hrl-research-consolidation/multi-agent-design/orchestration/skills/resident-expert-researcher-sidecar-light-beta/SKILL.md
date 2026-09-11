---
name: resident-expert-researcher-sidecar-light-beta
description: "Attach a bounded Expert then Researcher consultation to a Light implementation run when one named technical fork needs resolution."
metadata:
  status: beta
  scope: light-orchestration-consultation
  workflow_id: resident-expert-researcher-sidecar
---

# Resident Expert + Researcher sidecar — Light

Use this only for one explicit technical fork that cannot be resolved from the
settled packet by the Implementer or Evaluator. Create a request under
`<plan_dir>/coordination/requests/` that names the exact question, known
evidence, affected owners, acceptance test, and `return_to` artifact/role.

Pass its absolute path as `consultation_request_path` to the parent Light
runner. The runner creates two held slots, executes one On-site Expert pass then
one Researcher pass, and passes their two durable responses back into the normal
Implementer/Evaluator loop. Work outside the named owners continues; the
sidecar does not restart planning, mutate sources, authorize Apply, or create a
human wait when the lab profile can adopt an evidence-backed default.

Do not supply this option for an ordinary module lookup or a settled decision.
Use Full Orchestration only for an actual target/authority/live-runtime need.
