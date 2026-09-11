---
title: Middle-role implementation and real-plan validation
observed_at: 2026-09-11T04:08:30Z
status: preparation-implemented-and-tested
dashboard_url: http://127.0.0.1:7900
run_id: hrl-preparation-20260911-r2
session_id: hrl-research-consolidation-preparation-ppid42220
downstream_activation: authorized_separately
---

# Result

The Coordinator and Researcher completed the current-plan preparation stage
through the installed multiagents MCP: route, research, compose, independent
review, one correction, re-review and release. The controller verified matching
artifact identity and plan SHA-256, archived its session, and stopped all
manifest-owned children, including its dashboard and watchdog. The shared
broker and existing chat peers were preserved. No infrastructure was changed,
no downstream roles were started, and no source plan reset is required.

This supersedes the earlier authoring-only receipt. `draft` remains in the
requested skill names; it does not mean the middle-stage implementation is a
stub. Whole-pipeline rollout remains a future integration scope.

## Deliverables and obligations

| ID | Requirement | Implementation and evidence | Result |
| --- | --- | --- | --- |
| O01 | Identify and safely stop run leftovers | Global runtime operator: durable run ID, owner PID identity, child PID/start-time/command ledger, protected broker/IDE, independent owner-death watchdog; final inventory below | Passed |
| O02 | Finish both middle roles and prompts | Two role SKILL.md files, companion orchestration metadata, shared execution contract and explicit manual followups linked from START-HERE.md | Passed |
| O03 | Reuse project/HRL guidance | Existing evaluator/implementer registry, HRL multiagents guidance, source-plan inventory, librarian advisory, Ansible knowledge gate and current repository owner candidates; actual readiness brief lists evidence | Passed |
| O04 | Support larger orchestration without activating it | Versioned pipeline/stage/task/run envelope, optional hash-checked upstream handoff, runtime/handoff.json, capability.yml and framework phase-scoped-plan-preparation pattern | Passed for preparation boundary; future roles unchanged |
| O05 | Run the roles on actual source material | Isolated r2 output with real source/project/HRL roots; seven successful work passes across two slots, including correction | Passed |
| O06 | Produce independently reviewed actionable handoff | Researcher caught missing systemd discovery; Coordinator corrected it; re-review and release bind the exact plan hash | Passed; first work is read-only discovery, not guessed live mutation |
| O07 | Make interruption/restart visible and bounded | 20-second heartbeat, terminal-status guard, 300-second work-pass/1500-second campaign deadlines, successful-pass/upstream hash receipts, active-owner resume rejection, completed-run no-op resume | Passed tested cases; limitations below |
| O08 | Offer scoped cleanup and preserve work | Sessions archived, processes stopped, sources/skills/evidence retained; exact optional inventory below and Coordinator release includes cleanup offer | Passed; optional deletion awaits user choice |

## Actual run and artifact proof

Evidence root:
`/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2`.

| Artifact | Path under evidence root | Verification |
| --- | --- | --- |
| Routing | coordination/current-phase-routing.md | research_requested |
| Readiness brief | research/current-phase-readiness-brief.md | ready; scoped evidence and remaining live discovery |
| Implementation plan | handoff/current-phase-implementation-plan.md | Apply/Verify/Undo, ordered slices, acceptance criteria, three diagrams and inventory |
| Independent review | research/current-phase-plan-review.md | plan_review_passed after F-01 correction |
| Release | handoff/current-phase-release.md | ready_for_implementation; no downstream authority |
| Machine handoff | runtime/handoff.json | exact plan/review/release paths and reviewed digest |
| Completed-pass receipts | runtime/artifact-receipts.json | successful terminal plus artifact/upstream hashes |
| Lifecycle result | runtime/result.json | passed; source_implementation_run=false |
| Process proof | runtime/processes-42220.json, cleanup.json, final-process-observation.json | stopped; remaining=[]; all child identity_live=false |
| Event/driver evidence | runtime/events.jsonl, orchestrator.log | finite pass completion, guard terminal/usage events, archival and stop |

Final plan SHA-256:
`2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c`.

Release SHA-256:
`a3866cf34b47fb0ef4b6ace8eddd09d405f71c82511d5ed06f116341fa8a4a69`.

The plan itself retains `awaiting_plan_review`: release is a separate artifact
so reviewing it never changes the reviewed bytes. Read release plus matching
review/hash to determine readiness, not the plan's earlier authoring status.

Event times (UTC): team created 03:59:12; dashboard healthy 03:59:47; routing
completed 04:01:28; research 04:03:31; initial plan 04:04:47; changes requested
04:05:33; revision 04:06:12; review passed 04:07:09; release verified 04:07:58;
session archived 04:07:58; cleanup and final success 04:08:08.

The real run used installed multiagents 0.5.0, Bun 1.4.0, and explicitly selected
the existing Cursor Codex 0.153.4 binary. No global model/configuration or
installed package source was changed. A per-process preload guards terminal
outcomes and suppresses unowned automatic UI launches; the reusable operator
owns the dashboard process instead.

## Tests and recovery verification

Fresh targeted checks:

```sh
# From global-skills
python3 -m unittest discover -s skills/implementation/multiagents-runtime-operator/scripts -p 'test_*.py'
MULTIAGENTS_GUARD_DISABLE_AUTO_INSTALL=1 bun test skills/implementation/multiagents-runtime-operator/scripts/codex_driver_guard.test.ts
bin/gs-env scripts/validate_skills_catalog.py

# From this packet
bun test runtime/artifacts.test.ts
bun run runtime/run-preparation.ts runtime/validation-config.json --resume
```

- Python lifecycle/operator tests: **22 passed**. Includes real benign parent
  termination/watchdog cleanup, unrelated-process preservation, PID-identity
  mismatch, wrong run identity and stopped-manifest race protection.
- Driver guard: **7 passed**, including failed/interrupted/missing terminal,
  stale success and transport exceptions.
- Artifact contract: **10 passed**, including changed plan, another run,
  missing metadata, failed review, unauthorized downstream activation,
  incomplete/mismatched pass receipts, upstream invalidation and diagram gate.
- Both role skills pass skill-creator quick_validate through `bin/gs-env`.
  Companion metadata uses explicit role, counterpart, inputs, artifacts,
  stage/contract and orchestration ownership; it is not a native scheduler.
- Catalog passes. Full global metadata validation still reports only two
  unrelated existing default-prompt errors in `multiagent-paired-review-designer`
  and `skill-to-paired-review-converter`; those were preserved. Advisory checks
  are non-blocking; optional skills-ref validation skipped because uninstalled.
- Global runtime bridge succeeded; runtime operator resolves to shared source
  in the client skill runtimes. It did not install these project-owned role
  drafts globally; the supplied prompts load their explicit paths.

Active-owner recovery test: while r2 was still running, the latest controller's
`--resume` exited 1 with `Previous owner still live` naming its exact manifest.
No second team was launched.

Completed recovery test: after teardown, the same command exited 0 with
`already_released` at 04:08:30 and no new team. It also exercised the current
project-diagram gate. The original `runtime/result.json` SHA-256 remained
`993dd694c111245e4952638e7fe98aee0d85a040b281d2d88f23adc0136762db`
before and after, preserving original session/owner provenance.

Earlier r1 completed the five-artifact content flow. Review then tightened the
diagram requirement and pass/resume receipts; r2 is the authoritative content
run. The latest completed-resume and active-owner guards were exercised
separately against r2. We did not deliberately SIGKILL the expensive real
content run: abrupt-owner cleanup was exercised with disposable real child
processes in the lifecycle tests, not falsely claimed as a full-model crash test.

## Runtime observation and optional cleanup

At 04:08:30 UTC: broker healthy with the two original chat peers; zero active
sessions; no orphaned runtime processes. Dashboard http://127.0.0.1:7900 was
intentionally stopped after testing. HTTP/data availability was verified during
the run; selected-session WebSocket/UI behavior was not separately tested.
Fresh manifest observation after the controller exited showed owner_alive=false
and no live recorded child identities.

Three archived session records remain from this task:

- `hrl-research-consolidation-preparation-ppid30559` — early slug-normalization
  check failure; session archived and owned processes stopped.
- `hrl-research-consolidation-preparation-ppid33133` — first content run.
- `hrl-research-consolidation-preparation-ppid42220` — authoritative r2 run.

Two isolated workspaces remain:

- `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r1`
- `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2`

Final operator question: **Clean up these archived test sessions and disposable
workspace material, preserving the reviewed handoff, source skills/plans and
durable evidence?** Do not remove a whole workspace until its retained artifacts
have been copied to an agreed durable destination and their links/hashes are
preserved. No session records or workspace files were deleted in this closeout.
The shared broker and current IDE/chat processes are not cleanup targets.

## Boundaries and remaining future work

The handoff is ready for the mature Implementer/Evaluator to begin its defined
discovery-first work when activated. It is not a claim that unknown storage
targets/policies have been decided or that a live infrastructure change has
passed the Evaluator. Future whole-pipeline scheduling, additional roles and
production rollout are outside this preparation-stage implementation.

Manual two-chat usage requires the explicit followups in the two prompts;
metadata alone does not wake agents. Automatic scheduling is supplied by the
tested controller. A fresh run requires a unique run ID/output root and an
already authorized healthy broker. Reboot recovery can require separate stale
broker-record archival after process reconciliation.

The process ledger is userspace identity protection, not a kernel-atomic
ownership primitive. Its watchdog cannot survive machine power loss or promise
capture of an instantly daemonized, never-registered child. Never broaden stop
to all process names or parent-PID-1 groups to hide that limitation.

Source guidance was checked locally in the HRL multiagents implementation guide,
vendor material and librarian advisory; the project's established paired-role
registry and Ansible gate; updated global lifecycle skills; and installed
orchestrator/CodexDriver/broker/dashboard code. The actual run's readiness brief
records the bounded storage/Ansible source map. Official
[Codex app-server documentation](https://developers.openai.com/codex/app-server/)
was used for terminal-event semantics; local driver evidence establishes the
installed behavior.
