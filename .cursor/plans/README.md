# Plans moved

Approved and in-progress plans now live under `docs/plans/` as date-prefixed
folder packets (`YYYY-MM-DD--short-slug/README.md`).

Incomplete or partially implemented plans use an `-incomplete` suffix on the
folder name (for example `2026-05-27--name-alignment-netbox-metadata-incomplete/`).

Do not add new **canonical** plan artifacts here. Use `docs/plans/` instead.

## Cursor CreatePlan drafts

Cursor's `CreatePlan` tool may write drafts under this folder or under the
user-level `~/.cursor/plans/` tree (outside the repo). Those drafts are still
**official Plan card surfaces**.

Before calling `CreatePlan` or leaving a `*.plan.md` here:

1. Load `framework-plan-governance.mdc` and partner-process Mandatory Diagram
   Requirements (see also the thin gate in `.cursorrules`).
2. Include titled Mermaid `Architecture/Structure Diagram`, required
   conditionals, **Diagram gate receipt**, and final **Diagram Inventory**.
3. Promote accepted work to `docs/plans/YYYY-MM-DD--slug/README.md`.

A sketch with only an untitled flowchart is not a valid CreatePlan body.
