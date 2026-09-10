---
name: hrl-research-consolidator
description: Synthesize multiple research entries into comprehensive findings reports organized by technology
status: draft
priority: high
---

# HRL Research Consolidator

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Researchers  
**Phase:** Research synthesis and reporting

---

## ⚠️ Draft Status

This skill is **draft work** documenting the research consolidation pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Take multiple completed research entries and synthesize them into a comprehensive findings report. Connect research back to the original problem, highlight cross-technology patterns, and present actionable recommendations.

---

## When to Use

Use this skill when:
- ✅ Multiple research entries are complete
- ✅ Need to synthesize findings across technologies
- ✅ Ready to report back to Onsite Expert
- ✅ Time to connect research to problem

Do NOT use when:
- ❌ Research is still in progress
- ❌ Only one entry to report (no synthesis needed)
- ❌ Consolidation was done during research

---

## Inputs

**Required:**
- `research_entries` - List of completed HRL entries (paths)
- `original_problem` - Problem that motivated research
- `query_package` - Original query package from Onsite Expert

**Optional:**
- `focus_areas` - Specific aspects to highlight
- `audience` - Who will consume this report

---

## Consolidation Dimensions

### 1. By Technology
Group findings by technology:
- Kubernetes
- Containerd
- vLLM
- HuggingFace Hub
- Ansible
- etc.

### 2. By Theme
Cross-cutting concerns:
- Storage management patterns
- Garbage collection strategies
- Automation approaches
- Safety considerations
- Performance trade-offs

### 3. By Priority
- High: Immediate actionable recommendations
- Medium: Important for complete solution
- Low: Nice-to-have optimizations

### 4. By Implementation Phase
- Quick wins (hours to implement)
- Short-term (days to implement)
- Long-term (weeks to implement)

---

## Workflow

### Phase 1: Research Collection
1. Locate all completed research entries
2. Read decision files for each
3. Extract key findings
4. Note selected approaches

### Phase 2: Pattern Identification
1. **Common themes:**
   - What patterns repeat across technologies?
   - Common safety considerations?
   - Similar implementation approaches?

2. **Technology interactions:**
   - How do findings relate?
   - Dependencies between technologies?
   - Integration points?

3. **Knowledge gaps filled:**
   - Which original questions answered?
   - Any remaining gaps?
   - New questions raised?

### Phase 3: Recommendation Synthesis
1. **Consolidate decisions:**
   - What approaches were selected?
   - What alternatives considered?
   - What trade-offs accepted?

2. **Implementation path:**
   - Logical order for implementation
   - Dependencies between steps
   - Quick wins vs. long-term

3. **Safety summary:**
   - Critical safety notes across all research
   - Common risks identified
   - Mitigation strategies

### Phase 4: Problem Connection
1. **Return to original problem:**
   - Does research address root cause?
   - Are all dimensions covered?
   - Gaps remaining?

2. **Validate completeness:**
   - Every query answered?
   - Every knowledge gap filled?
   - Ready for validation?

### Phase 5: Report Generation
Create findings report with:
- Executive summary
- Technology-by-technology findings
- Cross-cutting themes
- Actionable recommendations
- Implementation roadmap
- Connection to original problem

---

## Output Structure

```markdown
# Research Findings Report: [Problem Name]

## Executive Summary
[High-level overview of research scope and key findings]

**Research Scope:**
- X technologies investigated
- Y research entries created
- Z total queries answered

**Key Achievements:**
- [Major finding 1]
- [Major finding 2]
- [Major finding 3]

**Critical Recommendations:**
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

---

## Original Problem Context
[Recap problem that motivated this research]

**Symptoms:**
- [Symptom 1]
- [Symptom 2]

**Investigation Surfaces:**
- [Surface 1: details]
- [Surface 2: details]

**Knowledge Gaps Identified:**
- [Gap 1]
- [Gap 2]

---

## Research Summary by Technology

### Technology 1: [Name]
**Research Entries:** X
- Entry 1: [Topic] - [path]
- Entry 2: [Topic] - [path]

**Key Findings:**
- [Finding 1]
- [Finding 2]

**Selected Approaches:**
- [Approach 1]: [Why selected]
- [Approach 2]: [Why selected]

**Safety Considerations:**
- [Safety note 1]
- [Safety note 2]

**Implementation Notes:**
- [Note 1]
- [Note 2]

---

### Technology 2: [Name]
[Same structure...]

---

## Cross-Technology Themes

### Theme 1: [e.g., Storage Management Patterns]
**Technologies involved:** Kubernetes, Containerd, HF Hub

**Common pattern:**
[Description of pattern seen across technologies]

**Recommendations:**
- [Recommendation 1]
- [Recommendation 2]

---

### Theme 2: [e.g., Automation Approaches]
[Same structure...]

---

## Actionable Recommendations

### High Priority (Immediate)
1. **[Recommendation 1]**
   - **What:** [Action to take]
   - **Why:** [Benefit/impact]
   - **How:** [Implementation approach]
   - **Risk:** [Low/Medium/High]
   - **Effort:** [Hours/Days]
   - **Research source:** [Entry that supports this]

2. **[Recommendation 2]**
   [Same structure...]

### Medium Priority (Short-term)
[Same structure...]

### Low Priority (Long-term)
[Same structure...]

---

## Implementation Roadmap

### Phase 1: Quick Wins (Hours to Days)
- [ ] [Action 1] - [Expected benefit]
- [ ] [Action 2] - [Expected benefit]

### Phase 2: Core Solutions (Days to Week)
- [ ] [Action 1] - [Expected benefit]
- [ ] [Action 2] - [Expected benefit]

### Phase 3: Optimizations (Week+)
- [ ] [Action 1] - [Expected benefit]
- [ ] [Action 2] - [Expected benefit]

---

## Safety Summary

**Critical Safety Notes:**
- ⚠️ [Safety consideration 1]
- ⚠️ [Safety consideration 2]

**Safe Operations:**
- ✅ [Safe operation 1]
- ✅ [Safe operation 2]

**Unsafe Operations (Avoid):**
- ❌ [Unsafe operation 1]
- ❌ [Unsafe operation 2]

**Validation Requirements:**
- [What needs testing before production]

---

## Knowledge Gaps Addressed

| Original Gap | Research Entry | Status |
|--------------|----------------|--------|
| Gap 1 | [Entry path] | ✅ Answered |
| Gap 2 | [Entry path] | ✅ Answered |
| Gap 3 | [Entry path] | ⚠️ Partial |

**Remaining Gaps:**
- [Gap X] - [Why not fully answered]

---

## Connection to Original Problem

### Problem: [Original problem statement]

### Research Addressed:
- ✅ [Aspect 1 addressed]
- ✅ [Aspect 2 addressed]
- ⚠️ [Aspect 3 partially addressed]

### Expected Impact:
- [Metric 1]: Current state → Expected state
- [Metric 2]: Current state → Expected state

### Next Steps:
1. Onsite Expert validation
2. Implementation planning
3. Execution

---

## Research Coverage Analysis

**Complete:** X entries
**Partial:** Y entries
**Blocked:** Z entries

**Quality Metrics:**
- High confidence: X entries
- Medium confidence: Y entries
- Low confidence: Z entries

**Source Quality:**
- Context7: X entries
- Vendor docs: Y entries
- Other: Z entries

---

## Appendix: Research Location Index
[Link to detailed index, or inline if short]

**All research entries:**
- `generated/context7/<technology>/<topic>/`
- [Full list in research-index.md]
```

---

## Example: Storage Optimization Consolidation

### Executive Summary
```markdown
# Research Findings Report: vLLM k3s-02 Storage Constraints

## Executive Summary

Research conducted across 5 technologies (Containerd, HF Hub, Kubernetes, 
vLLM, Ansible) generated 20+ Context7 entries in the HRL. This research 
was triggered by storage constraints on the vLLM k3s-02 VM and expanded 
into a broader investigation of homelab resource management.

**Research Scope:**
- 5 technologies investigated
- 20+ research entries created
- 25+ queries answered

**Key Achievements:**
- ✅ Identified 31GB reclaimable build artifacts (Hyper-V host)
- ✅ Defined safe containerd cleanup patterns (crictl rmi --prune)
- ✅ Validated USB 3.0 model cache offload approach
- ✅ Created automation patterns for recurring cleanup
- ✅ Documented K8s storage architecture and PVC overcommit behavior

**Critical Recommendations:**
1. Reclaim 31GB from HVH-02 D: drive (build artifacts)
2. Weekly containerd image pruning automation
3. USB 3.0 VHDX for model cache capacity expansion
4. Update Ansible roles with shared cache logic

---

## Original Problem Context

**Problem:** vLLM has 13GB free space (84% disk utilization)

**Symptoms:**
- Disk usage: 64G / 77G (84%)
- vLLM pod: 4 restarts in 8 days
- PVC claims 120Gi on 77GB disk

**Investigation Surfaces:**
- Containerd: 33GB (24GB overlayfs, 9.3GB blobs)
- HF model cache: 19GB
- Build artifacts on host: 31GB
- PVC behavior: No size enforcement

**Knowledge Gaps Identified:**
- How does containerd GC work?
- HF cache management commands?
- K8s kubelet disk pressure?
- vLLM cache offload options?
- Ansible automation patterns?

---

## Research Summary by Technology

### Containerd (1 entry)
**Research Entries:** 1
- `image-store-disk-reclamation/` - Storage layers and GC

**Key Findings:**
- Two-layer storage: content store (blobs) + overlayfs (layers)
- Safe cleanup: `crictl rmi --prune`
- Unsafe: Manual content store deletion

**Selected Approaches:**
- Weekly `crictl rmi --prune` automation
- Monitor disk space trend

**Safety Considerations:**
- Only remove unreferenced images
- Safe during pod operations
- Idempotent operation

**Implementation Notes:**
- Ansible cron task
- Sunday 3am schedule
- Add disk monitoring

---

### Hugging Face Hub (3 entries)
[Similar detailed breakdown...]

### Kubernetes (9 entries)
[Similar detailed breakdown...]

### vLLM (4 entries)
[Similar detailed breakdown...]

### Ansible (9 entries)
[Similar detailed breakdown...]

---

## Cross-Technology Themes

### Theme 1: Storage Management Patterns
**Technologies involved:** Kubernetes, Containerd, HF Hub

**Common pattern:**
All three technologies implement layered storage with:
- Read-only base layers (images, models)
- Mutable overlay layers (containers, cache)
- Garbage collection for unused content
- Conservative cleanup (safety over space)

**Recommendations:**
- Apply similar cleanup patterns across stack
- Weekly automation at each layer
- Monitor combined disk usage

---

### Theme 2: Automation Safety
**Technologies involved:** All

**Common pattern:**
Every automation requires:
- Idempotent operations
- Non-destructive by default
- Monitoring after changes
- Rollback capability

**Recommendations:**
- Start with dry-run modes
- Add logging/alerting
- Test cleanup on non-prod first

---

## Actionable Recommendations

### High Priority (Immediate)

1. **Reclaim Build Artifacts from HVH-02**
   - **What:** Move/delete 31GB unused VM provisioning artifacts
   - **Why:** Immediate D: drive space relief
   - **How:** PowerShell script to move tar.gz to shared cache, delete VHD
   - **Risk:** Low (build artifacts, not in use)
   - **Effort:** 1 hour
   - **Research source:** Investigation + Ansible role analysis

2. **Weekly Containerd Cleanup**
   - **What:** Automate `crictl rmi --prune`
   - **Why:** Prevent 33GB containerd from growing
   - **How:** Ansible cron playbook, Sunday 3am
   - **Risk:** Low (safe, idempotent)
   - **Effort:** 2 hours
   - **Research source:** `containerd/image-store-disk-reclamation/`

[... more recommendations ...]

---

## Implementation Roadmap

### Phase 1: Immediate Reclamation (Hours)
- [x] Identify build artifacts on HVH-02
- [ ] Execute cleanup script
- [ ] Verify D: drive space reclaimed
- [ ] Update shared cache structure

### Phase 2: Automation (Days)
- [ ] Create containerd cleanup playbook
- [ ] Schedule via Ansible cron
- [ ] Add disk monitoring
- [ ] Test first run

### Phase 3: Capacity Expansion (Week)
- [ ] Create USB 3.0 VHDX
- [ ] Attach to k3s-02 VM
- [ ] Configure model cache mount
- [ ] Migrate models to new location

---

## Safety Summary

**Critical Safety Notes:**
- ⚠️ Never manually delete from containerd content store
- ⚠️ HF cache symlink structure is fragile
- ⚠️ Model loading slower on USB 3.0 (9min vs 5s)

**Safe Operations:**
- ✅ `crictl rmi --prune` (removes only unused)
- ✅ `hf cache delete` (official tool)
- ✅ USB 3.0 attach (non-destructive capacity add)

**Unsafe Operations (Avoid):**
- ❌ `rm -rf /var/lib/containerd/` (breaks pods)
- ❌ Manual HF cache blob deletion (orphans models)
- ❌ Network share over Wi-Fi (performance unacceptable)

**Validation Requirements:**
- Test containerd prune on non-prod first
- Verify USB 3.0 mount before migration
- Monitor first cleanup runs

---

## Knowledge Gaps Addressed

| Original Gap | Research Entry | Status |
|--------------|----------------|--------|
| Containerd GC | `containerd/image-store-disk-reclamation/` | ✅ Complete |
| HF cache mgmt | `huggingface-hub/cache-disk-management/` | ✅ Complete |
| K8s disk pressure | `kubernetes/kubelet-image-garbage-collection/` | ✅ Complete |
| vLLM offload | `vllm/cache-and-artifact-offload/` | ✅ Complete |
| Ansible automation | `ansible/recurring-runs-and-artifact-retention/` | ⚠️ Partial |

**Remaining Gaps:**
- Ansible execution scaling (5 topics pending)
- Ansible quality gates (not yet researched)

---

## Connection to Original Problem

### Problem: vLLM has 13GB free (84% disk utilization)

### Research Addressed:
- ✅ Identified all major storage consumers
- ✅ Defined safe cleanup patterns for each
- ✅ Validated capacity expansion approach (USB 3.0)
- ✅ Created automation path for ongoing management
- ⚠️ Some Ansible research still pending

### Expected Impact:
- D: drive free space: 69GB → 100GB (reclaim 31GB)
- k3s-02 VM capacity: 77GB → 120GB (USB 3.0 expansion)
- Disk pressure: 84% → <70% (after cleanup + expansion)
- Model cache: NVMe-only → NVMe + USB 3.0 (capacity for growth)

### Next Steps:
1. Onsite Expert validation of recommendations
2. Execute Phase 1 (artifact reclamation)
3. Implement Phase 2 (automation)
4. Plan Phase 3 (capacity expansion)

---

## Research Coverage Analysis

**Complete:** 15 entries (Containerd, HF Hub, K8s, vLLM)
**Partial:** 5 entries (Ansible execution scaling topics)
**Blocked:** 0 entries

**Quality Metrics:**
- High confidence: 12 entries
- Medium confidence: 3 entries
- Low confidence: 0 entries

**Source Quality:**
- Context7: 15 entries (vendor docs via Context7)
- Vendor docs: 3 entries (direct)
- Other: 2 entries (implementation experience)

---

## Appendix: Research Location Index
See: `research-index.md` for detailed navigation

**All research entries:**
- `generated/context7/containerd/` (1 entry)
- `generated/context7/huggingface-hub/` (3 entries)
- `generated/context7/kubernetes/` (9 entries)
- `generated/context7/vllm/` (4 entries)
- `generated/context7/ansible/` (9 entries)
```

---

## Quality Checklist

Before submitting consolidated report:

✅ **Comprehensive coverage:**
- All research entries included
- Technology groups complete
- Cross-technology themes identified

✅ **Problem connection:**
- Original problem clearly stated
- Research addresses root cause
- Expected impact quantified

✅ **Actionable recommendations:**
- Prioritized (High/Medium/Low)
- Implementation details provided
- Risks and effort estimated

✅ **Safety emphasis:**
- Safe operations highlighted
- Unsafe operations explicitly called out
- Validation requirements clear

✅ **Implementation path:**
- Logical phasing (quick wins → long-term)
- Dependencies identified
- Roadmap provided

---

## Integration Points

**Receives from:**
- `hrl-research-entry-create` - Individual research entries
- `hrl-research-location-index` - Navigation structure

**Feeds into:**
- Onsite Expert validation
- Implementation planning
- Plan folder documentation

---

## Notes for Implementation

When ready to implement:

1. **Automation potential:**
   - Auto-collect completed research entries
   - Template-based report generation
   - Cross-reference validation

2. **Synthesis intelligence:**
   - Pattern detection across entries
   - Theme extraction
   - Priority scoring

3. **Integration:**
   - Plan folder creation
   - Index generation
   - Handoff to Onsite Expert

---

## Related Skills

- `hrl-research-entry-create` (produces input)
- `hrl-research-location-index` (navigation)
- `multi-agent-solution-validator` (consumes output)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
