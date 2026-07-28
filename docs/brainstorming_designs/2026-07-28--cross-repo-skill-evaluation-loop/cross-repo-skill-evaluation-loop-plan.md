# Cross-Repo Skill Evaluation Loop Plan

## Intent

Evaluate where current skills should be used across project/framework surfaces.
Use existing evaluation skills first. Improve those skills when needed. Create
new skills only when the existing sequence cannot answer the need.

## Where Evaluation Skills Apply

### 1) `dotfile-vnext`

Targets:

- `AGENTS.md` and `docs/codex_framework/*` (process prose vs skill routing)
- `.cursor/rules/*` (governance vs operational instructions)
- `skills/catalog.yaml` and `.cursor/skills/` mirrors (authoring vs runtime drift)

Run first:

- `project-capability-surface-audit`
- `framework-skill-routing-auditor`
- `project-skill-runtime-bridge`

### 2) `global-skills`

Targets:

- `skills/catalog.yaml` quality and ownership boundaries
- skill process conformance (scope, metadata, handoffs, runtime bridge)

Run first:

- `skill-process-conformance-auditor`
- `project-skill-governance-and-migration`
- `validate-skill-library-metadata`
- `global-skill-runtime-bridge`

### 3) `homelab-reference-library`

Targets:

- `skills/catalog.yaml` routing and handoffs
- metadata and index integrity after skill/doc updates

Run first:

- `validate-library-metadata`
- `rebuild-library-indexes` (when catalog/docs changed)
- `skill-process-conformance-auditor` (cross-store checks when relevant)
- `project-skill-governance-and-migration` (ownership decisions when relevant)

## Default Sequence (before creating new skills)

1. `project-capability-surface-audit` (dotfile inventory)
2. `framework-skill-routing-auditor` (framework reduction candidates)
3. `project-skill-governance-and-migration` (cross-store rulings)
4. `skill-process-conformance-auditor` (quality gate)
5. Repo-local metadata validators / runtime bridge scripts as needed

## Improvement Loop For Existing Skills

1. Record the failure mode (missing branch, weak output contract, unclear handoff)
2. Patch the existing skill first
3. Rerun the evaluation sequence
4. Create a new skill only for a truly new capability family

## Related

- Sibling packet: `docs/brainstorming_designs/2026-07-28--skill-instruction-reduction-patterns/`
- Tracking (optional): repo-root `IN-PROGRESS.md` files for each project above
