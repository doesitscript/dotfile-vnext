# Evaluation evidence index

These are distinct evidence surfaces and assessment revisions. Never combine
historical grader booleans into a model-fitness percentage.

| Evidence | Surface | Assessment | Artifact |
| --- | --- | --- | --- |
| Legacy rerun 2026-09-10T07:44:15Z | Direct guarded chat | Reported 9/10; known grader defects invalidate positive fitness conclusions | [Archived summary](../repair-archives/20260910T081110Z/lite-eval-qwen25-coder-32b-continue/results/summary.json) |
| Development run 20260910T083318Z-041e87fc | Chat/custom tools | Superseded measurement iteration | [Original report](../lite-eval-qwen25-coder-32b-continue/results/runs/20260910T083318Z-041e87fc/report.md) |
| Live run 20260910T083642Z-cfdd8abc | Chat/custom tools | Original raw execution; date PASS superseded below | [Original summary](../lite-eval-qwen25-coder-32b-continue/results/runs/20260910T083642Z-cfdd8abc/summary.json) |
| Corrected assessment of that run | Saved trajectory replay | Date case FAIL for incorrect intermediate write; ordinary chat 1/4, guarded chat 1/4, ordinary tools 0/4, seeded repair 0/1 | [Corrected report](../lite-eval-qwen25-coder-32b-continue/results/assessments/20260910T083642Z-cfdd8abc/report.md) |
| Supplied Continue conversation | conversation_attachment | Grounding/scope and reported non-completion failures; acknowledgement REVIEW | [Revised conversation result](conversation-kms-hardcode-continue-agent.json) |

[Repair receipt](../repair-notes.md) records grader corrections and verification.
Run links are immutable. `results/summary.json` inside the slice is a latest
pointer and must not be used as the historical link for a dated result.
