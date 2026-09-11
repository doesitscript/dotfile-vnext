# Accepted gap — next major improvement

## Partial delivery (2026-09-11)

The storage campaign now has an explicit
[`refined-technical-handoff.md`](implementation-campaign/coordination/research-application/performance-layout-bootstrap-2026-09-11/refined-technical-handoff.md)
that maps post-research Expert/Researcher findings to project owners and
functional areas, and Light skills require it as the Implementer/Evaluator
primary input. The work queue is Implementer-owned and dynamic.

**Still deferred:** automatic parent scheduling of the full
Research-Synthesizer ↔ Expert ↔ Planner loop before every campaign. Manual or
bootstrap production of the refined handoff remains the activation path until
that scheduler exists.

## Status

Accepted as a future major-iteration design improvement for **auto-scheduling**
the research-application loop. The handoff artifact contract itself is no
longer an open gap for this campaign.

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

## Manual performance pass to automate

The user and On-site Expert demonstrated the missing loop in the storage
campaign: cross-reference research with verified hardware, current configured
surfaces, workload I/O patterns, durability classes, and available disk tiers;
then turn the result into a small set of placement decisions. The resulting
[performance layout evaluation](multi-agent-design/multi-agent-onsite-expert/examples/storage-performance-research-application.md)
used NVMe for model/image/PVC capacity, a smaller SATA SSD for isolated
low-value I/O such as journal/swap/rebuildable caches, and root for K3s durable
state plus kubelet-accounted pod logs.

In the next major iteration, this becomes a bounded **performance and placement
pass**, not another broad research phase:

1. Researchers organize existing domain findings by workload, I/O pattern,
   durability class, and candidate infrastructure surface.
2. A hardware/current-state collector supplies verified drive classes,
   capacity, attachment constraints, and current paths.
3. The Expert synthesizes those two inputs into a placement matrix, hard
   compatibility corrections, expected gain, validation metrics, and rollback.
4. The Planner maps each accepted placement to a narrow configuration/Ansible
   surface and materializes it before Implementer work begins.
5. The Evaluator verifies both the intended performance/durability fit and the
   measured post-change result; unsupported performance claims return as a
   targeted evidence request.

This preserves the value of broad research while making its application
repeatable, scoped, and efficient. It also gives future roles a defined way to
use every available storage tier rather than leaving smaller drives unused.

## Future acceptance signals

- The Expert receives an indexed, topic-to-decision research summary before
  making recommendations.
- Each planned configuration change links to the applicable current project
  surface and the evidence that selected its design.
- Performance/scalability claims are stated as assumptions and validation
  metrics rather than implied by a best-practice label.
- Implementer receives a materially complete plan; Evaluator can trace each
  applied decision back through the organized research and Expert rationale.
