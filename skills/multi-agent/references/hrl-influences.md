# Homelab Reference Library — implementer influences

Read when booting skill `multi-agent-implementer`. Paths are under
`/Users/joshc/develop/homelab-reference-library/` unless noted.

## Separation of evaluator vs implementer

| HRL path | Use |
| --- | --- |
| `implementation-guides/agentskills/skill-scripting-quality-evaluation.md` | Two-doorway eval; evaluator writes `evaluator_feedback.md`; skill writer fixes in a **separate** role — do not collapse in one turn without evidence |
| `skills/_shared/agent-stack-layers.md` | Skills = portable procedures; LangGraph = future graph runtime — this loop is **skill-orchestrated**, not graph-hosted |

**Carryover:** Same model may play evaluator then implementer in **sequence**;
in one implementer turn, do not perform evaluation authorship.

## Evidence and receipts

| HRL path | Use |
| --- | --- |
| `implementation-guides/agentskills/skill-scripting-quality-evaluation.md` § Anchored | Quote command output in receipts; evaluator feedback must cite evidence |
| `implementation-guides/pytest/user-journey-receipt-tests.md` | (if present) Receipt-shaped proof for automation — analog to `EXECUTION-RECEIPT.md` |

**Project pairing:** `docs/codex_framework/verification-before-completion-gate.md`,
Superpowers `verification-before-completion`.

## Governance

| HRL path | Use |
| --- | --- |
| `governance/ai/agent-runtime-selection.md` | Client vs runtime vs gateway — implementer works at skill + Ansible layer |

## Project-native (not HRL but required with HRL)

| Path | Use |
| --- | --- |
| `dotfile-vnext/docs/codex_framework/plan-verification-receipt.md` | Obligation inventory for plan closeout after evaluator sign-off |
| `dotfile-vnext/skills/one-off/one-off-promotion-verify` | Live Ansible execute-complete for promotion scope |
| `dotfile-vnext/skills/multi-agent/references/implementer-good-bad-examples.md` | Calibration from codex multi-terminal run |

## Library topic check

```text
Exists:
- implementation-guides/agentskills/skill-scripting-quality-evaluation.md — evaluator/implementer split
- skills/_shared/agent-stack-layers.md — stack mental model

Missing:
- dedicated HRL pack for Cursor folder-watch evaluator loops — covered by project skills/multi-agent/

Research Needed: none for implementer bootstrap
Context7: skipped (local guides sufficient)
```
