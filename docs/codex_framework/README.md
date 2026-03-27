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
2. project Codex runtime config in `.codex/config.toml`
3. skill workflows
4. MCP and live environment tools
5. multi-agent delegation later, only after the first four are stable

For OpenAI/Codex topics in this repo, the default authoritative-docs path is the
`openaiDeveloperDocs` MCP server before training knowledge or generic web use.
This applies broadly, not just to a narrow "researcher-only" role: Codex/API
questions, AGENTS/customization questions, MCP/config questions, and
subagent/multi-agent questions should all start there when the docs server can
answer them.

So this folder is also a migration aid. It makes the current framework visible even though parts of it were introduced incrementally inside the project.

## Current Status

Implemented now:
- `Planner / Steward`
- `Researcher`
- official project-level Codex runtime config in `.codex/config.toml`
- built-in Codex role mapping:
  - `default` -> `Planner / Steward` in the main thread
  - `explorer` -> `Researcher`
  - `worker` -> `Executor`
- visible transition signals for active framework surfaces:
  - `Planner/Steward view:`
  - `Researcher view:`
  - `Executor view:`
  - `Evidence:`
- troubleshooting mode for repeated failures and explicit debugging requests
- diagnostic-discovery research for finding logs, event channels, output
  surfaces, and verbosity controls for a component under investigation
- explicit lifecycle-state modeling for Ansible capabilities as a preferred pattern
- lightweight GitHub-issue workflow support for staged work that should outlive local notes
  or rough brainstorming once it becomes concrete enough to preserve

Planned next:
- quality comparison workflow for the next 2-3 efforts
- one real repo problem taken through the framework end to end
- runtime validation of the effective Codex instruction stack:
  - confirm which surfaces are actually injected into Codex sessions
  - confirm whether `.cursor/rules/*.mdc` files are enforced, advisory, or inactive
  - distinguish configured multi-agent support from verified separate-agent execution

## Environment-Specific Enforcement Hierarchy

This repo intentionally uses different top-level enforcement paths depending on
the chat/runtime environment.

### Codex / OpenAI conversations in this repo

Use this hierarchy:

1. `AGENTS.md`
2. project `.codex/config.toml`
3. `.cursorrules`
4. active `.cursor/rules/*.mdc`
5. `docs/codex_framework/README.md`
6. `docs/codex_framework/partner_process.md`

In this environment, `AGENTS.md` is the highest repo-level contract and is
responsible for bootstrapping the rest of the instruction/doc surfaces, while
`.codex/config.toml` is the official Codex runtime layer for project-scoped MCP
and subagent configuration.

### Cursor-native workspace conversations

Use this hierarchy:

1. `.cursorrules`
2. active `.cursor/rules/*.mdc`
3. `AGENTS.md`
4. framework docs and skills

In that environment, Cursor-native rule loading is the strongest path and
`AGENTS.md` remains part of the repo contract beneath it.

## Known Validation Gap

The repo now has three different layers that can be easy to conflate:

- documented framework intent in `docs/codex_framework/` and `.cursor/rules/`
- Codex and MCP tooling installed/configured on the machine
- the subset of instructions that are actually active inside a given Codex session

Current evidence supports the following:

- `AGENTS.md` is part of the active repo contract
- the repo now has a project-level Codex config surface at `.codex/config.toml`
- Codex tooling and Codex MCP integration are present and configured
- the repo clearly documents `Planner / Steward`, `Researcher`, and later
  `Executor` as framework roles
- the project now maps official Codex built-in agent roles to those framework
  roles instead of describing them only as abstract personas

What still needs explicit validation:

- whether `.cursor/rules/*.mdc` are actually injected/enforced in Codex runtime
  sessions or are primarily a Cursor-side rule layer
- whether a given Codex session is using only one agent with multiple role
  signals, or is actually spawning separate agents
- whether the configured `default` / `explorer` / `worker` mapping is being used
  automatically in practice or only when delegation is explicitly requested

Until that validation is done, the safest language is:

- the repo has a documented Codex framework
- parts of that framework are operational at the process/instruction level
- the repo now has an official Codex project-config layer for MCP and subagents
- true separate-agent enforcement/execution should not be claimed without
  direct runtime evidence

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
  Supporting collaboration rule for working with Josh, including voice-to-text tolerance, strong-context inference, and explicit surfacing of text that still does not make sense.
- [.cursor/rules/codex-framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-github-issue-workflow.mdc)
  The dedicated rule surface that introduces and governs the GitHub issue workflow as its own reusable capability area.
- [.cursor/rules/codex-framework-troubleshooting-mode.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-troubleshooting-mode.mdc)
  The dedicated rule surface that governs troubleshooting-mode triggers,
  evidence hierarchy, per-run reporting, and operator-facing evidence options.

### Skill workflows

- [.cursor/skills/ansible-planner/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-planner/SKILL.md)
  The current `Planner / Steward` workflow.
- [.cursor/skills/ansible-researcher/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-researcher/SKILL.md)
  The current `Researcher` workflow. This now explicitly includes
  diagnostic-discovery research for questions like "where does this thing log"
  and "how do we surface more output for troubleshooting?"
- [.cursor/skills/github-issue-workflow/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/github-issue-workflow/SKILL.md)
  A small reusable workflow for turning staged work or concrete brainstorming into GitHub issues when durable backlog tracking is better than local notes alone. The repo plan under `docs/plans/` is the canonical durable plan, while the issue acts as the higher-level roadmap/tracking layer. The workflow now uses a non-optional light label schema: one `type:*`, one `state:*`, and one `scope:*` label on every created issue.

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
- `troubleshooting-*` is not a separate family; troubleshooting mode is a
  framework-owned capability and therefore stays under `codex-framework-*`.

The `github-*` group should be treated as a capability family, not a one-off
exception. The first active member of that family is:

- [codex-framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/codex-framework-github-issue-workflow.mdc)

### Naming anatomy example

`codex-framework-github-issue-workflow.mdc` is meant to read as:

- `codex-framework`
  This is an active framework-owned rule surface, not just an incidental doc or
  one-off project note.
- `github`
  This belongs to the GitHub-backed planning/backlog capability family.
- `issue-workflow`
  This specific rule governs how issues are created, updated, closed, labeled,
  and used for pickup.
- `.mdc`
  This is an active rule file, not plain markdown.

So the filename is doing three jobs at once:

- showing framework ownership
- showing capability-family grouping
- showing the specific behavior owned by the file

The family purpose is lightweight GitHub-backed project planning and lifecycle
handling for things like:

- new capabilities
- features
- bugs
- cleanup work
- staged follow-ups

This is intentionally loose. It is meant to reduce rough planning clutter in
the repo, not replace judgment with rigid process.

## Troubleshooting Mode

Troubleshooting mode is an active framework capability for repeated failures and
explicit debugging requests.

Default trigger:

- automatic on repeated failure for the same component or capability
- immediate when the user explicitly asks to troubleshoot or gather more output

In troubleshooting mode, every retry or reapply should report:

- the component under investigation
- evidence surfaces identified
- evidence surfaces collected in that run
- evidence surfaces still missing
- the actual output seen in that run

The framework treats these as separate first-class evidence categories:

1. component-native logs, events, status, or vendor diagnostics
2. explicit remote command output
3. module results and registered task output
4. Ansible verbosity or transport output

This means `-vvv` or `-vvvv` are useful, but they do not replace logs, event
sources, vendor CLI diagnostics, or explicit remote stdout/stderr.

## Diagnostic Discovery

Diagnostic discovery is an active Researcher capability.

It covers requests like:

- where this component logs
- what event channels it uses
- what CLI diagnostics it exposes
- how to enable more output or debug verbosity
- which evidence surfaces are already wired into the repo
- research where Multipass logs on Windows
- find the output surfaces for this service
- what knobs can I turn on to get more debug output for this tool

The expected standardized result is:

- where the component logs or reports state
- how to enable more output
- what surfaces are already wired into the repo
- what is still missing
- what simple operator knobs can be used on later runs

The expected durable home for those findings is:

- [docs/diagnostics](/Users/joshc/develop/dotfile-vnext/docs/diagnostics)

When the answer should survive beyond one run, Codex should prefer creating or
updating a diagnostics note there instead of leaving the research only in chat.

## Implemented Plan History

Approved plans should be stored under:

- [docs/plans](/Users/joshc/develop/dotfile-vnext/docs/plans)

That repo plan is the canonical durable artifact. It should be detailed enough
to stand alone if GitHub is unavailable.

When GitHub is available:

- mirror the work into a higher-level issue
- keep the issue more roadmap-like than the repo plan
- link the two when that helps future pickup

Framework-specific implemented-plan history should still be stored under:

- [docs/codex_framework/implemented_plans](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/implemented_plans)

This is the framework-only history layer for accepted framework plans that have
already been implemented.

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

For the `github-*` family specifically, do not wait for multiple rule files
before calling it a family. If the repo has:

- a named capability group
- at least one active rule in that group
- an active skill aligned to that group

then it should already be documented and treated as a scalable family.

### Legacy note

Older files may still use numbered names or other historical naming. Treat those as legacy unless they are intentionally kept active and there is a clear reason not to rename them yet.
