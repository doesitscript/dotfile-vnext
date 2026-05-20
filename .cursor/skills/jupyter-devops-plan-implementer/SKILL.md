---
name: jupyter-devops-plan-implementer
description: Implement the Jupyter DevOps plan set under docs/intake/jupyter-devops-implementation-plans in order, starting with Plan 00. Use when the task is to create repo resources, run safe preview and validation steps first, deploy only after each plan's prerequisites pass, and continue plan by plan until a destructive action, unresolved naming or NetBox decision, missing secret, or failed validation needs the user's decision.
---

# Jupyter DevOps Plan Implementer

Use this skill for the specific six-plan Jupyter DevOps intake sequence under
`docs/intake/jupyter-devops-implementation-plans/`.

## Core Rule

Treat this as a controlled sequential implementation lane, not a generic
"implement some Jupyter work" request.

## Sequence

1. Start with Plan 00.
2. Finish the current plan's safe repo and validation work before moving to the
   next plan.
3. Advance in this order only:
   - `00-upgraded-server-ubuntu-docker-k3s-baseline.md`
   - `01-remote-jupyterlab-workbench.md`
   - `02-langfuse-platform-on-k3s.md`
   - `03-litellm-gateway.md`
   - `04-vllm-runtime-and-huggingface-cache.md`
   - `05-end-to-end-ai-devops-validation.md`

## Required Workflow Per Plan

1. Read the current plan slice and the plan-set `README.md`.
2. Inspect existing repo surfaces before adding new structure.
3. If the work is moving from intake to real implementation, first promote the
   current slice into an official folder-backed plan under `docs/plans/`.
4. State the current plan's:
   - Apply
   - Verify
   - Undo
   - Change class
5. Create or update the repo resources required by that plan.
6. Run the safest available preview, syntax, lint, task-list, or read-only
   validation steps before any mutating deployment.
7. Deploy only after the plan-specific prerequisites and validations pass.
8. Verify the actual result before declaring the plan slice complete.
9. Continue to the next plan unless a stop condition fires.

## Stop Conditions

Stop and ask the user only when one of these happens:

- the next action is destructive
- a naming or NetBox modeling decision is still unresolved
- a required secret or credential is missing
- a validation or preview fails and the failure needs a user decision

Do not stop for ordinary safe reads, previews, validation, or non-destructive
repo changes.

## Repo-Specific Expectations

- Prefer existing roles, playbooks, inventory, and NetBox seed surfaces over
  ad hoc new paths.
- Keep Docker/service VM work and K3s VM work clearly separated.
- Treat NetBox and the active naming standards as authority for names, roles,
  platforms, IPs, and hierarchy.
- Keep later plans from back-driving earlier prerequisites. If Plan 03 needs a
  missing baseline from Plan 00, fix Plan 00 first.

## Default Invocation

Use this short prompt:

`Use $jupyter-devops-plan-implementer and start at Plan 00.`

## Reference

Load `references/implementation-sequence.md` for the exact order, stop
conditions, and the preserved long-form launch prompt.
