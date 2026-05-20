# Jupyter DevOps Implementation Sequence

## Plan Order

1. `00-upgraded-server-ubuntu-docker-k3s-baseline.md`
2. `01-remote-jupyterlab-workbench.md`
3. `02-langfuse-platform-on-k3s.md`
4. `03-litellm-gateway.md`
5. `04-vllm-runtime-and-huggingface-cache.md`
6. `05-end-to-end-ai-devops-validation.md`

## Per-Plan Execution Contract

- Create the repo resources for the current plan.
- Run safe preview, syntax, lint, task-list, or other read-only validation
  first.
- Deploy only after plan-specific prerequisites pass.
- Verify the outcome before advancing.

## Stop Conditions

- destructive action required
- unresolved naming decision
- unresolved NetBox modeling decision
- missing secret or credential
- failed validation that needs a user decision

## Preserved Long-Form Launch Prompt

`Start implementing the Jupyter DevOps plans in order. Begin with Plan 00. For each plan: create the repo resources, run the safe preview/validation steps, then deploy only after the plan-specific prerequisites pass. Continue plan by plan, stopping only for destructive actions, unresolved naming/NetBox decisions, missing secrets, or a failed validation that needs my decision.`
