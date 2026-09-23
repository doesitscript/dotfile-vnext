# Scenario evaluation

Evaluator: primary agent, direct rubric walkthrough plus executable fixture.
This is not an independent evaluator approval or a fresh autonomous model run.
The prompts and reject criteria live in the global pack's `evals/evals.json`.
Raw fixture commands, stdout, stderr and exit codes: [scenarios.json](evidence/scenarios.json).

| Scenario | Instruction decision exercised | Actual fixture observation | Verdict |
| --- | --- | --- | --- |
| S1: installed CLI absent from application PATH | Steps 1–3 require exact context, desired state and acceptance; step 8 prohibits own-shell substitution | Absolute `rg --version` exits 0 while the application-context search exits 127 | pass; reject installed-means-working inference |
| S2: manual repair then project repair | Steps 4–7 require mutation ledger, retained project fix and restored experiment baseline | Manual change passes; restored bytes/hash produce exit 127; preview preserves baseline; first Ansible apply changes 1; second changes 0; both post-apply searches return exact proof text | pass; convergence and repeatability separately demonstrated |
| S3: unchanged but broken | Steps 8–10 and Validation require original behavior despite recap success | Removing separately owned fixture binary leaves PATH task changed=0 while application exits 127 | pass; expected rejection of completion |

Safety walkthrough: step 6 prohibits restoring production failure unsafely and
requires isolation with a stated evidence limit. The fixtures write only inside
TemporaryDirectory, preserve an unrelated sentinel, and automatically remove
their temporary state. This implements the approved safe substitute, not a claim
of production rollback testing.

Mutation-ledger walkthrough: `assets/receipt.md` provides baseline evidence,
mutation owner, undo and restoration evidence columns. No temporary production
configuration changes were needed to implement this workflow. During bridge
inspection, an unsupported `--help` argument caused an early sync; only this
new skill's five links were removed, previewed absent, then applied via the normal
hook. No unrelated runtime links were removed.

Proportionality walkthrough: the global Evidence proportionality section and
project troubleshooting adapter permit compact saved output and condition new
collectors on recurrence/complexity/volume. The legacy diagnostics rule now
explicitly honors that boundary. Metadata validation does not stand in for these
scenario decisions; fixture execution does not prove future models will comply.

## Documentation Provenance

Origin: user-approved plan.md and approved-outline.md. Direct inputs: global
SKILL.md, receipt template, eval prompts, actual isolated Ansible fixture output.
Consumer: implementation-accounting.md. Skills: scaffold-global-skill,
validate-skill-library-metadata, global-skill-runtime-bridge,
verification-before-completion.
