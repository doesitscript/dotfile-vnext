# Preparation → implementation integration contract (beta)

This project adapter composes with `paired-agent-plan-implementer`,
`paired-agent-plan-evaluator`, and `paired-agent-feedback-artifacts`. The mature
roles retain judgment, artifact ownership and finite-pass behavior. Their global
sources are not forked. This contract adds upstream intake, campaign identity,
bounded research return and optional observation. The separate parent runner
below provides scheduling while these role adapters remain finite-pass skills.

## Inputs and intake

`project_root` is `/Users/joshc/develop/dotfile-vnext`; `plan_dir` is the absolute
`implementation-campaign/` directory next to this design package. Read its README,
accounting and authorization ledger. Run `runtime/check-implementation-handoff.ts`
on that directory before each role's first work pass and after any upstream
change. A failure blocks consumption of that handoff, not permission to diagnose
the failed file. Never auto-repair the manifest or frozen review to make it pass.

The manifest maps five original absolute paths to byte-preserved project-owned
snapshots. Verify every hash, preparation identity, review/release path binding,
review status and plan digest. No source files under `oneoffs/` are required at
runtime. The checker proves consistent reviewed intake only: it does not prove
live facts, Apply permission, feasibility of unmade decisions or implementation
approval. Project/HRL evidence cited by the snapshots still requires currentness
checks when used.

## Role composition

## Orchestration profiles

The default `light` profile uses the light adapters: settled research/Expert
decisions, grouped project changes, targeted source validation, and an
Evaluator design/idempotence verdict. A light `ready` artifact approves only
the declared source package; it never asserts host deployment or live proof.

The opt-in `full` profile uses the existing full adapters and retains target
identity, governed live discovery, Apply authorization and runtime/deployment
evidence. A parent must name `full`; no light run may silently acquire those
requirements.

| Role | Entry and additional behavior | Protected boundaries |
| --- | --- | --- |
| Implementer | Read project adapter, then load the mature global Implementer and its required children. Convert S1–S6 into owning Ansible work and receipts; consume current evaluator feedback. | Never author evaluator verdicts, edit frozen upstream, self-approve, poll or launch peers. |
| Evaluator | Read project adapter, then load the mature global Evaluator and its required children. Review actual changed owners, evidence, authorization, full obligation coverage and freshness. | Never implement fixes or promote preparation review to implementation sign-off. |
| Coordinator / Researcher | On a bounded return request only, use their existing preparation skills with separate request outputs. | Do not reopen the whole project or overwrite imported upstream. |
| Observer | Read-only runtime and governed-artifact snapshots with brief observations. | No feedback/sign-off, inbox consumption, routing, process starts/stops or edits. |
| External operator/orchestrator | Assign invocation IDs/session slots, wake roles after durable events and own lifecycle. | Never replace role judgment with broker counters or helper status. |

The [role operating contract](../role-operating-contract.md) defines the
shared decision and consultation behavior for this beta adapter. It is
normative for inputs and boundaries; this contract remains authoritative for
artifact identity, runtime ownership, and scheduling behavior.

## Identity and durable handoffs

Use `pipeline_id`, `task_id` and `campaign_id` from `upstream-manifest.json`;
`stage_id: implementation`. Preserve the upstream preparation `run_id` as
`upstream_run_id` and its plan digest as `upstream_plan_sha256`.

Each invocation has a unique `run_id` (operator-supplied, otherwise
`<campaign-id>-<role>-<UTC timestamp>-<random suffix>`). Re-entry is a new
invocation, not a new campaign. Share the campaign across both agents; do not
copy the preparation session ID into the implementation run. Include this
frontmatter on new handoff/verdict/receipt/request Markdown:

```yaml
---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: "<unique invocation id>"
role: "implementer | evaluator"
event_id: "<run-id>:<monotonic event sequence>"
responds_to: "<exact prior artifact path or null>"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: "<mature artifact contract status>"
next_actor: "Implementer | Evaluator | operator | none"
mode: manual
session_id: null
owner_manifest_path: null
expert_recommendation_path: null
decision_authority_profile_path: null
---
```

Use the mature timestamped filenames. For evaluator artifacts, name the exact
Implementer outbox and the reviewed source/receipt state in the body (Git HEAD,
dirty scope and relevant file digests); unchanged filenames or a prior `ready_*`
do not establish freshness. New review-relevant implementation changes reopen
review; observer/status noise does not. IDs and metadata are integration data,
not native automatic skill activation or a scheduling engine.

`expert_recommendation_path` and `decision_authority_profile_path` are optional
but paired inputs. When supplied, both roles read the exact versioned paths;
Implementer applies a profile-adopted technical default within scope and
Evaluator checks fit. A lab profile may auto-adopt a recommendation into the
campaign plan, but never bypasses target identity, evidence, receipt, or
Evaluator requirements. A product profile routes the same recommendation to a
narrow human decision wait.

## Turn routing and larger-orchestration seam

| Durable event | Next owner | Meaning |
| --- | --- | --- |
| Verified preparation release + user activation | Implementer | Begin the practical campaign; no automatic Apply permission |
| `review_ready_for_evaluator_*` | Evaluator | Review the exact changed state |
| `feedback_for_review_by_evaluator_*` | Implementer | Correct actionable scoped findings |
| `waiting_for_review_by_evaluator_*` | Operator/orchestrator holds | No new reviewable state; do not busy-loop |
| Fresh `ready_for_review_by_evaluator_*` | None / parent closeout | Whole S1–S6 scenario approved by Evaluator, not merely one slice |
| Bounded research request | Coordinator → Researcher | Answer a decision needed for this campaign, then return to requesting role |

For research return, the requester writes `coordination/requests/<event-id>.md`
using a filesystem-safe event ID, with slice, exact question, known evidence,
acceptance test and `return_to` role/artifact. The parent routes the existing
Coordinator/Researcher skills with a fresh preparation output directory under
that request and a unique run ID. Result: a separate brief/review/release with
`responds_to` pointing back to the request. The requester verifies identity/hash
and records disposition; original upstream snapshots stay immutable. Minor
module lookups can be done by the current role via the Ansible knowledge gate.
Research does not grant Apply authority or create whole-campaign sign-off.

For the active Light runtime, this route is now executable as an optional
sidecar rather than merely a documented escalation: pass the request's absolute
path as `consultation_request_path`. The parent adds held On-site Expert and
Researcher slots, runs one artifact pass in that order, writes their responses
under `coordination/consultations/`, and supplies those paths to the normal
Implementer/Evaluator turns. It is bounded to the named fork and does not
restart preparation or delay unrelated source owners.

Classify before routing: an in-scope evidence-backed Expert recommendation is
materialized as a plan decision under `lab_recreatable_autonomy`; do not create
a human wait or research loop merely to reconsider it. Route only a named
technical doubt to Expert, a named stale/missing fact to Researcher, an exact
identity gap to read-only discovery, or a source/runtime contradiction to a
documented exception and Evaluator review. Under `product_governed`, the same
consequential choice remains a narrow operator decision.

In managed mode the external harness must provide `mode: orchestrated`, fresh
`session_id`, run ownership manifest, live role→slot mapping and parent runtime
observation. Resolve null-peer CodexDriver slots using `to_slot_id`. Optional
`signal_done`, `submit_feedback`, and `approve` mirror durable role events only;
the operator must not signal `approve` before the Evaluator's evidenced whole-
campaign verdict. Deduplicate by event ID and exact artifact content digest;
never schedule parallel writers for the same role/campaign. Stop on unchanged
waiting/terminal errors; use the existing bounded lifecycle/watchdog helpers.

The [parent orchestrator skill](skills/paired-plan-orchestrator-beta/SKILL.md) and
[`run-implementation.ts`](../runtime/run-implementation.ts) now provide the
preferred one-chat implementation loop, with parent progress observation and
owned runtime cleanup. Do not point the preparation-only `run-preparation.ts`
at this campaign. In two ordinary chats, manual launch/re-entry remains a
fallback: start Implementer, invoke
Evaluator after an outbox, then use `Continue one pass on the same campaign`
after feedback. Idle chats cannot autonomously observe or wake one another.

In this managed implementation runner, inactive slots are held so approval or
other broker messages cannot wake the Implementer outside a parent-dispatched
pass. The Evaluator signals approval of the Implementer only after writing a
fresh whole-campaign ready artifact. Both are checked before successful teardown.
Research return requests remain opt-in parent escalation, not automatic broad
preparation. The Light parent can launch the bounded Expert/Researcher sidecar
only when a named `consultation_request_path` is supplied.

## Runtime and cleanup

Dashboard: http://127.0.0.1:7900 (report observed status, not assumed uptime).
Manual role work does not require a team/session/dashboard. A dashboard may be
shared or MCP-managed independently of this campaign; preserve it. Runtime
failures are not plan-quality findings unless they prevent required evidence.

Only an explicitly activated runtime owner uses `multiagents-runtime-operator`
to start/recover/stop processes, recording unique IDs and exact PID/start-time
ownership. Roles consume parent observations; the Observer may invoke `observe`
only. No process is owned merely because it is old, parentless, or on port 7900.
After completion, the runtime owner inventories exact leftovers and offers user
cleanup while preserving skills, source plans and durable evidence. Abort cleanup
uses existing ownership/authorization immediately; it does not wait for an offer.
When no runtime was launched, say so—do not invent cleanup work.

## Scope discipline

Apply knowledge to the work in scope. A finding is blocking only when tied to a
campaign acceptance criterion, correctness/safety of a selected change, or a
missing authority/target decision. Put adjacent improvements in optional notes.
The Ansible librarian/knowledge resources are available through HRL and the
project Ansible knowledge gate; do not turn consultation into a project-wide audit.
