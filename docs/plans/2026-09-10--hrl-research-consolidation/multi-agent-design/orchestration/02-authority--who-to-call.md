# 02 — Authority: who to call

Who owns judgment, who supplies facts, who signs quality.

| Need | Go to | Do not |
| --- | --- | --- |
| Frame problem / work area / decision questions | **On-site Expert** | Researcher inventing scope |
| Missing / stale / conflicting fact | **Researcher** (then Expert) | Broad rediscovery |
| Technical fork: placement, sizing, mechanism | **On-site Expert** Best recommendation ([on-call](06-expert-on-call--lab-consultation.md)) | Implementer guessing design |
| Map decision → roles/playbooks/owners | **Planner / Coordinator** | Handing raw research to Implementer |
| Source edits + review-ready package | **Implementer** | Evaluator writing fixes |
| Ansible quality / chunk accept or reject | **Evaluator** | Parent “approving” from dashboard |
| Schedule next role / runtime lifecycle | **Parent orchestrator** | Roles polling each other |
| Consequential product cost/outage/data-risk | **Human operator** (`product_governed`) | Lab auto-adopt outside scope |
| Exact host/disk identity before Apply | Read-only discovery (evidence gate) | Guessing by-id |

## Authority profiles

| Profile | When | Effect |
| --- | --- | --- |
| `lab_recreatable_autonomy` | This homelab campaign | Auto-adopt evidence-backed Expert Best defaults into the plan; keep target checks + Evaluator |
| `product_governed` | Future product | Expert default is proposed; human wait for consequential choices |

Neither profile grants Apply by implication. Recommendation ≠ deployed.

## Artifact ownership (hard)

| Role | Owns | Never owns |
| --- | --- | --- |
| Expert | Recommendations, framing | Apply, Evaluator verdicts |
| Researcher | Evidence deltas | Plan decisions, source edits |
| Planner | Refined technical handoff, plan materialization | Implementation edits |
| Implementer | Source intake from handoff, receipts, `review_ready_*`, dynamic queue | Feedback / ready verdicts; redesign |
| Evaluator | `feedback_*` / `waiting_*` / `ready_*` | Source fixes |
| Parent | Dispatch, locks, cleanup | Quality judgment |

Shared memory is durable artifacts. Private chat is not authority.
