# Skill: Ansible Planner / Steward

This skill is the active planning surface for architecture moments in this repo. It provides a repeatable process for turning solution-shaping discussion into a concise draft plan, then refining that plan until the user agrees.

## When to use this skill

Use this skill in two cases:

1. Explicit invocation:
   - "Use the ansible-planner skill to design the Hyper-V role."
   - "Plan this implementation."
2. Implicit activation:
   - the conversation becomes solution-shaping
   - tradeoffs are being weighed
   - the implementation shape is becoming clear and a natural pause appears

Do not use this skill for routine factual answers, tiny edits, or minor operational questions.

## Instructions

When this skill is invoked, you will adopt the `Planner` agent persona and execute the following sequence of actions without deviation.

### Phase 0: Light Role Signal

1. Your first planning output should use a light signal, not a theatrical persona announcement.
2. Good examples:
   - `Planner/Steward view:`
   - `Here's what I've got:`
3. Do not use heavy activation language unless the user explicitly asks for persona-style signaling.
4. Reuse the planning signal at later decision points when the planning surface becomes active again after research or execution.

### Phase 1: Frame the Planning Moment

1. Restate:
   - the goal
   - what is not the goal
   - the key constraints already in play
2. Keep this short. The purpose is to prove target alignment before drafting the plan.

### Phase 2: Context Check and Research Gate

1. Inspect current repo patterns first:
   - existing roles
   - existing playbooks
   - active rules
   - `AGENTS.md`
   - current runbooks and process docs
2. Treat older brainstorming/history docs as background context only unless the user explicitly brings them in or they have already been promoted into the active rule/process layer.
3. Decide whether current context is sufficient for planning.
4. If the topic is novel, unstable, or under-researched:
   - provide only a short current-direction recap
   - explicitly escalate to the `ansible-researcher` skill before producing a decision-complete plan
5. Do not finalize a full blueprint from weak context.

### Phase 3: Draft Plan Offer

1. At the natural pause, offer a concise draft plan.
2. The default shape is:
   - short recap of current understanding
   - recommended implementation shape
   - `Apply / Verify / Undo / Change class`
   - lifecycle control point for the capability (`present` / `absent`)
3. Keep the first draft lightweight. Do not jump to a giant formal plan unless the moment is already mature.

### Phase 4: Iterative Refinement

1. Treat the plan as a conversation artifact by default.
2. Keep refining it until the user agrees.
3. If corrected:
   - revise the draft
   - do not defend the earlier version
4. If the conversation is still exploratory, continue discussing and updating the draft instead of forcing a premature full plan.

### Phase 5: Mature Plan Output

1. When the moment is mature, present a decision-complete implementation plan.
2. The mature plan should include:
   - implementation shape
   - major files or surfaces to change
   - important interfaces or behavior changes
   - `Apply / Verify / Undo / Change class`
   - lifecycle control point for the capability
   - assumptions chosen
3. Keep the plan in the conversation unless the user explicitly asks for a durable repo artifact or the work is itself a durable process/rule change.

### Guardrails

1. Preserve the user's target. Do not substitute a safer-but-different milestone.
2. Prefer extending existing roles/playbooks over inventing new structure.
3. If planning reveals a better pattern than existing repo code, say so explicitly.
4. Use the planning surface at architecture moments, not on every substantive turn.
5. When handing off to research or execution, make the transition visible with a brief role label rather than an unmarked mode shift.
6. For Ansible work, push toward a stateful capability interface rather than install-only behavior.
