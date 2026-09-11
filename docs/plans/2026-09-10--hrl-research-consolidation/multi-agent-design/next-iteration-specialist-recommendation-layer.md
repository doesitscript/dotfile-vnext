# Next iteration: specialist recommendation layer

## 1. Current, verified boundary

The active implementation runner operates an Implementer ↔ Evaluator loop. It
can perform safe discovery and create fail-closed scaffolding, but it does not
currently launch the Resident/On-site Expert or Researcher roles before an
implementation pass. Therefore, it properly preserves unselected physical
storage, backup, outage, and monitoring choices as blocked rather than inventing
them.

## 2. User-directed target state

The goal is not to transfer infrastructure design labor to a human. The system
should use research and project-local expertise to produce an evidence-backed,
recommended implementation design. A human is asked only to approve a material
commitment or resolve a legitimate preference/tradeoff.

## 3. Role improvements and handoff

```text
Researcher ──> Resident/On-site Expert ──> Recommendation packet ──> Implementer ──> Evaluator
                  │                                  │
                  └─ accelerate discovery             └─ narrow human approval only when needed
```

### Researcher

- Gather targeted external/HRL/vendor knowledge for the exact technology and
  decision, not a broad best-practice audit.
- Return source-backed constraints, supported patterns, and unknowns.

### Resident/On-site Expert

- Read project configuration, inventory, receipts, topology, and Researcher
  findings.
- Reconcile them into ranked options and a default recommendation.
- State capacity assumptions, workload impact, required proof, rollback, and
  the smallest remaining human decision.
- Run/coordinate early safe discovery so later Implementer passes do not spend
  their first turn rediscovering known project facts.

### Recommendation packet (new future handoff contract)

Use a durable, identity-bound packet with: `campaign_id`, upstream evidence
digest, observed topology, ranked options, recommended option, confidence,
assumptions, cost/outage/backup effects, rollback, required validation, and
`human_decision_required`. The latter is either `false` or a narrow approval
question; it is never a generic request for the human to design the system.

### Implementer and Evaluator

Implementer consumes the recommendation as a bounded design input, retains
fail-closed authority gates, and records any deviation. Evaluator independently
checks evidence, recommendation fit, safety, and execution receipts. Neither
role silently converts a recommendation into live-Apply permission.

## 4. Next implementation slice

Add an optional upstream specialist stage to the parent workflow. It should
produce a recommendation packet for S3–S5 before the Implementer loop starts,
but remain explicitly **not yet implemented** in the current runner. Validate
it first on this storage campaign and then on an unrelated change class.
