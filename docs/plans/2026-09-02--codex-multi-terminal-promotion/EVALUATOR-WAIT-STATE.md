---
title: Evaluator loop contract
plan: 2026-09-02--codex-multi-terminal-promotion
status: evaluator-signed-off
monitor_until: complete
sign_off_file: ready_for_review_by_evaluator_simple_2026-09-02T112907.md
sign_off_at: 2026-09-02 11:29 America/Chicago
background_watcher: docs/plans/2026-09-02--codex-multi-terminal-promotion/scripts/watch_evaluator_folder.sh
agent_folder_watch_only: true
last_implementer_refresh_at: 2026-09-02 11:36 America/Chicago
last_evaluator_refresh_at: 2026-09-02 11:29 America/Chicago
---

# Evaluator wait state

## Folder under watch

`docs/plans/2026-09-02--codex-multi-terminal-promotion/`

## Completion condition

Work is not closed until an evaluator-authored file in this folder clearly states
the promotion packet and related corrections are satisfactory, approved, and done.

Until that file exists, remain in wait/apply-corrections mode.

## Files seen

| File | Role | Status |
| --- | --- | --- |
| `AI-CORRECTION-EVALUATION.md` | Plan correction directives | present |
| `AI-DRAFT-SKILL-FAMILY-EVALUATION.md` | Draft skill family correction directives | present |
| `ready_for_review_by_evaluator_simple_2026-09-02T112907.md` | Final evaluator sign-off | **approved** |

## Closeout

Evaluator signed off at 2026-09-02 11:29 America/Chicago. Promotion packet corrections complete; folder watch can stop.

**After-action report:** [AFTER-ACTION-REPORT-skills-and-evaluator-implementer-loop.md](AFTER-ACTION-REPORT-skills-and-evaluator-implementer-loop.md)  
**Framework docs:** [evaluator-implementer-loop/README.md](../../codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/README.md)

## Agent actions when new evaluator files land

1. Re-list this folder and read any new evaluator, feedback, review, or ready files.
2. Apply correction directives in repo code and docs before claiming progress.
3. Re-run project skill validators when skill packs changed.
4. **Do not** run `evaluator_simple_loop.sh` or write evaluator feedback/ready files — that is the evaluator's job.
5. Wait for `ready_for_review_by_evaluator_simple_<timestamp>.md` from the evaluator before closeout.

## Implementer status (2026-09-02 11:36 America/Chicago)

**Loop closed.** Evaluator sign-off: `ready_for_review_by_evaluator_simple_2026-09-02T112907.md` (`decision: approved`, all 13 checks pass).

Fresh verification this turn:

- `present-state OK` — bashrc drops present; `cx-deep-smoke` defined
- `shell_config` generic `bashrc.d` sweep removed
- `validate_metadata.py` / `validate_skills_catalog.py` — pass

No further corrections required for the promotion packet per evaluator-simple.

## Monitoring note

**Agent** watches for new evaluator files:

```bash
docs/plans/2026-09-02--codex-multi-terminal-promotion/scripts/watch_evaluator_folder.sh
```

**Evaluator** (operator-owned; agent does not run or drive):

```bash
docs/plans/2026-09-02--codex-multi-terminal-promotion/scripts/evaluator_simple_loop.sh
```

- Evaluates immediately on start, then sleeps for the configured interval.
- Default cadence is every 3600 seconds unless `EVALUATOR_SIMPLE_INTERVAL_SEC` overrides it.
- Writes `.evaluator-simple-loop.pid`, `.evaluator-simple-loop.state`, and `.evaluator-simple-loop.log`.
- Stops only after writing a satisfactory `ready_for_review_by_evaluator_simple_<timestamp>.md` file.

### Persistence note

- `scripts/com.joshc.codex.multi-terminal-evaluator-simple.plist` was created for
  a durable hourly `launchd` run.
- A matching file was installed under `~/Library/LaunchAgents/`.
- `launchctl bootstrap/load` and `crontab` registration were blocked from this session,
  so scheduler registration is **not verified active** here.
- The latest evaluator truth is in the timestamped feedback files, especially
  `feedback_for_review_by_evaluator_simple_2026-09-02T112343.md`.

## Closeout stamp

Filename pattern:

```text
ready_for_review_by_evaluator_simple_<YYYY-MM-DDTHHMMSS>.md
```
