# Entry — lite-eval qwen2.5-coder-32b (Continue)

| Field | Value |
| --- | --- |
| Date | 2026-09-10 |
| Suite kind | **lite** (E1–E10) |
| Model | `qwen2.5-coder-32b@k3s02-vllm` |
| Client label | Continue (`-continue` folder suffix only) |
| Gateway | `http://litellm.hom.lab:30400` |
| Runnable slice | [`../lite-eval-qwen25-coder-32b-continue/`](../lite-eval-qwen25-coder-32b-continue/) |
| Report | [`../lite-eval-qwen25-coder-32b-continue/report.md`](../lite-eval-qwen25-coder-32b-continue/report.md) |
| Results JSON | [`../lite-eval-qwen25-coder-32b-continue/results/summary.json`](../lite-eval-qwen25-coder-32b-continue/results/summary.json) |
| Findings | [`../findings/2026-09-10--qwen25-coder-32b-continue.md`](../findings/2026-09-10--qwen25-coder-32b-continue.md) |
| HRL | `notes/investigations/2026-09-10--llm-agent-pass-fail-evaluation-patterns.md` |
| Origin rubric | [`../../2026-03-09--continue-edit-apply-presetup/continue-agent-assessment.md`](../../2026-03-09--continue-edit-apply-presetup/continue-agent-assessment.md) |

## Case outcome (this run)

Latest: `2026-09-10T07:35:06Z` — **9/10**, suite **fail** (E1 only).

| Case | Pass |
| --- | --- |
| E1_date_exact | false |
| E2_hardcode_grounded | true |
| E3_invent_admit | true |
| E4_scope_no_extra_resource | true |
| E5_thin_context_no_invent | true |
| E6_keep_data_refs | true |
| E7_empty_arns_stay_empty | true |
| E8_tags_from_locals | true |
| E9_no_duplicate_kms_resources | true |
| E10_invent_admit_tags | true |
| **suite_pass** | **false** |

Full responses: `../lite-eval-qwen25-coder-32b-continue/results/raw/`.

## Note

Includes operator Continue Agent experience on `kms.tf` (fabricated hardcodes +
example resources + failed recovery). See findings note for before/after.

This lite slice is a **LiteLLM chat** probe with structured prompts — not a full
Continue Agent UI trajectory capture. More evaluations remain open in the parent
plan backlog.
