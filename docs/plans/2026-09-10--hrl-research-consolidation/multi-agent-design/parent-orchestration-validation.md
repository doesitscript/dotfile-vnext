# Single-parent orchestration validation — 2026-09-11

## Outcome and next action

The parent launcher can run the Implementer/Evaluator pair, route corrections,
observe progress, resume a retained campaign and clean up its own runtime.
Use the first prompt in [launch-directory.md](../launch-directory.md). A separate
Observer chat is optional. The mature global roles remain unchanged; project
adapters compose them and preserve their judgment/artifact ownership.

This verifies the orchestration transport on an isolated fixture, **not a storage
deployment or full model compliance with the mature storage skills**. The real
campaign intake passes and is ready to begin discovery/implementation. S1–S6
are still pending; specific live Apply targets and authority remain gated.

## Verification

- 64 Bun tests pass: preparation 10, implementation intake 10, finite-pass and
  causal resume 36, evaluator-only thread tool policy 8.
- All four project skill folders pass `skill-creator/scripts/quick_validate.py`.
- Real campaign intake reverified the upstream plan digest
  `2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c`;
  checker explicitly grants neither Apply authority nor implementation approval.
- Local runtime: multiagents 0.5.0, Bun 1.4.0, Codex 0.153.4. Model/effort were
  inherited, not selected or overridden by the runner.

## Live smoke evidence

Retained fixture root:
`/Users/joshc/develop/oneoffs/paired-parent-smoke-kYIPPF`.
Each run contains `result.json`, events, ownership and cleanup observations;
created sessions also have `archived-session.json`.

| Run | Evidence-backed outcome |
| --- | --- |
| run-1 | Rejected task writes outside runtime cwd; incomplete, archived/cleaned. Fixed explicit project/plan write scope. |
| run-2 | Stale peer target rejected; incomplete, archived/cleaned. Fixed explicit driver slot target. |
| run-3 | Real Impl → feedback → corrected Impl → Eval-ready cycle (four artifact passes, eight completed turns including initialization). Final peer approval denied by tool policy; correctly incomplete, archived/cleaned. |
| run-4 | Evaluator-first restart; per-tool approval policy worked, but peer reported no active session. Correctly incomplete, archived/cleaned. |
| run-5 | Evaluator-first restart after explicit peer session/slot binding: **approved**, five completed turns; Implementer slot 35 `task_state: approved`; session archived and all 68 tracked process identities absent after cleanup. Finished 05:48:12 UTC. |
| run-6 | Retained ready artifact detected without launching a team: `prior_signoff_present`, zero model turns. This is not a fresh source or transport verdict. |

Successful session:
`paired-runtime-fixture-implementation-paired-parent-smoke-20260911-e-ppid84117`.
Final artifact: `ready_for_review_by_evaluator_2026-09-11T05-47-00Z.md`, digest
`4ab8b4468d9829275b3241a2c411ff127e4afbb32fd92469cf0e3e51485e46cf`.
Fixture content independently checked by Evaluator: exact `verified` plus newline.
The final corrected runtime was tested on the Evaluator-first continuation;
the four-pass correction loop was demonstrated in run-3, not rerun from empty
after the final session-binding fix. No result is labeled a real storage sign-off.

## Runtime safeguards and discovered side effect

The parent owns scheduling, not approval. Successful terminal turns and exactly
one new identity-bound role artifact are required; old/opposing events cannot
be overwritten. Inactive slots stay held, including Implementer during approval.
Timeouts, owner identity, a duplicate-run lock, interruption watchdog, explicit
archive checks and exact-owned process cleanup remain enforced. Recovery preserves
campaign work. Prior verdicts never substitute for fresh source/receipt checking.

The installed launcher's `ensureMcpConfigs` rewrites global Codex configuration
(and may update Gemini configuration). **Earlier smokes reached that behavior
before it was identified**; there is no pre-smoke byte snapshot establishing the
exact content delta. No guessed restoration was performed. The corrected preload
suppresses those exact global writes and supplies per-thread peer configuration.
Before/after run-5 global-file SHA-256 values were identical:

- `~/.codex/config.toml`: `16a5e2e2fbc80e9bfad46b3f1e4f218e3ad1be65f9aacb7d13104f64452dc970`
- `~/.gemini/settings.json`: `d4454151071506c74f90d6399f29efb4f2c94082c9acb88666065d0ab0ee4d58`

Only the Evaluator's intended final `approve` tool is permitted through a
thread-local setting. Other tool permissions and infrastructure authority are
unchanged; managed policy still applies. See the [runtime instructions](runtime/implementation-runner.md)
for the official setting and installed-protocol basis. Explicit CLI identity
and driver mode prevent fallback to an unscoped standalone peer connection.

Dashboard: http://127.0.0.1:7900 was reachable and reused during the final live
run. It is shared/pre-existing, not owned by that run; it was left running.
Runtime directories and archived test sessions are retained as evidence. Offer
the user scoped cleanup of those leftovers; preserve this receipt, skills, plan,
upstream snapshots and shared services. No actual storage Apply was performed.

## Follow-up interruption correction

The first real storage campaign run (`hrl-storage-implementation-beta-01-parent-
20260911t060422z`) was interrupted by the installed upstream's 60-second
`lastNotificationActivity` watchdog during an active Implementer pass. The
parent guard rejected the interrupted turn, preserved the partial repository
work, recorded `status: incomplete`, and its registered owner/children were
later observed stopped. No governed review handoff was produced. The runner now
uses a session-local interrupt guard and retains its own finite 900-second pass
and 5,400-second run limits. `implementation-interrupt-guard.test.ts` verifies
the narrow interception. Resume only through the original parent with fresh run
identity and owner-checked `--recover-lock`; do not discard the unreviewed
`playbooks/report_storage.yaml` change.

The subsequent focused fast suite contains 68 tests: the original 64, two
idle-interrupt guard cases, and two private-turn-timeout alignment cases. This
is unit-level proof of the narrow interception and alignment; the next
owner-checked real campaign resume is the runtime confirmation.

Each parent-managed stop now also requires an append-only, timestamped receipt
under `observer/observation-reports/`. The receipt records the stop trigger,
gate state, named fix files and validation, owned-runtime disposition, and next
action. This prevents untracked run-specific fixes while keeping Observer
reports separate from evaluator approval.

## Follow-up pass-timeout correction

The fresh recovery run `hrl-storage-implementation-beta-01-parent-20260911t062202z`
proved that the earlier idle-watchdog correction worked, but its active
Implementer turn reached the installed CodexDriver's private 600-second default
before the configured 900-second parent pass limit. The run stopped incomplete,
with no governed handoff or approval. The session-local preload now aligns that
private driver timeout with `pass_timeout_seconds`; the parent remains the
finite 900-second pass and 5,400-second overall stopping authority. No live
storage mutation occurred. See the timestamped Observer receipt for exact run
evidence and recovery direction.
