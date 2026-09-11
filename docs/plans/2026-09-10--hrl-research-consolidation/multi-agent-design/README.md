# Multi-agent design (source project)

This folder is the **main multi-agent design project** for the HRL research
consolidation / storage campaign: role definitions, Light orchestration, and
runtime adapters. It is primarily **source material** for how agents coordinate;
live campaign artifacts live under `../implementation-campaign/`.

## Start here

| Doc | Role |
| --- | --- |
| [START-HERE.md](START-HERE.md) | How to launch preparation / implementation |
| [orchestration/01-critical-path--expert-to-evaluator.md](orchestration/01-critical-path--expert-to-evaluator.md) | **Big-picture critical path** |
| [orchestration/02-authority--who-to-call.md](orchestration/02-authority--who-to-call.md) | Who owns judgment / who to call |
| [orchestration/03-handoffs-and-loops.md](orchestration/03-handoffs-and-loops.md) | Handoffs, loops, Light vs Full |
| [orchestration/04-decision-authority-profiles.md](orchestration/04-decision-authority-profiles.md) | Lab vs product authority profiles |

## Core components (folders)

| Folder | Owns |
| --- | --- |
| `orchestration/` | Critical-path extract, authority, handoffs, diagrams, Light contracts, parent skills |
| `multi-agent-onsite-expert/` | Expert role, transcript, research-application examples |
| `researchers/` | Researcher / synthesizer skills |
| `implementer/` | Light (+ full) Implementer skills |
| `evaluator/` | Light (+ full) Evaluator skills |
| `runtime/` | Parent runner (`run-implementation.ts`), contract tests |
| `observer/` | Optional observe skill (not on critical path) |
| `agent-prompts/` | Copy/paste prompts for preparation / beta launch |
| `capability.yml` | Packet ownership for preparation trial |

## Critical scaffolding

Expert work-area conversation → research-enhanced recommendation →
**refined technical handoff** → Implementer Ansible chunks ↔ Evaluator.

Do not feed the raw Expert transcript to Implementer/Evaluator as the work
spec. Use the refined handoff under the implementation campaign.
