# Durable Plans

Approved plans belong here.

## Default Rules

- Store the full approved plan in this directory.
- Treat the repo plan as the canonical durable artifact.
- Mirror the work into a GitHub issue as a higher-level roadmap when GitHub is available.
- Keep the GitHub issue shorter than the repo plan and link the two when that improves pickup.
- **Include Mermaid diagrams** visualizing architecture, implementation flow, and naming standards (see `.cursor/rules/framework-partner-process.mdc` for full requirements). The same baseline applies to official conversational `<proposed_plan>` plans.

## Required Diagram Checklist

Every stored plan must include these sections before it is considered complete:

- `Architecture/Structure Diagram`: required for every stored plan. Show the repo files, roles, inventories, playbooks, external systems, and managed targets that the plan changes or depends on.
- `Capability Routing Diagram`: required when the plan has runtime branching, multiple systems, preview/apply/verify paths, lifecycle state, conditional execution, or target selection.
- `Naming/Modeling Diagram`: required when the plan changes names, aliases, object hierarchy, source-of-truth metadata, or naming standards.
- `Other Available Diagram Types` or `Diagram Inventory`: required at the end
  of every plan so reviewers can see which optional diagrams were considered.

If a diagram is truly not applicable, include the section anyway with an explicit
`N/A` reason. Do not omit the section silently.

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

## Proactive Reinforcement During Planning

**Core Principle:** When the user has to explain, correct, or clarify something during planning, that represents a gap in project documentation or standards. The AI should proactively add tasks to the current plan to strengthen those areas.

### Pattern Recognition During Planning

Watch for these signals that indicate missing project guidance:

1. **User questions about tool choice**
   - Example: "Why should I use uv? Is this redundant to poetry?"
   - Signal: Python tooling authority unclear
   - Response: Add task to update `python` role README with pattern guidance

2. **User corrections about existing patterns**
   - Example: "We use pip/venv for git-cloned projects, not uv"
   - Signal: Pattern not documented or discoverable
   - Response: Add task to strengthen template or role documentation

3. **User requests for version pinning or stability**
   - Example: "What about version pinning?"
   - Signal: Template doesn't enforce or guide toward stability
   - Response: Add task to update template with version pinning variables and guidance

4. **User asks to document decisions**
   - Example: "Capture this discussion so we don't lose the knowledge"
   - Signal: Decision rationale not preserved for future reference
   - Response: Evaluate if role README or central doc is warranted; add appropriate task

### The Reinforcement Loop

```
User explains/corrects during planning
    ↓
AI identifies root cause (missing guidance, unclear authority, weak template)
    ↓
AI adds task to current plan to strengthen that area
    ↓
Future plans benefit from strengthened guidance
    ↓
Fewer explanations/corrections needed
```

### Required Step During Planning

Before finalizing any plan, explicitly ask:

> "What user explanations or corrections during this planning session reveal gaps in project documentation or standards? What tasks should I add to this plan to prevent needing those same explanations next time?"

Then add those reinforcement tasks to the current plan, not as future follow-up work.

### Real Example: NetBox MCP Server Plan (May 2026)

**User corrections during planning:**
- "Why should I use uv?" → Pattern authority unclear
- "What about version pinning?" → Template enforcement weak
- "Document this decision" → No preservation path

**Tasks added to plan:**
- Update `python` role README with pattern guidance and tool evaluation rationale
- Update MCP template with version pinning variables and enforcement
- Create central doc for cross-cutting Python tooling decisions
- Update planning process itself with this reinforcement pattern

**Result:** Next MCP server or Python tooling decision has stronger guidance available from the start.

### Documentation Decision Tree (During Planning)

When a decision needs documentation:

1. **Single role affected?**
   - YES → Add task to update that role's README
   - NO → Continue to #2

2. **Cross-cutting (affects multiple roles)?**
   - Evaluate: Does it provide decision framework? Connect scattered decisions? Prevent repeated investigations?
   - YES → Add task to create/update central doc + update affected role READMEs with pointers
   - NO → Add task to update most relevant role README only

3. **Template/standard gap revealed?**
   - Add task to update template with stronger guidance or fail-fast validation

**Goal:** Every plan should leave the project stronger than it found it, not just implement the immediate feature.
