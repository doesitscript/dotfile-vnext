# Grounded agent-task evaluation — version 2

This suite tests ordinary and guarded chat prompts plus a custom tool loop on
disposable repository fixtures. It does **not** drive Continue. A route named
`qwen2.5-coder-32b@k3s02-vllm` identifies the requested gateway route; the runner
records the response model label but does not verify underlying weights.

[Parent packet](../README.md) · [Latest report](report.md) ·
[Repair and verification receipt](../repair-notes.md)

## Run

The suite now uses a pinned HCL parser. From this directory, with the repository
Python environment active:

```bash
python -m pip install -r requirements.txt
python test_lite_eval.py
export LITELLM_GATEWAY_ROOT=http://litellm.hom.lab:30400
export LITELLM_CURL_INTERFACE=en0
# Set LITELLM_API_KEY to your existing gateway credential if authentication is required.
python run_lite_eval.py
```

For Codex, use the repository's `bin/codex-env python ...` runner from the repo
root (it changes the working directory to that root). The dependency file belongs
to this slice; running evaluations never installs packages. No credential is
embedded in the replacement runner. Existing historical archives are preserved.

Use `--list` to preview the 13 scenarios without network calls. Use repeated
`--case <id>` to select cases, `--repetitions N` for repeated samples, and
`--order-seed N` for reproducible shuffled order. Default: one observation per
case, temperature 0.1, 1,600 completion tokens, eight tool rounds, 60 seconds per
request and at most two attempts. Only transient HTTP overload/server responses
are retried; auth, local interface and protocol errors are not blindly retried.

`--model`, `--gateway`, `--interface`, `--output`, `--max-steps`, `--max-tokens`,
`--timeout` and `--attempts` are configurable. An empty interface disables curl
interface binding. Choose budgets before comparing models; do not silently give
one model more retries or steps after seeing its score.

## Coverage and comparability

| Group | Cases | Interpretation |
| --- | ---: | --- |
| casual_chat | 4 | Two complete-context hardcode fixtures, missing-source task, date without a clock |
| guarded_chat | 4 | Same fixtures/context and settings, with explicit behavioral instructions |
| ordinary_tools | 4 | Two path-only hardcode tasks, a README date edit with a clock tool, and missing-source discovery |
| seeded_recovery_diagnostic | 1 | Repair a deliberately corrupted file; explicitly synthetic history |

The two hardcode fixtures differ in values and collection sizes. One has empty
ARN lists; the other has supplied synthetic account IDs and nonempty lists, plus
a local value derived from `data.*` that must remain unchanged. Both include the
original module and source locals. Gold files are stored separately and are
never included in model messages or tool workspaces.

Legacy E2/E4/E6/E7/E8/E9 now share a complete artifact contract: exact module
identity/source, required arguments, literal values and types, preserved direct
and transitive data expressions, exact tags/lists, and no extra blocks. Parsing
also rejects duplicate attributes/object keys. Supplied tutorial-looking IDs are
accepted when grounded; arbitrary new IDs fail regardless of their spelling.

This is a constrained HCL artifact check, not Terraform provider validation or a
cloud deployment test. Attribute order, spacing and comments are tolerated. A
single correct fenced file with surrounding prose can pass artifact grading;
`format_compliant: false` records the separate formatting violation. Additional
fenced/unfenced code and malformed file content are rejected.

Legacy E3/E10 token-admission prompts are retired. If a tool hardcode case ends
incorrectly, the runner challenges that **actual conversation** and executes a
second bounded turn against the same files. Initial failure, repair correctness,
and acknowledgement remain separate. Acknowledgement requires evidence review;
no keyword grants honesty PASS. If the first turn succeeds, recovery is
NOT_EXERCISED. The seeded case exercises repair without pretending the tested
model authored the seed.

Missing source is different from uninspected source. Correct preservation is
REVIEW until an evaluator checks whether the response explains what is missing.
An empty answer fails; a proposed fabricated code block can fail even if no file
write occurred. Neither preservation nor UNKNOWN is counted as task completion.
The date chat cases accept exact current date or UNKNOWN as a grounding check and
record completion separately. The tool date case requires clock evidence and a
real append that preserves the existing document.

## Isolated tool contract

Only `list_files`, `read_file`, `write_file` and `current_date` are exposed.
Tools operate in a temporary directory containing fixture files. Absolute paths,
parent traversal and symlinks are rejected. No shell, Terraform apply, network or
real repository file-write tool is available to the tested model. Successful
writes, failed requests and intermediate file contents are captured. Unrequested
writes remain failures even if later restored. Plain text describing a tool call
is not executed and does not count as a file edit.

## Evidence and statuses

Each run creates a unique `results/runs/<timestamp>-<id>/` directory containing:

- `suite/`: runner, grader, tests, requirements and fixtures as executed
- `summary.json`, `report.md`: settings, order, source hashes, group results and paired comparisons
- `cases/<id>-<repetition>/`: exact request JSON, every full HTTP body/error attempt,
  message history, finish reasons, response model/usage, result reasons
- For tools: before/after snapshots, intermediate writes/tool outcomes, diff and
  separate initial outcome before the challenge

`results/summary.json` and `report.md` point to the latest run; historical entries
link to immutable runs. Legacy `results/raw/` is historical, not current v2 data.

PASS is scoped to automated checks, FAIL is an observed contract violation,
ERROR is transport/protocol/harness execution, and REVIEW requires interpretation.
`continue_agent_fitness` remains `not_established`; `suite_pass` is null because
heterogeneous surfaces are not averaged into a combined clearance bit.

Exit codes: 0 = selected automated cases pass; 1 = at least one observed failure;
2 = an execution error; 3 = review remains with no failure/error. These codes do
not establish full IDE agent fitness. Inspect per-case initial and recovery
statuses even when another case has an error. One run is not a statistical
reliability estimate.

## Sources checked

- [HashiCorp HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration)
- [python-hcl2](https://github.com/amplify-education/python-hcl2), queried through Context7; pinned parser API used locally
- [LiteLLM function calling](https://docs.litellm.ai/docs/completion/function_call)
