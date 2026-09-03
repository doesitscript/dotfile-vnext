---
title: Conceptual Sequence Diagram - Inbox Outbox Coordination
created_at: 2026-09-03
status: active
---

# Conceptual Sequence Diagram - Inbox Outbox Coordination

## Purpose

This is a conceptual coordination diagram. It intentionally uses tool-agnostic
language so the core paired-agent workflow is understandable even if the
underlying transport, orchestration engine, or client runtime changes later.

The model is:

- each role has an inbox
- each role can place work into its outbox
- the other role receives that work in its inbox
- the loop continues until approval is issued and no further action is pending

## Conceptual Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Shared as Shared Work Packet
    participant IInbox as Implementer Inbox
    participant Impl as Implementer
    participant IOutbox as Implementer Outbox
    participant EInbox as Evaluator Inbox
    participant Eval as Evaluator
    participant EOutbox as Evaluator Outbox

    User->>Shared: Define task scope and expected outcome
    User->>IInbox: Place initial assignment

    IInbox->>Impl: Deliver assigned work
    Impl->>Shared: Read scope, current work, and prior history
    Impl->>Impl: Perform implementation work
    Impl->>IOutbox: Place review-ready work item
    IOutbox->>EInbox: Deliver review request

    EInbox->>Eval: Deliver work for evaluation
    Eval->>Shared: Read scope and review-ready work

    alt Work is not yet satisfactory
        Eval->>EOutbox: Place actionable feedback
        EOutbox->>IInbox: Deliver feedback to implementer
        IInbox->>Impl: Deliver correction request
        Impl->>Shared: Read feedback and current state
        Impl->>Impl: Apply corrections
        Impl->>IOutbox: Place corrected review-ready work item
        IOutbox->>EInbox: Deliver corrected work for re-review
        EInbox->>Eval: Deliver corrected work
        Eval->>Shared: Re-read corrected work
    else Work satisfies scope and quality bar
        Eval->>EOutbox: Place approval
        EOutbox->>Shared: Record approval and completion signal
    end

    Note over Impl,Eval: Done condition = evaluator has approved,\nall requested corrections are closed,\nand neither inbox contains pending work.
    Shared-->>User: Work complete and durably recorded
```

## Explanation

This diagram strips away product-specific details and shows only the enduring
workflow contract. The implementer does not decide completion alone. Its job is
to perform the assigned work and place a review-ready result into its outbox.
That output becomes the evaluator's next inbox item.

The evaluator then decides whether the work is satisfactory. If it is not, the
evaluator places actionable feedback into its outbox, and that becomes a new
inbox item for the implementer. The implementer responds to that feedback and
returns a revised review-ready result. This continues until the evaluator no
longer has open objections.

The important completion rule is intentionally simple and transport-agnostic:
work is done only when approval has been placed and there is no remaining
pending item in either agent's inbox. In other words, "done" requires both a
positive decision and an empty-action state. That rule should remain true even
if the project later changes its orchestration engine, messaging layer, or AI
client.

## Done condition

The workflow is complete only when all of the following are true:

- the evaluator has issued approval
- the implementer has no unresolved feedback remaining
- the evaluator has no pending review item remaining
- the shared work packet contains the final approved state

## Mapping note

This document is conceptual on purpose. It does not prescribe whether inboxes
and outboxes are implemented with files, broker messages, task states, queue
objects, or a different transport. It defines the coordination semantics that
the implementation must preserve.
