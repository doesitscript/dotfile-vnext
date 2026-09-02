---
title: Post-signoff improvement report
created_at: 2026-09-02T113937
author: evaluator-simple
status: advisory
decision: post-approval recommendations
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Post-signoff improvement report

Approval was re-verified against:

- `ready_for_review_by_evaluator_simple_2026-09-02T112907.md`
- `ready_for_review_by_evaluator_simple_2026-09-02T113920.md`
- current `README.md`
- current `EXECUTION-RECEIPT.md`

The promotion work is satisfactory and done. The items below are improvement opportunities, not reopen blockers.

## Highest-value process improvements

1. Split the evaluator into a pure one-shot checker plus a separate scheduler wrapper.
   Current issue: `scripts/evaluator_simple_loop.sh` mixed evaluation, persistence, and debug-loop behavior, which made interference and stale processes harder to reason about.
   Better target: one script that evaluates once and writes exactly one artifact; separate wrappers for hourly execution.

2. Define ownership boundaries between evaluator and implementer artifacts.
   Current issue: evaluator files were modified while evaluation was in progress, which made the feedback stream noisy and less trustworthy.
   Better target: evaluator owns `feedback_*`, `waiting_*`, `ready_*`, `EVALUATOR-WAIT-STATE.md`; implementer owns code, docs, receipt, and explicit response artifacts only.

3. Standardize a receipt contract for one-off promotion verification.
   Current issue: the last blocker existed because undo evidence was not captured in a predictable shape.
   Better target: a required receipt section template for apply, absent converge, restore, and interactive/manual checks.

4. Promote the one-off lifecycle into a reusable reviewed skill after the draft family stabilizes.
   Current issue: this promotion generated useful patterns, but some logic still lived in ad hoc evaluator files.
   Better target: a stable lifecycle skill pair for promotion and promotion-verification with mandatory receipt fields.

## Implementer improvements

1. Close plan checklists only after evidence lands.
   The implementer should treat any `done` state in a plan as evidence-backed only, never intention-backed.

2. Prefer explicit absent verification early.
   The main late-stage correction came from proving uninstall/undo behavior, not install behavior. Future promotions should verify absent-state before claiming the role is fully promoted.

3. Keep repo-truth and historical truth separate.
   `README.md` is the active contract. `EXECUTION-RECEIPT.md` is evidence. The implementer should avoid blending those responsibilities.

4. When the same blocker repeats twice, research before another patch.
   This rule is now part of the evaluator guidance and should remain. Repeated patches without new information slow the closeout loop.

## Project improvements

1. Add a small verifier for promotion packet completeness.
   Suggested scope:
   - check Apply/Undo rows are self-contained
   - require a disposition ledger
   - require explicit uninstall path
   - require an execution receipt link
   - require undo verification before a plan checklist item can be marked done

2. Add a reusable receipt template under the one-off skill family.
   Suggested sections:
   - implemented in repo
   - initial apply
   - idempotent re-run
   - absent converge
   - restored present
   - manual/TTY-only checks
   - known open gaps

3. Add a project convention for role-owned shell drop-ins.
   This work corrected a real ambiguity around `~/.bashrc.d` ownership. That convention should be documented once and referenced by roles instead of rediscovered during promotions.

4. Add a durable scheduler only outside the agent sandbox.
   The repo now contains scheduler artifacts, but OS-level scheduler registration was not verifiable from this session. If continuous evaluator automation matters, install and verify it from a normal operator shell, not from a constrained agent run.

## AI-facing next-step suggestions

1. Mature the draft one-off skills and then re-run a pack-level evaluation.
2. Extract the evaluator logic into a reusable project skill or script with a single authoritative output contract.
3. Add machine-readable state for evaluator findings so repeated-blocker detection does not depend on parsing markdown.
4. Add a manual-check placeholder contract for TTY-only verification so interactive gaps are tracked consistently.

## Final evaluator view

This promotion ended in a good state. The main lesson is that future-proofing came less from the initial promotion itself and more from forcing truthful undo semantics, explicit evidence capture, and clearer separation between implementation and evaluation roles.
