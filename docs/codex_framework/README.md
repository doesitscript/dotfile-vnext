# Codex Framework Capability

This folder documents the Codex-side framework capability currently being developed inside this repo.

The intent is visibility first:
- show what files actively shape the capability
- separate framework guidance from project-specific infrastructure notes
- make later extraction easier if this capability moves out of `dotfile-vnext`

## What Belongs Here

This folder is for Codex framework behavior:
- durable working contract
- planning and research workflow
- capability inventory
- status of the framework itself

Project-specific information docs can still live elsewhere in `docs/` when they are mainly about this repo. Examples:
- WinRM quirks
- environment-variable workarounds
- lessons learned from a broken bootstrap
- recovery notes kept as a backup while the environment is still unstable

Those notes can be important and still remain outside this folder. They are project information first, framework definition second.

## Why This Is Transitional

Some of the active rule files were created before the current OpenAI/Codex customization shape was better understood.
Historical notes and conversation archives may still mention the older filenames and paths. Treat the files listed in this README as the active names.

The capability-specific rule files no longer use numeric prefixes or double-dash load-order naming. The framework README is now the visibility layer for what is active.

Today the working stack is:
1. `AGENTS.md`
2. skill workflows
3. MCP and live environment tools
4. multi-agent delegation later, only after the first three are stable

So this folder is also a migration aid. It makes the current framework visible even though parts of it were introduced incrementally inside the project.

## Current Status

Implemented now:
- `Planner / Steward`
- `Researcher`
- visible transition signals for active framework surfaces:
  - `Planner/Steward view:`
  - `Researcher view:`
  - `Executor view:`
  - `Evidence:`
- explicit lifecycle-state modeling for Ansible capabilities as a preferred pattern
- lightweight GitHub-issue workflow support for staged work that should outlive local notes
  or rough brainstorming once it becomes concrete enough to preserve

Planned next:
- `Executor` contract
- quality comparison workflow for the next 2-3 efforts
- one real repo problem taken through the framework end to end

## Active Capability Surfaces

These are the current files actively shaping this capability.

### Durable repo behavior

- [AGENTS.md](/Users/joshc/develop/dotfile-vnext/AGENTS.md)
  The small, durable contract for how Codex should behave in this repo.

### Framework docs

- [docs/codex_framework/partner_process.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/partner_process.md)
  The deeper working process for `Planner / Steward`, `Researcher`, and later `Executor`.
- [docs/codex_framework/README.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/README.md)
  This capability map and status document.

### Capability-specific rule layer

- [.cursor/rules/codex-framework-partner-process.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-partner-process.mdc)
  The main rule that operationalizes the partner process.
- [.cursor/rules/codex-framework-agent-role-and-persona.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-agent-role-and-persona.mdc)
  Supporting role/persona rule currently affecting how the framework presents and asserts.
- [.cursor/rules/codex-framework-knowledge-and-research.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-knowledge-and-research.mdc)
  Supporting research hierarchy and stewardship gate.
- [.cursor/rules/codex-framework-mcp-and-tool-usage.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-mcp-and-tool-usage.mdc)
  Supporting MCP-first and validation/tool-usage rule.
- [.cursor/rules/codex-framework-user-interaction-style.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-user-interaction-style.mdc)
  Supporting collaboration rule for working with Josh.
- [.cursor/rules/codex-framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-github-issue-workflow.mdc)
  The dedicated rule surface that introduces and governs the GitHub issue workflow as its own reusable capability area.

### Skill workflows

- [.cursor/skills/ansible-planner/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-planner/SKILL.md)
  The current `Planner / Steward` workflow.
- [.cursor/skills/ansible-researcher/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-researcher/SKILL.md)
  The current `Researcher` workflow.
- [.cursor/skills/github-issue-workflow/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/github-issue-workflow/SKILL.md)
  A small reusable workflow for turning staged work or concrete brainstorming into GitHub issues when durable backlog tracking is better than local notes alone. The issue is treated as the highest practical planning layer when that helps preserve refined direction across sessions, while repo docs and READMEs remain the offline pickup layer. The workflow now uses a non-optional light label schema: one `type:*`, one `state:*`, and one `scope:*` label on every created issue.

## Supporting But Not Owned By This Capability

These still affect behavior in the repo, but they are not the main home of this framework:
- repo infrastructure docs under `docs/`
- lessons learned and conversation contexts
- older brainstorming docs
- global Cursor rules such as boot and failure diagnostics

Those are background, support, or historical surfaces unless explicitly promoted into the active framework layer above.

## Separation Of Concerns Goal

The direction is:
- keep project-specific infrastructure knowledge in project docs
- keep Codex behavior and workflow definition in this folder, `AGENTS.md`, and the capability-specific rules/skills
- make the framework extractable later without dragging the whole project layout with it

The root project should only need to say that it uses this capability. The capability itself should be documented here.

## Naming Guidance For Domain-Specific Additions

If the framework later gains domain-specific extensions, the names should say so plainly.

Examples:
- `ansible-*` for Ansible-specific rules, workflows, or skills
- `github-*` for GitHub issue workflow rules and related durable backlog behavior
- project-qualified names when something is specific to this repo rather than reusable elsewhere

That keeps the generic Codex framework visible and reduces accidental coupling between reusable framework behavior and project-specific automation concerns.

## Active Naming Logic

This is the naming logic Codex should treat as active in this repo:

- `codex-framework-*`
  Use for active rules that define cross-project Codex behavior in this repo.
- `ansible-*`
  Use for active rules, workflows, or skills that are specifically about Ansible behavior, design, or execution.
- `github-*`
  Use for active rules and workflows that govern GitHub issue creation, staging, labeling, and pickup behavior.
- project-qualified names
  Use when something is specific to this repo and would not travel cleanly to another project unchanged.

This is not just descriptive. It is intended to be representative of:
- what the repo is converging toward
- how Codex should name new active framework surfaces going forward

### What not to do

- do not create new active rule files with legacy numeric-prefix naming unless there is a strong reason
- do not leave active rules as plain `.md` files when they are meant to behave like rules
- do not mix generic Codex framework behavior and Ansible-specific behavior under names that hide the distinction

## Rule And Skill Grouping Strategy

Codex should not create active rules and skills as a flat pile of unrelated
files. New active surfaces should be grouped by capability area and named so the
group is obvious from the filename.

Current grouping model:

- `codex-framework-*`
  Core framework rules that shape how Codex behaves across the repo.
- `ansible-*`
  Domain-specific rules, workflows, or skills for Ansible behavior.
- `github-*`
  Workflow surfaces for durable GitHub issue tracking, staging, labeling, and
  pickup behavior.

This means:

- rules should show both ownership and grouping in the filename
- skills can stay a bit more task-oriented, but should still align to the same
  capability areas when they are active framework workflows
- new capability areas should be introduced intentionally, not casually

### Current examples

Rules:
- [codex-framework-partner-process.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-partner-process.mdc)
- [codex-framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-github-issue-workflow.mdc)
- [ansible-coding-standards.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/ansible-coding-standards.mdc)

Skills:
- [ansible-planner](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-planner/SKILL.md)
- [ansible-researcher](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-researcher/SKILL.md)
- [github-issue-workflow](/Users/joshc/develop/dotfile-vnext/.cursor/skills/github-issue-workflow/SKILL.md)

### Creation rule

When Codex creates a new active rule or workflow surface, it should decide:

1. is this core framework behavior, a domain behavior, or a project-specific extension?
2. which existing capability group should own it?
3. does the filename make that ownership obvious without extra explanation?

If the answer is not clear, prefer updating an existing grouped surface instead
of creating a new one.

### Legacy note

Older files may still use numbered names or other historical naming. Treat those as legacy unless they are intentionally kept active and there is a clear reason not to rename them yet.
