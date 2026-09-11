# 03 — Handoffs and loops

## Critical handoff chain

| From → To | Artifact | Meaning |
| --- | --- | --- |
| Expert → Researchers | Decision questions + scope | Not a topic dump |
| Researchers → Expert | Evidence packets / Context7 packs | Facts + confidence + gaps |
| Expert → Planner | Settled recommendation | Best / Preference + assumptions |
| Planner → Implementer/Evaluator | **`refined-technical-handoff.md`** | Hard corrections, placement, functional areas → owners |
| Implementer → Evaluator | `review_ready_for_evaluator_*` | One frozen chunk (`chunk_id`, hashes, validation) |
| Evaluator → Implementer | `feedback_*` | Specific file/owner corrections |
| Evaluator → done | `ready_for_review_by_evaluator_*` | Chunk (Light) or campaign (Full) accept |
| Any → Expert/Researcher | Named consultation request | One fork only; refresh handoff if design changes |

Classification-only packets without a refined handoff are **incomplete**.
Transcripts are provenance, not Implementer input.

## Loops

**Research application (pre-Implementer)**  
Expert frames → Synthesizer classifies → Expert challenges → Planner
materializes handoff. Repeat only on named ambiguity.

**Light Implementer ↔ Evaluator**  
Implementer derives queue from handoff functional areas → freezes one chunk →
Evaluator reviews freeze → Implementer may start next non-overlapping area.
Feedback returns to its chunk only.

**Bounded consultation (during Light)**  
Named fork → Expert then Researcher sidecar → paths supplied to the pair.
Does not restart preparation.

**Full Orchestration (explicit only)**  
Live identity, Apply, deployment proof. Never an automatic escalation from a
Light source finding.

## Consultation classifier (short)

| Signal | Route |
| --- | --- |
| Decision already in handoff | Continue |
| Technical doubt | Expert |
| Missing fact | Researcher → Expert |
| Missing target identity | Read-only discovery |
| Source/runtime conflict | Exception → Evaluator |
| Out-of-lab consequential choice | Human |

## Light vs Full

Light: source-first Ansible quality, cattle posture, dynamic chunks.  
Full: SSH/live proof, Apply, safety/identity gates—only when named.
