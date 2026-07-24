# Dotfile Skill Convention

Authority for project-skill layout in this repo:

1. `AGENTS.md`
2. `skills/catalog.yaml`
3. this file

Pattern source: `/Users/joshc/develop/homelab-reference-library/skills`.

## Goals

1. Discoverable — agents match on catalog descriptions and triggers first.
2. Lean — `SKILL.md` should stay concise and point to references only when needed.
3. Routable — the catalog should encode handoffs instead of duplicating them in prose everywhere.
4. Honest — `status` and workflow limits must match reality.
5. Safe — no secrets in skill files, and no repo-wrapper bypass for Python or Ansible work.

## Pack layout

```text
skills/<category>/<skill-name>/
  SKILL.md
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

Catalog-only optional routing fields:

- `aliases`
- `target_surface`
- `default_for`
- `preferred_prompt`
- `recommended_sequence`
- `companion_skills`
- `part_of_flows`

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
