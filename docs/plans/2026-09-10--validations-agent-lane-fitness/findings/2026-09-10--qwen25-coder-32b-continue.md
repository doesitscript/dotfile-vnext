# Finding — observed agent failures and evaluation defects

The supplied Continue conversation describes unsupported Terraform values,
unrequested resource blocks and an unfinished task after challenge. These are
reasons not to treat that observed agent workflow as reliable. They do not
isolate a cause in model weights, client orchestration, configuration or routing.

## Corrections to the earlier assessment

The original assessment and outputs are preserved under
[`repair-archives/20260910T081110Z/`](../repair-archives/20260910T081110Z/).

- Withdraw the claim that the direct API suite and Continue session were proven
  to use identical weights. The cited session title identifies a client profile;
  upstream routing/weights were not independently verified in this repair.
- Withdraw positive conclusions drawn from legacy E2–E10 PASS labels. Auditing
  the actual grader code showed acceptance of empty responses, arbitrary new IDs,
  renamed extra resources and incomplete tags.
- E2/E4 did not even include the module to be rewritten. A prompt with the locals
  pasted in is not equivalent to a path-only agent task requiring discovery.
- Withdraw the requirement for `YES_INVENTED` and unprompted confession. Assess
  acknowledgement against the actual conversation; incomplete recovery is a
  separate task outcome, not proof of dishonesty.
- The legacy report did save prompts and full assistant text. Do not claim those
  were absent. It lacked the richer request/tool/finish-reason record needed for
  agent-trajectory conclusions.
- Remove unsupported recommendations that this evaluator or another model/lane
  is reliable based on these tests. Equal scrutiny requires comparable evidence.

## Incident evidence boundary

The user supplied an original module and an output containing unsupported
`Hardcoded Description`, an invented alias, IAM users/account IDs, tutorial tags,
and extra `aws_kms_key`/`aws_kms_alias` blocks. The user's report also describes
an incorrect README date and no completed repair after challenge. Earlier agent
statements about reading session files are retained as attributed claims, not
newly verified observations.

The associated [conversation result](../results/conversation-kms-hardcode-continue-agent.json)
separates grounding, scope, acknowledgement and reported recovery. Real application
files were not changed by this repair.

## Replacement evaluation

See [v2 coverage](../lite-eval-qwen25-coder-32b-continue/README.md),
[latest report](../lite-eval-qwen25-coder-32b-continue/report.md), and
[verification receipt](../repair-notes.md). Ordinary/guarded comparisons now share
fixtures; tool tests use isolated files and capture actual actions. A passing
custom harness case is not Continue UI clearance. One campaign cannot establish
persistent model defects or statistically reliable unattended operation.

## Evaluation-author accountability

The test author is a separate subject: missing task context, unvalidated graders,
answer cueing, unsupported causal claims, and changing application files during
an evaluation discussion are the relevant observable concerns. These support
criticism of measurement and self-verification. Intent, favoritism and character
are not established by these artifacts. The updated global skill includes a
separate evidence-based evaluator-author audit rubric.
