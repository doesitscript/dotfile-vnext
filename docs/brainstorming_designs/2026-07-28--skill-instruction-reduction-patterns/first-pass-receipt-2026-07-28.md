# Skill instruction reduction — first pass receipt (2026-07-28)

Source packet: `docs/brainstorming_designs/2026-07-28--skill-instruction-reduction-patterns/`

## Hotspots found

| current repeated instruction | exact location | candidate skill / action | reduction class | migration risk |
| --- | --- | --- | --- | --- |
| Full always-on framework family was already reduced; keep only thin boot rules | `.cursor/rules/framework-context-budget.mdc`, `framework-user-interaction-style.mdc`, `framework-ai-agent-model-lanes.mdc` | keep as-is; load heavy `framework-*` on demand | already reduced | low — re-enabling always-on would blow Ornith 32k |
| Diagram skill lived as personal/local copy then global promotion left backup dirt | `roles/common/agent_skills/files/cursor/skills/create-diagrams.before-…` | prefer `create-diagrams` global skill; delete bridge backups | small | low — backup removed this pass |
| Skill-standards audit phrasing vs conformance skill | global `skill-process-conformance-auditor` triggers | use that skill; avoid restating audit process in prompts | small | low |
| Ansible install/mutate process restated in AGENTS + rules | `AGENTS.md` §32, `homelab-ansible-first-entry` | keep entry-door skill; do not duplicate full procedure in always-on rules | medium | medium if someone always-applies ansible-coding-standards |

## Actions taken this pass

1. Removed obsolete `create-diagrams.before-global-skill-runtime-bridge-*` backup under role skill files.
2. Refreshed project skill runtime bridge (`project-skill-runtime-bridge`).
3. Confirmed only three always-on framework rules remain (context budget + interaction style + model lanes).

## Not done (deferred)

- Full `generate-project-state-report` / `ansible-coordinator` / `generate-mcp-briefing` runs (larger token pass).
- Scaffolding new micro-skills from hotspots (not needed until a second measurement).
