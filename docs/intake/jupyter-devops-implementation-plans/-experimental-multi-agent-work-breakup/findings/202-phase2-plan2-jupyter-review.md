# 202 Phase 2 Plan 2 Jupyter Review

## Finding Topic

Review of the remote JupyterLab workbench slice.

## Date

2026-05-20

## Plan Slice Or Task

`01-remote-jupyterlab-workbench`

## Agent/Model Used

Planner 2 / Bohr: `019e4409-993a-7b80-b32f-229b83ffe187`

## Runtime Context If Known

Read-only repo review. No file edits, Ansible runs, or NetBox changes.

## Input Given To The Agent

Read the plan slice, matching research, repo rules, and naming standards.
Produce findings only.

## Output Artifact Path

This file.

## Strengths

- Proposed a clear capability role:
  `roles/dev_jupyterlab_workbench/`.
- Recommended a state-based interface:
  `dev_jupyterlab_workbench_state`.
- Correctly treated secure access as a first-class design point:
  bind to `127.0.0.1` and prefer SSH tunnel unless a reverse proxy lane is
  explicitly introduced.

## Gaps Or Failures

- Target placement is unresolved: local Mac, K3s VM, 5090 server VM, or another
  workbench node.
- The plan needs to decide whether Jupyter is a systemd service, user service,
  container workload, or Kubernetes workload.
- Cookbook/source material handling is not yet specified.

## Repo-Rule Violations Found

None from the review. Future implementation must avoid exposing Jupyter on
`0.0.0.0` without an approved ingress or tunnel pattern.

## Naming/Schema Issues Found

The `jpy` service code exists, but the domain/context is unresolved. Use
`ctl` only for infrastructure hosts. Use an AI/workload domain such as `aix`
only after the schema says how workload identities render.

## NetBox Or Ansible Assumptions That Needed Correction

NetBox should model the host/VM/interface/IP now. Runtime Jupyter endpoint
records should wait until the service endpoint model is approved.

## Final Reviewer Decision

Implementation readiness: 5/10. This can follow the baseline slice once target
host, access model, and service form are decided.
