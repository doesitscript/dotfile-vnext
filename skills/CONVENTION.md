# Dotfile Skill Convention

Authority for project-skill layout in this repo:

1. `AGENTS.md`
2. `skills/catalog.yaml`
3. this file

**Format authority:** Agent Skills ([agentskills.io](https://agentskills.io)).

**Scaffold / contract sync:** Prefer creating and aligning project skills via
`global-skills` (schema, `_template/`, scaffold skills). Soft provenance fields
(`based_on_library`, `based_on_library_version`, `library_contract_version`)
come from `global-skills/skills/library_contract.yaml`. Mismatch or absence is
advisory only — do not hard-fail validation on version skew today.

Pattern source: `/Users/joshc/develop/homelab-reference-library/skills` and
`/Users/joshc/develop/global-skills/skills`.

## Goals

1. Discoverable — agents match on catalog descriptions and triggers first.
2. Lean — `SKILL.md` should stay concise and point to references only when needed.
3. Routable — the catalog should encode handoffs instead of duplicating them in prose everywhere.
4. Honest — `status` and workflow limits must match reality.
5. Safe — no secrets in skill files, and no repo-wrapper bypass for Python or Ansible work.
6. Adaptable — runtime-specific companion metadata can evolve by provider without changing the core skill contract.

## Pack layout

```text
skills/<category>/<skill-name>/
  SKILL.md
  agents/                  # optional provider-specific companion metadata
  references/              # optional
  scripts/                 # optional
  assets/                  # optional
```

Shared files:

- `skills/README.md`
- `skills/CONVENTION.md`
- `skills/catalog.yaml`
- `skills/_shared/*`
- `skills/_template/*`

## Categories

- `documentation`
- `implementation`
- `validation`

## Frontmatter contract

Required:

- `name`
- `description`
- `title`
- `technology`
- `document_type`
- `status`
- `authority`
- `source_type`
- `skill_scope`

Recommended:

- `license`
- `version`
- `author`
- `compatibility`
- `modes`
- `depends_on_skills`
- `requires_summary`
- `last_reviewed_at`
- `applies_to`
- `related`
- `tags`

## Catalog contract

`skills/catalog.yaml` uses:

- `schema_version: 2`
- top-level `description`
- `skills.<skill-name>` entries with routing, scope, and handoff metadata

Scope contract:

- project skill frontmatter must declare `skill_scope: project`
- project catalog entries must declare `scope: project`
- the project schema lives at `skills/schemas/skills-catalog.v2.json`
- validate with:
  - `bin/codex-env python skills/scripts/validate_metadata.py`
  - `bin/codex-env python skills/scripts/validate_skills_catalog.py`

Each skill should declare:

- `name`
- `description`
- `path`
- `scope`
- `category`
- `purpose`
- `status`
- `triggers`
- `do_not_use_when`
- `handoff_from`
- `handoff_to`
- `complements`
- `references`

Catalog-only optional routing fields:

- `aliases`
- `target_surface`
- `default_for`
- `preferred_prompt`
- `recommended_sequence`
- `companion_skills`
- `part_of_flows`

## Provider companion metadata

The portable source of truth for skill behavior is still:

1. `SKILL.md`
2. `skills/catalog.yaml`

Provider- or IDE-specific invocation metadata may live under:

- `agents/<provider>.yaml`

Current implemented provider target:

- `agents/openai.yaml` for OpenAI/Codex-aware runtimes

Contract:

- draft skills may omit provider companion metadata
- reviewed skills should include `agents/openai.yaml`
- `agents/openai.yaml` is companion metadata, not the primary behavior contract
- future provider files may be added alongside it without changing the core `SKILL.md` or catalog pattern

For `agents/openai.yaml`, include:

- `interface.display_name`
- `interface.short_description`
- `interface.default_prompt`

`interface.default_prompt` should explicitly mention the skill name in `$skill-name`
form so supported runtimes can invoke it directly.

## Body skeleton

1. When to use / not use
2. Inputs
3. Workflow
4. Handoffs
5. Outputs
6. Validation
7. Failure boundaries
8. Prohibited behavior
9. Progressive disclosure

## Update rule

For `dotfile-vnext`, new project-skill design starts in `skills/` first.
`.cursor/skills/` is the runtime-discovery layer, not the design authority.
