# Cross-Repo Skill Evaluation Loop Plan

## Intent Snapshot

Evaluate where current skills should be used across project/framework surfaces,
use existing evaluation skills first, and improve those skills when needed.
Avoid one-off setup paths.

## Findings: Where Evaluation Skills Should Be Applied

### 1) `dotfile-vnext` framework and capability surfaces

Primary evaluation targets:

- `AGENTS.md` and `docs/codex_framework/*` (repeated process prose vs skill routing)
- `.cursor/rules/*` (governance vs operational instructions)
- `skills/catalog.yaml` and `.cursor/skills/catalog.yml` (authoring vs runtime mirror drift)
- wrapper/runtime paths (`bin/codex-env`, bridge scripts, validation command surfaces)

Existing skills to run first:

- `project-capability-surface-audit`
- `framework-skill-routing-auditor`
- `project-skill-runtime-bridge`

### 2) `global-skills` reusable store governance

Primary evaluation targets:

- `skills/catalog.yaml` quality and ownership boundaries
- skill process conformance (scope, metadata, handoffs, runtime bridge)
- wrapper runtime policy (`bin/gs-env`) for reusable bootstrap behavior

Existing skills to run first:

- `skill-process-conformance-auditor`
- `project-skill-governance-and-migration`
- `validate-skill-library-metadata`
- `global-skill-runtime-bridge`
- `venv-wrapper-runtime-bootstrap`
- `new-computer-skill-runtime-bootstrap`

### 3) `homelab-reference-library` project skill store

Primary evaluation targets:

- `skills/catalog.yaml` routing and handoff shape
- metadata and index integrity post-skill updates
- wrapper runtime policy (`bin/hrl-env`) consistency with the cross-repo pattern

Existing skills to run first:

- `validate-library-metadata` (HRL-local skill)
- `project-skill-governance-and-migration` (cross-repo ownership decisions)
- `skill-process-conformance-auditor` (cross-store duplication/conformance checks)
- `venv-wrapper-runtime-bootstrap`

## Skill Likely Already Exists: Apply Before Creating New

Default evaluation order:

1. `project-capability-surface-audit` (dotfile project inventory)
2. `framework-skill-routing-auditor` (framework reduction candidates)
3. `project-skill-governance-and-migration` (cross-store migration rulings)
4. `skill-process-conformance-auditor` (quality gate for changed skills)
5. Repo-local metadata validators and runtime bridge scripts

Only add new skills when this sequence cannot answer the evaluation need.

## Improvement Loop For Existing Skills

When existing skills are insufficient:

1. record failure mode (missing decision branch, weak output contract, unclear handoff)
2. patch the existing skill first (inputs, workflow, validation, handoff)
3. rerun the evaluation sequence
4. create a new skill only for truly new capability families

## Cross-References To IN-PROGRESS

- `dotfile-vnext/IN-PROGRESS.md`
- `global-skills/IN-PROGRESS.md`
- `homelab-reference-library/IN-PROGRESS.md`

These IN-PROGRESS files track Mac-side completion work for wrapper/runtime
setup and should be reviewed before finalizing the evaluation loop execution.

## Mac Completion Note

This packet is intentionally execution-neutral. Operational completion steps are
tracked in the linked IN-PROGRESS files and should be finished on Mac.
