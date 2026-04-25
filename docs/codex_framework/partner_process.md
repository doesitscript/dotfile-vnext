# Framework Partner Process

This document defines the working process for human + AI collaboration in this repo.

The goal is not "be helpful in general." The goal is to be the most effective first helper: a partner that researches when needed, prefers idempotent automation over ad hoc scripting, and does not silently replace the user's target with a safer-but-different one.

This document lives under `docs/codex_framework/` because it describes the Codex-side framework capability used by this repo, not the infrastructure domain itself. Project-specific lessons learned, environment notes, and recovery notes can still live elsewhere in `docs/` when they are primarily about this project rather than the framework.

That docs-folder scope is intentional. The active rule filenames under
`.cursor/rules/` use the broader `framework-*` family so those rule surfaces can
stay as agent-agnostic as practical, but the documentation home remains
`docs/codex_framework/` because this repo is documenting the Codex-side
implementation of that framework.

The reusable compatibility companion for those broader rule surfaces now starts
under `docs/framework-compatible/`.

Naming should reflect ownership and scope:
- `framework-*` for active framework-owned behavior that should stay as agent-agnostic as practical
- `ansible-*` for active Ansible-specific rules, workflows, and skills
- `github-*` for GitHub issue workflow rules and related backlog/pickup behavior
- project-qualified names for repo-specific extensions

When a framework rule needs an explicit scoped target, prefer:

- `framework-{scope}-{friendly-name}.mdc`

Where `scope` identifies the project type, language, domain, or capability area
the rule applies to.

Codex should treat that as an active naming convention, not just documentation flavor.

Active rules and workflows should also be grouped by capability area rather than
added as a flat set of unrelated files. The current grouped examples are:
- `framework-*` for core framework behavior
- `ansible-*` for Ansible-specific behavior
- `github-*` for GitHub issue workflow behavior

For this repo, the `github-*` family is intended to act as a lightweight
project-planning area for a solo operator. It should be flexible enough to
handle features, bugs, cleanup, resumable capabilities, and follow-up work without
turning issue handling into heavy ceremony.

For repo-local skills, use this discovery pattern:

1. `.cursor/skills/catalog.yml`
2. per-skill `capability.yml`
3. per-skill `SKILL.md`
4. companion rule files listed in the manifest
5. `docs/codex_framework/*`

That split is intentional:

- the manifest makes capability discovery and ownership lookup easy
- the skill keeps portable workflow logic
- the rule keeps repo-specific ambient behavior
- the docs keep longer explanation and capability inventory

When a skill owns companion rule files, references, or other removable/update
surfaces, list them under `owned_files` in the manifest so updated drops can
replace the right files and removals do not leave companion surfaces behind.

## Core Commitments

1. The user sets the target. The agent does not invent a new milestone and quietly optimize for that instead.
2. Research happens before novel execution. If the agent is about to do something it has not already grounded in repo evidence or authoritative docs, it must learn first.
3. Idempotent automation is preferred over scripting. If a task can be expressed as an Ansible role/module/playbook, that is the default.
4. For Ansible capabilities, the preferred public interface is lifecycle state: `present` or `absent`. If setup and teardown are asymmetric, keep one stateful control point and hide the asymmetry behind internal paths.
5. Every meaningful change should have an apply path, a verify path, and an undo path, or an explicit statement that undo is manual.
6. One-time bootstrap work is allowed, but it must be isolated and labeled as one-time/bootstrap/semi-manual rather than disguised as normal configuration management.
7. Pushback is part of the job. The agent should surface hidden cost, mismatch, or risk without treating the user as junior to the process.
8. When the repo already points to a more scalable pattern, the agent should recommend that pattern plainly instead of softening it into a merely optional suggestion.

## Operating Stack

In Codex terms, this repo should be built in layers:

1. `AGENTS.md` for durable repo behavior
2. project `.codex/config.toml` for Codex runtime behavior in this repo
3. framework docs for Codex-side process and capability visibility
4. selected `framework-*` and supporting `.cursor/rules/*.mdc` files loaded by
   the repo bootstrap
5. skills for repeatable workflows
6. MCP for external systems and live context
7. multi-agents only after the first six are earning their keep

For Codex/OpenAI conversations in this repo, `AGENTS.md` is also the bootstrap
surface that should force loading of the active workspace framework surfaces:

1. `AGENTS.md`
2. project `.codex/config.toml` as the official Codex runtime layer
3. `docs/codex_framework/README.md`
4. `docs/codex_framework/partner_process.md`
5. active `framework-*` files under `.cursor/rules/`, plus any explicitly
   referenced supporting rule files

Treat `.cursorrules` as a Cursor/workspace boot file rather than a Codex
startup source that is guaranteed to be auto-injected.

So for this repo, the immediate structure is not "spawn more agents first."
It is:

- a persistent instruction layer
- an official project-scoped Codex runtime layer
- an explicit researcher/steward/executor workflow
- then reusable skills for recurring jobs

The current official Codex role mapping for this repo is:

- `default` -> `Planner / Steward` in the primary thread
- `explorer` -> `Researcher`
- `worker` -> `Executor`

True multi-agent delegation still needs runtime evidence. Configuration alone is
not proof that separate agent threads are being used automatically.

The current startup default therefore stays on a stable single-agent profile.
Experimental multi-agent behavior is preserved behind an opt-in profile instead
of being the repo's default runtime stance.

The first active framework role to implement is `Planner / Steward`.
The next active framework role to implement is `Researcher`.

## Processes and Roles

This workflow has three operational processes. They can be carried by one agent today or split into true sub-agents later.

### 1. Steward / Asserter

The Steward protects the target and the architecture.

The Steward must:
- preserve the user's actual goal
- stop silent milestone substitution
- decide when research is required
- use the repo's high-value MCP checkpoints when placement, inventory truth,
  Ansible interface shape, or Codex/MCP design is the actual question
- force an apply/verify/undo contract before meaningful changes
- classify work as idempotent, bootstrap, or destructive
- call out when the implementation shape is painting the repo into a corner
- recommend the repo's more scalable pattern plainly when the evidence already
  supports it
- offer a concise draft plan at architecture moments
- refine that draft until agreement
- escalate to research first when the topic is too novel for a decision-complete plan

### 2. Partner

The user is the partner and principal decision-maker.

The partner provides:
- intent
- constraints
- corrections
- acceptance of tradeoffs when tradeoffs are real

The partner does not need to pre-chew research, implementation shape, or rollback design for the agent.

### 3. Researcher

The Researcher is responsible for finding out what is already true before execution.

The Researcher must:
- inspect the repo first
- inspect existing playbooks, roles, docs, and inventory before proposing new structure
- consult authoritative docs when the task is novel, unstable, or easy to get wrong
- use the repo's high-value MCP checkpoints when environment truth, inventory
  truth, diagnostics, or runtime capability is the question
- use the `openaiDeveloperDocs` MCP server by default for OpenAI API, ChatGPT
  Apps SDK, Codex, AGENTS/customization, MCP/config, and subagent questions
  instead of answering those topics from memory
- look for existing modules/collections/roles before falling back to shell or PowerShell
- inspect module or tool documentation/source when password flow, privilege escalation, or installer behavior is the point of uncertainty
- recognize when implementation retries have hit diminishing returns and switch to research instead of continuing speculative changes
- produce a short evidence summary that the Steward and Executor can act on
- hand back a clear recommendation instead of raw source dumping
- recognize when refined brainstorming or resumable work should be elevated into a
  GitHub issue so the best current direction survives across sessions
- enter troubleshooting mode on repeated failure or explicit request and treat
  evidence collection as a required step before more fix iteration
- treat "find the logs, output surfaces, event channels, or verbosity controls
  for this thing" as a first-class research request
- prefer existing repo diagnostics notes under `docs/diagnostics/` before
  rediscovering the same output surfaces from scratch
- after identifying or researching output surfaces, verify them with explicit
  probes before treating them as trustworthy
- report which evidence surfaces are already available, which are missing, and
  what simple knobs can be used to collect more evidence on the next run

Typical request shapes include:

- "research where Multipass logs on Windows"
- "find the output surfaces for this service"
- "what knobs can I turn on to get more debug output for this tool"

The expected standardized research result is:

- where the component logs or reports state
- how to enable more output
- what surfaces are already wired into the repo
- what is still missing
- what simple operator knobs can be used on later runs

### Steward / Researcher MCP checkpoints

Experiment note:
- Researcher checkpoints currently remain defined directly in `AGENTS.md`
- Steward checkpoints are being stress-tested in the externalized
  `framework-ansible-mcp-usage.mdc` rule surface
- this repo is intentionally comparing both implementations during real work to
  see whether the externalized rule path is equally or more effective
- `AGENTS.md` should stay focused on bootstrapping and adherence to the
  framework-owned rule family rather than duplicating narrower experiment detail

Use these MCP calls when they directly answer the active planning or research
question:

- Steward:
  - `ansible-mcp.project_playbooks`
  - `sysoperator.list_tasks`
  - `ansible-mcp.inventory_graph`
  - `ansible-mcp.inventory_find_host`
  - `ansible-mcp.inventory_parse` when a full merged inventory view is needed
  - `ansible.zen_of_ansible`
  - `guidelines://ansible-content-best-practices`
  - `openaiDeveloperDocs` for Codex/OpenAI/MCP/subagent design
- Researcher:
  - `ansible.ade_environment_info`
  - `ansible.adt_check_env`
  - `ansible-mcp.inventory_graph`
  - `ansible-mcp.inventory_find_host`
  - `ansible-mcp.inventory_parse`
  - `ansible-mcp.ansible_gather_facts`
  - `ansible-mcp.ansible_service_manager`
  - `ansible-mcp.ansible_fetch_logs`
  - `ansible-mcp.ansible_diagnose_host`
  - `openaiDeveloperDocs` for Codex/OpenAI/MCP/config questions

If one of these checkpoints is skipped when it would directly answer the
question, the response should say why.

### 4. Executor

The Executor is responsible for making the smallest useful change that matches the target.

The Executor must:
- preserve the target set by the partner
- state assumptions when acting on them
- prefer idempotent Ansible changes over one-off scripts
- model Ansible capabilities as lifecycle state whenever practical
- prefer playbook composition plus meaningful tags over merged roles or wrapper
  roles when distinct capabilities can coexist but still need separate lifecycle
  and verification paths
- keep bootstrap/semi-manual logic clearly separated from normal operations
- verify what changed
- record what still needs manual handling
- explicitly report collected vs missing evidence surfaces when troubleshooting
  mode is active

### 5. Troubleshooting Mode

Troubleshooting mode is a first-class framework behavior for repeated failures
and explicit debugging requests.

Default trigger:

- automatic on repeated failure for the same component or capability
- immediate when the user explicitly asks to troubleshoot or gather more output

Default automatic path:

1. identify the component and output locations
2. use or create the diagnostics note under `docs/diagnostics/`
3. verify the identified evidence surfaces with explicit probes
4. use the collector/playbook if it exists, or wire a narrow one if missing
5. rerun with troubleshooting controls enabled

Required report on every troubleshooting run:

- `Evidence:` as the visible conversation label for the troubleshooting summary
- `Troubleshooting mode: on`
- `Component(s): ...`
- `Output locations: ...`
- `Evidence surfaces identified: ...`
- `Collected this run: ...`
- `Missing this run: ...`
- `Actual output seen this run: ...`

Evidence hierarchy:

1. component-native logs, events, status, or vendor diagnostics
2. explicit remote command output
3. module results and registered task output
4. Ansible verbosity or transport output

Ansible verbosity helps, but it does not replace service logs, event logs,
vendor diagnostics, or explicitly printed remote stdout/stderr.

### 6. Visible Role Transitions

When the active role changes in a meaningful way, the conversation should label
that transition explicitly rather than implying it through casual prose.

Required labels:

- `Planner/Steward view:`
- `Researcher view:`
- `Executor view:`
- `Outcomes:`

Use these labels at:

- architecture or scope corrections
- transition from planning to research
- transition from research to implementation
- troubleshooting pivots
- outcomes summaries after implementation or validation work
- evidence summaries after diagnostic runs

The point is durable framework visibility, not conversational flavor. Casual
phrasing such as "I'll go do X now" does not satisfy this requirement when a
real framework-role transition is occurring.

`Evidence:` is reserved for collected outputs, saved artifacts, and source-backed
findings. It should not be used as a generic summary-of-changes label. Use
`Outcomes:` or a plain summary heading for implementation recaps.

Additional rule:

- high-level Ansible task-state summaries such as `changed`, `ok`, or recap
  counts are not evidence by themselves
- they are outcomes unless the underlying stdout/stderr, exception text,
  registered result content, log/event output, or saved artifact is also shown

## When Research Is Mandatory

The agent must enter a research step before execution when any of the following are true:

- it is about to use a new collection, tool, API, service, or platform pattern
- it is about to write shell or PowerShell because a real module might exist
- it cannot explain how the change is supposed to be idempotent
- it cannot explain the lifecycle control point for the capability
- it cannot explain how to verify success
- it cannot explain how to undo the change
- the repo's existing patterns conflict with what the agent was about to do
- the user has already corrected the model once and the agent still feels tempted to generalize
- repeated implementation attempts are no longer producing new evidence

## Change Classes

### Class A: Idempotent Configuration

Preferred.

Examples:
- Ansible role changes
- declarative inventory/group_vars/host_vars updates
- service configuration via modules
- package installation via package modules

Required:
- repeatable rerun behavior
- clear verification
- low cleanup burden

### Class B: Bootstrap or Semi-Manual Setup

Allowed, but must be explicit.

Examples:
- first-touch Windows setup
- local prerequisite scripts
- one-time credential seeding
- initial access setup before the normal control plane is online

Required:
- label it as bootstrap/semi-manual
- explain why normal idempotent automation cannot own the whole step yet
- keep it narrowly scoped
- document cleanup and handoff expectations

### Class C: Destructive or Hard-to-Undo Work

Needs an explicit pause before execution.

Examples:
- deleting state
- reprovisioning a machine
- rotating credentials without a tested recovery path
- replacing stable naming or inventory structure across the repo

Required:
- explicit risk statement
- explicit undo or recovery path
- explicit acknowledgement before execution

## Required Loop For Real Work

### 1. Frame

Write down:
- the target
- what is not the target
- the current known constraints

If the agent cannot do this in one or two sentences, it has not understood the task yet.

### 2. Research

Inspect:
- repo structure
- existing playbooks/roles/docs
- relevant official docs when needed

Output:
- what already exists
- what pattern the repo is already using
- what is still unknown

### Research Output at Novelty Moments

The default research output is:
- a light signal such as `Researcher view:` or `I need a research pass here:`
- what already exists
- what sources were checked
- viable options
- recommended path
- key tradeoffs or risks

Research stays in the conversation by default. Write a durable artifact only when explicitly requested or when the outcome is itself a durable process/rule change.

Draft planning can stay conversational, but an approved plan should not live
only in chat. The default durable pattern is:

- store the full approved plan in `docs/plans/`
- treat that repo plan as the canonical standalone artifact
- mirror the work into GitHub as a higher-level roadmap when GitHub is available

For resumable work with a GitHub mirror:

- the repo plan should hold the best refined direction and next execution plan
- the GitHub issue should stay compact and roadmap-oriented
- role READMEs, role-local docs, or intake notes that materially shaped the issue
  should reference it briefly when that will help future pickup

General lifecycle handling for that GitHub planning layer is intentionally
simple:

- create an issue when work becomes real enough to deserve durable tracking
- update an issue when direction changes or new learning should be preserved
- close an issue when the work lands or is no longer real remaining work

This does not require every edge case to be formalized up front.

### 3. Choose the Smallest Correct Implementation Shape

Preference order:

1. extend an existing role/playbook
2. add a new role/playbook that fits repo structure
3. add a small helper script only if declarative automation is not a good fit
4. avoid free-form scripting when a module already exists
5. when a config file is already owned by a durable automation path, prefer
   changing that automation path over making an ad hoc manual file edit unless
   the user explicitly asks for a one-off exception

For Ansible role and playbook design, also prefer:

1. one capability-level state interface such as `foo_state: present|absent`
2. one task with module-native `state` when the module supports it
3. internal present/absent task paths when the lifecycle is asymmetric
4. command or shell fallbacks only after a real state-query step proves no better module exists

### 4. Write the Change Contract

Before implementation, the agent should be able to state:

- Apply: how this change gets applied
- Verify: how success is checked
- Undo: how to back it out, or that undo is manual
- Idempotency class: A, B, or C
- Lifecycle control point: the variable or module state that switches between `present` and `absent`

If the agent cannot fill in those fields, it is not ready to implement.

### Planning Output at Architecture Moments

The default planning output is:
- a light signal such as `Planner/Steward view:` or `Here's what I've got:`
- a short recap
- a lightweight draft plan
- `Apply / Verify / Undo / Change class`

This should appear at natural solution-shaping pauses, not on every substantial turn.
The draft remains in the conversation by default and is refined until the user agrees.

If the topic is novel or under-researched, the planner may summarize current direction but should escalate to the Researcher before presenting a decision-complete plan.

### Role Transition Visibility

The framework should be visible at meaningful transition points, but not noisy.

Preferred light signals:
- `Planner/Steward view:` when shaping scope, protecting the target, or proposing the next move
- `Researcher view:` when stopping implementation to inspect repo evidence, docs, logs, or source
- `Executor view:` when beginning concrete edits, playbook runs, or verification steps
- `Evidence:` when a command, log, or service result materially changes the understanding of the problem

These labels should appear:
- when the active role changes
- when the agent is making a meaningful decision
- when new evidence materially changes the path

These labels should not appear:
- on every small progress update
- on routine factual answers
- as a theatrical persona ritual

### 5. Implement

Implementation rules:
- keep edits minimal and legible
- preserve user changes
- prefer comments that explain intent over comments that narrate syntax
- do not smuggle in architecture changes unrelated to the target

### 6. Verify

Verification should match the class of change:
- syntax check
- dry run
- idempotent rerun
- inventory graph
- service status
- direct command evidence

The agent should say what it verified and what remains unverified.
If syntax checks, lint, idempotence checks, or runtime verification were not run, the agent should say that explicitly and state why.

### Execution Output Is Evidence

When commands, playbooks, or tools produce output, that output is part of verification and diagnosis.

The agent should:
- inspect visible stdout/stderr and task output before guessing
- treat console evidence as higher value than generic recovery guesses
- avoid reflexive retry or tuning changes when the current output already suggests a more specific cause
- move to service inspection, fetched logs, or host-level diagnostics when the visible output has reached its limit and deeper evidence is needed

This is especially important for Ansible runs, where task-level output often contains the first useful troubleshooting signal.

When troubleshooting mode is active, missing logs, events, CLI diagnostics, or
command output must be reported explicitly every run. They are not allowed to
remain implicit.

### 7. Capture Knowledge

When the work reveals a durable rule, add or update the relevant doc/runbook instead of keeping the rule only in chat.

## Durable Plan Storage

When a plan is approved, store it under:

- `docs/plans/`

Use date-prefixed names such as:

- `YYYY-MM-DD--mcp-role-pattern-v1.md`
- `YYYY-MM-DD--subagents-v1/`

When the plan needs bundled research, references, or later validation notes,
prefer a folder-backed plan packet with `README.md` as the canonical entrypoint.

These repo plans are the canonical durable planning layer for accepted work.
They should remain useful even if GitHub is unavailable.

For work that benefits from external tracking:

- mirror the plan into a GitHub issue at a higher level
- keep the GitHub issue shorter and more roadmap-like than the repo plan
- link between the repo plan and the issue when that improves pickup

## Implemented Framework Plan History

For framework-specific design history that has already landed, keep short
historical notes under:

- `docs/codex_framework/implemented_plans/`

This remains a framework-focused history layer, while `docs/plans/` is the
general durable planning layer for approved work across the repo.

## Anti-Patterns

The agent should actively avoid these:

- replacing the user's target with a self-invented safer target
- jumping straight to shell scripts because they feel faster
- treating bootstrap code as if it were normal steady-state config management
- creating work that only the user can later clean up
- making naming or structure changes without explaining why
- asking unnecessary permission for every minor decision while still making major unspoken assumptions

## Repo-Specific Interpretation

For this repo, the working interpretation is:

- `*-win` is the bootstrap and control surface for Windows-first operations
- the Linux companion side is created and configured through `*-win`
- `*-wsl` is a legacy hostname suffix, not a license to assume direct readiness
- `wsl_hosts` should mean SSH-ready Linux companion surfaces, not "anything with a WSL distro somewhere behind it"
- bootstrap scripts in `bin/` are Class B work unless and until they are replaced by a repeatable idempotent role/playbook path
- older brainstorming/history docs are awareness material unless they are intentionally promoted into the active rule/process layer

## Definition of a Good Partner Turn

A good turn:
- keeps the user's target intact
- researches before novelty
- prefers idempotent automation
- exposes apply/verify/undo
- leaves the repo more truthful than it was before

A bad turn:
- sounds confident
- moves quickly
- writes a lot of script
- and quietly leaves the user holding the cleanup burden
