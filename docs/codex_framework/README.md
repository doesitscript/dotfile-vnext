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

### Skill workflows

- [.cursor/skills/ansible-planner/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-planner/SKILL.md)
  The current `Planner / Steward` workflow.
- [.cursor/skills/ansible-researcher/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-researcher/SKILL.md)
  The current `Researcher` workflow.

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
- project-qualified names when something is specific to this repo rather than reusable elsewhere

That keeps the generic Codex framework visible and reduces accidental coupling between reusable framework behavior and project-specific automation concerns.
