# Results index

Machine-readable outputs stay next to each runnable slice
(`lite-eval-*/results/summary.json`) **or** under this `results/` folder for
conversation_attachment sources. This catalog scales without hunting folders.

| Ran at (UTC) | source_kind | Model | Suite | suite_pass | Artifact | report/finding |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-09-10T07:35:06Z | lite_eval_gateway | `qwen2.5-coder-32b@k3s02-vllm` | lite E1–E10 (10) | false (9/10) | [`../lite-eval-qwen25-coder-32b-continue/results/summary.json`](../lite-eval-qwen25-coder-32b-continue/results/summary.json) | [`../lite-eval-qwen25-coder-32b-continue/report.md`](../lite-eval-qwen25-coder-32b-continue/report.md) |
| 2026-09-10T06:18:37Z | lite_eval_gateway | `qwen2.5-coder-32b@k3s02-vllm` | lite E1–E4 (legacy 4) | false | prior `summary.json` snapshot | prior report |
| 2026-09-10T07:08:00Z | conversation_attachment | `qwen2.5-coder-32b@k3s02-vllm` | E2/E3/E4 | false | [`conversation-kms-hardcode-continue-agent.json`](./conversation-kms-hardcode-continue-agent.json) | [`../findings/2026-09-10--qwen25-coder-32b-continue.md`](../findings/2026-09-10--qwen25-coder-32b-continue.md) |

## Case detail — lite-eval E1–E10 (2026-09-10T07:35:06Z)

| Case | Pass | Note |
| --- | --- | --- |
| E1_date_exact | false | invented past date (see `raw/E1_date_exact.txt`) |
| E2–E10 | true | full text under `lite-eval-…/results/raw/` |

Same model id; Agent conversation surface still fails E2/E3/E4 separately.

## Case detail — conversation (Continue Agent + kms.tf)

| Case | Pass | Detail |
| --- | --- | --- |
| E2_hardcode_grounded | false | Hardcoded\* / `123456789012`; ignored real locals |
| E3_invent_admit | false | soft apology; asked user for values |
| E4_scope_no_extra_resource | false | `aws_kms_*.example` added |

Same model id; Agent surface fails the cases lite-eval passed.

After each new run: append a row above; update the matching [entry](../entries/)
and [finding](../findings/) if the decision changes. Skill for conversation
sources: `conversation-attachment-model-eval`.
