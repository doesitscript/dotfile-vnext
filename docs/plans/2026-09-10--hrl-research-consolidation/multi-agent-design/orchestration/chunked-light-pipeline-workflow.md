# Chunked Light implementation pipeline

```mermaid
flowchart LR
  H[Refined technical handoff\nfunctional areas → owners] --> I[Implementer derives/refreshes queue]
  I --> Q[Dynamic work queue]
  Q --> C[Implementer selects one ready chunk]
  C --> S[Freeze owner diff hashes and validation]
  S --> E[Evaluator reviews frozen snapshot]
  S --> N[Implementer begins next independent area]
  E -->|accepted| A[Committable chunk]
  E -->|feedback| F[Only affected owners return]
  F --> C
  N --> S
```

The **refined technical handoff** is the first input. The work queue is
Implementer-owned: derived from the handoff’s functional areas, not a static
script. Implementer selects the earliest ready non-overlapping chunk, edits
those Ansible owners, validates, and freezes a snapshot. Evaluator reviews that
snapshot while Implementer may begin only the named next independent area.

This is safe only when owner roots, generated artifacts, and shared playbooks
do not overlap. Feedback that changes a later chunk's design pauses that chunk.
Live Apply, target identity, and final multi-owner synthesis remain serial,
Full-lane work.
