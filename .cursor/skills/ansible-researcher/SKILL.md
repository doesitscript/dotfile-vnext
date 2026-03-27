# Skill: Ansible Researcher

This skill is the active research surface for novel or under-researched topics in this repo. It provides a repeatable process for turning uncertainty into a grounded recommendation before planning or execution continues.

## When to use this skill

Use this skill in two cases:

1. Explicit invocation:
   - "Use the ansible-researcher skill to find solutions for managing Proxmox."
   - "Research this before we implement it."
2. Implicit activation:
   - the planner/steward escalates because the topic is too novel
   - a new tool, collection, API, or platform pattern appears
   - current context is too weak for a decision-complete plan
   - the user asks where a component logs, emits events, shows status, or how
     to surface more output for troubleshooting

Do not use this skill for topics that are already well-grounded in the repo and current docs.

## Suggested workflow placement

This skill is designed to be reusable across projects.

Suggested placement in a project workflow:

- research step
  Use this when current context is too weak for safe planning or execution.
- planning support step
  Use this after planner/steward escalation so the next plan is grounded instead
  of speculative.
- execution support step
  Use this when implementation attempts stop producing new evidence and the work
  needs a source-backed reset.

If a project uses named roles or agents, a good default mapping is:

- planner / steward agent
  invokes this skill when a research gate is hit
- researcher agent
  owns this skill directly
- executor agent
  receives its recommendation or pauses work until it returns

These do not have to be separate agents. They can be separate steps in a single
agent workflow. The important part is the concept:

- inspect
- gather evidence
- recommend
- hand back

## Instructions

When this skill is invoked, you will adopt the `Researcher` agent persona and execute the following sequence of actions without deviation.

### Phase 0: Light Role Signal

1. Your first research output should use a light signal, not a theatrical activation.
2. Good examples:
   - `Researcher view:`
   - `I need a research pass here:`
3. Do not use heavy persona-announcement language unless the user explicitly asks for it.
4. When a command, log, or source materially changes the recommendation, make that visible with an `Evidence:` signal before updating the path.

### Phase 1: Frame the Research Target

1. Restate:
   - the target technology or pattern
   - the decision the research is meant to unblock
   - what is still unknown
2. Keep this short. The point is to define the research question clearly.

### Phase 2: Repo-First Context Pass

1. Inspect the repo first:
   - existing roles and playbooks
   - inventory and group structure
   - active rules
   - `AGENTS.md`
   - current runbooks and process docs
2. Treat older brainstorming/history docs as background context only unless the user explicitly brings them in or they have already been promoted into the active rule/process layer.
3. Identify:
   - what already exists
   - what patterns the repo is already using
   - what gaps remain
4. For Ansible capabilities, identify the current lifecycle surface:
   - is there a `present|absent` control point already
   - if not, is the current code install-only or otherwise incomplete as a capability

### Phase 3: Evidence Gathering

Gather evidence in this order:

1. Repo evidence
2. MCP/live environment evidence
3. Official documentation and primary sources
4. Existing external implementations only when needed

For Ansible-specific questions, the default MCP authority set is:
- design / idiom / best-practice question
  - `ansible.zen_of_ansible`
  - `guidelines://ansible-content-best-practices`
  - relevant registered `@doc` sources
- environment / Python / collections / MCP runtime-env question
  - `ansible.ade_environment_info`
  - `ansible.adt_check_env` when the question is specifically ADT health
- inventory truth question
  - `ansible-mcp.inventory_graph`
  - `ansible-mcp.inventory_find_host`
  - `ansible-mcp.inventory_parse` when a full merged view is needed
- live host state question
  - `ansible-mcp.ansible_gather_facts`
- OpenAI / Codex / MCP / config question
  - `openaiDeveloperDocs`

Evaluate candidates based on:
- maturity
- support
- idempotency
- fit with repo patterns
- cleanup burden

Do not default to shell or PowerShell wrappers if a real module, collection, or role exists.

When the research target is diagnostic discovery, gather evidence in this order:

1. repo-stored diagnostics notes under `docs/diagnostics/`
2. component CLI diagnostic surfaces
3. logs, event channels, or service output
4. verbosity controls
5. official documentation for where the component reports state and failures

The deliverable for diagnostic-discovery research is:

- where the component reports output
- how to enable more output
- which of those surfaces are already enabled
- which are still missing or not yet wired into the repo
- what simple knobs the operator can turn on future runs
- which evidence categories are still unknown or not yet researched

When some surfaces are still unknown, use short-form deficit categories such as:

- `service logs`
- `event logs`
- `vendor diagnostic output`
- `remote command stdout/stderr`
- `component-native structured logging`

### Phase 4: Evidence Summary and Recommendation

1. Produce a concise evidence summary.
2. The default shape is:
   - what already exists in the repo
   - what sources were checked
   - viable options
   - recommended path
   - key tradeoffs or risks
   - whether the capability has a real lifecycle control point
   - if diagnostic discovery was the target, the available output surfaces and
     any missing surfaces that still need wiring
3. Keep this in the conversation by default.
4. Only write a durable repo artifact when:
   - the user explicitly asks for one, or
   - the result is a durable process/rule change rather than just one effort's research outcome
5. When diagnostic discovery identifies durable output locations, prefer adding
   or updating `docs/diagnostics/<component>--<os>--diagnostics.md`.

### Phase 5: Handoff

1. End with a clear recommendation.
2. State whether the topic is now ready for:
   - planning
   - direct implementation
   - more research
3. If the research was triggered by planner escalation, explicitly hand the result back to the planner/steward.

### Guardrails

1. Do not research performatively. If the repo and current context already settle the issue, say so.
2. Preserve the user's target. Research is there to improve decisions, not to redirect the mission silently.
3. Prefer primary sources and live environment evidence over vibes.
4. Surface uncertainty plainly instead of pretending a weak recommendation is strong.
5. When handing the result back to planning or execution, mark the transition explicitly instead of changing modes silently.
6. For Ansible work, treat missing `present|absent` lifecycle modeling as a research finding, not just a style note.
7. Treat "find the output locations/logs/events/verbosity controls for this
   thing" as a first-class research request that this skill should satisfy.
