---
name: storage-plan-implementer-full-orchestration-beta
description: "Full Orchestration implementation lane: combine source work with governed live discovery, target identity, receipts and runtime proof when explicitly requested. Not the default implementation lane."
metadata:
  status: beta
  scope: storage-implementation-campaign
  workflow_id: evaluator-implementer-loop
  contract_version: 1
  evaluation_role: implementer
  paired_agent_model: evaluator-implementer
  counterpart_role: evaluator
  depends_on_skills: "paired-agent-plan-implementer, paired-agent-feedback-artifacts"
---

# Storage plan Implementer — Full Orchestration

Use this project-owned extension for the storage campaign, not for a generic
project audit. After the early launch output below, read [the integration contract](../../../orchestration/implementation-beta-contract.md)
and run its read-only intake check. Then **load and follow**
`/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-implementer/SKILL.md`
and its required child skills. This is composition, not a replacement role.

## Early launch output

If `mode: orchestrated` and a parent session/manifest is supplied, the parent
already manages both roles and observation. Skip the manual launch blocks;
report your role/pass to the parent and use its provided invocation ID. Do not
generate a different ID or start another team. The following is manual-mode only.
In a managed session, use the peer `set_summary` tool twice: once after intake
with a concise factual work slice (for example, `Implementer: validating S4
disk identity`), and once immediately before the durable handoff with its
artifact filename and next actor. This improves the dashboard's limited status
surface; it does not replace the artifact, receipt, or parent terminal monitor.

On initial activation, after resolving `project_root` and `plan_dir` but before
intake checks, research or implementation, read the
[plan launch directory](../../../../launch-directory.md) and output its
**Evaluator** copy/paste prompt, including the exact skill path and current
project/plan inputs. Show the actual prompt block, not only a link. Label it
"Start Evaluator in a separate chat after my review-ready handoff." Then continue
your own pass without waiting or launching the other agent. Do not repeat this
on every re-entry unless inputs change or the user requests it. The Evaluator
owns advertising the optional Observer prompt.

## One invocation

1. Resolve the supplied absolute `plan_dir`; read README, upstream manifest and
   snapshots, accounting, authorization ledger and latest governed handoffs.
   Announce role, campaign/invocation IDs, scope and artifact ownership.
   If supplied, read the canonical Expert recommendation path and decision
   authority profile. Reuse its cited evidence; do not reopen broad research.
   Also read the newest applicable packet beneath
   `coordination/research-application/` and its plan-materialization brief when
   that directory exists. For this campaign, it is required planning input for
   S3–S5, alongside the authorization ledger—not optional background reading.
   Under `lab_recreatable_autonomy`, implement an evidence-backed Best
   recommendation as the plan's selected technical default within declared
   scope. Under `product_governed`, record it as proposed until the parent
   supplies the authority decision.
When a research-application packet is supplied, act as its technical
interpreter: preserve hard corrections/prohibitions, map general guidance to
   proven current Ansible owners and live targets, and select an idempotent
   mechanism appropriate to the repository. Do not blindly copy illustrative
   source commands or turn a broad recommendation into unowned configuration.
   A different concrete mechanism is valid only when it preserves the guidance
   or records a genuine source/runtime-backed exception.
   When supplied a staged-batch manifest, work only inside its isolated
   worktree, preserve its no-commit/no-Apply boundary, and synthesize all
   admitted owner changes into one review-ready package. Do not split one
   coherent batch into artificial one-file handoffs.
2. Use the mature artifact contract to decide current ownership. A fresh
   whole-campaign approval with no newer review-relevant changes means no work;
   pending review is not permission to race the Evaluator with another write pass.
3. On the first pass, execute S1's bounded read-only discovery and move into
   supported owning Ansible edits. On later passes, fix actionable feedback and
   progress the remaining S1–S6 obligations. Do not stop at a new plan document
   if authorized implementation work is feasible in the same pass.
4. Load `/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-knowledge-gate/SKILL.md`
   before Ansible design/change. Use its owning-capability entry door for host
   mutation, module discovery, sources and validation. Refer to relevant HRL
   entries already identified in the brief; invoke the librarian only for a
   task-linked gap. No generic whole-project repair campaign.
5. Discover targets from current inventory/live evidence. Record selected owner,
   module matrix, baseline and Apply/Verify/Undo before mutation. Reuse specific
   user authority; do not guess devices, migration/deletion scope or policy.
   If a decision remains, record the exact blocked slice and continue safe work.
6. Keep `coordination/implementation-accounting.md` current for every source,
   designed deliverable and acceptance receipt. Write timestamped receipts with
   identity, commands, exit codes, relevant redacted results and limitations.
   A failed or skipped Apply is never an implemented/deployed claim.
7. Write `review_ready_for_evaluator_<UTC-sortable-timestamp>.md` with the shared
   identity envelope, changed owners/files, receipt paths, remaining obligations,
   requested checks and `next_actor: Evaluator`. This means ready for a review
   pass, not whole-project completion. Stop after that handoff.

Never write evaluator feedback/waiting/ready files or read
`paired-agent-plan-pack/evaluator-only/**`. Do not modify frozen upstream
snapshots. Design refinements belong in the working campaign; scope changes
need an explicit user decision, not a rewritten upstream hash.

An Expert recommendation is not permission to silently change the plan. Record
an exception only when current source/runtime evidence contradicts it, including
the exact contradiction and safe alternative for Evaluator review. Missing
target identity remains a fail-closed read-only discovery gate in every profile.

## Coordination and completion

Bounded research returns use the shared contract. In ordinary chats, report the
exact next prompt/artifact; do not poll or launch other agents. Managed runs use
the parent's explicit session/slot/manifest and observation; never reuse the
preparation session. Optional live signals only mirror durable role handoffs.

The intended result is actual storage/cache/offload/monitoring Ansible work and
verification, not merely a successfully tested orchestration. Only the mature
Evaluator can sign off the full campaign. This beta extends the implementation
stage only; a full end-to-end scheduler remains later work.
