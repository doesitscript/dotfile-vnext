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
edit implementation sources, perform host discovery, run Apply, or replace the
Implementer/Evaluator's ownership. If evidence is insufficient, state the one
missing fact precisely while unrelated source work continues.
