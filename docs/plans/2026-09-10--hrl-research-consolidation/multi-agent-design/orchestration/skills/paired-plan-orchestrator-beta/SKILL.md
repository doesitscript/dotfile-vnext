---
name: paired-plan-orchestrator-beta
description: Run a prepared implementation campaign from one parent chat through the multiagents MCP runtime. Launch and alternate the existing Implementer/Evaluator adapters, report progress, handle bounded stops and owned cleanup. Use when the user wants one chat to manage the pair rather than manual role re-entry.
metadata:
  status: beta
  workflow_id: evaluator-implementer-loop
  role: parent-orchestrator
  scope: implementation-stage
  depends_on_skills: multiagents-runtime-contract, multiagents-runtime-operator
---

# One-chat paired plan orchestrator

You are the parent operator, not the Implementer or Evaluator. Run their existing
finite-pass skills through the supplied runner and remain the user's single
point of contact. You provide lightweight observation; a third Observer chat is
optional, not required. Do not replace evaluator judgment with your own verdict.

Default to `orchestration_profile: light`: grouped source-first changes,
targeted validation, and design/idempotence review. Select `full` only when
explicitly requested for live infrastructure proof/Apply or when a named
target/authority contradiction requires it. Never silently escalate a light run.

## Inputs and early output

Resolve absolute `project_root` and `plan_dir`. If supplied the source plan folder
and its `implementation-campaign/upstream-manifest.json` exists, use that child
as `plan_dir`. Otherwise require the supplied campaign's `upstream-manifest.json`.
The runner accepts any matching campaign identity; its current default role
adapters are storage-specific. Do not present them as arbitrary-domain skills.

Read the campaign README and
[shared integration contract](../../implementation-beta-contract.md). Load
`/Users/joshc/develop/global-skills/skills/documentation/multiagents-runtime-contract/SKILL.md`
and `/Users/joshc/develop/global-skills/skills/implementation/multiagents-runtime-operator/SKILL.md`,
including its lifecycle/start/recovery references before starting processes.
When `parallel_preflight_jobs` is requested, first load the adjacent
[`parallel-work-admission-experimental`](../parallel-work-admission-experimental/SKILL.md)
skill. Give the runner only independent read-only candidates; report its
admission receipt and continue serially even when all candidates are rejected.
After a research/On-site Expert packet has stabilized an implementation direction,
load [`batch-change-staging-experimental`](../batch-change-staging-experimental/SKILL.md)
to decide whether a no-commit grouped source batch is worthwhile. Do not use it
for a live target, shared mutable owner, approval, or unresolved design fork.
Also read the [role operating contract](../../role-operating-contract.md)
and any paired Expert recommendation / decision-authority profile named by the
campaign. Treat them as canonical inputs, never as private-chat context.
When `coordination/research-application/` exists, identify the newest applicable
bootstrap packet and require both adapters to read its research-to-decision and
plan-materialization artifacts before their first S3–S5 pass. This is planning
input, not a separate runtime role to launch or a reason to repeat research.

Early in the chat, report the plan folder, your parent role and
`Dashboard: http://127.0.0.1:7900 — <observed status>` using operator observe.
Immediately after the runner returns its `session_id`—before scheduling the
first role pass—put the runner's exact `watch-implementation-output.sh` command
at the top of the parent response in a fenced `bash` block. It must contain the
returned session ID and fresh run directory, use `--interval 5 --clear`, and
state that it is read-only and `Ctrl-C` stops only the monitor. Do not replace
it with raw curl JSON. The monitor polls `/slots/list` and joins that status with
the durable `events.jsonl`; the web dashboard's `driver-mode MCP adapter` label
is adapter metadata, not a worker transcript.
State that you will manage both roles and report meaningful changes here. Do
not tell the user to open two more chats. Link the plan's launch directory as
an optional manual fallback, not another required step.

## Start or resume the pair

1. Read [the runner instructions](../../../runtime/implementation-runner.md).
   Validate the reviewed intake. Inspect any campaign `.paired-run-lock.json`;
   never start a duplicate writer. If an existing owner is alive, monitor that
   exact run instead. If interrupted, use exact owner-manifest cleanup and
   `--recover-lock` as documented; preserve all campaign work and prior evidence.
2. The user's request to run this parent authorizes the named team's runtime
   and dashboard startup. Recover the broker through the runtime operator if
   needed; never run `multiagents setup` or overwrite client configuration.
   Reuse shared/MCP-managed dashboards; do not adopt or stop them.
3. Create a unique run ID and private runtime container under the project's
   chosen runtime location (on this machine, `/Users/joshc/develop/oneoffs/`).
   Copy the [config example](../../../runtime/implementation-config.example.json)
   into it, filling actual plan/project paths, an unused child `run_dir`, a
   verified installed Codex binary and the existing runtime-operator skill root.
   Preserve configured model/effort. Do not set `fixture_mode` on real work.
4. Run `bun <absolute runtime/run-implementation.ts> <absolute config.json>`.
   This launches a parent-owned MCP orchestrator and exactly two Codex workers,
   then schedules their turns. It does not merely print manual prompts. Use the
   execution tool's returned session ID to stay attached and collect output.
5. Monitor events/checkpoints and role artifacts while this parent invocation
   is active. Poll with waits no longer than 60 seconds and give short progress
   updates at least each minute. Show actual session/run/manifest paths and
   dashboard health. Never leave a live controller running and claim this
   launch task is finished just because the shell yielded a session ID.

## Decisions, completion and cleanup

The runner advances Implementer → Evaluator → correction → Evaluator without
user chat-hopping. It ends on an evidenced Evaluator ready artifact plus peer
approval, an operator-wait artifact, a finite pass/time limit, or runtime error.
An unfinished campaign is not completed merely because a controller stopped.

Read `result.json`, the last role artifact and cleanup evidence before reporting:

- `approved`: report the Evaluator's scoped outcome and evidence, not your own
  independent infrastructure approval.
- `prior_signoff_present`: report only the retained Evaluator verdict; no team
  was launched. This is not fresh verification or proof that a prior managed
  run completed its approval transport and cleanup. Inspect prior runtime
  receipts separately. Compare the verdict's reviewed source/receipt state
  with current state; if changed or freshness cannot be established, record
  that evidence and use `reopen_review: true` for an Evaluator-first run.
  Never upgrade a retained verdict into fresh whole-campaign completion.
- `waiting_for_operator`: ask only the exact unresolved target/policy/authority
  decision; do not rerun an unchanged blocker. Safe independent work should have
  been pursued by the Implementer before this stop.
  On later user resolution, record the concrete answer in the campaign and pass
  that file as `operator_resolution_path` in a fresh config.
- `pass_limit_reached` / `incomplete`: report the concrete remaining work or
  runtime failure. A later invocation starts a fresh run on existing campaign
  artifacts, with owner-checked lock recovery if needed; never reset the plan.

Runtime startup is not permission for infrastructure Apply. The Implementer
must honor recorded user authority and verified storage targets/rollback. The
parent must not select a disk, approve deletion, waive missing evidence or claim
research-ready means implementation-complete.

## Consultation and profile routing

Before declaring a wait or dispatching a return request, classify the blocking
fact. Under `lab_recreatable_autonomy`, continue with an in-scope,
evidence-backed Expert Best recommendation (or Preference whose stated
assumptions hold) after it is materialized in the campaign; retain all identity,
test, receipt, and Evaluator gates. Do not wait for a human merely to select
that technical default. Under `product_governed`, route the same consequential
choice to the smallest human decision.

Dispatch a Resident Expert only for a named technical fork and a Researcher
only for a named stale/missing evidence gap. In the Light runner, write a
bounded request under `coordination/requests/` and supply its absolute path as
`consultation_request_path`: the optional
`resident-expert-researcher-sidecar-light-beta` creates one held Expert slot,
then one held Researcher slot, and returns both concise artifacts to the normal
pair. An exact target-identity gap needs the smallest read-only probe. A
source/runtime conflict needs a recorded exception and Evaluator review. None
of these routes authorize broad re-planning or automatic launch of the earlier
preparation pipeline.

On interruption, stop this exact owned run immediately using its manifest. On
every automatic, error, limit, waiting, or user-requested stop, write one
concise timestamped receipt at
`<plan_dir>/multi-agent-design/observer/observation-reports/orchestration-stop-YYYY-MM-DDTHH-MM-SSZ.md`
before presenting recovery instructions. It must identify the campaign/session/run,
trigger, gate/artifact state, process disposition, every fix file and its
validation, and next action. This is append-only; never overwrite an earlier
report or hide a one-off runtime fix outside the plan packet. If no fix was
made, say so explicitly. On completion, verify its workers/watchdog stopped and
session archived.

Before presenting or performing cleanup, follow the
[default end-of-run retention contract](../../../execution-record-retention-default.md):
materialize the plan-owned execution record, verify its checksums, and write a
continuation checkpoint whenever no Evaluator-approved outcome exists. Then
present—not execute—an exact owned cleanup candidate list. Cleanup requires a
separate explicit user choice. Retain skills, plan, receipts, upstream evidence,
and execution records. Preserve shared services.

This skill restores single-parent implementation-stage orchestration. It can
optionally start the bounded Expert/Researcher consultation sidecar from a
named request; it does not automatically restart the earlier full preparation
stage or future roles.
