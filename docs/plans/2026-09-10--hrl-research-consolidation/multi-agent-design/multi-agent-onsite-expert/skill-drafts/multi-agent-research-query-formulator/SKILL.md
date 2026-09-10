---
name: multi-agent-research-query-formulator
description: Transform investigation findings into scoped Context7 research queries with context and priority
status: draft
priority: high
---

# Multi-Agent Research Query Formulator

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Onsite Expert  
**Phase:** Research scoping and handoff preparation

---

## ⚠️ Draft Status

This skill is **draft work** documenting the query formulation pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Take an investigation report (from intake) and transform knowledge gaps into precise, actionable research queries that can be handed off to researcher specialists. The quality of these queries directly determines research success.

---

## When to Use

Use this skill when:
- ✅ Investigation is complete (surfaces identified, gaps known)
- ✅ Multiple technologies need research
- ✅ Ready to dispatch to researcher specialists
- ✅ Need to break down complex problems into focused queries

Do NOT use when:
- ❌ Investigation is incomplete
- ❌ Problem is simple enough to solve directly
- ❌ All necessary knowledge already exists

---

## Inputs

**Required:**
- `investigation_report` - Output from intake phase
- `knowledge_gaps` - List of unknowns identified

**Optional:**
- `priority_context` - Critical vs. nice-to-know research
- `time_constraints` - Urgency factors

---

## Workflow

### Phase 1: Review Investigation
1. Read the investigation report
2. Understand the problem context
3. Note the technologies involved
4. Review identified knowledge gaps

### Phase 2: Technology Grouping
1. **Group gaps by technology:**
   - Kubernetes questions together
   - Containerd questions together
   - vLLM questions together
   - etc.

2. **Identify cross-cutting concerns:**
   - Storage patterns across technologies
   - Automation/management patterns
   - Safety/risk considerations

### Phase 3: Query Formulation

For each technology/gap, create a query with:

**1. Precise Question**
- Not: "Research Kubernetes storage"
- But: "How does kubelet image GC work? imageGCHighThresholdPercent, imageGCLowThresholdPercent, disk pressure triggers"

**2. Context**
- Why does this matter?
- Current state/metrics
- What problem it addresses

**3. Priority**
- High: Blocks immediate fixes
- Medium: Needed for complete solution
- Low: Nice-to-have for optimization

**4. Expected Output**
- Decision file with selected approach
- Implementation-ready recommendations
- Safety considerations

### Phase 4: Research Package Assembly

Create handoff package containing:
- All scoped queries by technology
- Problem context summary
- Current state facts
- Priority ordering
- Expected deliverables

---

## Query Quality Standards

### Good Query Example ✅
```yaml
technology: containerd
query: |
  How does containerd garbage collection reclaim disk space? 
  Content store vs overlayfs snapshotter disk usage, 
  gc scheduler config, gc.ref labels, 
  pruning unused images and snapshots with ctr and crictl rmi --prune

context: |
  k3s-02 has 33GB in containerd (24GB overlayfs, 9.3GB blobs).
  Need safe cleanup patterns that won't break running pods.

priority: high
reason: Disk pressure imminent, need cleanup options

expected_output:
  - Safe vs unsafe cleanup commands
  - Expected disk reclamation
  - Automation frequency recommendations
  - Safety considerations
```

### Poor Query Example ❌
```yaml
technology: kubernetes
query: "Research Kubernetes storage"
context: "We need storage info"
priority: medium
```

**Why poor:**
- Too vague ("research storage" is not actionable)
- No specific questions
- Minimal context
- No guidance on what answers look like

---

## Output Structure

```markdown
# Research Query Package: [Problem Name]

## Problem Context Summary
[Brief recap of the issue and why research is needed]

## Current State Facts
- Fact 1: [metric or observation]
- Fact 2: [metric or observation]

## Research Queries

### Technology 1: [Name]
**Query 1:** [Precise question with specifics]
- **Context:** [Why this matters, current state]
- **Priority:** [High/Medium/Low]
- **Expected Output:** [What answers look like]

**Query 2:** [Next query for this technology]
...

### Technology 2: [Name]
...

## Research Coordination
- **Parallel execution:** [Which queries can run in parallel]
- **Dependencies:** [If any query depends on another]
- **Validation checkpoints:** [When to sync with Onsite Expert]

## Success Criteria
- [ ] All queries answered with authoritative sources
- [ ] Decision files include selected approach + alternatives
- [ ] Safety considerations documented
- [ ] Implementation-ready recommendations provided
```

---

## Example: Storage Optimization Queries

### Input (from intake)
```
Knowledge Gaps:
- How does containerd GC work?
- HF cache structure and management?
- K8s kubelet disk pressure handling?
- vLLM cache offload options?
- Ansible recurring cleanup patterns?
```

### Output (scoped queries)
```markdown
# Research Query Package: vLLM k3s-02 Storage Constraints

## Problem Context Summary
vLLM k3s-02 VM at 84% disk utilization (13GB free / 77GB total).
Need to understand storage patterns across the stack and identify
safe reclamation strategies.

## Current State Facts
- Containerd: 33GB (24GB overlayfs, 9.3GB blobs)
- HF model cache: 19GB (single model)
- Disk pressure: 84% (critical threshold approaching)
- PVC claim: 120Gi on 77GB disk (no enforcement)
- vLLM pod: 4 restarts in 8 days

---

### Technology 1: Containerd

**Query 1: Image Store Disk Reclamation**
```
How does containerd garbage collection reclaim disk space? 
Content store vs overlayfs snapshotter disk usage, 
gc scheduler config, gc.ref labels, 
pruning unused images and snapshots with ctr and crictl rmi --prune
```

- **Context:** 33GB consumed, need safe cleanup without breaking running pods
- **Priority:** High - disk pressure imminent
- **Expected Output:**
  - Explanation of two storage layers
  - Safe cleanup commands (crictl rmi --prune)
  - Unsafe operations to avoid
  - Expected reclamation amount
  - Automation recommendations

---

### Technology 2: Hugging Face Hub

**Query 1: Cache Disk Management**
```
Manage the local HF cache disk usage: hf cache scan, hf cache delete, 
HF_HUB_CACHE and HF_HOME layout, blobs snapshots refs symlink structure, 
.locks directory, scan_cache_dir and delete_revisions
```

- **Context:** 19GB model cache on NVMe, potential growth with more models
- **Priority:** Medium - offload option for capacity
- **Expected Output:**
  - Cache directory structure explained
  - Management CLI commands
  - Safe deletion patterns
  - Symlink behavior

**Query 2: HF Hub APIs and CLIs**
...

---

### Technology 3: Kubernetes

**Query 1: Kubelet Image Garbage Collection**
```
kubelet image garbage collection configuration: imageGCHighThresholdPercent, 
imageGCLowThresholdPercent, imageMinimumGCAge, imageMaximumGCAge, 
how the kubelet reclaims container image disk space on node disk pressure eviction
```

- **Context:** K3s-02 at 84%, need to understand automatic cleanup triggers
- **Priority:** High - approaching GC threshold
- **Expected Output:**
  - GC threshold configuration
  - Disk pressure triggers
  - Automatic vs manual cleanup
  - K3s-specific behavior

(... 8 more K8s queries)

---

### Technology 4: vLLM

**Query 1: Cache and Artifact Offload**
```
vLLM cache and artifact offload: drive implementation targets per technology
```

- **Context:** 19GB model cache, considering USB 3.0 offload
- **Priority:** Medium - capacity expansion option
- **Expected Output:**
  - Model loading behavior (disk → VRAM)
  - Cache offload options
  - Performance implications
  - USB 3.0 vs NVMe trade-offs

(... 3 more vLLM queries)

---

### Technology 5: Ansible

**Query 1: Disk Management Inventory**
```
Ansible facts for disk management: ansible_mounts, ansible_devices
```

- **Context:** Need automation for cleanup and monitoring
- **Priority:** Medium - after immediate fixes
- **Expected Output:**
  - Available Ansible facts for disk info
  - Playbook patterns for disk queries
  - Cross-platform considerations

(... 8 more Ansible queries)

---

## Research Coordination

**Parallel Execution:**
- All 5 technology streams can run in parallel
- No dependencies between technologies

**Validation Checkpoints:**
- After containerd + K8s research (safety validation)
- After HF + vLLM research (offload strategy validation)
- After Ansible research (automation approach validation)

**Expected Duration:**
- ~2 hours with 5 parallel researchers
- ~10+ hours if sequential

## Success Criteria
- [ ] 25+ queries answered with Context7 or vendor docs
- [ ] Each has decision.yaml with selected approach
- [ ] Safety considerations for destructive operations
- [ ] Implementation guides or playbook recommendations
```

---

## Quality Checklist

Before handoff to researchers, verify:

✅ **Specificity**
- Each query has concrete questions (not vague exploration)
- Technical terms and specific APIs/commands mentioned
- Current state metrics provided

✅ **Context**
- Why this research matters for the problem
- Current state that motivates the question
- How the answer will be used

✅ **Priority**
- High/Medium/Low clearly marked
- Reasoning for priority level
- Critical path vs. nice-to-have

✅ **Expected Output**
- What a "complete" answer looks like
- Required artifacts (decision files, guides)
- Safety considerations to address

✅ **Actionability**
- Researcher can execute immediately
- No ambiguity about scope
- Clear deliverables

---

## Integration Points

**Receives from:**
- `multi-agent-onsite-expert-intake` - Investigation report

**Feeds into:**
- Researchers - Scoped query package
- `multi-agent-coordination-checkpoint` - Validation loops

---

## Notes for Implementation

When ready to implement:

1. **Template system needed:**
   - Query template with required fields
   - Technology grouping logic
   - Priority scoring rubric

2. **Context extraction:**
   - Parse investigation report automatically
   - Extract metrics and current state
   - Map gaps to query templates

3. **Quality gates:**
   - Validate query specificity
   - Check required fields present
   - Ensure actionability

---

## Related Skills

- `multi-agent-onsite-expert-intake` (provides input)
- `multi-agent-coordination-checkpoint` (validation loops)
- `multi-agent-solution-validator` (consumes research results)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
