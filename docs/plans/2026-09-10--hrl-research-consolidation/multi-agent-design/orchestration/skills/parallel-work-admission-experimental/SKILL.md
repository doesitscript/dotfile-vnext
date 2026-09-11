---
name: parallel-work-admission-experimental
description: "Assess candidate implementation-preflight work for safe parallel execution, quarantine incompatible jobs with a receipt, and supply an admitted read-only fan-out to the parent orchestrator. Use only before a serial Implementer/Evaluator pass."
metadata:
  status: experimental
  scope: bounded-read-only-preflight
  workflow_id: evaluator-implementer-loop
  role: preflight-admission
---

# Parallel work admission — experimental

Use this only to shorten independent discovery, ownership mapping, contract
inspection, or tests before the serial implementation loop. It is not an
approval mechanism and does not create parallel source edits or host changes.

Build at most four candidates with distinct facts to collect. Good examples are
verified-route evidence, storage/Alloy/vLLM ownership mapping, Ansible
inspection, and fast tests. Do not split work that shares a mutable file, a
host target, a user decision, or final technical synthesis.

Pass candidates as `parallel_preflight_jobs` to the parent runner. The runner
uses `runtime/run-parallel-preflight.ts`, which permits only allowlisted
read-only commands. It records accepted jobs and every rejected candidate in
`parallel-preflight/admission.json`, then omits rejected candidates from the
derived manifest. This is the experimental self-healing behavior: **quarantine
and explain; never delete source, receipts, artifacts, sessions, or processes.**

Afterward, the Implementer reads the manifest and makes the single technical
synthesis. The Evaluator reviews that synthesis and the receipts serially.
Failed read-only jobs are evidence, not an excuse to infer missing facts.
