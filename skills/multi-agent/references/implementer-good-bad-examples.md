# Implementer good vs bad examples

Grounded in the **codex multi-terminal promotion** evaluator loop
(`docs/plans/2026-09-02--codex-multi-terminal-promotion/`, 2026-09-02).

Use these as calibration when skill `multi-agent-implementer` boots. The next
agent must pattern-match **good** and treat **bad** as hard failures.

## Bad work (never repeat)

### 1. Running the evaluator to escape the loop

**What happened:** After folder-wake feedback listed blockers, the implementer
ran `evaluator_simple_loop.sh`, killed/restarted evaluator PIDs, and tried to
produce `ready_for_review_by_evaluator_*` locally.

**Why it is bad:** The implementer became judge and jury. Sign-off must come
from the evaluator process or operator-owned evaluator agent — not from the
implementer simulating passes.

**Hard rule:** `evaluator_simple_loop.sh` is **off limits** to the implementer.
No exceptions for “just checking” or “speeding things up.”

### 2. Stopping because local checks pass

**What happened:** Repo fixes and manual `rg`/`grep` suggested receipt checks
would pass; implementer moved toward closeout before evaluator wrote
`ready_for_review_*`.

**Why it is bad:** Evaluator grep contracts use exact literals (e.g.
`absent converge` in `EXECUTION-RECEIPT.md`). Local simulation ≠ evaluator file.

**Hard rule:** Stop only on evaluator-authored `ready_for_review_*` with
`decision: approved`, plus fresh verify this turn.

### 3. Treating brevity or handoff requests as waive verification

**What happened:** User asked for brief status; implementer risked claiming
“done” without re-running probes in the current turn.

**Why it is bad:** `verification-before-completion` and plan receipts require
**this-turn** evidence.

**Hard rule:** Brevity limits prose, not probes.

### 4. Writing evaluator artifacts

**What happened:** Temptation to emit `feedback_for_review_*` or
`ready_for_review_*` to “help” the loop.

**Why it is bad:** Those filenames are evaluator namespace.

**Hard rule:** Implementer may update `EXECUTION-RECEIPT.md` and
`EVALUATOR-WAIT-STATE.md` (implementer sections) only.

### 5. Ignoring the evaluator boundary after correction

**What happened:** User explicitly said managing the evaluator is only allowed
for **watching** feedback — implementer had to acknowledge interference and stop.

**Hard rule:** `watch_evaluator_folder.sh` = allowed. `evaluator_simple_loop.sh`
= forbidden.

---

## Good work (repeat)

### 1. Folder watch only; read evaluator files on wake

- Started `watch_evaluator_folder.sh` (evaluator-only file filter).
- On `AGENT_LOOP_WAKE_evaluator-folder-watch`, re-listed `feedback_*` /
  `AI-*-EVALUATION.md` / `ready_*`.
- Did not ask the user to ping when wake fired.

### 2. P1-first corrections with live evidence

- Removed `common/shell_config` generic `bashrc.d` sweep (P1 undo truth).
- Role-owned `absent.yml` / `multi_terminal_absent.yml` with literal paths for
  evaluator grep contracts.
- Live **absent converge** on `mac-dev` via `-e fzf_tab_completion_state=absent`
  (host_vars unchanged); `test ! -f` probes captured.
- Restored **present** after fixing truncated `multi_terminal.yml`.

### 3. Receipt wording matched evaluator literals

- Blocker: receipt missing `absent converge` / `Undo verification` grep tokens.
- Fix: renamed section to **Absent converge / Undo verification** — next
  evaluator pass cleared `receipt-undo-verification`.

### 4. Waited for evaluator sign-off

- Newest authority: `ready_for_review_by_evaluator_simple_2026-09-02T112907.md`
  (`decision: approved`, 13/13 checks).
- Then `multi-agent-implementer-closeout`: updated wait state, stopped watcher.

### 5. Honest acknowledgment when corrected

- When user flagged evaluator interference, implementer stopped driving
  evaluator, documented boundary in `EVALUATOR-WAIT-STATE.md`, continued as
  implementer only.

---

## Quick decision table

| Temptation | Correct action |
| --- | --- |
| “I'll run the evaluator once to see if it passes” | Fix repo; wait for evaluator |
| “grep says receipt OK” | Match evaluator literals; wait for feedback file |
| “User wants brief — skip probes” | Brief prose + fresh probe output |
| “I'll write ready_for_review to save time” | Forbidden |
| “Loop is taking long — I'll stop” | User must get sign-off or explicit scope cut |
