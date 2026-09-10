---
name: extract-researchers-role
description: Analyze conversation work patterns to extract and formalize a "Researchers" multi-agent role definition
status: draft
priority: high
companion_skill: extract-onsite-expert-role
companion_path: ./extract-onsite-expert-role.md
---

# Extract Researchers Role from Conversation

**Status:** 🚧 DRAFT - Role extraction meta-skill  
**Purpose:** Create reusable multi-agent role definitions from observed conversation patterns  
**Output:** Formalized role documentation with responsibilities, workflows, and skills  
**Companion skill:** [`extract-onsite-expert-role`](./extract-onsite-expert-role.md) — apply both to the same conversation

---

## ⚠️ Draft Status

This is a **meta-skill** for role extraction and formalization. It documents how to identify when a "Researchers" pattern emerged in a conversation and how to codify it into a reusable role definition.

**Always pair with:** [`extract-onsite-expert-role.md`](./extract-onsite-expert-role.md). Together they recreate the full multi-agent design from conversation evidence.

---

## How These Skills Work Together

```
Conversation with emergent roles
        ↓
┌───────────────────────────────────────┐
│ Apply BOTH meta-skills in parallel:   │
├───────────────────────────────────────┤
│                                       │
│  extract-onsite-expert-role           │
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (intake, query formulator, │
│           validator)                  │
│  - Integration patterns               │
│                                       │
│  extract-researchers-role ← THIS      │
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

See companion: [`extract-onsite-expert-role.md`](./extract-onsite-expert-role.md).

---

## Purpose

When agent work naturally separates into research execution that happens after problem scoping, extract the "Researchers" role pattern and create formal documentation so parallel research workflows can be reused in future multi-agent systems.

---

## When to Use

Use this skill when:
- ✅ A conversation involved extensive research across multiple technologies
- ✅ Research was scoped/directed by another agent (coordinator)
- ✅ Research produced structured artifacts (Context7 entries, decision files)
- ✅ Research was organized and synthesized into reports
- ✅ The pattern worked well and should be formalized

Do NOT use when:
- ❌ Research was ad-hoc, not structured
- ❌ Single-technology research (no parallel execution benefit)
- ❌ Research wasn't artifact-driven
- ❌ Pattern didn't work well

---

## Role Recognition: What are "Researchers"?

### Primary Indicators

Look for these patterns in the conversation:

**1. Scoped Query Reception**
```
Receives: Precise research queries with context from coordinator
Example: "How does containerd GC work? Content store vs overlayfs, gc.ref labels..."
```

**2. Parallel Research Execution**
```
Multiple technologies researched simultaneously
Example: Containerd, HF Hub, Kubernetes, vLLM, Ansible all researched in parallel
```

**3. Structured Artifact Creation**
```
Consistent format across research entries
Example: README, query.md, result.md, decision.yaml, receipt.yaml for each entry
```

**4. Technology Organization**
```
Research organized by technology, not by problem
Example: generated/context7/containerd/, generated/context7/kubernetes/, etc.
```

**5. Synthesis & Reporting**
```
Individual research consolidated into comprehensive reports
Example: Findings report spanning 5 technologies with cross-cutting themes
```

**6. Connection to Original Problem**
```
Research explicitly tied back to what motivated it
Example: "This addresses the vLLM disk pressure problem identified in intake"
```

### Key Distinguishing Characteristics

**What makes it "Researchers" vs. other roles:**
- ✅ Executes research queries (doesn't scope them)
- ✅ Creates durable knowledge artifacts
- ✅ Organizes by technology (not by problem)
- ✅ Works in parallel across domains
- ✅ Synthesizes findings across technologies

**What it is NOT:**
- ❌ Problem scoper (receives scoped queries)
- ❌ Implementation executor (researches, doesn't implement)
- ❌ Solution validator (provides findings, coordinator validates)
- ❌ Ad-hoc researcher (structured, repeatable process)

---

## Extraction Workflow

### Phase 1: Conversation Analysis

**Step 1: Identify research scope boundary**

Mark where research started and ended:
```
[Before Research]
- Problem identified
- Investigation complete
- Queries scoped

[Research Execution] ← Extract this phase
- Context7 queries executed
- Artifacts created
- Organized by technology

[After Research]
- Findings synthesized
- Report delivered
- Validation by coordinator
```

**Step 2: Extract research work performed**

For each research entry, document:
- **Query received:** What question was asked?
- **Research performed:** What sources consulted?
- **Artifacts created:** What files/entries produced?
- **Organization:** Where was it filed?

**Example extraction:**
```
Entry: containerd/image-store-disk-reclamation

Query received:
  "How does containerd GC reclaim disk space? 
   Content store vs overlayfs snapshotter, 
   gc scheduler, crictl rmi --prune"
   Context: 33GB consumed, need safe cleanup
   Priority: High

Research performed:
  - Context7: containerd-docs library
  - Vendor docs: containerd/containerd/docs/gc.md
  - Duration: 1.5 hours

Artifacts created:
  - README.md (entry overview)
  - query.md (original query preserved)
  - result.md (findings, 2500 words)
  - decision.yaml (selected approach: crictl rmi --prune)
  - receipt.yaml (execution metadata)

Organization:
  - Filed: generated/context7/containerd/image-store-disk-reclamation/
  - Status: Complete
  - Confidence: High
```

### Phase 2: Responsibility Identification

**Extract primary responsibilities** from research patterns:

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
1. **Execute Scoped Research Queries**
   - What: Take precise queries and fetch authoritative documentation
   - How: Context7, vendor docs, committed mirrors
   - Output: Research findings with source citations
   - Example: Executed 25+ queries across 5 technologies using Context7

2. **Create Structured Knowledge Artifacts**
   - What: Transform research into durable, reusable knowledge entries
   - How: 5-file format (README, query, result, decision, receipt)
   - Output: HRL research entries under generated/context7/
   - Example: 20+ entries created, all following consistent structure

3. **Organize Research by Technology**
   - What: Group findings by technology domain, not by problem
   - How: Directory structure: generated/context7/<technology>/<topic>/
   - Output: Navigable research tree
   - Example: containerd/, kubernetes/, vllm/, ansible/ with subtopics

4. **Document Decisions with Rationale**
   - What: Capture selected approach, alternatives, trade-offs
   - How: decision.yaml with approaches_evaluated, selected_approach, rationale
   - Output: Reusable decision records
   - Example: Containerd cleanup decision: crictl rmi --prune vs manual vs gc scheduler

5. **Synthesize Cross-Technology Findings**
   - What: Consolidate research into comprehensive reports
   - How: Group by technology, identify themes, connect to problem
   - Output: Findings report with actionable recommendations
   - Example: Storage research consolidated across 5 technologies

6. **Maintain Connection to Original Problem**
   - What: Ensure research addresses what was asked
   - How: Reference original query, validate coverage, note gaps
   - Output: Gap analysis, coverage summary
   - Example: Knowledge Gaps Addressed table showing query → entry mapping
```

### Phase 3: Workflow Documentation

**Extract workflow patterns** for research execution:

Template:
```markdown
## Workflow: [Workflow Name]

### Inputs
- [What's received]

### Process
1. [Step 1]
2. [Step 2]
...

### Outputs
- [What's produced]

### Quality Gates
- [Validation checks]

### Integration Points
- Receives from: [Source]
- Feeds into: [Destination]
```

**Document 3-5 core workflows**

Example:
```markdown
## Workflow: Single Research Entry Creation

### Inputs
- Scoped query from Onsite Expert:
  - Technology
  - Precise question
  - Context (why needed)
  - Priority (High/Medium/Low)
  - Expected output

### Process
1. Validate query is actionable and scoped
2. Select research sources (Context7, vendor docs, mirrors)
3. Execute research query
4. Extract key findings:
   - Core concepts
   - Configuration options
   - Best practices
   - Safety considerations
5. Identify decision points (approaches, trade-offs)
6. Create directory: generated/context7/<technology>/<topic>/
7. Write artifacts:
   - README.md (overview)
   - query.md (preserved original query)
   - result.md (detailed findings)
   - decision.yaml (selected approach + alternatives)
   - receipt.yaml (execution metadata)
8. Validate completeness (all 5 files, sources cited)

### Outputs
- Complete research entry
- Decision record with rationale
- Source citations

### Quality Gates
- ✅ All 5 files present
- ✅ Query-to-decision alignment
- ✅ Sources cited
- ✅ Safety considerations explicit
- ✅ Implementation-ready guidance

### Integration Points
- Receives from: Onsite Expert (query package)
- Feeds into: Research consolidation, location index
```

### Phase 4: Skill Identification

**Extract skills** that would have helped this role:

Look for:
- Repeated artifact creation patterns
- Organization/navigation needs
- Synthesis processes
- Quality validation steps

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
## Skill: hrl-research-entry-create
- **Purpose:** Create structured Context7 research entries with consistent format
- **When:** Executing a scoped research query
- **Value:** Ensures completeness, reusability, proper sourcing
- **From conversation:** Created 20+ entries, all followed 5-file format

## Skill: hrl-research-consolidator
- **Purpose:** Synthesize multiple research entries into findings reports
- **When:** Research phase complete, ready to report back
- **Value:** Connects research to problem, identifies themes, provides actionable recommendations
- **From conversation:** Consolidated 20+ entries into comprehensive storage findings report

## Skill: hrl-research-location-index
- **Purpose:** Create navigable indexes organized by technology
- **When:** Multiple entries exist, need discoverability
- **Value:** Makes research findable, shows coverage, aids navigation
- **From conversation:** Created research-index.md spanning 5 technologies, 20+ entries

## Skill: multi-agent-coordination-checkpoint
- **Purpose:** Interim validation loops with Onsite Expert
- **When:** Research is progressing, some entries complete
- **Value:** Early course correction, validation confidence, efficiency
- **From conversation:** Checkpoints after containerd+K8s, HF+vLLM, Ansible phases
```

### Phase 5: Integration & Coordination

**Extract how this role works with others:**

Look for:
- Query reception pattern
- Interim reporting
- Final handoff
- Validation loops

Template:
```markdown
## Integration: [Role Name] ↔ [Other Role]

### Handoff Pattern
[Workflow diagram]

### Communication Protocol
- **Receives:** [What format]
- **Delivers:** [What format]
- **Checkpoints:** [When/how]

### Example from conversation
[Concrete example]
```

Example:
```markdown
## Integration: Researchers ↔ Onsite Expert

### Handoff Pattern
```
Onsite Expert                    Researchers
    |                                |
    | Query Package                  |
    | (25+ scoped queries)           |
    |------------------------------->|
    |                                | Parallel Research
    |                                | (5 technologies)
    |                                |
    | Checkpoint 1 Report            |
    |<-------------------------------| (After high-priority)
    | Validation / Feedback          |
    |------------------------------->|
    |                                |
    | Checkpoint 2 Report            |
    |<-------------------------------| (After capacity research)
    | Validation / Redirect          |
    |------------------------------->|
    |                                |
    | Final Findings Report          |
    | + Location Index               |
    |<-------------------------------|
    |                                |
    | Validation (Go/No-Go)          |
    |------------------------------->|
```

### Communication Protocol
- **Receives from Onsite Expert:**
  - Query package (technology, question, context, priority for each)
  - Problem context summary
  - Expected deliverables
  - Validation criteria

- **Delivers to Onsite Expert:**
  - Research entries (5-file format per entry)
  - Interim checkpoint reports (findings so far, seeking validation)
  - Location index (navigable research tree)
  - Findings report (synthesis with recommendations)

- **Checkpoints:**
  - After high-priority research (safety validation)
  - After major batches (redirect if needed)
  - Before final delivery (completeness check)

### Example from conversation
Query package: 25+ queries across 5 technologies →
Parallel execution (20+ entries created) →
Checkpoint 1: containerd+K8s complete (validated safe) →
Checkpoint 2: HF+vLLM complete (redirected to USB 3.0) →
Final delivery: findings report + location index →
Validation: approved with noted Ansible gaps
```

---

## Output Structure: Role Definition Document

Create this file: `researchers/multi-agent-researchers.md`

```markdown
# Multi-Agent Role: Researchers

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

### Research Execution Phase
[Workflow extracted]

### Artifact Creation Phase
[Workflow extracted]

### Organization Phase
[Workflow extracted]

### Synthesis & Reporting Phase
[Workflow extracted]

---

## Integration with Other Roles

### How This Role Works With Onsite Expert

**Clear Separation of Concerns**

**Onsite Expert:**
- [Responsibilities extracted]

**Researchers:**
- [Responsibilities extracted]

**Effective Handoff Pattern**
[Workflow diagram extracted]

---

## Research Artifact Structure

[Document the 5-file format extracted from conversation]

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

Good Researchers execution produces:
- [Criteria extracted from what worked]
```

---

## Output Structure: Example Document

Create this file: `researchers/examples/[problem-name]-research-execution.md`

```markdown
# Example: Researchers Role in [Problem Name]

## Context
[From conversation]

## Handoff from Onsite Expert

### Query Package Received
[Extracted queries]

### Research Scope
- Technologies: [list]
- Total queries: [count]
- Priority distribution: [breakdown]

---

## Research Execution

### Parallel Execution Across Technologies

#### Technology 1: [Name]
[Extracted research work]

**Queries executed:**
- Query 1: [details]
- Query 2: [details]

**Entries created:**
- `<topic-1>/` - [summary]
- `<topic-2>/` - [summary]

**Key findings:**
- [Finding 1]
- [Finding 2]

---

## Artifact Organization

### Directory Structure Created
[Extracted structure]

### Entry Quality
- All entries: 5-file format ✅
- Sources cited: [count] authoritative sources
- Decisions documented: [count] decision.yaml files

---

## Research Synthesis

### Findings Report Delivered
[Summary of what was delivered]

### Cross-Technology Themes
[Themes identified]

### Problem Connection
[How research addressed original problem]

---

## Coordination Checkpoints

### Checkpoint 1: [Description]
[What was reported, what feedback received]

### Checkpoint 2: [Description]
[What was reported, what feedback received]

---

## What Made This Effective

[Analysis of what worked well]

---

## Integration with Onsite Expert

[How handoff and validation worked]
```

---

## Quality Checklist

Before finalizing role extraction:

✅ **Complete responsibility coverage:**
- Research execution documented
- Artifact creation patterns clear
- Organization scheme explicit
- Synthesis process defined

✅ **Concrete examples:**
- Every responsibility has example from conversation
- Real entries shown (5-file structure)
- Actual research queries included
- Decision files referenced

✅ **Clear integration:**
- Query reception protocol documented
- Checkpoint patterns clear
- Final delivery format specified
- Validation loops explained

✅ **Actionable skills:**
- Skills address actual research workflow
- Artifact creation templated
- Synthesis process codified
- Navigation/organization automated

✅ **Reusability:**
- Role definition generalizes to other research needs
- Not locked to storage optimization
- Patterns apply to any multi-technology research

---

## Common Pitfalls

### ❌ Don't: Lose the Parallel Execution Pattern
```
Bad: "Researchers do research sequentially"
Good: "Researchers execute parallel research across technologies, with checkpoint validation"
```

### ❌ Don't: Skip the Artifact Structure
```
Bad: "Researchers document findings"
Good: "Researchers create 5-file entries: README, query, result, decision.yaml, receipt.yaml"
```

### ❌ Don't: Forget Technology Organization
```
Bad: "Researchers organize by problem"
Good: "Researchers organize by technology (containerd/, kubernetes/), enabling reuse"
```

### ❌ Don't: Ignore Synthesis
```
Bad: "Researchers create individual entries"
Good: "Researchers create entries AND synthesize into findings reports with themes"
```

### ❌ Don't: Skip Problem Connection
```
Bad: "Researchers produce generic knowledge"
Good: "Researchers maintain explicit connection to original problem, validate coverage"
```

---

## Validation Questions

Ask these before finalizing:

**1. Role Clarity**
- Can someone read this and understand what "Researchers" means?
- Is the parallel execution pattern clear?

**2. Completeness**
- Are all research workflows documented?
- Is artifact structure explicit?
- Is synthesis process defined?

**3. Reusability**
- Could this role apply to other research needs?
- Are patterns technology-agnostic?

**4. Integration**
- Is query reception clear?
- Are checkpoints documented?
- Is final handoff specified?

**5. Practicality**
- Could someone execute this role from the documentation?
- Are artifact templates provided?
- Is quality validation clear?

---

## Next Steps After Extraction

1. **Create role folder structure:**
   ```
   researchers/
   ├── multi-agent-researchers.md (role definition)
   ├── examples/
   │   └── [problem]-research-execution.md
   ├── enhancements/ (optional improvements)
   └── skill-drafts/ (extracted skills)
   ```

2. **Populate with extracted content**

3. **Create skill drafts:**
   - hrl-research-entry-create
   - hrl-research-consolidator
   - hrl-research-location-index
   - (shared) multi-agent-coordination-checkpoint

4. **Document artifact templates:**
   - 5-file research entry structure
   - decision.yaml schema
   - receipt.yaml schema
   - findings report template

5. **Document integration** with Onsite Expert

6. **Add to multi-agent design README**

---

## Artifact Template Extraction

**From conversation, extract these templates:**

### Template: Research Entry (5-file structure)
```
generated/context7/<technology>/<topic>/
├── README.md          ← [Extract structure]
├── query.md           ← [Extract structure]
├── result.md          ← [Extract structure]
├── decision.yaml      ← [Extract schema]
└── receipt.yaml       ← [Extract schema]
```

### Template: decision.yaml Schema
```yaml
---
technology: <string>
topic: <slug>
research_date: YYYY-MM-DD

query:
  question: |
    [multiline]
  context: |
    [multiline]
  priority: high|medium|low

sources:
  preferred_source: context7|vendor_docs|mirror|other
  context7_library: <string>
  vendor_urls:
    - <url>

findings:
  summary: |
    [multiline]
  approaches_evaluated:
    - name: <string>
      description: |
        [multiline]
      pros:
        - <string>
      cons:
        - <string>
      safety: safe|unsafe|conditional

decision:
  selected_approach: <string>
  rationale: |
    [multiline]
  confidence: high|medium|low
  safety_considerations:
    - <string>
  implementation_notes:
    - <string>

validation:
  needs_real_world_test: true|false
  validated_by: onsite_expert|none
  validation_notes: |
    [multiline]
---
```

### Template: Findings Report Structure
```markdown
# Research Findings Report: [Problem Name]

## Executive Summary
[Research scope, key achievements, critical recommendations]

## Original Problem Context
[Problem recap]

## Research Summary by Technology
[For each technology: entries, findings, decisions]

## Cross-Technology Themes
[Patterns across technologies]

## Actionable Recommendations
[By priority: High/Medium/Low]

## Implementation Roadmap
[Phased approach]

## Safety Summary
[Safe operations, unsafe operations, validation needs]

## Knowledge Gaps Addressed
[Gap → Entry mapping table]

## Connection to Original Problem
[How research addressed problem, expected impact]
```

---

## How This Meta-Skill Fits in the Extraction Process

```
Conversation with emergent roles
        ↓
┌───────────────────────────────────────┐
│ Apply BOTH meta-skills in parallel:   │
├───────────────────────────────────────┤
│                                       │
│  extract-onsite-expert-role           │
│  ↓                                    │
│  Creates:                             │
│  - Role definition                    │
│  - Responsibilities                   │
│  - Workflows                          │
│  - Skills (intake, query formulator, │
│           validator)                  │
│  - Integration patterns               │
│                                       │
│  extract-researchers-role ← YOU ARE HERE
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
- **`extract-onsite-expert-role`** - Extract problem intake and coordination role
  - **Location:** `role-design-exports-skill-draft/extract-onsite-expert-role.md`
  - **Relationship:** These skills work together - Onsite Expert scopes research that Researchers execute
  - **Use together:** Apply both skills to the same conversation to extract the complete multi-agent pattern
  - **Integration:** The Researchers role receives queries from Onsite Expert; extract both to document the handoff

### Optional Enhancement Skills
- `extract-role-integration-pattern` - Document cross-role coordination patterns
- `design-multi-agent-workflow` - Combine extracted roles into complete workflow

---

**Status:** Draft meta-skill for role extraction  
**Last Updated:** September 10, 2026  
**Purpose:** Extract reusable "Researchers" role from successful conversation patterns  
**Companion:** `extract-onsite-expert-role.md` (apply both to same conversation)
