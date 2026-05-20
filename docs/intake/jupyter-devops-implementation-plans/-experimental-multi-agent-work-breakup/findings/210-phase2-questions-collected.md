# 210 Phase 2 Questions Collected

## Finding Topic

Questions that must be resolved before final plan edits or implementation.

## Date

2026-05-20

## Plan Slice Or Task

All Phase 2 plan slices.

## Agent/Model Used

Main Codex fallback coordinator, using outputs from all six planner agents.

## Runtime Context If Known

Read-only synthesis. No infrastructure changes.

## Input Given To The Agent

Six planner findings plus coordinator repo checks.

## Output Artifact Path

This file.

## Questions For User

1. Do the two upgraded servers replace the current `network_server` lane, or
   coexist with it during migration?
2. What compact schema names and `idx` reservations should be assigned to the
   5090 server and the second upgraded server?
3. Should AI workload identities use an `aix` domain now, or should hosts stay
   in `hom-lab-ctl-*` while only services use `jpy`, `lfs`, `llm`, `vlm`, and
   `hfc` codes?
4. Should runtime service endpoints be modeled in NetBox in this pass, or stay
   in Ansible vars until a dedicated service endpoint model is approved?
5. For Langfuse, should the first pass use bundled in-cluster dependencies or
   external/shared Postgres, Redis, and object storage?
6. For JupyterLab, is the first workbench a systemd service on a VM, a user
   service, a container, or a Kubernetes workload?
7. For vLLM/Hugging Face cache, is the cache a shared PVC, host path, separate
   cache role, or runtime-local path?
8. Should LiteLLM launch with a real provider route, a vLLM route, or an
   explicit placeholder route until vLLM is live?
9. Should the validation notebook run from the local Mac, the JupyterLab host,
   or both?
10. Should the stale comment in
    `inventory/host_vars/hom-lab-ctl-k3s-01.yaml` be cleaned during the final
    plan edit pass or deferred to implementation?

## Strengths

The question set separates naming, NetBox, Ansible, platform dependency, and
runtime concerns.

## Gaps Or Failures

No user answers are recorded yet. Add `211-phase2-user-answers.md` after the
next decision pass.

## Repo-Rule Violations Found

None.

## Naming/Schema Issues Found

Domain placement is the largest unresolved schema question.

## NetBox Or Ansible Assumptions That Needed Correction

NetBox service endpoint modeling must not be assumed complete.

## Final Reviewer Decision

Block final plan edits on at least questions 1 through 5.
