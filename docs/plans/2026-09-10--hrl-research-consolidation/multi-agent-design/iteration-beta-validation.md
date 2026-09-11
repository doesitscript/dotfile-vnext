# Beta integration validation — 2026-09-11

Historical authoring receipt. The subsequent single-parent runtime and isolated
live tests are recorded in [parent orchestration validation](parent-orchestration-validation.md);
use the first block of the [launch directory](../launch-directory.md) now.

## Result

The three project adapters and launch prompts are ready for operator-started
implementation/evaluation and optional read-only observation. This is authoring
and intake validation, **not storage Apply or mature Evaluator sign-off**.
Global role sources were not changed. No implementation agents or services were
launched. The [prior receipt](validation-2026-09-11.md) covers the actual
Coordinator/Researcher run; its five outputs are now byte-preserved inside the
project and independently rechecked by this iteration's intake checker.

## Fresh checks performed

| Check | Result |
| --- | --- |
| `bun test .../runtime/check-implementation-handoff.test.ts .../runtime/artifacts.test.ts` | **20 passed, 0 failed**: 10 intake tests + 10 existing preparation tests |
| `bun .../runtime/check-implementation-handoff.ts .../implementation-campaign` | Intake verified; explicitly grants neither Apply authority nor implementation approval |
| `skill-creator/scripts/quick_validate.py`, through `global-skills/bin/gs-env`, for each adapter | All three valid |
| Companion YAML inspection | Correct role/approval/read-only boundaries, `$skill` prompts and resolved contract/checker paths |
| Documentation link checks | Local links resolve; checked again after final edits |
| Mature `resolve_plan_workspace.py --project-root ... --plan-dir ... --json` | Campaign resolves correctly; no bootstrap directory needed |
| `git diff --check` | Passed; unrelated changes preserved |
| Runtime operator `observe` | `2026-09-11T05:08:54.363012+00:00`: broker healthy, dashboard unavailable; no campaign session selected or state changed |

Intake rejection tests cover changed bytes, cross-run review, stale review of an
updated plan, failed review, wrong plan path, missing separate authorization,
wrong release-review binding, redirected snapshot mapping and pipeline mismatch.
These tests do not prove model compliance with the new prompts.

## Source readiness and remaining implementation work

The source-reviewed plan is discovery-first, not an existing one-command storage
deployment. All S1–S6 obligations remain visible. `report_storage.yaml` needs an
exact verified limit; the sibling storage-upgrade plan still labels upgrade
pending. Its proposed capacities/device names are not live facts. The existing
`k3s_storage_prep` role is pre-install and deletes destination directories; the
campaign explicitly prohibits using it as a live migration shortcut. Existing
Hyper-V relocation and vLLM/PVC surfaces are candidate owners, not proof of a
second-data-disk capability.

The next Implementer performs live discovery, builds owning Ansible changes,
records actual authority/targets/backup/decisions, then applies and verifies
authorized slices. The Evaluator independently checks implementation evidence.
Use the [three launch prompts](agent-prompts/implementation-beta-prompts.md) on
`../implementation-campaign/`. Ordinary chats require explicit re-entry; this
beta defines identity/events/research returns but does not ship the full later-
stage scheduler or claim an end-to-end managed implementation run.

## Runtime and cleanup

Dashboard: http://127.0.0.1:7900 — unavailable at the observation above.
Shared/pre-existing processes were observed, not adopted or changed. There are
**no new process/session leftovers from this iteration**. Future runtime owners
must offer scoped leftover cleanup while preserving plans, skills and evidence;
shared/MCP-managed dashboards are not automatically campaign-owned.
