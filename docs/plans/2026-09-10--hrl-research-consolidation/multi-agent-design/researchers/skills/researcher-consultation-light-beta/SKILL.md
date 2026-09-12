---
name: researcher-consultation-light-beta
description: "Verify and synthesize evidence for one On-site Expert technical fork during a Light implementation run."
metadata:
  status: beta
  scope: bounded-light-consultation
  workflow_id: resident-expert-researcher-sidecar
  evaluation_role: researcher
  counterpart_role: onsite-expert-coordinator
---

# Researcher consultation — Light

Use this only when the parent supplies a named `consultation_request_path` and
the paired On-site Expert output. Read the named request, that output, and only
the cited settled research/campaign evidence. Verify whether the recommendation
is supported, identify a material caveat or a narrower alternative when needed,
and return a concise synthesized recommendation to the requesting role.

Write only the requested consultation artifact. Include the request path,
reviewed Expert artifact, evidence coverage, recommendation disposition,
assumptions, affected owners, and `return_to`. Do not repeat broad research,
edit implementation sources, or run Apply. If Expert cited a live probe,
verify that evidence (re-read receipt/output or a matching read-only re-check
via project Ansible/SSH helpers when needed). Do not invent by-id/serial.
If evidence is insufficient, state the one missing probe precisely so Expert
can re-run it—do not escalate that fact to the human when the lab can obtain it.
