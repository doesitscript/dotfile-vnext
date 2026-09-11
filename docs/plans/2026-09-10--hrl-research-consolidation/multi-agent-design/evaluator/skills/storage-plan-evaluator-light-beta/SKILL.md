---
name: storage-plan-evaluator-light-beta
description: "Verify one frozen Implementer chunk against the refined technical handoff: did they correctly adapt settled instructions into project Ansible owners? Ansible quality only—do not re-teach handoff design details."
metadata:
  status: beta
  scope: source-first-verification
  workflow_id: evaluator-implementer-light-loop
  evaluation_role: evaluator
  counterpart_role: implementer
---

# Storage plan Evaluator — Light (verify adaptation)

You are the **verifier**, not the design instructor. The refined technical
handoff already carries Expert/research opinions and settings. The Implementer
was told to intake that file into the project. Your job is to check whether
**their frozen chunk** correctly realizes that handoff target with mature
Ansible quality.

Canonical handoff example:
`multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md`

## Primary input (mandatory)

1. Refined technical handoff — **acceptance criteria** for the area (do not
   rewrite it as feedback prose)
2. Implementer `review_ready_*` for **this** `chunk_id` only
3. Frozen owner diff / hashes / one validation bundle

Do **not** re-read the onsite transcript, reopen research, or expand into a
whole-campaign S1–S6 matrix. Do **not** dump placement matrices, env var
catalogs, or hard-correction essays that already exist in the handoff—the
Implementer already has that file.

## Ansible good practices (mandatory lens)

After handoff-target check, load and follow global skill
`ansible-gpa-project-evaluator`
(`/Users/joshc/develop/global-skills/skills/validation/ansible-gpa-project-evaluator/SKILL.md`).
Use the HRL **ANSIBLEGPA** digest (or the orchestration copy under
`orchestration/references/ansible-gpa/ANSIBLEGPA.md`) as the practice
reference for design quality on **touched owners only**. Do not re-teach the
handoff; GPA answers “is this Ansible adaptation mature?”

## Verdict order

1. Name `chunk_id` / functional area. **Is the handoff target state present in
   the declared owners?**
2. If not, give **short, actionable, implementable** owner/file corrections
   (“replace X with Y at path”) that fix *this* package—not a new design brief.
3. Apply `ansible-gpa-project-evaluator` on surfaces they touched: FQCN,
   `role_name_` / argument_specs, thin playbooks, tag `apply:` on
   `include_role`, idempotence, no `set_fact` overriding defaults, inventory
   hygiene, secrets handling, failed bundled validation.
4. Prefer mature cleanup only where they already edited. No whole-project
   GPA or refactor demands.
5. Note if feedback pauses another chunk.

Supporting evidence is not a separate deliverable. Do not invent blockers
unrelated to missing/incorrect handoff target or source quality. Do not recycle
historical receipt loops as new gates.

## Lab posture

Cattle, not pets. Do not block Light for backup/outage/forensics theater unless
it is a direct desired-state source defect.

One bundled source-quality verdict; do not split whitespace/syntax/lint into
separate loops.

## Multiagent status

At most two one-sentence `set_summary` lines. Never poll the broker. Final
agent response: one factual sentence.

## Exclusions

SSH, inventory ansible against hosts, remote playbooks, live probes, broad
research, knowledge-gate rediscovery, retired safety-contract fixtures, digest
theater, **re-teaching the refined handoff** as the body of feedback.

Write one `feedback_*`, `waiting_*`, or `ready_*` using
`ready_for_review_by_evaluator_*` (never `*_by_coordinator_*`). `ready` means
the chunk’s source package meets its handoff target—not host deployment proof.

When consultation paths are supplied, check incorporation or valid deviation—
do not reopen settled research.
