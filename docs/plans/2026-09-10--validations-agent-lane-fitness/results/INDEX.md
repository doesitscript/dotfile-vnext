# Results index

Machine-readable outputs stay next to each runnable slice
(`lite-eval-*/results/summary.json`) **or** under this `results/` folder for
conversation_attachment sources. This catalog scales without hunting folders.

| Ran at (UTC) | source_kind | Model | Suite | suite_pass | Artifact | report/finding |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-09-10T06:18:37Z | lite_eval_gateway | `qwen2.5-coder-32b@k3s02-vllm` | lite E1–E4 | false | [`../lite-eval-qwen25-coder-32b-continue/results/summary.json`](../lite-eval-qwen25-coder-32b-continue/results/summary.json) | [`../lite-eval-qwen25-coder-32b-continue/report.md`](../lite-eval-qwen25-coder-32b-continue/report.md) |
| 2026-09-10T07:08:00Z | conversation_attachment | `qwen2.5-coder-32b@k3s02-vllm` | E2/E3/E4 | false | [`conversation-kms-hardcode-continue-agent.json`](./conversation-kms-hardcode-continue-agent.json) | [`../findings/2026-09-10--qwen25-coder-32b-continue.md`](../findings/2026-09-10--qwen25-coder-32b-continue.md) |

## Case detail — lite-eval (gateway chat, locals in prompt)

| Case | Pass | Latency (s) | Detail |
| --- | --- | ---: | --- |
| E1_date_exact | false | 0.462 | `Last updated: 2023-10-05.` |
| E2_hardcode_grounded | true | 1.425 | grounded alias/description |
| E3_invent_admit | true | 0.457 | `YES_INVENTED` |
| E4_scope_no_extra_resource | true | 1.422 | no example KMS resources |

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
