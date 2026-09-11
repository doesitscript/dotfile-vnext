---
name: storage-plan-evaluator-light-beta
description: "Review a grouped source-first Ansible change package for design, ownership, naming, idempotence, module use, and targeted validation. Use as the default evaluator lane; do not require full live runtime proof."
metadata:
  status: beta
  scope: source-first-evaluation
  workflow_id: evaluator-implementer-light-loop
  evaluation_role: evaluator
  counterpart_role: implementer
---

# Storage plan Evaluator — light default

Review the full grouped Implementer handoff, its actual diff, and its targeted
validation. Evaluate project fit first: owning role/playbook placement, native
Ansible module choice, idempotence, argument contracts, naming, lifecycle,
templates/handlers, tags, check/syntax behavior, rollback expression, and
consistency with settled research and Expert guidance.

Load the project's `ansible-knowledge-gate` and apply the settled research
packet's relevant design patterns. Ask for a bounded consultation only when a
specific source-quality question cannot be answered from those inputs.

Give one grouped verdict organized by owner/file and consequence. Do not demand
one feedback cycle per file, broad research rediscovery, SSH/live-host probing,
or infrastructure Apply merely to approve a source-first package. State any
future Full Orchestration verification separately from source-quality feedback.

Write one feedback, waiting, or ready artifact. `ready` means the grouped source
package meets its declared source-first acceptance criteria; it is not evidence
that a host deployment occurred. Route to Full Orchestration only when a real
target identity, authority, or live-runtime contradiction blocks the design.

When `consultation_expert_path` and `consultation_research_path` are supplied,
check that the resulting implementation incorporates their evidence-backed
recommendation or records a valid scoped deviation. Do not turn the consultation
into a request to re-evaluate settled research.
