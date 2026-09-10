---
name: extract-onsite-expert-role
description: Analyze conversation work patterns to extract and formalize an "Onsite Expert" multi-agent role definition
status: draft
priority: high
companion_skill: extract-researchers-role
companion_path: ./extract-researchers-role.md
---

# Extract Onsite Expert Role from Conversation

**Status:** 🚧 DRAFT - Role extraction meta-skill  
**Purpose:** Create reusable multi-agent role definitions from observed conversation patterns  
**Output:** Formalized role documentation with responsibilities, workflows, and skills  
**Companion skill:** [`extract-researchers-role`](./extract-researchers-role.md) — apply both to the same conversation

---

## ⚠️ Draft Status

This is a **meta-skill** for role extraction and formalization. It documents how to identify when an "Onsite Expert" pattern emerged in a conversation and how to codify it into a reusable role definition.

**Always pair with:** [`extract-researchers-role.md`](./extract-researchers-role.md). Together they recreate the full multi-agent design from conversation evidence.

---

## How These Skills Work Together

```
Conversation with emergent roles
        ↓
┌───────────────────────────────────────┐
│ Apply BOTH meta-skills in parallel:   │
├───────────────────────────────────────┤
│                                       │
│  extract-onsite-expert-role ← THIS    │
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (intake, query formulator, │
│           validator)                  │
│  - Integration patterns               │
│                                       │
│  extract-researchers-role             │
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (entry-create, consolidator,│
│           location-index)             │
│  - Artifact templates                 │
│                                       │
└───────────────────────────────────────┘
        ↓
Complete multi-agent design
with reusable role definitions
```

See companion: [`extract-researchers-role.md`](./extract-researchers-role.md).

---

## Purpose

When agent work naturally separates into distinct phases (problem intake → investigation → research coordination → validation), extract the "Onsite Expert" role pattern and create formal documentation so the pattern can be reused in future multi-agent workflows.

---

## When to Use

Use this skill when:
- ✅ A conversation involved complex problem-solving with distinct phases
- ✅ One agent/phase handled problem intake, investigation, and coordination
- ✅ Another agent/phase handled deep research execution
- ✅ The pattern worked well and should be formalized
- ✅ Want to create reusable multi-agent roles

Do NOT use when:
- ❌ Work was single-phase (no role separation)
- ❌ Pattern didn't work well
- ❌ Roles aren't clearly separable

---

## Role Recognition: What is an "Onsite Expert"?

### Primary Indicators

Look for these patterns in the conversation:

**1. Problem Intake & Structuring**
```
User provides raw problem → Agent processes it → Structured understanding
Example: "disk is full" → Investigation of surfaces → "33GB containerd, 19GB cache, 31GB artifacts"
```

**2. Initial Investigation & Data Collection**
```
Agent probes systems → Collects metrics → Identifies surfaces
Example: df -h, du -sh, kubectl get pvc → Breakdown by component
```

**3. Technology Identification**
```
Agent maps problem to technologies → Lists involved systems
Example: "This involves Kubernetes, containerd, vLLM, HuggingFace Hub, Ansible"
```

**4. Research Scoping**
```
Agent breaks problem into research queries → Scopes with context
Example: "Need to research: containerd GC (context: 33GB), HF cache mgmt (context: 19GB)"
```

**5. Guardian/Validation Role**
```
Agent validates solutions → Gatekeeps against unsafe/impractical approaches
Example: Rejected network share over Wi-Fi, approved USB 3.0 direct attach
```

### Key Distinguishing Characteristics

**What makes it "Onsite Expert" vs. other roles:**
- ✅ Owns problem understanding (not just executing tasks)
- ✅ Catalyzes other work through good handoffs
- ✅ Stays connected to problem throughout (guardian)
- ✅ Validates against real-world constraints
- ✅ Collaborative with user (not autonomous black box)

**What it is NOT:**
- ❌ Deep technical researcher (delegates research)
- ❌ Implementation executor (plans but doesn't implement alone)
- ❌ Purely autonomous (works with user)

---

## Extraction Workflow

### Phase 1: Conversation Analysis

**Step 1: Identify role boundaries**

Read through the conversation and mark phases:
```
[Problem Intake] User describes issue
    ↓
[Investigation] Agent probes systems, collects data
    ↓
[Scoping] Agent identifies technologies, gaps
    ↓
[Handoff] Agent scopes research queries
    ↓
[Validation] Agent validates research results
    ↓
[Guardian] Agent gatekeeps implementation
```

**Step 2: Extract work performed**

For each phase, document:
- What did the agent DO? (concrete actions)
- What did the agent PRODUCE? (artifacts)
- How did it CONNECT? (to user, to other agents)

**Example extraction:**
```
Phase: Problem Intake
- Actions: Read user message, asked clarifying questions
- Produced: Problem statement recap
- Connected: Directly with user

Phase: Investigation
- Actions: ssh to host, ran df/du, kubectl commands
- Produced: Disk usage breakdown, surface list
- Connected: System probes, metrics collection

Phase: Research Scoping
- Actions: Identified technologies, formulated queries
- Produced: 25+ scoped research queries with context
- Connected: Prepared handoff to researchers
```

### Phase 2: Responsibility Identification

**Extract primary responsibilities** from the work pattern:

Template:
```markdown
1. **[Responsibility Name]**
   - What: [Description]
   - How: [Approach taken]
   - Output: [Artifacts produced]
   - Example: [From conversation]
```

**From conversation, extract 4-6 core responsibilities**

Example:
```markdown
1. **Problem Intake**
   - What: Take raw problem and structure it
   - How: Read user message, probe systems, collect metrics
   - Output: Investigation report with surfaces identified
   - Example: "disk full" → "33GB containerd, 19GB cache, 31GB artifacts"

2. **Initial Investigation & Data Collection**
   - What: Probe systems to understand problem space
   - How: SSH, kubectl, file system analysis
   - Output: Quantified surfaces with paths and sizes
   - Example: Ran df, du, kubectl get pvc on k3s-02

3. **Technology Mapping**
   - What: Identify which technologies are involved
   - How: Analyze components, map dependencies
   - Output: Technology list with relationships
   - Example: Kubernetes → containerd → images; vLLM → HF cache

4. **Research Coordination**
   - What: Scope research queries for specialists
   - How: Break down gaps into focused questions with context
   - Output: Query package with technology, question, context, priority
   - Example: 25+ queries across 5 technologies

5. **Solution Validation**
   - What: Validate research findings against constraints
   - How: Check safety, problem fit, practicality
   - Output: Approved/rejected/conditional decisions
   - Example: Approved USB 3.0, rejected network share

6. **Guardian Through Phases**
   - What: Protect project from degradation
   - How: Stay engaged, validate at checkpoints, gatekeeper
   - Output: Go/no-go decisions with rationale
   - Example: Blocked unsafe containerd manual deletion
```

### Phase 3: Workflow Documentation

**Extract workflow patterns** - how did work flow through phases?

Template:
```markdown
## Workflow: [Phase Name]

### Inputs
- [What came in]

### Process
1. [Step 1]
2. [Step 2]
...

### Outputs
- [What went out]

### Integration Points
- Receives from: [Source]
- Feeds into: [Destination]
```

**Document 3-5 core workflows** from conversation

Example:
```markdown
## Workflow: Problem Intake to Investigation Report

### Inputs
- Raw problem statement from user
- System context (which hosts/services affected)

### Process
1. Read and clarify problem
2. Identify affected systems
3. Probe systems (SSH, kubectl, filesystem)
4. Collect metrics (disk usage, pod state, etc.)
5. Identify major surfaces
6. Map technologies involved
7. Identify knowledge gaps

### Outputs
- Investigation report with:
  - Problem statement
  - Affected systems
  - Observable symptoms
  - Key surfaces (quantified)
  - Technologies involved
  - Knowledge gaps
  - Next steps

### Integration Points
- Receives from: User (problem statement)
- Feeds into: Research Query Formulation
```

### Phase 4: Skill Identification

**Extract skills** that would have helped this role:

Look for:
- Repeated patterns that could be templated
- Complex workflows that need guidance
- Critical gates that need checklists

Template:
```markdown
## Skill: [skill-name]
- **Purpose:** [What it does]
- **When:** [When to use]
- **Value:** [Why it helps this role]
- **From conversation:** [Where this pattern appeared]
```

**Identify 3-5 high-value skills**

Example:
```markdown
## Skill: multi-agent-onsite-expert-intake
- **Purpose:** Structured problem intake and investigation
- **When:** New problem arrives, needs initial investigation
- **Value:** Ensures thorough initial investigation, no surfaces missed
- **From conversation:** Storage problem intake, probed k3s-02, identified all surfaces

## Skill: multi-agent-research-query-formulator
- **Purpose:** Transform knowledge gaps into scoped research queries
- **When:** Investigation complete, ready to dispatch research
- **Value:** Good queries = effective research; bad queries = wasted time
- **From conversation:** Created 25+ queries with context, enabled parallel research

## Skill: multi-agent-solution-validator
- **Purpose:** Validate research findings against real constraints
- **When:** Research complete, before implementation
- **Value:** Prevents unsafe/impractical solutions from reaching production
- **From conversation:** Rejected network share (Wi-Fi performance), approved USB 3.0
```

### Phase 5: Integration & Coordination

**Extract how this role works with others:**

Look for:
- Handoff points to other roles
- Validation loops
- Coordination checkpoints

Template:
```markdown
## Integration: [Role Name] ↔ [Other Role]

### Handoff Pattern
[Workflow diagram]

### Communication
- **To other role:** [What's sent]
- **From other role:** [What's received]

### Validation Loops
- [Checkpoint description]

### Example from conversation
[Concrete example]
```

Example:
```markdown
## Integration: Onsite Expert ↔ Researchers

### Handoff Pattern
```
Onsite Expert                    Researchers
    |                                |
    | Investigation Report           |
    | + Query Package                |
    |------------------------------->|
    |                                | Execute Research
    |                                |
    | Checkpoint Feedback            |
    |<-------------------------------|
    |                                |
    | Final Findings Report          |
    |<-------------------------------|
    | Validation                     |
```

### Communication
- **To Researchers:** 
  - Query package (technology, question, context, priority)
  - Problem context summary
  - Expected deliverables

- **From Researchers:**
  - Research entries (decision files, results)
  - Interim reports (checkpoint feedback)
  - Findings report (synthesis)

### Validation Loops
- Checkpoint 1: After high-priority research (safety validation)
- Checkpoint 2: After capacity research (approach validation)
- Final: Complete findings (implementation readiness)

### Example from conversation
Onsite Expert scoped 25+ queries → Researchers executed in parallel →
Checkpoint after containerd+K8s (validated safety) →
Checkpoint after HF+vLLM (redirected to USB 3.0) →
Final validation (approved recommendations)
```

---

## Output Structure: Role Definition Document

Create this file: `multi-agent-onsite-expert/multi-agent-onsite-expert.md`

```markdown
# Multi-Agent Role: Onsite Expert

## Role Overview
[High-level description extracted from conversation]

**In essence:** [One-sentence description]

**Key value:** [What this role provides]

---

## Primary Responsibilities

1. **[Responsibility 1]**
   [Details extracted]

2. **[Responsibility 2]**
   [Details extracted]

[... all core responsibilities]

---

## How This Role Works

### Problem Intake Phase
[Workflow extracted]

### Investigation Phase
[Workflow extracted]

### Research Coordination Phase
[Workflow extracted]

### Validation Phase
[Workflow extracted]

---

## Integration with Other Roles

### How This Role Works With [Other Role]

**Clear Separation of Concerns**

**Onsite Expert:**
- [Responsibilities extracted]

**[Other Role]:**
- [Contrast extracted]

**Effective Handoff Pattern**
[Workflow diagram extracted]

---

## Skills That Support This Role

[List of extracted skills with descriptions]

---

## When to Use This Role

**Use when:**
- [Extracted from conversation patterns]

**Don't use when:**
- [Extracted from anti-patterns]

---

## Example: [Problem from Conversation]

[Detailed walkthrough extracted]

---

## Success Criteria

A good Onsite Expert execution produces:
- [Criteria extracted from what worked]
```

---

## Output Structure: Example Document

Create this file: `multi-agent-onsite-expert/examples/[problem-name]-handoff.md`

```markdown
# Example: Onsite Expert Role in [Problem Name]

## Context
[From conversation]

## How the Role Was Demonstrated

### Phase 1: Problem Intake
[Extracted actions and artifacts]

### Phase 2: Investigation
[Extracted actions and artifacts]

### Phase 3: Research Scoping
[Extracted actions and artifacts]

### Phase 4: Validation
[Extracted actions and artifacts]

### Phase 5: Guardian Role
[Extracted actions and artifacts]

---

## Key Artifacts Produced

[List artifacts with examples from conversation]

---

## What Made This Effective

[Analysis of what worked well]

---

## Integration with [Other Role]

[How handoff worked in this case]
```

---

## Quality Checklist

Before finalizing role extraction:

✅ **Complete responsibility coverage:**
- All major work phases documented
- Nothing significant missing
- Clear boundaries with other roles

✅ **Concrete examples:**
- Every responsibility has example from conversation
- Artifacts shown, not just described
- Real commands/outputs included

✅ **Clear integration:**
- Handoff patterns documented
- Communication protocols clear
- Validation loops explained

✅ **Actionable skills:**
- Skills address real role needs
- Each skill has clear value proposition
- Skills referenced in role workflows

✅ **Reusability:**
- Role definition abstract enough to reuse
- Not too specific to one problem
- Patterns generalize to similar problems

---

## Common Pitfalls

### ❌ Don't: Extract Too Narrow
```
Bad: "Role that handles vLLM storage on k3s-02"
Good: "Role that intakes infrastructure problems, investigates, coordinates research"
```

### ❌ Don't: Lose the Examples
```
Bad: "Probes systems to collect metrics"
Good: "Probes systems (example: ran df -h, du -sh /var/lib/rancher, kubectl get pvc)"
```

### ❌ Don't: Skip Integration
```
Bad: Only document what Onsite Expert does
Good: Document how it hands off to Researchers and validates their work
```

### ❌ Don't: Forget the Guardian Aspect
```
Bad: "Scopes research then waits for results"
Good: "Scopes research, validates at checkpoints, gatekeeps before implementation"
```

---

## Validation Questions

Ask these before finalizing:

**1. Role Clarity**
- Can someone read this and understand what "Onsite Expert" means?
- Is it clear when to use this vs. other roles?

**2. Completeness**
- Are all phases of work documented?
- Are skills comprehensive for this role?

**3. Reusability**
- Could this role apply to other similar problems?
- Are examples helpful but not limiting?

**4. Integration**
- Is handoff to other roles clear?
- Are validation loops documented?

**5. Practicality**
- Could someone execute this role from the documentation?
- Are workflows concrete enough to follow?

---

## Next Steps After Extraction

1. **Create role folder structure:**
   ```
   multi-agent-onsite-expert/
   ├── multi-agent-onsite-expert.md (role definition)
   ├── examples/
   │   └── [problem]-handoff.md
   ├── enhancements/ (optional improvements)
   └── skill-drafts/ (extracted skills)
   ```

2. **Populate with extracted content**

3. **Create skill drafts** from skill identification phase

4. **Document integration** with other roles

5. **Add to multi-agent design README**

---

## How This Meta-Skill Fits in the Extraction Process

```
Conversation with emergent roles
        ↓
┌───────────────────────────────────────┐
│ Apply BOTH meta-skills in parallel:   │
├───────────────────────────────────────┤
│                                       │
│  extract-onsite-expert-role ← YOU ARE HERE
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (intake, query formulator, │
│           validator)                  │
│  - Integration patterns               │
│                                       │
│  extract-researchers-role             │
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (entry-create, consolidator,│
│           location-index)             │
│  - Artifact templates                 │
│                                       │
└───────────────────────────────────────┘
        ↓
Complete multi-agent design
with reusable role definitions
```

---

## Related Meta-Skills

### Required Companion Skill
- **`extract-researchers-role`** - Extract parallel research execution role
  - **Location:** `role-design-exports-skill-draft/extract-researchers-role.md`
  - **Relationship:** These skills work together - Onsite Expert coordinates research that Researchers execute
  - **Use together:** Apply both skills to the same conversation to extract the complete multi-agent pattern
  - **Integration:** The Onsite Expert role hands off to Researchers; extract both to document the handoff

### Optional Enhancement Skills
- `extract-role-integration-pattern` - Document cross-role coordination patterns
- `design-multi-agent-workflow` - Combine extracted roles into complete workflow

---

**Status:** Draft meta-skill for role extraction  
**Last Updated:** September 10, 2026  
**Purpose:** Extract reusable "Onsite Expert" role from successful conversation patterns  
**Companion:** `extract-researchers-role.md` (apply both to same conversation)
