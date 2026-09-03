---
name: complete-plan-lifecycle
description: Mark a plan as implemented, create tracking issue, rename with -implemented suffix, and optionally mark as archive candidate.
---

# Complete Plan Lifecycle

Use this skill when a plan in `docs/plans/` has been fully implemented and verified.

## What this skill does

1. Adds YAML frontmatter to the plan file with lifecycle metadata
2. Renames the plan file with `-implemented` suffix
3. Creates a GitHub issue tracking the completed work
4. Closes the issue immediately as done
5. Marks the plan as `archive_candidate: true` (eligible for cleanup)
6. Stages changes and updates the commit message
7. Optionally pushes to remote

## When to use this skill

Use when:
- A plan from `docs/plans/` is fully implemented
- All code changes are committed
- Verification is complete and successful
- You want to formally close out the plan lifecycle

Do not use when:
- The plan is still in progress
- Verification failed or is incomplete
- The work needs further iteration
- **Plan verification receipt** is missing or checklist-only (see below)

## Typical trigger phrases

- "mark this plan as implemented"
- "complete the plan lifecycle"
- "create issue and mark plan done"
- "this plan worked, close it out"

## Required inputs

1. **Plan file path** (relative to repo root)
2. **Implementation date** (YYYY-MM-DD format)
3. **Optional: GitHub issue number** (if issue already exists)
4. **Optional: Archive candidate** (default: true for completed plans)

## Plan verification receipt (mandatory)

Before rename or `lifecycle: implemented`:

1. Load Superpowers skill `verification-before-completion` and run fresh proving
   commands in the **current** turn (see
   [verification-before-completion-gate.md](../../../docs/codex_framework/verification-before-completion-gate.md)).
2. Ensure the plan packet includes `## Plan verification receipt` per
   [plan-verification-receipt.md](../../../docs/codex_framework/plan-verification-receipt.md):
   - **Obligation inventory** — every testable requirement from the full plan (checklist,
     change contract Apply/Verify/Undo/Class, frontmatter dependencies, prose gates,
     reference tables for the slice) — not only `## Checklist` rows
   - **Evidence** per in-scope obligation (`pass` with proof, or `blocked`/`fail` with proof)
   - **Completion gate** checkboxes satisfied

Reject completion if the only verification artifact is a short execute-receipt table
without the full inventory.

## Plan diagram gate (mandatory)

Also confirm `## Diagram gate receipt` and Required Diagram Checklist medium rules
per [architecture-diagram-routing.md](../../../docs/codex_framework/architecture-diagram-routing.md):

- Architecture diagrams may be **pack artifacts** (`create-diagrams` + **SVG**
  default, optional drawio/mmd) **or** fenced Mermaid when Mermaid is preferred
- `Diagram Inventory` must record the medium used
- Do not require Mermaid fences only; do not reject pack SVG/drawio evidence

Reject completion if the diagram gate is Mermaid-only-required against a plan that
correctly used pack artifacts (or vice versa without inventory note).

## Workflow

### Step 1: Verify plan file exists

```bash
test -f <plan_path> && echo "Plan found" || echo "Plan not found"
```

### Step 2: Add YAML frontmatter

Read the current plan file and prepend:

```yaml
---
lifecycle: implemented
github_issue: <number or will be filled after creation>
implemented_date: YYYY-MM-DD
archive_candidate: true
---
```

If the plan already has frontmatter, merge the fields. If `archive_candidate` is not desired, set to `false`.

### Step 3: Rename file with -implemented suffix

```bash
# From: docs/plans/YYYY-MM-DD--slug.md
# To:   docs/plans/YYYY-MM-DD--slug-implemented.md

mv <old_path> <new_path>
```

For folder-based plans:
```bash
# From: docs/plans/YYYY-MM-DD--slug/README.md
# To:   docs/plans/YYYY-MM-DD--slug-implemented/README.md

mv <old_dir> <new_dir>
```

### Step 4: Create GitHub issue (if not exists)

Extract key sections from the plan for the issue body:
- Overview/Context
- What was completed
- Verification results
- Plan file reference

Use `gh issue create`:

```bash
gh issue create \
  --repo <owner/repo> \
  --title "<scope>: <brief description>" \
  --body "$(cat <<'EOF'
## Overview
<from plan>

## What Was Completed
<from plan>

## Verification
<from plan>

## References
- Plan: `<path to renamed plan file>`
- Commit: <commit hash>
EOF
)"
```

Extract the issue number from the output (e.g., `https://github.com/owner/repo/issues/13` → `13`).

### Step 5: Update frontmatter with issue number

If issue was just created, update the plan file frontmatter:

```yaml
github_issue: 13
```

### Step 6: Close the issue

```bash
gh issue close <number> --repo <owner/repo> --comment "Work completed and verified."
```

### Step 7: Stage changes

```bash
git add <renamed_plan_file> docs/plans/README.md
```

If `docs/plans/README.md` was not updated this run (already has the lifecycle documentation), skip it.

### Step 8: Amend or create commit

If changes are already committed (from the implementation):

```bash
git commit --amend -m "$(cat <<'EOF'
<Original commit message>

Completed plan lifecycle:
- GitHub issue #<number> created and closed
- Plan marked as implemented and archive candidate
- Plan file renamed with -implemented suffix
EOF
)"
```

If this is a new commit:

```bash
git commit -m "Complete plan lifecycle for <slug>"
```

### Step 9: Push (optional, ask user first)

```bash
git push
# or if amended:
git push --force-with-lease
```

**Always ask the user before pushing**, especially for force-push scenarios.

## Archive Candidate Standard

`archive_candidate: true` means:
- The plan is fully implemented and verified
- The GitHub issue provides searchable tracking
- The file can be safely archived or removed
- Useful for housekeeping scripts to identify cleanup-ready plans

Plans marked as archive candidates can be:
- Moved to `docs/plans/archive/` for long-term reference
- Removed if commit + GitHub issue are sufficient
- Left in place if they provide valuable pattern reference

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `lifecycle` | Yes | Plan lifecycle state: `draft`, `approved`, `implemented`, `obsolete` |
| `github_issue` | Yes (after creation) | GitHub issue number tracking this work |
| `implemented_date` | Yes | Date the plan was fully implemented (YYYY-MM-DD) |
| `archive_candidate` | Optional | `true` = eligible for archival/removal, `false` = keep for reference |

## Examples

### Example 1: Simple plan completion

```
User: "The upgrade plan worked, mark it as implemented"

Agent:
1. Reads docs/plans/2026-05-18--upgrade-codex-cursor-pet.md
2. Adds frontmatter with lifecycle: implemented, implemented_date: 2026-05-18, archive_candidate: true
3. Renames to docs/plans/2026-05-18--upgrade-codex-cursor-pet-implemented.md
4. Creates GitHub issue #13 with summary from plan
5. Closes issue #13
6. Updates frontmatter with github_issue: 13
7. Stages renamed file
8. Amends previous commit with lifecycle completion note
9. Asks: "Ready to push? This will force-with-lease since commit was amended."
```

### Example 2: Keep plan for reference (not archive candidate)

```
User: "Mark this as implemented but don't mark it for archival, it's a good reference"

Agent: (same workflow but sets archive_candidate: false in frontmatter)
```

### Example 3: Issue already exists

```
User: "Mark plan as implemented, issue #42 already tracks it"

Agent:
1. Adds frontmatter with github_issue: 42
2. Renames file
3. Closes issue #42 (does not create new issue)
4. Stages and commits
```

## Integration with github-issue-workflow skill

This skill is **complementary** to `github-issue-workflow`:
- `github-issue-workflow` creates issues for **planned or in-progress** work
- `complete-plan-lifecycle` creates issues for **completed and verified** work

Both use similar GitHub patterns but serve different lifecycle stages.

## Pattern Enforcement

This skill enforces the project's completed plan lifecycle pattern documented in `docs/plans/README.md`:

1. Plan verification receipt with full obligation inventory (not checklist-only)
2. YAML frontmatter with lifecycle metadata
3. `-implemented` file suffix
4. GitHub issue created and closed as done
5. `archive_candidate: true` for searchable cleanup metadata
6. Commit message updated with lifecycle completion

## Reference

See `docs/plans/README.md` section "Completed Plan Lifecycle" for the full project standard.
