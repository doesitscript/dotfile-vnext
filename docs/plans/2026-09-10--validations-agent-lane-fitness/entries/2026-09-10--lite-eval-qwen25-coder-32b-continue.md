# Entry — gateway and isolated tool evaluation

Requested route: `qwen2.5-coder-32b@k3s02-vllm`. The `-continue` folder suffix is
a historical target-client label; these automated runs do not operate Continue.

- [Runner and coverage](../lite-eval-qwen25-coder-32b-continue/README.md)
- [Latest report](../lite-eval-qwen25-coder-32b-continue/report.md)
- [Run index](../results/INDEX.md)
- [Repair receipt](../repair-notes.md)

## Legacy evidence

The unchanged rerun at `2026-09-10T07:44:15Z` reported 9/10 passing, with E1
failing. Its graders were subsequently shown to accept invalid answers; the
individual PASS results do not support fitness claims.

[Preserved legacy summary](../repair-archives/20260910T081110Z/lite-eval-qwen25-coder-32b-continue/results/summary.json)
contains the original outputs. This is distinct from v2 evidence, which has
parsed artifact contracts and separate prompt/tool/recovery groups.

## Interpretation boundary

Keep ordinary prompts separate from guarded diagnostics and custom tool runs.
Do not attribute differences to weights alone without runtime and context
verification. The real Continue incident remains separate conversation evidence.
