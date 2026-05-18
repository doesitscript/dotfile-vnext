# Durable Plans

Approved plans belong here.

## Default Rules

- Store the full approved plan in this directory.
- Treat the repo plan as the canonical durable artifact.
- Mirror the work into a GitHub issue as a higher-level roadmap when GitHub is available.
- Keep the GitHub issue shorter than the repo plan and link the two when that improves pickup.

## Naming

Use date-prefixed names:

- `YYYY-MM-DD--short-slug.md`
- `YYYY-MM-DD--short-slug/`

Example:

- `2026-03-26--mcp-role-pattern-v1.md`
- `2026-03-27--subagents-v1/`

When a plan needs bundled research, references, or validation notes, prefer a
folder-backed plan packet with a `README.md` as the canonical entrypoint.

## Completed Plan Lifecycle

When a plan is fully implemented and verified:

1. **Add YAML frontmatter** to mark lifecycle status and GitHub tracking:
   ```yaml
   ---
   lifecycle: implemented
   github_issue: <number>
   implemented_date: YYYY-MM-DD
   archive_candidate: true
   ---
   ```

2. **Rename the file** with `-implemented` suffix:
   ```
   YYYY-MM-DD--short-slug.md  →  YYYY-MM-DD--short-slug-implemented.md
   ```

3. **Create a GitHub issue** (via `github-issue-workflow` skill or `gh` CLI) with:
   - `type:capability` (or appropriate type)
   - `state:done`
   - `scope:*` (relevant scope)
   - Reference to the plan file in the issue body
   - Close the issue immediately as completed

4. **Commit** the renamed plan file with the issue reference.

### Archive Candidate Frontmatter

**`archive_candidate: true`** marks a completed plan as eligible for cleanup:
- The plan is fully implemented
- The work is committed and verified
- The GitHub issue provides searchable tracking
- The file can be safely archived or removed without losing critical information

This is a **searchable metadata standard** for housekeeping. Plans marked as archive candidates can be:
- Moved to `docs/plans/archive/` for long-term reference
- Removed entirely if the commit history and GitHub issue are sufficient
- Left in place if they provide valuable pattern reference

The frontmatter metadata allows scripts or agents to identify archive-ready plans without manual review:

```bash
# Find all archive candidates
grep -l "archive_candidate: true" docs/plans/*.md
```

### Three-Layer Model

- **Repo plan** (`docs/plans/`) = canonical detailed plan and implementation record
- **GitHub issue** = higher-level roadmap and tracking (closed as done for completed work)
- **Role docs/READMEs** = implementation context and recovery layer

## Relationship To Other Docs

- `docs/plans/` is the durable planning layer for approved work across the repo.
- `docs/codex_framework/implemented_plans/` remains the framework-specific implemented-history layer.
- Role READMEs, intake notes, and diagnostics docs should link to a plan only when that link materially helps future pickup.
