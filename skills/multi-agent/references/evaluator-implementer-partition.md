# Evaluator–implementer partition

A meditation on multi-agent work where **one agent implements** and **another
agent (or loop) evaluates**. This pattern showed up during the codex
multi-terminal promotion: an implementer fixed Ansible, docs, and live converge;
an evaluator-simple loop emitted timestamped feedback until a
`ready_for_review_by_evaluator_simple_<timestamp>.md` sign-off.

## Why this is a distinct workflow

Normal single-agent work collapses “did I do it right?” into the same turn.
Multi-agent correction loops **separate concerns**:

| Role | Owns | Must not own |
| --- | --- | --- |
| **Implementer** | Code, docs, playbooks, live apply/verify, `EXECUTION-RECEIPT.md`, `EVALUATOR-WAIT-STATE.md` (implementer sections) | Writing evaluator feedback/ready files; running `evaluator_simple_loop.sh`; declaring satisfactory because checks “should” pass |
| **Evaluator** | `feedback_for_review_*`, `waiting_for_review_*`, `ready_for_review_*`, `AI-*-EVALUATION.md` audits, automated check matrix | Mutating roles/playbooks to “fix” findings without implementer evidence |
| **Folder watch** (implementer tool) | Detect new/changed evaluator markdown; wake implementer | Acting as evaluator; re-running evaluator to force sign-off |

The failure mode we hit: the implementer **ran the evaluator** to chase
satisfactory output. That contaminates the loop — the implementer becomes judge
and jury. The fix is a hard boundary skill (`multi-agent-implementer-folder-watch`
+ prohibited behavior in every implementer skill).

## Artifacts and filenames

```text
docs/plans/<plan-slug>/
  AI-CORRECTION-EVALUATION.md          # durable correction directives (evaluator/audit)
  AI-*-EVALUATION.md                   # optional family audits
  feedback_for_review_by_evaluator_*   # not satisfactory + check matrix
  waiting_for_review_by_evaluator_*    # no source change; blockers unchanged
  ready_for_review_by_evaluator_*      # approved / satisfactory — loop may close
  EVALUATOR-WAIT-STATE.md              # implementer contract + closeout pointer
  EXECUTION-RECEIPT.md                 # implementer evidence (apply + undo)
  scripts/watch_evaluator_folder.sh    # implementer may run
  scripts/evaluator_simple_loop.sh     # evaluator/operator — implementer must not drive
```

## Implementer loop (happy path)

1. **Watch** — `watch_evaluator_folder.sh` wakes on evaluator file changes.
2. **Read** — newest `feedback_*` or `AI-CORRECTION-*`; ignore own doc edits as approval.
3. **Correct** — apply P1-first (or ordered findings); run Ansible live; update receipt.
4. **Verify fresh** — Superpowers `verification-before-completion` this turn.
5. **Wait** — do not write `ready_for_review_*`; evaluator re-runs on its cadence.
6. **Closeout** — on `ready_for_review_*` with `decision: approved`, update wait state, stop watcher.

## Trust rules

- Prior-turn pass claims are **stale**; re-probe before closeout claims.
- Evaluator grep contracts (exact phrases) are real — match their literals in receipts.
- `extra-vars` absent converge is valid undo proof when host_vars stay `present`.
- Stale audit docs (`status: fail`) yield to passing validators **and** evaluator-simple sign-off.

## When to use this family

- Plan promotion with an independent evaluator loop or second AI reviewer.
- Long-running correction cycles with timestamped feedback files.
- Any task where the user says “wait for evaluator satisfaction.”

**Conversation entry point:** skill `multi-agent-implementer` — pass `docs/plans/<slug>/` or auto-detect; boots the correcting-implementer loop in one invoke.

**Calibration:** `references/implementer-good-bad-examples.md` (required with parent skill).

**HRL:** `references/hrl-influences.md`.

## When not to use

- Single-agent plan work with no evaluator surface.
- Operator explicitly asks the implementer to **be** the evaluator.
