# Accepted gap — next major improvement

## Status

Accepted as a future major-iteration design improvement. The current
research-to-Expert-to-Implementer/Evaluator workflow is stable enough to use;
this note does not reopen the present storage campaign or alter its decisions.

## Observed gap

Research expanded into multiple findings and was subsequently organized and
indexed within this plan work. The On-site Expert did consume the initial
research and adjusted its recommendations, which kept the current result
evidence-driven and stable. That organized research/index phase, however, was
not explicitly coordinated as a concise, decision-specific input to the
On-site Expert.

## Desired next-iteration capability

Introduce a deliberate multi-stage planning loop between research organization,
the On-site Expert, and plan composition:

1. Research organizers condense the already-collected findings by the decision
   topics surfaced by the Expert, preserving sources, confidence, alternatives,
   performance implications, and unresolved assumptions.
2. The Expert uses those concise decision packets to select or refine the best
   design, implementation shape, best-practice defaults, and performance
   tradeoffs without repeating broad discovery.
3. The Planner maps each selected decision to the actual project surfaces and
   configured technologies that represent it today.
4. For each small configuration/change surface, the organized evidence guides a
   scalable design choice, an Ansible or general implementation step,
   validation, rollback, and measurable expected improvement.
5. The resulting materialized plan goes to Implementer and Evaluator with its
   research-to-decision traceability intact.

This should progress from sound general decisions to specific, evidence-backed
configuration changes. It is intended to improve stability, performance-aware
design, and reuse of existing research—not to add unbounded research or make
the current roles wait for a human by default.

## Future acceptance signals

- The Expert receives an indexed, topic-to-decision research summary before
  making recommendations.
- Each planned configuration change links to the applicable current project
  surface and the evidence that selected its design.
- Performance/scalability claims are stated as assumptions and validation
  metrics rather than implied by a best-practice label.
- Implementer receives a materially complete plan; Evaluator can trace each
  applied decision back through the organized research and Expert rationale.
