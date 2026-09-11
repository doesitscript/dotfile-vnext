# Role interaction expansion

This future-facing design increment is informed by the live storage campaign:
late Implementer passes repeatedly performed discovery and contract validation
before producing a handoff. It is not a claim that the current runner already
launches these roles.

## Canonical plan and evidence contract

Research, receipts, topology facts, readiness briefs, decision records, and
role artifacts belong to the campaign/plan packet—not to an individual agent's
conversation memory. The Implementer, Evaluator, Researcher, and Resident
Expert receive the same relevant, versioned evidence paths and hashes. A later
role must reuse verified current evidence rather than rediscover it because an
earlier agent's private context is unavailable.

The canonical packet also names a
[decision authority profile](decision-authority-profiles.md). In this homelab,
`lab_recreatable_autonomy` auto-adopts evidence-backed Expert defaults within
the campaign scope; a future product can switch to `product_governed` and
restore human decision waits without changing role boundaries.

## Recommendation packet contract

The future handoff between Resident Expert and execution roles should include:

- campaign/upstream evidence identity and freshness;
- verified facts reused without reprobe;
- ranked feasible options and a recommended default;
- sizing/placement rationale, confidence, assumptions, and disqualifiers;
- expected benefit, validation, rollback, and relevant specialist sources;
- `human_decision_required: false` or one narrowly worded consequential
  approval question.

It must also declare its **consultation class**:

| Class | Meaning | Execution response |
| --- | --- | --- |
| Technical doubt | A bounded source/contract/design ambiguity within accepted scope | Implementer applies the Best recommendation and tests it. |
| Evidence gap | A named missing or conflicting fact changes the safe solution | Researcher/capability refreshes only that fact; Expert updates the recommendation. |
| Consequential decision | Cost, outage, retention, destructive target, or data-risk choice remains | Expert recommends a default; parent applies the named authority profile. This lab auto-adopts in scope; product governance waits for the narrow authority decision. |
| Implementation conflict | Current source/runtime evidence contradicts a recommendation | Implementer records a deviation/exception and routes it to Evaluator; it does not silently substitute a design. |

`Deviation` is therefore exceptional. It is not the ordinary response to an
expert consultation: ordinary consultation removes doubt so the established
plan can continue.

## Bounded consultation loop

The Expert is an evidence-aware consultant, not a parallel planner or an
implementation authority:

1. Implementer or Evaluator names the exact uncertainty and supplies the
   canonical plan/evidence paths it affects.
2. Expert consumes the relevant evidence and produces a scoped recommendation
   packet, not a broad replacement plan.
3. Implementer uses a technical Best recommendation in the existing plan seam,
   records the receipt, and returns the normal review-ready handoff.
4. Evaluator tests recommendation fit, evidence, safety, and any recorded
   exception. Recommendation is never automatic approval.
5. The parent applies the named authority profile. This lab records and adopts
   an evidence-backed default; the product profile pauses for the smallest
   authority question.

## Value by role

| Role | Added value | Avoids |
| --- | --- | --- |
| Resident/On-site Expert | Synthesizes project knowledge and specialist evidence into a safe default | Human-as-system-designer and repeated broad discovery |
| Researcher | Refreshes only named gaps or conflicting technical options | Generic research sweeps that do not change execution |
| Knowledge capability | Supplies domain constraints/modules/patterns on demand | Recreating a permanent expert role for each technology |
| Implementer | Continues the existing plan using a bounded technical recommendation; records an exception only for a real source/runtime conflict | Re-solving architecture during every finite pass |
| Evaluator | Tests evidence, recommendation fit, safety, and any exception rationale | Treating a recommendation as automatic approval |
| Observer/operator | Surfaces gate, evidence freshness, and blocked approval succinctly | Confusing runtime activity with implementation quality |

## Automation boundary

Automate evidence routing, freshness checks, option comparison, default
recommendation, and narrow decision extraction. Retain human control for new
cost commitments, outage windows, retention policy, and irreversible data-risk.
That is a deliberate approval boundary—not a gap requiring the human to design
the implementation. The designated Expert should narrow those choices to a
recommended default and motivation before the human is asked.

For this lab, the profile intentionally overrides that final human wait for
recreatable, availability-tolerant work. It does not override technical
evidence, target-identity, evaluator, or receipt requirements.
