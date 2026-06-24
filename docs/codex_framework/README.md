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

## Capability introduction

Before adding a new Ansible capability with inventory SSOT, naming patterns, or
NetBox seeds, complete
[capability_introduction_checklist.md](capability_introduction_checklist.md).

Plan diagram enforcement: [plan-governance-dependencies.md](plan-governance-dependencies.md)
(see also `.cursor/rules/framework-plan-governance.mdc`).
Plan execute/complete verification: [plan-verification-receipt.md](plan-verification-receipt.md)
(full obligation inventory — not checklist-only).
Reusable multi-agent and role-split execution patterns:
[agent-workflows/](agent-workflows/README.md).
Patterns belong in `docs/reference/naming-standards/`; instances in
`live-object-registry.yml` — not duplicated in plan bodies.

## Scope Boundary

This folder name stays `docs/codex_framework/` on purpose.

- The folder documents this project's Codex-specific implementation and usage of
  the framework.
- The active rule family under `.cursor/rules/` uses `framework-*` filenames on
  purpose so those rule files stay as agent-agnostic as practical.

Do not treat those two naming decisions as the same scope. The filename family
for active rule surfaces is intentionally broader; the docs folder remains
Codex-scoped because it describes the Codex implementation layer for this repo.

The agnostic companion area for reusable framework-compatible surfaces now lives
under [docs/framework-compatible/](/Users/joshc/develop/dotfile-vnext/docs/framework-compatible/README.md).

## Why This Is Transitional

Some of the active rule files were created before the current OpenAI/Codex customization shape was better understood.
Historical notes and conversation archives may still mention the older filenames and paths. Treat the files listed in this README as the active names.

The capability-specific rule files no longer use numeric prefixes or double-dash load-order naming. The framework README is now the visibility layer for what is active.

Today the working stack is:
1. `AGENTS.md`
2. project Codex runtime config in `.codex/config.toml`
3. framework docs under `docs/codex_framework/`
4. selected `framework-*` and supporting `.cursor/rules/*.mdc` files loaded by
   the repo bootstrap
5. skill discovery via `.cursor/skills/catalog.yml` and per-skill manifests
6. MCP and live environment tools
7. multi-agent delegation via reusable patterns under
   `docs/codex_framework/agent-workflows/`, only after the first six are stable

The current startup default is a stable single-agent Codex profile.
Experimental multi-agent behavior remains available, but it is no longer the
default entry path while runtime validation is still incomplete.

Current framework experiment:
- Researcher MCP checkpoints remain defined directly in `AGENTS.md`
- Steward MCP checkpoints are externalized into `framework-ansible-mcp-usage.mdc`
- this is an intentional stress test comparing direct `AGENTS.md` definition
  versus externalized rule-surface definition during normal repo work
- `AGENTS.md` now stays general and points Codex at the framework-owned rule
  family instead of carrying the narrower experiment details as if they were
  the permanent top-level contract

For MCP validation, this repo now also keeps a small probe profile in project
`.codex/config.toml`:
- `mcp_probe_drawio`

That profile is not meant for normal work. It is a low-noise validation entry
point for `codex exec` when the goal is to isolate one MCP server from other
runtime chatter such as SQLite warnings, app/plugin sync, or unrelated MCP
startup.

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
- startup default profile:
  - `stable_single_agent`
- opt-in experimental profile:
  - `experimental_multi_agent`
- built-in Codex role mapping:
  - `default` -> `Planner / Steward` in the main thread
  - `explorer` -> `Researcher`
  - `worker` -> `Executor`
- visible transition signals for active framework surfaces:
  - `Planner/Steward view:`
  - `Researcher view:`
  - `Executor view:`
  - `Outcomes:`
- `Evidence:` is reserved for troubleshooting proof, collected outputs, saved
  artifacts, and source-backed findings
- troubleshooting mode for repeated failures and explicit debugging requests
- diagnostic-discovery research for finding logs, event channels, output
  surfaces, and verbosity controls for a component under investigation
- explicit lifecycle-state modeling for Ansible capabilities as a preferred pattern
- reusable agent workflow registry for coordinator/validator/release-gate
  patterns
- lightweight GitHub-issue workflow support for concrete brainstorming or
  resumable work that should outlive local notes once it becomes durable enough
  to preserve

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
3. `docs/codex_framework/README.md`
4. `docs/codex_framework/partner_process.md`
5. active `framework-*` files under `.cursor/rules/`, plus any explicitly
   referenced supporting rule files
6. `.cursorrules` only as workspace boot intent, not as a native Codex startup
   source

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
- official Codex discovery behavior aligns with `AGENTS.md` and project-scoped
  `.codex/config.toml`
- the startup default now intentionally favors stable single-agent operation
  over experimental multi-agent operation
- Codex tooling and Codex MCP integration are present and configured
- the repo clearly documents `Planner / Steward`, `Researcher`, and later
  `Executor` as framework roles
- the project now maps official Codex built-in agent roles to those framework
  roles instead of describing them only as abstract personas

What still needs explicit validation:

- whether `AGENTS.md`-bootstrapped loading of selected `.cursor/rules/*.mdc`
  files is happening consistently enough to treat them as durable Codex process
  inputs rather than repo guidance that must be re-read per task
- whether `.cursor/rules/*.mdc` are actually startup-injected/enforced in Codex
  runtime sessions or are primarily a Cursor-side rule layer
- whether `.cursorrules` should remain in the Codex-framework conversation at
  all beyond documenting Cursor-native behavior, given official Codex discovery
  uses `AGENTS.md` plus fallback filenames and includes at most one instruction
  file per directory
- whether a given Codex session is using only one agent with multiple role
  signals, or is actually spawning separate agents
- whether the configured `default` / `explorer` / `worker` mapping is being used
  automatically in practice or only when delegation is explicitly requested

Until that validation is done, the safest language is:

- the repo has a documented Codex framework
- parts of that framework are operational at the process/instruction level
- the repo now has an official Codex project-config layer for MCP and subagents
- the default startup posture should stay on `stable_single_agent`
- multi-agent behavior should be treated as an explicit experiment via
  `experimental_multi_agent`
- `.cursorrules` should not be treated as a native Codex startup source without
  direct evidence
- true separate-agent enforcement/execution should not be claimed without
  direct runtime evidence

## MCP Probe Profiles

When a repo-local MCP server needs startup validation, prefer a dedicated
profile over ad hoc `codex exec` overrides when the pattern is likely to be
reused.

Current practical profile:

- `mcp_probe_drawio`
  - disables `sqlite`
  - disables `apps`
  - disables unrelated MCP servers
  - leaves only `drawio` enabled

Use it like:

```bash
codex exec \
  -C /Users/joshc/develop/dotfile-vnext \
  -p mcp_probe_drawio \
  --ephemeral \
  'Very short probe: tell me whether the drawio MCP server started successfully in this session.'
```

This is a practical repo-local documentation and validation surface, not yet a
generalized framework abstraction. If more MCP servers need this treatment,
either add sibling probe profiles or promote the pattern into a more reusable
Codex validation note later.

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
- [docs/codex_framework/container-orchestration-integration.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/container-orchestration-integration.md)
  The Codex/OpenAI implementation note for the container-orchestration integration capability family.
- [docs/codex_framework/mcp-research-collection-stack.md](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/mcp-research-collection-stack.md)
  The controller-local research and fetching MCP capability covering Context7,
  Firecrawl, Playwright, and Fetch routing.
- [docs/codex_framework/capabilities/mcp-research-collection-stack.yml](/Users/joshc/develop/dotfile-vnext/docs/codex_framework/capabilities/mcp-research-collection-stack.yml)
  Machine-readable ownership, integration, update, and removal manifest for the
  MCP Research Collection Stack.

### Capability-specific rule layer

- [.cursor/rules/framework-partner-process.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-partner-process.mdc)
  The main rule that operationalizes the partner process.
- [.cursor/rules/framework-agent-role-and-persona.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-agent-role-and-persona.mdc)
  Supporting role/persona rule currently affecting how the framework presents and asserts.
- [.cursor/rules/framework-knowledge-and-research.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-knowledge-and-research.mdc)
  Supporting research hierarchy and stewardship gate.
- [.cursor/rules/framework-mcp-and-tool-usage.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-mcp-and-tool-usage.mdc)
  Supporting MCP-first and validation/tool-usage rule.
- [.cursor/rules/framework-user-interaction-style.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-user-interaction-style.mdc)
  Supporting collaboration rule for working with Josh, including voice-to-text tolerance, strong-context inference, and explicit surfacing of text that still does not make sense.
- [.cursor/rules/framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-github-issue-workflow.mdc)
  The dedicated rule surface that introduces and governs the GitHub issue workflow as its own reusable capability area.
- [.cursor/rules/framework-troubleshooting-mode.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-troubleshooting-mode.mdc)
  The dedicated rule surface that governs troubleshooting-mode triggers,
  evidence hierarchy, per-run reporting, and operator-facing evidence options.
- [.cursor/rules/ansible-knowledge-gate.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/ansible-knowledge-gate.mdc)
  The Ansible-specific knowledge gate for repo-grounded automation design,
  module discovery, and validation planning.
- [.cursor/rules/netbox-knowledge-gate.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/netbox-knowledge-gate.mdc)
  The NetBox-specific knowledge gate for source-of-truth modeling, naming,
  hierarchy, tags, fields, interfaces, IPs, and `nb_inventory`.
- [.cursor/rules/framework-project-maturity-router.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-project-maturity-router.mdc)
  The router rule for broad project-maturity requests that should activate one
  or more domain knowledge gates without merging them.
- [.cursor/rules/framework-container-orchestration-integration.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-container-orchestration-integration.mdc)
  The framework-owned rule for normalizing imported Kubernetes and Docker guidance into repo-local runtime, NetBox, Ansible, and naming authorities.

### Skill workflows

- [.cursor/skills/catalog.yml](/Users/joshc/develop/dotfile-vnext/.cursor/skills/catalog.yml)
  Machine-readable skill inventory and first-stop discovery surface for what
  capabilities exist.
- [.cursor/skills/README.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/README.md)
  The standard skill pattern, discovery order, and update/remove guidance.

- [.cursor/skills/ansible-planner/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-planner/SKILL.md)
  The current `Planner / Steward` workflow.
- [.cursor/skills/ansible-researcher/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-researcher/SKILL.md)
  The current `Researcher` workflow. This now explicitly includes
  diagnostic-discovery research for questions like "where does this thing log"
  and "how do we surface more output for troubleshooting?"
- [.cursor/skills/ansible-knowledge-gate/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/ansible-knowledge-gate/SKILL.md)
  The modular Ansible knowledge gate. It requires repo and Ansible authority
  checks before Ansible design or implementation.
- [.cursor/skills/netbox-knowledge-gate/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/netbox-knowledge-gate/SKILL.md)
  The modular NetBox knowledge gate. It requires repo and NetBox authority
  checks before NetBox modeling or source-of-truth changes.
- [.cursor/skills/project-maturity-router/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/project-maturity-router/SKILL.md)
  The composition skill for broad project-improvement requests. It routes to
  the Ansible gate, NetBox gate, or both while keeping the gates separate.
- [.cursor/skills/container-orchestration-integration/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/container-orchestration-integration/SKILL.md)
  The modular runtime-guidance integration workflow. It keeps imported
  Kubernetes and Docker guidance in separable packets and maps each source item
  to repo-local runtime, NetBox, Ansible, and naming authorities.
- [.cursor/skills/container-orchestration-integration/capability.yml](/Users/joshc/develop/dotfile-vnext/.cursor/skills/container-orchestration-integration/capability.yml)
  The machine-readable manifest for the container-orchestration integration
  capability family, including packet refs, companion rule, and owned-file
  inventory.
- [.cursor/skills/github-issue-workflow/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/github-issue-workflow/SKILL.md)
  A small reusable workflow for turning concrete brainstorming or resumable work
  into GitHub issues when durable backlog tracking is better than local notes
  alone. The repo plan under `docs/plans/` is the canonical durable plan, while
  the issue acts as the higher-level roadmap/tracking layer. The workflow now
  uses a non-optional light label schema: one `type:*`, one `state:*`, and one
  `scope:*` label on every created issue. It now also supports explicit
  multi-repo issue sets with `primary` / `secondary` / `reference_only` repo
  roles.
- [.cursor/skills/github-issue-workflow/capability.yml](/Users/joshc/develop/dotfile-vnext/.cursor/skills/github-issue-workflow/capability.yml)
  The machine-readable manifest for the GitHub issue workflow, including
  suggested roles, capabilities, companion rule, and owned-file inventory.

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
- keep the reusable compatibility layer in `docs/framework-compatible/`
- make the framework extractable later without dragging the whole project layout with it

The root project should only need to say that it uses this capability. The capability itself should be documented here.

## Skill Discovery Pattern

For repo-local skills, the standard discovery order is:

1. `.cursor/skills/catalog.yml`
2. per-skill `capability.yml`
3. per-skill `SKILL.md`
4. companion rule files listed by the manifest
5. `docs/codex_framework/*`

Use that order on purpose:

- catalog first for quick capability discovery
- manifest second for machine-readable role, trigger, and ownership data
- skill body third for the actual portable workflow
- rule fourth for repo-specific ambient guidance
- docs last for broader explanation and capability inventory

## Capability Packet Default

Grouped capabilities are installed as capability packets, not scattered edits.
This applies to framework extensions, skill families, MCP stacks, feature
families, and non-trivial Ansible capability groups.

Each packet needs a manifest that tracks:

- `owned_files`
- `integration_files` when existing framework surfaces are touched
- `update_behavior`
- `removal_behavior`
- lifecycle/apply/verify/undo surfaces when runtime automation exists

Broad framework docs and rules should carry short integration anchors that point
back to the packet manifest or primary capability document. Detailed capability
behavior belongs with the packet so install, update, and removal remain
predictable.

New or meaningfully updated skills should carry:

- a `capability.yml`
- a catalog entry
- an `owned_files` list in the manifest when the capability owns companion rule
  files, references, or other update/remove surfaces

## Naming Guidance For Domain-Specific Additions

If the framework later gains domain-specific extensions, the names should say so plainly.

Examples:
- `ansible-*` for Ansible-specific rules, workflows, or skills
- `netbox-*` for NetBox-specific rules, workflows, or skills
- `github-*` for GitHub issue workflow rules and related durable backlog behavior
- project-qualified names when something is specific to this repo rather than reusable elsewhere

That keeps the generic Codex framework visible and reduces accidental coupling between reusable framework behavior and project-specific automation concerns.

## Active Naming Logic

This is the naming logic Codex should treat as active in this repo:

- `framework-*`
  Use for active rules that define framework-owned behavior in an agent-agnostic way where practical.
- `ansible-*`
  Use for active rules, workflows, or skills that are specifically about Ansible behavior, design, or execution.
- `netbox-*`
  Use for active rules, workflows, or skills that are specifically about
  NetBox source-of-truth modeling, naming, inventory derivation, and API-backed
  object management.
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

- `framework-*`
  Core framework rules that shape the repo's AI working framework without tying the filenames to a single host or agent brand.
- `ansible-*`
  Domain-specific rules, workflows, or skills for Ansible behavior.
- `github-*`
  Workflow surfaces for durable GitHub issue tracking, staging, labeling, and
  pickup behavior.
- `troubleshooting-*` is not a separate family; troubleshooting mode is a
  framework-owned capability and therefore stays under `framework-*`.

The `github-*` group should be treated as a capability family, not a one-off
exception. The first active member of that family is:

- [framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-github-issue-workflow.mdc)

### Naming anatomy example

`framework-github-issue-workflow.mdc` is meant to read as:

- `framework`
  This is an active framework-owned rule surface, not just an incidental doc or
  one-off project note. The name is intentionally agent-agnostic so the same
  rule family can make sense across Codex/OpenAI, Cursor-native, and similar
  chat/runtime environments.
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
- durable follow-ups

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

When a component is entering repeated troubleshooting and the repo still lacks a
saved-artifact entrypoint for it, the expected follow-on is:

1. create or update the diagnostics note under `docs/diagnostics/`
2. verify the identified evidence surfaces with explicit live probes
3. add a narrow collector task file under `roles/troubleshooting_collectors/`
4. add a dedicated troubleshoot playbook under `playbooks/troubleshoot/`

This is the default automatic path inside troubleshooting mode, not an optional
extra workflow:

1. trigger on repeated failure or explicit request
2. identify the component and output locations
3. use or create the diagnostics note
4. verify the evidence surfaces with direct probes
5. use the collector/playbook if present, or wire one if missing
6. rerun with troubleshooting controls enabled

That collector/playbook layer is support work. It does not replace the
mandatory troubleshooting-mode report in the normal role/playbook path.

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
- [framework-partner-process.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-partner-process.mdc)
- [framework-github-issue-workflow.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-github-issue-workflow.mdc)
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
