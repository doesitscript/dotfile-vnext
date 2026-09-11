# Multi-Agent Design Documentation

**Purpose:** Define and document the multi-agent roles and workflows that enabled successful research consolidation for the storage optimization project.

**Status:** Active documentation  
**Last Updated:** September 10, 2026

**Current delivery:** [START-HERE.md](START-HERE.md) links the implemented
preparation-role skills, two copy/paste prompts and executable controller. A
real two-agent preparation run passed independent review/revision/release and
owned-process teardown. The storage plan has not been executed. See the
[fresh validation receipt](validation-2026-09-11.md) for proof and limitations.

**Active implementation profile:**
[Light Orchestration](orchestration/light-profile-rationale-2026-09-11.md) is
the default for this campaign: rapid grouped source work and grouped Evaluator
feedback. Full Orchestration remains explicit for named live-runtime, target,
or authority needs. An optional bounded Expert → Researcher sidecar resolves
one named technical fork without restarting the earlier preparation pipeline.

---

## Overview

This directory captures the **proven multi-agent patterns** used to successfully execute deep research and implementation for complex infrastructure problems. These roles emerged organically from the storage optimization work and are now documented for reuse.

**Proposed operating model:**
[`SUGGESTED-OVERALL-WORKFLOW.md`](SUGGESTED-OVERALL-WORKFLOW.md) describes a proposed end-to-end role, artifact, readiness, and escalation flow. It is design material only; it does not activate an orchestrator or replace the mature Implementer and Evaluator contracts.

**Skill recommendations:**
[`knowledge-capabilities/SKILL-RECOMMENDATIONS.md`](knowledge-capabilities/SKILL-RECOMMENDATIONS.md)
identifies the one proposed new project skill and the existing skills/workflows
to enhance, without creating new permanent roles.

**Current-phase two-agent draft:**
[`CURRENT-PHASE-PREPARATION-PLAN.md`](CURRENT-PHASE-PREPARATION-PLAN.md)
is the practical Coordinator + Researcher preparation packet. Its two drop-in
draft skills and prompts produce a bounded implementation plan and research
readiness brief for the established Implementer/Evaluator loop.

**Immediate next-step guide:**
[`IMMEDIATE-RECOMMENDATIONS-BEFORE-ACTIVATION.md`](IMMEDIATE-RECOMMENDATIONS-BEFORE-ACTIVATION.md)
is the single pre-plan recommendation file. Read it before activating an
Implementer/Evaluator campaign for this work.

---

## Defined Roles

### 1. Onsite Expert
**Location:** `multi-agent-onsite-expert/`

**Role:** First responder, problem analyst, research coordinator

**Responsibilities:**
- Takes in raw problems
- Investigates and collects key data
- Identifies technologies and knowledge gaps
- Scopes research queries
- Dispatches to researchers
- Validates solutions
- Guards against project degradation

**Example:** `examples/storage-optimization-handoff.md` - How the vLLM storage problem was investigated, scoped, and handed off to researchers

---

### 2. Researchers
**Location:** `researchers/`

**Role:** Specialized knowledge gatherers and organizers

**Responsibilities:**
- Execute deep-dive research on specific technologies
- Create standardized research artifacts
- Organize findings by technology and theme
- Build navigable indexes
- Generate findings reports
- Maintain connection to original problem
- Coordinate with Onsite Expert for validation

**Example:** `examples/storage-research-execution.md` - How 25+ research entries were created, organized, and consolidated

### 3. Knowledge Capabilities
**Location:** `knowledge-capabilities/`

**Role:** A composable, task-specific source of expert operating knowledge.

Knowledge capabilities are not new permanent agents. They make a role smarter
for one bounded part of its task, then leave the role's ownership intact. For
example, the Ansible capability routes an agent to the installed Ansible MCP,
project conventions, module discovery, and an implementation-readiness brief.

This keeps future specialist knowledge swappable: a storage, Kubernetes,
NetBox, security, or API capability can follow the same contract without
turning every agent into a universal expert.

### 4. Implementer Enhancements
**Location:** `implementer/enhancements/`

These are design additions for the mature implementer skill family. They teach
the implementer to consume a readiness brief, record any justified deviation,
and never treat research as evaluator sign-off.

### 5. Evaluator Enhancements
**Location:** `evaluator/enhancements/`

These are design additions for the mature evaluator skill family. They define
how to audit research use and implementation fidelity without making the
evaluator redo every research stream or perform implementer work.

---

## How These Roles Work Together

### Workflow Pattern

```
Problem Arrives
    ↓
Onsite Expert (Investigation & Scoping)
    ├─ Probes systems
    ├─ Identifies technologies
    ├─ Scopes research queries
    └─ Provides context & priority
    ↓
Researchers (Parallel Execution)
    ├─ Execute focused research
    ├─ Create structured artifacts
    ├─ Organize by technology
    └─ Report findings
    ↓
Validation Loop (Coordination)
    ├─ Onsite Expert validates
    ├─ Researchers clarify/adjust
    └─ Safety gates applied
    ↓
Consolidation (Research Synthesis)
    ├─ Indexes created
    ├─ Findings reports generated
    └─ Solution paths documented
    ↓
Ready for Planning/Implementation
```

### Key Success Factors

1. **Clear Separation of Concerns**
   - Onsite Expert: Holistic understanding, problem context
   - Researchers: Deep technical knowledge, organization

2. **Effective Handoff**
   - Scoped queries (not vague exploration)
   - Context provided (why it matters)
   - Priority indicated (sequencing work)
   - Output format specified (standardized artifacts)

3. **Continuous Coordination**
   - Researchers can ask clarifying questions
   - Onsite Expert remains available
   - Validation checkpoints throughout
   - Gaps flagged early

4. **Problem Connection**
   - Every research entry traces to original issue
   - Solutions map to implementation needs
   - Traceability maintained in artifacts

---

## Storage Optimization Case Study

### The Problem
**vLLM k3s-02 disk 84% full, 13GB free**

### Onsite Expert Investigation
- Probed k3s-02 system
- Found: 33GB containerd, 19GB models, 31GB build artifacts
- Identified: 10 technologies involved
- Scoped: 25+ precise research queries

### Researchers Execution
- 5 parallel research streams
- 2 hours total time (vs. 10+ sequential)
- 26 entries created across 10 technologies
- Organized into navigable structure
- Comprehensive indexes and findings reports

### Outcomes
- ✅ 31GB immediately reclaimed
- ✅ Clear strategy for containerd cleanup
- ✅ HF cache offload approach validated
- ✅ Implementation-ready playbook scopes
- ✅ Research organized for future use

### Why It Worked
- Clear scoping eliminated ambiguity
- Parallel execution maximized efficiency
- Standardized artifacts enabled consolidation
- Continuous validation caught issues early
- Problem connection maintained throughout

---

## Using These Roles

### When to Use Onsite Expert Role

✅ **Raw problem arrives** - Needs investigation and scoping  
✅ **Complex multi-technology issue** - Requires holistic understanding  
✅ **Research coordination needed** - Multiple specialists required  
✅ **Solution validation required** - Safety and quality gates  

### When to Use Researchers Role

✅ **Scoped queries available** - Clear questions to answer  
✅ **Deep technical dive needed** - Specific technology focus  
✅ **Multiple topics in parallel** - Independent work streams  
✅ **Knowledge organization required** - Structured outputs needed  

### When Both Work Together

✅ **Always** - These roles are complementary, not alternatives  
✅ **Iterative problems** - Initial investigation → research → validation loop  
✅ **Long-term knowledge building** - Research organized for reuse  

---

## Role Flexibility

**Important:** These role definitions are **not rigid boundaries**.

### Collaborative Nature
- Often the user and AI share the Onsite Expert role
- Interaction levels vary by context
- AI can take initiative based on problem understanding
- Roles can blend when appropriate

### Evolution Expected
- Names may change
- Responsibilities may broaden or narrow
- New roles may emerge
- Patterns will adapt to different problem types

### Context Matters
- Simple problems may not need full separation
- Emergency fixes may collapse roles
- Planning phases may introduce new roles
- Implementation may need different specialists

---

## Related Documentation

### In This Plan
- `../planner.md` - Future automation of consolidation workflow
- `../research-index.md` - Location map for all research entries
- `../findings-report.md` - Comprehensive findings summary
- `../README.md` - Plan overview

### In Dotfile-vnext
- `../../2026-09-10--storage-reclamation-and-optimization.md` - Implementation results
- `../../diagrams/cst-hom-lab-ctl-dia-vllmcache-*.md` - Architecture diagrams

### In HRL
- `/Users/joshc/develop/homelab-reference-library/generated/context7/` - All research entries
- Indexes: `technologies.md`, `sources.md`, `tasks.md`

---

## Future Development

### Planned Enhancements

1. **Planner Role Definition**
   - Consolidates research into implementation plans
   - Generates plan.md from organized findings
   - Bridges research to implementation

2. **Implementer Role Definition**
   - Executes plans as Ansible automation
   - Creates playbooks and roles
   - Validates against research constraints

3. **Evaluator enhancement adoption**
   - Add the knowledge-capability review rubric to the mature evaluator path
   - Preserve evaluator-owned feedback and sign-off artifacts
   - Require a targeted research escalation when an evidence gap remains

4. **Knowledge capability trials**
   - Trial the Ansible capability on the storage implementation path
   - Add sibling capabilities only after a task proves the need

4. **More Examples**
   - Additional case studies
   - Different problem types
   - Role adaptations

---

## Quick Reference

| Need | Role | See |
|------|------|-----|
| Investigate problem | Onsite Expert | `multi-agent-onsite-expert/` |
| Deep research | Researchers | `researchers/` |
| Make a role expert for one task | Knowledge capability | `knowledge-capabilities/` |
| Consume implementation research | Implementer enhancement | `implementer/enhancements/` |
| Audit research use and evidence | Evaluator enhancement | `evaluator/enhancements/` |
| See example handoff | Both | `multi-agent-onsite-expert/examples/` |
| See research execution | Researchers | `researchers/examples/` |

---

**Status:** Active multi-agent pattern documentation  
**Proven:** Storage optimization project (Sep 2026)  
**Next:** Add Planner, Implementer, Validator roles
