# Plan 15b — re-review (historical findings)

> Current status: the Continue filter defect identified below was fixed and
> re-converged successfully. See [plan-15b_re-reviewed_executed.md](plan-15b_re-reviewed_executed.md)
> and [CURRENT_STATE.md](CURRENT_STATE.md). The findings below remain as the
> review input and are not an open TODO.

**Note on the artifact:** `plan-15_…_executed.md` is mostly a paste of my earlier evaluation (including “I’m in Ask mode…”). The real execution receipt is **`plan-14_clien_and_other_cli_evaluation_reviewed.md`**. Review below is against **repo + plan-14**, not plan-15’s title.

Also: this session is still **Ask mode** (read-only). I can inspect deeply; I can’t patch. Switch to Agent if you want the Continue bug fixed.

---

## Verdict

Codex implemented the scalable direction correctly for **agent clients** (Cline / OpenCode / Kilo): shared `ai_cli_client_model_contracts` + filter by `accept_roles`. That’s the right generalization of the Cline-only fix.

**Continue wiring has a real bug.** Aider/Codex are incomplete. `require_any_labels: [tools]` was **not** implemented (optional residual).

---

## What landed well (matches the design)

| Piece | Status |
| --- | --- |
| `ai_cli_client_model_contracts` in `ai_cli_apps.yml` | Present — Continue gets FIM/embed; Cline/OpenCode/Kilo get chat/edit/apply; Aider declared as `[chat]` |
| Cline filter uses contract | Correct — on the **loop** task |
| OpenCode / Kilo same pattern | Correct — on the loop + default-model asserts |
| OpenCode/Kilo SSOT enrichment | Context/output (and Kilo `tool_call` from `tools` label) — good |
| Plan-14 honesty | Convergence proven; not full interactive OpenCode/Kilo sessions |

That is real execution on the earlier feedback, not rename theater.

---

## Blocking issue: Continue filter on the wrong task

In `roles/continue_ide/tasks/mac.yml`:

1. **Resolve** sets `continue_ide_models: []` (no loop) but its `when:` references `item.labels` ∩ `continue_ide.accept_roles`.
2. **Translate** loops all `ai_cli_commissioned_models` with **no** accept_roles filter.

So:

- The contract is not applied where rows are built.
- `item` on a non-looping task is invalid / leftover-loop hazard.
- Continue may still ingest rows the contract was meant to gate (or Resolve may skip oddly).

Cline/OpenCode/Kilo got this right; Continue looks like a mis-paste of the `when` onto the wrong task.

**Fix shape:** put the intersect on the **Translate** loop’s `when`, same as Cline; Resolve should only be `present` + SSOT defined.

---

## Gaps vs the full scalable standard

| Gap | Severity |
| --- | --- |
| No `require_any_labels: [tools]` for agent clients | Medium — chat/edit/apply without `tools` (7B/14B, some Gemini) can still enter Cline/Kilo/OpenCode; plan-14 notes tools only on Qwen3/GPT-OSS in Cline capabilities, but those models remain selectable |
| `aider` in contract, **no** role uses it | Low/medium — dead contract row |
| **Codex** not in contract / not filtering SSOT this way | Medium if Codex builds a model picker from the full commissioned set |
| Filter logic duplicated per role (not one shared include/filter) | Acceptable for now; DRY later |
| Plan-15 filename/content mismatch | Doc hygiene |

---

## Evidence claims (plan-14)

I did **not** re-run playbooks this turn. Plan-14’s claimed converges (Cline/OpenCode/Kilo) and “no FIM/embed in agent catalogs” are plausible given the Cline/OpenCode/Kilo code paths. Treat Continue catalog claims as **unproven** until the wiring bug is fixed and Continue is re-converged.

---

## Bottom line

- **Direction:** good — shared contracts + role-aware SSOT filtering is the right scalable answer.
- **Execution:** solid for Cline/OpenCode/Kilo; **Continue needs a corrective patch**; Aider/Codex not fully on the contract yet; tools-required gate still optional debt.
- **plan-15:** rename/replace with a short pointer to plan-14, or turn it into a true post-execution review — don’t leave my Ask-mode text labeled “executed.”

If you flip to Agent mode, the first fix is Continue’s misplaced `when`, then optional `require_any_labels: [tools]` for agent contracts if that matches the second Cline error you saw.
