---
name: onsite-expert-consultation-light-beta
description: "Resolve one named technical fork from settled research for a Light implementation run; may run read-only project probes for target identity. No Apply."
metadata:
  status: beta
  scope: bounded-light-consultation
  workflow_id: resident-expert-researcher-sidecar
  evaluation_role: onsite-expert-coordinator
  counterpart_role: researcher
---

# On-site Expert consultation — Light

Use this only when the parent supplies a named `consultation_request_path`.
Read that request, its cited settled research, and current campaign evidence.
Frame the exact technical fork and give an evidence-backed **Best
recommendation** the Implementer can fit into existing role/playbook ownership.

This is a recreatable lab: answer as an on-call human would—best practice and
best recommendation from settled research. Do not invent production outage
windows, heavy backup/rollback theater, or deferred “validation question”
packs that avoid deciding.

## Target identity — find, never invent

If the fork needs an exact host/disk/path/slot identity, **obtain it**:

1. Repo inventory / host_vars / prior receipts first
2. Else project read-only Ansible/report owners via `bin/codex-env`
3. Else live read-only probe on the inventory host:
   - Linux: SSH/bash or Ansible modules
   - Windows: `ansible.windows.win_powershell` or
     `homelab-ssh-alias-connect` remote PowerShell helper — not nested
     `ssh … powershell -Command "…"` one-liners

Cite the exact command and captured output in the consultation artifact.
Do **not** guess by-id/serial. Do **not** Apply, attach, format, or mutate
during this consultation unless the parent explicitly authorized that Full
Apply action in the request.

Write only the requested consultation artifact. Include the request path,
recommendation, motivation, evidence (including probe output when used),
assumptions, affected owners, validation expectations, and `return_to`. Do not
reopen broad preparation, restructure the campaign plan, or edit Implementer-
owned source. The recommendation narrows a doubt and may bind identity; it is
not deployment authority by itself.

When a consultation changes a settled placement or hard correction, say so
explicitly and name that Planner must refresh the refined technical handoff
before the next Implementer pass. Do not expect Implementer to discover the
change from chat alone.

See also [06-expert-on-call--lab-consultation.md](../../../orchestration/06-expert-on-call--lab-consultation.md).

The paired Researcher receives this output next and tests its evidence coverage.
