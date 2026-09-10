# Shared Skill Notes: Onsite Expert

This file contains notes for skills that are shared across multiple roles in the multi-agent design.

---

## Shared Skill: multi-agent-coordination-checkpoint

**Status:** 🚧 DRAFT - Not ready for execution  
**Shared between:** Onsite Expert, Researchers  
**Phase:** Coordination and validation loops

### ⚠️ Draft Status

This skill concept is **draft work** documenting the coordination checkpoint pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

### Purpose

Establish validation checkpoints during multi-agent research work. Allow Onsite Expert to validate intermediate research findings, provide feedback, adjust priorities, or redirect research efforts before all work is complete.

---

### When to Use

Use this skill when:
- ✅ Research is ongoing across multiple technologies
- ✅ Some research is complete and ready for interim validation
- ✅ Need to adjust priorities based on findings so far
- ✅ Want to course-correct before all research finishes

Do NOT use when:
- ❌ Research just started (too early)
- ❌ All research is complete (use final validation)
- ❌ No actionable findings yet

---

### Coordination Pattern

```
Researchers                     Onsite Expert
    |                                |
    | Execute parallel research      |
    |                                |
    | [First batch complete]         |
    |                                |
    | Interim Report                 |
    |------------------------------->|
    |                                | Review findings
    |                                | Validate against constraints
    |                                | Check problem fit
    |                                |
    | Feedback                       |
    |<-------------------------------|
    | - ✅ Approved findings         |
    | - ⚠️ Concerns to address       |
    | - 🔄 Redirect queries          |
    | - 📋 Priority updates          |
    |                                |
    | Continue research with feedback|
    |                                |
    | [Next batch complete]          |
    |                                |
    | Next Interim Report            |
    |------------------------------->|
```

---

### Example: Storage Optimization Checkpoints

#### Checkpoint 1: After Containerd + K8s Research

**Researchers Report:**
```
Containerd: crictl rmi --prune is safe
Kubernetes: kubelet GC triggers at 85% disk
```

**Onsite Expert Validation:**
```
✅ Safety: Validated - both approaches safe
✅ Problem fit: Addresses disk pressure
⚠️ Question: Will prune reclaim enough space?
🔄 Adjust: Run test prune on k3s-02, report actual reclamation
```

**Research continues** with adjusted focus on quantifying actual reclamation.

---

#### Checkpoint 2: After HF + vLLM Research

**Researchers Report:**
```
HF Hub: Cache management via hf CLI
vLLM: Model loading disk → VRAM, offload possible
```

**Onsite Expert Validation:**
```
✅ Techniques: Understood and documented
⚠️ Concern: Network share over Wi-Fi proposed
🔄 Redirect: Evaluate USB 3.0 direct attach instead
📋 Priority: Make offload research high priority
```

**Research redirects** to USB 3.0 approach instead of network share.

---

#### Checkpoint 3: After Ansible Research (Partial)

**Researchers Report:**
```
Ansible: Basic patterns researched
Status: 9/14 topics complete, 5 pending
```

**Onsite Expert Validation:**
```
⚠️ Scope: Ansible research incomplete
Decision: Proceed with available research
Rationale: Enough to create automation playbooks
📋 Later: Complete remaining 5 topics in follow-up
```

**Research closes** with acceptance of partial Ansible coverage.

---

### Validation Dimensions at Checkpoint

**Safety Check:**
- Are approaches safe so far?
- Any concerning recommendations?

**Problem Fit Check:**
- Does research address root cause?
- Gaps in coverage?

**Practicality Check:**
- Can we implement what's been researched?
- Dependencies available?

**Adjustment Opportunities:**
- Change research priority?
- Redirect specific queries?
- Add new research topics?

---

### Interim Report Format

```markdown
# Interim Research Report: [Checkpoint N]

## Research Complete (This Batch)
- Technology 1: X entries
- Technology 2: Y entries

## Key Findings
- [Finding 1]
- [Finding 2]

## Recommendations (So Far)
- [Recommendation 1]
- [Recommendation 2]

## Research In Progress
- Technology 3: Z entries pending
- Technology 4: W entries pending

## Seeking Validation On
- [Question 1 for Onsite Expert]
- [Question 2 for Onsite Expert]

## Possible Adjustments
- [Potential redirect 1]
- [Potential priority change 2]
```

---

### Feedback Format from Onsite Expert

```markdown
# Checkpoint Feedback: [Checkpoint N]

## Validated ✅
- [Approved finding 1]
- [Approved finding 2]

## Concerns ⚠️
- [Concern 1: description]
  - Impact: [what this affects]
  - Suggestion: [what to do]

## Redirects 🔄
- [Query X]: Change from [old approach] to [new approach]
- [Query Y]: Add [new aspect] to investigation

## Priority Updates 📋
- [Topic Z]: Increase from Medium → High
- [Topic W]: Can be deferred to later

## Continue As Planned
- [List of research that's on track]
```

---

### Benefits of Checkpoints

**Early Course Correction:**
- Catch unsafe approaches early
- Redirect before wasted effort
- Adjust priorities based on findings

**Validation Confidence:**
- Onsite Expert stays engaged
- User alignment throughout
- No surprises at final review

**Efficiency:**
- Don't wait until all research done
- Parallelize validation with research
- Focus effort on high-value areas

---

### Integration Points

**Used by:**
- Onsite Expert (validation role)
- Researchers (seeking feedback)

**Feeds into:**
- Research continuation
- Priority adjustments
- Final solution validation

---

### Notes for Implementation

When ready to implement:

1. **Checkpoint triggers:**
   - Time-based (every N hours)
   - Batch-based (every N entries complete)
   - Priority-based (high-priority items complete)
   - Request-based (explicit checkpoint call)

2. **Communication protocol:**
   - Interim report format/template
   - Feedback format/template
   - Status tracking

3. **Decision authority:**
   - What can Researchers adjust autonomously?
   - What requires Onsite Expert approval?
   - What requires user confirmation?

---

**Status:** Draft workflow concept  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
