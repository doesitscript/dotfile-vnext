# Suite and skill repair receipt — 2026-09-10

Scope: repair the evaluation and its related guidance. The tested agent is not
required to pass for this repair to succeed. Actual Continue UI validation,
upstream-weight verification and broader benchmark campaigns remain outside this
slice and are not claimed complete.

## What changed

- Replaced the 10 substring/blacklist cases with 13 scoped scenarios using two
  explicit source/expected HCL fixtures, paired ordinary/guarded prompts,
  missing-source checks, clock-backed date editing and isolated file tools.
- Added parsed artifact contracts and negative controls for empty/incomplete
  answers, arbitrary IDs, extra blocks, missing tags/arguments, duplicate keys,
  altered data references, format differences, truncation and execution errors.
- Challenge actual failed tool turns with their real histories. Preserve initial
  failure and score repair separately; acknowledgement requires review.
- Preserve complete requests/responses, tool outcomes, intermediate writes,
  before/after files, diffs and hashed source copies per immutable run.
- Updated three global skills: conversation-attachment-model-eval (v0.2.0),
  homelab-litellm-model-lane-pytest (v0.1.1), and
  homelab-model-lane-atdd-coordinator (v0.1.1). Updated conversation templates,
  evidence/author rubrics, provider metadata and discovery examples.
- Corrected packet claims about identical weights, legacy PASS validity and
  token-based honesty. Original artifacts remain in repair-archives/20260910T081110Z.

## Verification and obligation inventory

| ID | Source | Obligation | Scope | Status / evidence |
| --- | --- | --- | --- | --- |
| O1 | User repair request / source preservation | Preserve original runner, reports and assessments | In | Archive path above; no real application files edited |
| O2 | Grader correctness | Reject independently constructed wrong artifacts and validate execution boundaries | In | 32 offline tests; [command output](validation/regression-tests.txt) |
| O3 | Ordinary versus guarded behavior | Equivalent task fixtures/context with separate results | In | Paired-context regression plus [live run](lite-eval-qwen25-coder-32b-continue/results/runs/20260910T083642Z-cfdd8abc/summary.json) |
| O4 | Agent task/recovery coverage | Actual disposable file tools, bounded continuation and preserved initial outcomes | In | Live tool-events, initial-outcome, before/after and messages per case; recovery regression tests |
| O5 | Self-verification | Inspect raw responses and writes; correct discovered grading mistakes | In | [Date trajectory replay](validation/date-trajectory-regrade.json); corrected assessment linked below |
| O6 | Skills and routing | Correct rubric/templates, qualification boundaries and runtime discovery | In | [Skill checks](validation/global-skills-checks.json); six catalog-managed runtime links verified; gateway-pytest child remains source-only by catalog |
| O7 | Verify contract / docs and diagrams | Update usage, findings, index, scope/undo and diagram surfaces | In | Packet README, slice README, this receipt; final diff/link checks |
| O8 | Library-wide validator | Report existing errors without silently changing unrelated skills | In, reporting only | Three existing metadata errors in unchanged HEAD files, detailed in skill checks |
| O9 | Prior backlog | Continue UI, larger benchmarks, multi-model reliability and weight identity | Out | Remains open in parent README; no completion claim |

## Live evidence and correction

The full final live campaign captured 13 scenarios at run
`20260910T083642Z-cfdd8abc`; exit 1 reflected case failures, not transport errors.
After inspecting intermediate writes, the date case's original PASS was corrected
by replaying its saved trajectory through the updated grader. The model had
written `2023-10-05` before overwriting it with the correct date, even though a
clock tool had already provided the current date. No new model response was
invented or substituted during reassessment.

[Corrected assessment](lite-eval-qwen25-coder-32b-continue/results/assessments/20260910T083642Z-cfdd8abc/report.md):
ordinary chat 1/4, guarded chat 1/4, ordinary tools 0/4, seeded repair 0/1 passed
their scoped checks. Both actual hardcode recovery attempts failed to produce
correct final files. The guarded date PASS was an honest `UNKNOWN`, not date-task
completion. Several other chat failures were malformed artifact presentation
(`kms.tf:` inside the HCL fence), which must not be described as fabrication.

The earlier development run `20260910T083318Z-041e87fc` is retained too. Its overly
strict surrounding-prose grading and missing-source proposal handling were
corrected before the later campaign. These preserved iterations make changes in
measurement visible instead of concealing them behind the latest score.

No combined agent-fitness PASS, same-weights claim or reliability percentage is
issued. The API/custom tool harness is not Continue itself.

## Validation limitations

Affected skill metadata and catalog checks pass. Full-library metadata validation
still reports three pre-existing provider-metadata errors in
`multiagent-paired-review-designer`, `multiagents-runtime-contract`, and
`skill-to-paired-review-converter`; those files match HEAD and were left unchanged.
The advisory checker reported existing warnings; optional skills-ref validation
was skipped because that tool is not installed. Skill instruction behavior has
not been independently forward-tested by another model in this repair.

HCL parser tests establish the constrained fixture contract, not Terraform
provider correctness. Terraform init/validate/apply and real application edits
were not run because the task is evaluation tooling and the source module is an
isolated fixture. No infrastructure deployment or repository-wide unrelated test
campaign was necessary. No commits or pushes were requested.

## Sources checked

The original runner, raw outputs, supplied conversation, affected global skills,
repo conventions, [HashiCorp HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration),
[python-hcl2](https://github.com/amplify-education/python-hcl2) through Context7,
and [LiteLLM function calling](https://docs.litellm.ai/docs/completion/function_call).
