---
name: library-entry-validate
description: Validate ai-resource-library entry-spec contracts and block incomplete packs. Use before marking an entry complete, after build scripts run, or when remediating an existing pack to the ai-library-entry contract.
---

# Skill: Library Entry Validate

Independent validator for packet-local `entry-spec.yml` contracts.

Does **not** build or collect content. Confirms declared outputs exist, families
match paths, provenance rules pass, and the validator pass token is recorded.

## When to use this skill

Use when:

- an `entry-spec.yml` exists or was just updated
- a build script finished and you need completion evidence
- remediating a pack to the `ai-library-entry` contract
- acting as `independent_validator` before `lifecycle: implemented`

Do not use when:

- no `entry-spec.yml` exists yet — use `ai-library-entry` first
- only inline research with no durable library outputs

## Required workflow

1. Locate the packet-local `entry-spec.yml`.
2. Run the validator:

```bash
ruby .cursor/skills/ai-library-entry/references/validate_entry_spec.rb \
  docs/plans/YYYY-MM-DD--slug/entry-spec.yml
```

3. Require output:

```text
AI_LIBRARY_ENTRY_VALIDATION_OK
```

4. Emit a **library skill receipt** (see below).
5. If validation fails, stop — do not mark the entry complete.

## Obligation checks beyond the validator

When `context7.firecrawl_cross_check.enabled` is true, confirm
`indexes/<entry>/firecrawl-context7-crosscheck.json` exists on disk.

When `context7.openapi_swagger.enabled` is true, confirm Context7 OpenAPI
outputs declared in `context7.openapi_swagger.outputs` exist.

## Library skill receipt

```markdown
## Library skill receipt
- Skill: library-entry-validate
- Entry spec: <path>
- Validator: pass | fail
- Pass token: AI_LIBRARY_ENTRY_VALIDATION_OK | absent
- Missing outputs: <list or none>
```

## Parent skill

Orchestrated by `ai-library-entry`. Invoked after `library-entry-build` when
build scripts ran.

## References

- `.cursor/skills/ai-library-entry/references/validate_entry_spec.rb`
- `.cursor/skills/ai-library-entry/references/entry-spec.template.yml`
