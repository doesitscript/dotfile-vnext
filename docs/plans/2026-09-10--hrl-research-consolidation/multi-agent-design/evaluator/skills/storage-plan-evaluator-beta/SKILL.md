---
name: storage-plan-evaluator-beta
description: "Extend the mature paired-agent-plan-evaluator with verified Coordinator/Researcher intake, storage campaign identity, bounded research returns and independent whole-campaign evaluation. Use on the supplied storage implementation plan, not a broad project audit."
metadata:
  status: beta
  scope: storage-implementation-campaign
  workflow_id: evaluator-implementer-loop
  contract_version: 1
  evaluation_role: evaluator
  paired_agent_model: evaluator-implementer
  counterpart_role: implementer
  depends_on_skills: "paired-agent-plan-evaluator, paired-agent-feedback-artifacts"
---

# Storage plan Evaluator — beta adapter

After the early launch output below, read [the integration contract](../../../orchestration/implementation-beta-contract.md)
and run its read-only intake check. Then **load and follow**
`/Users/joshc/develop/global-skills/skills/validation/paired-agent-plan-evaluator/SKILL.md`
and its required child skills. Preserve that role's evidence standards, research
gate, verdict ownership and finite-pass behavior.

## Early launch output

If `mode: orchestrated` and a parent session/manifest is supplied, the parent
already manages both roles and observation. Skip the manual launch blocks;
report your role/pass to the parent and use its provided invocation ID. Do not
generate a different ID or start another team. The following is manual-mode only.

On initial activation, after resolving `project_root` and `plan_dir` but before
intake checks or evaluation, read the
[plan launch directory](../../../../launch-directory.md). Output both its
**Implementer** and **Observer** copy/paste prompts, each with the exact skill
path and current project/plan inputs. Show the actual prompt blocks, not only
links. Label them "Start Implementer in a separate chat if not already running"
and "Optional: start Observer here or in a third chat." Continue your own pass;
do not launch either agent, wait for an answer or create a duplicate run. Do not
repeat the blocks on every re-entry unless inputs change or the user requests it.
This early output is required even when no Implementer handoff exists yet.

## One invocation

1. Resolve `plan_dir`; announce role and campaign/invocation IDs. Read README,
   accounting, authorization, the frozen upstream evidence, latest Implementer
   outbox/receipts and latest Evaluator state. Verify identity before consuming a
   handoff. The preparation Researcher review is not your implementation approval.
   If supplied, read the canonical Expert recommendation and decision authority
   profile. Verify that Implementer followed the profile-adopted technical
   default or recorded a real source/runtime exception; do not treat either a
   recommendation or a lab profile as approval without independent evidence.
2. Inspect actual code/Ansible owners and receipt freshness, not only summaries.
   Tie findings to S1–S6 and the work changed. The authoring validation receipt
   tests adapters, not storage correctness. Do not demand unrelated maturity work.
3. Load `/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-knowledge-gate/SKILL.md`
   for relevant Ansible evaluation. Check actual module contracts, role lifecycle,
   tags, limits, preview/check-mode support and idempotence. Consult current HRL,
   installed runtime or official sources when a high-risk decision needs proof;
   do not treat a configured MCP as successfully queried.
4. Confirm any Apply had verified targets and user authority, baseline,
   backup/reversal and fresh post-change evidence. Where affected, check actual
   VHDX/guest mount/cache/PVC backing, data integrity, workload/vLLM health,
   imagefs/DiskPressure and monitoring behavior. A successful syntax check is not
   live verification; cleanup-only results do not fulfill new storage/offload.
5. Review whole-campaign obligation accounting while accepting incremental work.
   An unfinished slice is pending, not automatically an error in the completed
   slice. Identify the concrete next work. Use the mature repeated-blocker
   research gate only for repeated actual blockers; route a bounded request back
   to Coordinator/Researcher when needed.
6. Write exactly one mature timestamped evaluator artifact with the integration
   identity envelope and exact reviewed outbox/source/receipt state:
   - `feedback_*`: actionable scoped corrections or required remaining work.
   - `waiting_*`: unchanged/no new reviewable evidence; name the next dependency.
   - `ready_*`: fresh independent evidence closes **all** S1–S6 and designed
     deliverables, or user-approved scope changes are explicitly recorded.
   Stop after the artifact. Never self-schedule, poll, or implement the fixes.

If started before the first Implementer handoff, inspect the seed, leave one
waiting artifact and stop; do not treat launch order as a storage defect. If a
previous ready verdict is followed by review-relevant source changes, review
again. Observer notes, dashboard state and broker approval counters do not
establish the reviewed source state.

## Orchestration boundary

Optional `submit_feedback` / `approve` transport mirrors your durable verdict
only in the parent's assigned session. Approval belongs to you, never the
Implementer, Researcher, Observer or intake checker. Runtime operator owns
processes, dashboard and cleanup. This beta adapter extends the implementation
stage without claiming the future full orchestration is deployed.
