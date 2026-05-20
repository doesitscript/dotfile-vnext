# IMPORTANT - Approach Tracking Experimental

## Tracking Rule

This experiment must collect findings as the work proceeds through three phases:

### Phase 1: Initial Findings (Draft Review)
- Structural compliance check on subagent-generated drafts
- Recorded in conversational format first
- Key findings documented in dedicated files

### Phase 2: Final Pass (Quality Gate Enforcement)
- Coordinator + 6 parallel Sonnet 4.5 reviewers
- Question collection and resolution
- Quality gate enforcement
- Recorded findings for each plan review

### Phase 3: Post-Implementation Findings
- Actual deployment validation
- Operational learnings
- Final experiment assessment

Each finding point should be recorded in its own file under:

```text
docs/intake/jupyter-devops-implementation-plans/-experimental-multi-agent-work-breakup/findings/
```

Use one file per reported finding so the evidence does not collapse into a
single vague summary.

## Finding File Naming

Use a short numbered filename organized by phase:

### Phase 1: Initial Findings (100-199 series)
```text
findings/100-phase1-initial-findings-overview.md
findings/101-phase1-structural-compliance.md
findings/102-phase1-diagram-quality.md
findings/103-phase1-naming-conventions.md
```

### Phase 2: Final Pass (200-299 series)
```text
findings/200-phase2-coordinator-setup.md
findings/201-phase2-plan1-baseline-review.md
findings/202-phase2-plan2-jupyter-review.md
findings/203-phase2-plan3-langfuse-review.md
findings/204-phase2-plan4-litellm-review.md
findings/205-phase2-plan5-vllm-review.md
findings/206-phase2-plan6-validation-review.md
findings/210-phase2-questions-collected.md
findings/211-phase2-user-answers.md
findings/220-phase2-final-synthesis.md
```

### Phase 3: Post-Implementation (300-399 series)
```text
findings/300-phase3-deployment-results.md
findings/301-phase3-baseline-deployment.md
findings/302-phase3-jupyter-deployment.md
findings/303-phase3-langfuse-deployment.md
findings/304-phase3-litellm-deployment.md
findings/305-phase3-vllm-deployment.md
findings/306-phase3-validation-results.md
findings/320-phase3-operational-learnings.md
```

### Final Summary (999)
```text
findings/999-final-overall-summary.md
```

## Required Finding Fields

Each finding file should include:

- finding topic
- date
- plan slice or task
- agent/model used
- runtime context if known
- input given to the agent
- output artifact path
- strengths
- gaps or failures
- repo-rule violations found
- naming/schema issues found
- NetBox or Ansible assumptions that needed correction
- final reviewer decision

## Runtime Info To Capture

Capture important runtime details when known:

- model name
- tool/runtime surface, such as Cursor, Codex, CLI, API, or MCP
- whether the agent had repo file access
- whether the agent had internet access
- whether the agent had live NetBox/Ansible access
- whether output was draft-only or allowed to edit files
- command, prompt, or task packet used to launch the pass

## Current Test Candidate

The current test candidate is the implementation/planning work in:

```text
docs/intake/jupyter-devops-implementation-plans/
```

The experiment should evaluate subagent performance across these plan slices:

- `00-upgraded-server-ubuntu-docker-k3s-baseline.md`
- `01-remote-jupyterlab-workbench.md`
- `02-langfuse-platform-on-k3s.md`
- `03-litellm-gateway.md`
- `04-vllm-runtime-and-huggingface-cache.md`
- `05-end-to-end-ai-devops-validation.md`

## Final Update Requirement

At the end of implementing the approved plans (after Phase 3), add a final findings file:

```text
findings/999-final-overall-summary.md
```

That final summary should cover:

**Phase 1 Results:**
- Gemini 2.5 draft quality
- Structural compliance rates
- Initial findings accuracy

**Phase 2 Results:**
- Sonnet 4.5 coordinator effectiveness
- Question collection quality
- Quality gate enforcement results
- Cross-plan coordination effectiveness

**Phase 3 Results:**
- Deployment success rates
- Idempotence validation
- Operational gaps discovered
- Plan vs reality deltas

**Overall Assessment:**
- Which agents/models were used for each phase
- Which plan slices they worked on
- How much of their output survived final review
- Common mistakes by phase and agent type
- Useful patterns worth keeping
- Whether the experimental three-phase multi-agent approach should be promoted,
  revised, or abandoned for future project work

## Commit And Tag Visibility

When committing or tagging this experiment, make the experimental status clear.

Recommended commit prefixes:

```text
experiment(multi-agent):
experiment(gemini-agent):
experiment(sonnet-agent):
```

Recommended tags:

```text
experiment/multi-agent-jupyter-devops-YYYYMMDD
experiment/gemini-jupyter-devops-pass-YYYYMMDD
experiment/sonnet-jupyter-devops-pass-YYYYMMDD
```

These labels are for experiment artifacts and findings. Normal implementation
commits should use normal project commit naming unless the implementation itself
is part of the experiment.
