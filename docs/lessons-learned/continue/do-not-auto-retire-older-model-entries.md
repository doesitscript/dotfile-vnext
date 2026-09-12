---
title: Continue / AI CLI — do not auto-retire older model entries
technology: continue
document_type: investigation
status: draft
authority: internal
source_type: internal
last_reviewed_at: "2026-09-12"
applies_to:
  - continue
  - ai_cli_apps
  - litellm
tags:
  - open-question
  - model-catalog
  - continue
---

# Do not auto-retire older model entries (open question)

## What happened

While implementing plan `2026-09-12-mac_and_model_recommend`, Edit moved from
`qwen2.5-coder-7b@desktop` to `qwen2.5-coder-14b@desktop`, and Apply kept 7B.
Client catalogs were updated so the **previous Edit=7B dual-role entry** was
replaced rather than left alongside the new 14B Edit entry.

That cleanup was reasonable for a single primary Edit binding, but it is **not**
a settled project rule that “newer lane ⇒ remove older named entry.”

## Open question (not closed)

**How should we handle older models when a newer recommendation lands?**

Possible futures (undecided):

- Keep both in the picker (14B Edit default; 7B still listed under edit or chat)
- Keep the id commissioned but demote roles (e.g. apply-only)
- Retire only after an explicit user decision or acceptance receipt
- Cap catalog size later if picker noise becomes a problem

Early on, catalog size is **not** out of control. Prefer **add / split roles**
over silent delete unless the user asks to remove something or a gate forbids
duplicates.

## Agent guidance (interim)

1. Adding a better model for a role ≠ permission to drop the prior model row.
2. If you change role bindings (edit/apply/autocomplete), **say what you removed
   or reassigned** in the turn summary.
3. Default when unsure: **keep the older entry enabled** (or `enabled: false`
   with a comment) and ask — do not treat “cleanup” as implied by upgrade.
4. SSOT comments: see `inventory/group_vars/all/ai_cli_apps.yml` and
   `ai_cli_apps-INTAKE.md` § “Older models when upgrading”.

## Related

- Intake: `inventory/group_vars/all/ai_cli_apps-INTAKE.md`
- Plan: `docs/plans/2026-09-12-mac_and_model_recommend/`
