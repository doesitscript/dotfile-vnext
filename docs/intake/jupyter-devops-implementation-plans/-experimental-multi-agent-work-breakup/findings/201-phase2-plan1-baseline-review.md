# 201 Phase 2 Plan 1 Baseline Review

## Finding Topic

Review of the upgraded server Ubuntu, Docker, and K3s baseline slice.

## Date

2026-05-20

## Plan Slice Or Task

`00-upgraded-server-ubuntu-docker-k3s-baseline`

## Agent/Model Used

Planner 1 / Rawls: `019e4409-8e2c-7192-beb7-3587521ec26c`

## Runtime Context If Known

Read-only repo review. NetBox-backed inventory probes returned permission
errors against `http://192.168.50.158:8000`, so live NetBox access should be
rechecked before relying on this slice operationally.

## Input Given To The Agent

Read the intake plan, matching research file, `AGENTS.md`, relevant framework
rules, and naming standards. Produce findings only.

## Output Artifact Path

This file.

## Strengths

- Correctly identified the existing baseline surfaces:
  `site.yaml`, `hyperv_ubuntu_docker_vm.yaml`, `hyperv_ubuntu_k3s_vm.yaml`,
  `k3s_bootstrap.yaml`, `deploy_ipam_netbox.yaml`, and naming validation.
- Correctly recognized the compact current lane:
  `hom-lab-ctl-hvh-01`, `hom-lab-ctl-dkr-01`, `hom-lab-ctl-k3s-01`.
- Kept Docker and K3s separated as distinct overlays on the Ubuntu base.

## Gaps Or Failures

- Implementation readiness is only moderate because the upgraded two-server
  target shape is not fully reconciled with current `network_server` inventory.
- K3s still has both real bootstrap and stub/readiness surfaces; the plan must
  say exactly when each is used.

## Repo-Rule Violations Found

No direct mutation. The plan needs a read-only target verification step before
any future mutating host targeting changes.

## Naming/Schema Issues Found

The plan should reserve compact schema names for both upgraded servers before
implementation. Legacy long names must remain transitional only.

## NetBox Or Ansible Assumptions That Needed Correction

NetBox cannot be assumed fully usable from all agents until the permission issue
is resolved. Ansible inventory and NetBox seed/live state must be reconciled
before promotion to implementation.

## Final Reviewer Decision

Implementation readiness: 5/10. Implement this slice first after resolving
target names, coexistence versus replacement, and NetBox access.
