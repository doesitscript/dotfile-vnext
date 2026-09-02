---
title: AI evaluation of draft one-off skill family
evaluated_at: 2026-09-02
status: fail
audience: ai-agent
evaluated_skills:
  - draft-one-off-trial-scaffold
  - draft-one-off-promotion
  - draft-one-off-discard-cleanup
  - draft-one-off-promotion-verify
applied_skills:
  - skill-pack-conformance-auditor
  - skill-process-conformance-auditor
  - design-to-known-future
---

# AI draft skill family evaluation

## Scope

Evaluate the draft one-off lifecycle skill family added under `skills/one-off/`
and its related wiring:

- `skills/one-off/README.md`
- four draft `SKILL.md` files
- `skills/catalog.yaml`
- `.cursor/skills/catalog.yml`
- `.cursor/skills/draft-one-off-*` symlinks
- `docs/one_off_tasks/README.md`
- `docs/codex_framework/verification-before-completion-gate.md`

This evaluation is written for a follow-on AI to correct the skills.

## What is already good

These parts are real and useful:

- all four draft skills exist in the project source-authority store
- all four have matching `.cursor/skills/` runtime symlinks
- all four have project scope in frontmatter and catalog
- duplicate-name checks against `global-skills` were clean
- the lifecycle intent is sensible:
  scaffold -> promote or discard -> verify
- `docs/one_off_tasks/README.md` now points agents at this skill family
- the verification gate explicitly pairs one-off promotion closeout with
  `draft-one-off-promotion-verify`

## Validator evidence

Validated with repo wrapper, not ambient Python:

```bash
bin/codex-env python skills/scripts/validate_metadata.py
bin/codex-env python skills/scripts/validate_skills_catalog.py
bin/codex-env python /Users/joshc/develop/global-skills/skills/validation/skill-process-conformance-auditor/scripts/audit_skill_process.py --repo-root /Users/joshc/develop/dotfile-vnext --skill-name <skill> --scope project --comparison-root /Users/joshc/develop/global-skills
bin/codex-env python /Users/joshc/develop/global-skills/skills/validation/skill-pack-conformance-auditor/scripts/resolve_skill_pack.py --repo-root /Users/joshc/develop/dotfile-vnext --skill-name draft-one-off-promotion
```

Observed validator failures:

- all four skills: missing `technology`
- all four skills: missing `last_reviewed_at`
- all four catalog entries: invalid `category: one-off`
- `draft-one-off-discard-cleanup`: `complements` missing or wrong shape

Observed process-audit passes:

- catalog entry exists
- scope is `project`
- runtime bridge metadata exists
- runtime symlink targets exist
- no duplicate skill names were found in `global-skills`

## Executive verdict

The family is directionally good but not ready even as a clean draft pack.

The main problems are:

- project validators fail
- project skill convention is violated in multiple files
- one skill references a runtime mirror instead of the project source-authority path
- one declared handoff target is not present in the project skill source of truth
- the promotion skill family bakes in the flawed apply/undo assumptions from the
  codex multi-terminal promotion packet it was modeled on
- the family is not grouped in a way that pack tooling can resolve as a four-skill
  lifecycle without manual help

## Findings

### SF1. All four draft skills fail metadata validation

**Severity:** high

**Observed problem**

Each new `SKILL.md` is missing:

- `technology`
- `last_reviewed_at`

The project validator treats both as required for current validation, even though
`skills/CONVENTION.md` labels `last_reviewed_at` as recommended.

**Evidence**

- Validator command:
  `bin/codex-env python skills/scripts/validate_metadata.py`
- Convention required fields:
  `skills/CONVENTION.md:54-67`
- Missing in:
  - `skills/one-off/draft-one-off-trial-scaffold/SKILL.md:1-24`
  - `skills/one-off/draft-one-off-promotion/SKILL.md:1-28`
  - `skills/one-off/draft-one-off-discard-cleanup/SKILL.md:1-23`
  - `skills/one-off/draft-one-off-promotion-verify/SKILL.md:1-27`

**AI correction directive**

Add both fields to all four draft skills now.

Minimum safe action:

- add `technology:` to each skill
- add `last_reviewed_at: "2026-09-02"` to each skill

Do not leave this unresolved just because the docs say `last_reviewed_at` is
recommended. The validator is the operative gate today.

**Acceptance condition**

`bin/codex-env python skills/scripts/validate_metadata.py` exits `0`.

### SF2. The new `one-off` category is invalid in this project skill library

**Severity:** high

**Observed problem**

All four catalog entries use `category: one-off`, but this project library only
documents three categories:

- `documentation`
- `implementation`
- `validation`

The catalog validator rejects `one-off`.

**Evidence**

- Validator command:
  `bin/codex-env python skills/scripts/validate_skills_catalog.py`
- Category contract:
  `skills/CONVENTION.md:48-52`
  `skills/README.md:31-37`
- Invalid catalog entries:
  `skills/catalog.yaml:1334`
  `skills/catalog.yaml:1364`
  `skills/catalog.yaml:1397`
  `skills/catalog.yaml:1424`

**AI correction directive**

Preferred fix: recategorize into existing project categories instead of expanding
the schema just for this family.

Recommended mapping:

- `draft-one-off-trial-scaffold` -> `implementation`
- `draft-one-off-promotion` -> `implementation`
- `draft-one-off-discard-cleanup` -> `implementation`
- `draft-one-off-promotion-verify` -> `validation`

Alternative fix:

- if the repo intentionally wants a new `one-off` category, update all of:
  - `skills/CONVENTION.md`
  - `skills/README.md`
  - any validator/schema surface enforcing categories

Do not update only the catalog entries or only the docs. Keep them coherent.

**Acceptance condition**

`bin/codex-env python skills/scripts/validate_skills_catalog.py` exits `0`.

### SF3. `draft-one-off-discard-cleanup` has malformed or missing `complements`

**Severity:** high

**Observed problem**

The catalog validator reports:

`draft-one-off-discard-cleanup: complements must be a list`

The entry currently jumps from `handoff_to` directly to `references`.

**Evidence**

- Validator command:
  `bin/codex-env python skills/scripts/validate_skills_catalog.py`
- Catalog contract:
  `skills/CONVENTION.md:99-113`
- Affected entry:
  `skills/catalog.yaml:1407-1413`

**AI correction directive**

Add an explicit `complements` list.

Minimum safe fix:

```yaml
complements: []
```

Better fix:

```yaml
complements:
  - draft-one-off-promotion
  - draft-one-off-promotion-verify
```

Choose the list that best matches actual routing intent.

**Acceptance condition**

The catalog validator no longer reports a `complements` shape error.

### SF4. The SKILL bodies do not conform to the project section skeleton

**Severity:** medium

**Observed problem**

The project convention expects this section sequence:

1. When to use / not use
2. Inputs
3. Workflow
4. Handoffs
5. Outputs
6. Validation
7. Failure boundaries
8. Prohibited behavior
9. Progressive disclosure

The draft family omits required control sections in multiple places:

- all four skills omit `## Failure boundaries`
- `draft-one-off-promotion` omits `## Validation`
- `draft-one-off-discard-cleanup` omits `## Validation`
- `draft-one-off-promotion-verify` omits both `## Handoffs` and `## Validation`

**Evidence**

- Skeleton contract:
  `skills/CONVENTION.md:129-139`
- Section inventory:
  - `draft-one-off-trial-scaffold/SKILL.md:31-141`
  - `draft-one-off-promotion/SKILL.md:35-160`
  - `draft-one-off-discard-cleanup/SKILL.md:29-127`
  - `draft-one-off-promotion-verify/SKILL.md:33-148`

**AI correction directive**

Add the missing sections to each skill. Keep them short and operational.

Minimum required additions:

- `## Failure boundaries`
  Explain when the skill must stop instead of guessing.
- `## Validation`
  Define what evidence makes the skill output acceptable.
- `## Handoffs` for `draft-one-off-promotion-verify`
  Include at least `single-host-ansible-rollout` and whichever plan-close skill
  is actually source-authority-valid.

Do not only add headings. Fill them with real decision boundaries.

### SF5. The promotion skill encodes the same flawed undo model as the codex promotion plan

**Severity:** high

**Observed problem**

The draft promotion skill repeats the same assumption already found incorrect in
the reference plan: that role `absent` states plus a legacy cleanup script are a
sufficient universal removal model.

The current codex multi-terminal promotion reference is not actually correct on
that point because static `files/bashrc.d/*.bash` contributions are deployed by
`common/shell_config` without state-aware removal.

The draft skill currently tells future agents to preserve `present|absent`
lifecycle on roles and treat `absent` as the undo model in the plan packet.
The bundled promotion-map template also says uninstall paths map to
`tasks/absent.yml` plus a legacy cleanup script.

That guidance will reproduce the same bug in future promotions.

**Evidence**

- Skill packet instructions:
  `skills/one-off/draft-one-off-promotion/SKILL.md:70-73`
  `skills/one-off/draft-one-off-promotion/SKILL.md:92-97`
  `skills/one-off/draft-one-off-promotion/SKILL.md:109-115`
- Promotion-map reference:
  `skills/one-off/draft-one-off-promotion/references/promotion-map-template.md:5-11`
- Governing reference packet with existing correction audit:
  `docs/plans/2026-09-02--codex-multi-terminal-promotion/AI-CORRECTION-EVALUATION.md`

**AI correction directive**

Update `draft-one-off-promotion` so it does not train future agents to produce
false undo contracts.

Required reshaping:

1. In the plan-packet instructions, change undo wording from generic
   "`absent` undo" to:
   "document the real removal path for every owned artifact; static shell
   contributions need explicit state-aware removal if `common/shell_config`
   deploys them."
2. Replace the simple promotion map with a full disposition ledger:
   - promoted
   - promoted with reshape
   - retired and replaced
   - retired with no managed replacement
   - open gap
3. In the template, do not claim
   `deploy/uninstall_*.sh -> tasks/absent.yml + legacy cleanup`
   is always sufficient.
4. Tell the correcting AI to cross-check the promotion packet against
   `AI-CORRECTION-EVALUATION.md` when the reference implementation is the codex
   multi-terminal promotion.

**Acceptance condition**

A future agent following this skill would not reproduce the false `.bashrc.d`
undo contract.

### SF6. `draft-one-off-promotion-verify` points to a runtime mirror instead of source authority

**Severity:** medium

**Observed problem**

One related-artifacts reference points to:

- `.cursor/skills/single-host-ansible-rollout/SKILL.md`

But project skill authority is:

1. `skills/catalog.yaml`
2. `SKILL.md` under `skills/`
3. `.cursor/skills/` only as runtime discovery

The reference should point to the source-authority skill path.

**Evidence**

- Project authority rule:
  `skills/README.md:15-20`
  `skills/CONVENTION.md:90-97`
  `skills/CONVENTION.md:168-169`
- Bad reference:
  `skills/one-off/draft-one-off-promotion-verify/references/related-artifacts.md:5-8`
- Real source-authority path exists:
  `skills/validation/single-host-ansible-rollout/SKILL.md`

**AI correction directive**

Replace the runtime-mirror reference with the source-authority path:

- `skills/validation/single-host-ansible-rollout/SKILL.md`

Review the whole new family for any other `.cursor/skills/` references and move
them to `skills/` unless the reference is explicitly about runtime wiring.

### SF7. The pack declares a handoff target that is not in the project source of truth

**Severity:** medium

**Observed problem**

The new family hands off to `complete-plan-lifecycle`, but that target is not
present in the project `skills/catalog.yaml`. It appears only as a runtime skill
under `.cursor/skills/complete-plan-lifecycle/`.

This creates a source-authority dead end for agents following catalog-based
routing.

**Evidence**

- Handoff declarations:
  `skills/one-off/draft-one-off-promotion/SKILL.md:148-154`
  `skills/catalog.yaml:1437`
- Runtime-only presence:
  `.cursor/skills/complete-plan-lifecycle/SKILL.md`
- No project catalog entry for the target in:
  `skills/catalog.yaml`

**AI correction directive**

Choose one of these:

1. Preferred: add a proper project skill and catalog entry for
   `complete-plan-lifecycle`.
2. Or remove that handoff from the new family until the project source-authority
   skill exists.
3. Or replace it with a source-authority-valid closeout target.

Do not keep a handoff that only resolves in runtime mirrors.

### SF8. The family is not auto-resolvable as a four-skill pack

**Severity:** medium

**Observed problem**

The family README clearly defines four related skills:

- `draft-one-off-trial-scaffold`
- `draft-one-off-promotion`
- `draft-one-off-discard-cleanup`
- `draft-one-off-promotion-verify`

But the pack resolver, when given parent `draft-one-off-promotion`, resolves only:

- `draft-one-off-promotion`
- `draft-one-off-promotion-verify`

because default pack resolution is parent + name-prefix siblings, and there is no
true parent family skill that owns the broader lifecycle.

**Evidence**

- Family declaration:
  `skills/one-off/README.md:1-12`
- Pack resolver output:
  `bin/codex-env python /Users/joshc/develop/global-skills/skills/validation/skill-pack-conformance-auditor/scripts/resolve_skill_pack.py --repo-root /Users/joshc/develop/dotfile-vnext --skill-name draft-one-off-promotion`
- Pack resolution rules:
  `global-skills/skills/validation/skill-pack-conformance-auditor/references/pack-resolution.md`

**AI correction directive**

If you want this to behave as a coherent family for future audits and routing,
choose one of these designs:

1. Add a parent family skill, for example `draft-one-off-lifecycle`, whose
   explicit handoffs/complements define the four-member pack.
2. Keep the current four-skill design, but add stronger explicit family metadata
   in the catalog using supported routing fields such as `companion_skills` or
   `part_of_flows`.
3. If a parent family skill is not wanted, update the family README to state that
   pack tooling requires an explicit member list for full-family audits.

Do not assume prefix-based tools will infer the whole lifecycle from
`draft-one-off-promotion`.

### SF9. The family is useful for future automation, but a fifth plan-only skill is optional, not urgent

**Severity:** low

**Observed problem**

`draft-one-off-promotion` currently combines:

- plan-packet authoring
- archival backup creation
- role/playbook integration design
- handoff to live verification

If plan-only work becomes frequent, a separate planning skill could reduce
branching inside this skill. Right now that is an optimization, not a blocker.

**Evidence**

- Combined scope:
  `draft-one-off-promotion/SKILL.md:32-33`
  `draft-one-off-promotion/SKILL.md:64-124`

**AI correction directive**

Do not add a fifth skill until SF1-SF8 are corrected.

If the family is used repeatedly and plan-only sessions keep occurring, then a
future split such as `draft-one-off-promotion-plan` can make sense.

Under `design-to-known-future`, if such a split is expected, shape the current
promotion skill so that:

- plan-packet creation is its own named phase
- implementation steps are cleanly separable
- handoff contracts already allow a future plan-only sibling

## Recommended correction order

1. Make the validator errors go green:
   - add `technology`
   - add `last_reviewed_at`
   - fix categories
   - add `complements` to discard-cleanup
2. Bring all four `SKILL.md` files up to the project body skeleton.
3. Fix source-authority routing:
   - remove `.cursor/skills/` references from skill docs where not appropriate
   - resolve the `complete-plan-lifecycle` dead end
4. Correct the promotion guidance so it stops teaching the flawed undo model.
5. Improve family-level pack discoverability if this lifecycle is meant to be a
   long-lived reusable pack.

## Minimal completion checklist for the correcting AI

- `validate_metadata.py` passes
- `validate_skills_catalog.py` passes
- all four skills include the required control sections
- no new skill reference prefers `.cursor/skills/` over `skills/` unless runtime
  discovery itself is the subject
- the promotion skill no longer teaches a false universal `absent` undo model
- the family can be audited coherently either through a real parent skill or
  explicit family metadata
