---
title: First Pass Operator Prompt - Single Entry Validation
created_at: 2026-09-03
status: active
---

# First Pass Operator Prompt - Single Entry Validation

## Purpose

This document defines the target single-entry operator prompt for the first-pass
paired-agent orchestration validation. It is not proof that the implementation
already exists. It is the prompt shape the implementation should make possible.

## Local documentation already available

The project already has enough documentation to kick off the first pass, but it
is a **starter set**, not a finished turnkey runbook.

Most relevant local references:

- [skill-upgrade-first-pass.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan/skill-upgrade-first-pass.md)
- [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan/README.md)
- [UML-sequence-diagram.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan/UML-sequence-diagram.md)
- [conceptual-sequence-diagram-inbox-outbox.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan/conceptual-sequence-diagram-inbox-outbox.md)
- [multiagents-codex-cli-orchestration.md](/Users/joshc/develop/homelab-reference-library/vendor/mcp/context7-style/multiagents-codex-cli-orchestration.md)
- [codex-app-server-protocol-and-setup.md](/Users/joshc/develop/homelab-reference-library/vendor/mcp/context7-style/codex-app-server-protocol-and-setup.md)
- [client-enablement-matrix-cursor-codex-continue.md](/Users/joshc/develop/homelab-reference-library/implementation-guides/mcp/client-enablement-matrix-cursor-codex-continue.md)
- [where-does-codex-read-mcp-config.md](/Users/joshc/develop/homelab-reference-library/q-and-a/codex/where-does-codex-read-mcp-config.md)

## Correct mental model

Your expectation is close, with one correction:

- yes, the ideal target is one single operator entrypoint
- yes, the system should spawn or resume the paired workflow and keep the roles
  moving
- yes, you should be able to observe role-to-role progress and reported state
- but the meaningful proof is not just "I saw extra agents appear"

The meaningful proof is:

- the orchestrator assigned distinct implementer and evaluator roles
- those roles exchanged real handoffs
- the outputs for those handoffs were captured
- the evaluator, not the implementer, ended the loop

## Target operator prompt

Use this as the target first-pass validation prompt once the implementation is
ready:

```text
Start the Codex-first paired-agent workflow for plan_dir=/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan using the first-pass staged ping-pong validation target.

Requirements:
- use the implementer and evaluator role contracts defined by the paired-agent skills
- use the minimal multiagents orchestration slice, not the broader final configuration
- use the minimal Codex app-server setup required for real thread/turn control
- run the smoke target first, then the 10-handoff stability target, then the 20-handoff acceptance target only if the earlier stages pass
- capture and show concrete output for each claimed passing stage
- do not summarize with "worked as expected" without evidence
- end the final passing stage by evaluator approval, not implementer self-declaration

Report back with:
- session or workflow identifier
- which role sessions were started or resumed
- the app-server setup and handshake evidence used for the run
- the observed handoff trail
- the artifacts or logs that prove each handoff
- the exact approval evidence for the terminating evaluator pass
- explicit pass/fail/unverified status for smoke, stability, and acceptance
```

## What you should expect to observe

If the first pass is implemented correctly, the observable behavior should look
roughly like this:

1. One Codex invocation accepts the single-entry request.
2. The orchestrator reports that it created or resumed a paired session.
3. The orchestrator identifies two distinct role participants:
   - implementer
   - evaluator
4. The implementer acts first and produces a review-ready output.
5. The evaluator receives that output and produces either feedback or approval.
6. The cycle continues through the staged ping-pong targets.
7. The final successful stage ends only when the evaluator emits approval.

## What does not count as proof

These observations are not sufficient by themselves:

- seeing a dashboard or extra terminal appear
- seeing a vague status like "workflow running"
- a final claim that the test passed with no handoff evidence
- implementer saying it is done without evaluator approval

## Minimum acceptable validation output

The implementing agent should show you at least:

- the workflow or session identifier
- the role identifiers or role names used
- the stage being tested
- the exact handoff count reached
- the ordered handoff evidence
- the final evaluator approval artifact or equivalent terminating output

## Why this is the right first operator test

This prompt tests the exact thing the new architecture is supposed to solve:
single-entry startup plus orchestrated back-and-forth without you manually
driving every handoff. It is intentionally small enough to validate the role
contract first, before broader scenario/config complexity is added.
