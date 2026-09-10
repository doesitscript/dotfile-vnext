---
name: multi-agent-solution-validator
description: Validate research findings against real-world constraints and safety requirements before implementation
status: draft
priority: high
---

# Multi-Agent Solution Validator

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Onsite Expert  
**Phase:** Solution validation and gatekeeping

---

## ⚠️ Draft Status

This skill is **draft work** documenting the validation pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Act as the quality gate between research findings and implementation. Validate that proposed solutions are safe, practical, and actually solve the problem. Prevent unsafe or impractical approaches from reaching production.

---

## When to Use

Use this skill when:
- ✅ Researchers have completed their work
- ✅ Solutions/recommendations are proposed
- ✅ Ready to move toward implementation
- ✅ Need to validate against real constraints

Do NOT use when:
- ❌ Research is still in progress
- ❌ No concrete recommendations yet
- ❌ Validation was already done during research

---

## Inputs

**Required:**
- `research_findings` - Completed research entries with decisions
- `original_problem` - The problem this research should solve
- `current_system_state` - Live facts about the system

**Optional:**
- `risk_tolerance` - How conservative to be
- `implementation_timeline` - Urgency factors

---

## Validation Dimensions

### 1. Safety Validation
**Question:** Is this approach safe for production?

**Check:**
- Would this break running workloads?
- Could this cause data loss?
- Is this reversible if it goes wrong?
- Are there blast radius concerns?

**Example:**
```
❌ REJECTED: "Delete all overlayfs snapshots manually"
Reason: Would break running pods, not reversible
Safe alternative: "Use crictl rmi --prune" (only removes unused)
```

### 2. Problem Fit Validation
**Question:** Does this actually solve the original problem?

**Check:**
- Does it address the root cause?
- Or just symptoms?
- Are there gaps in coverage?
- What doesn't it solve?

**Example:**
```
✅ ACCEPTED: "USB 3.0 VHDX for model cache offload"
Reason: Solves capacity constraint, startup penalty acceptable
Validates against: User confirmed 9min startup OK
```

### 3. Practicality Validation
**Question:** Can we actually implement this?

**Check:**
- Do we have the required access/permissions?
- Are dependencies available?
- Is complexity manageable?
- Timeline realistic?

**Example:**
```
❌ REJECTED: "Network share over Wi-Fi for models"
Reason: Performance unacceptable, reliability concerns
Better alternative: Local USB 3.0 (acceptable trade-offs)
```

### 4. Constraint Validation
**Question:** Does this fit within known constraints?

**Check:**
- Disk space available?
- Network bandwidth adequate?
- Hardware capabilities sufficient?
- Budget/licensing OK?

**Example:**
```
⚠️ CONDITIONAL: "Expand k3s-02 VHDX to 120GB"
Constraint: D: drive only has 69GB free
Needs: Either free space on D: OR move to USB 3.0
Status: Blocked until constraint resolved
```

### 5. Side Effects Validation
**Question:** What else might this impact?

**Check:**
- Downstream effects?
- Performance implications?
- Maintenance burden?
- Future flexibility?

**Example:**
```
✅ ACCEPTED WITH NOTES: "Weekly containerd prune"
Side effect: Needs monitoring/alerting
Side effect: Must coordinate with maintenance windows
Mitigation: Add to Ansible scheduled tasks
```

---

## Validation Process

### Step 1: Load Context
1. Review original problem statement
2. Understand current system state
3. Note constraints and requirements
4. Recall user preferences/decisions

### Step 2: Review Research
1. Read research findings
2. Understand recommended approach
3. Note alternatives considered
4. Check confidence levels

### Step 3: Apply Validation Checks

For each recommendation, evaluate:
```
Safety:      [ ] Safe / [ ] Unsafe / [ ] Needs review
Problem Fit: [ ] Solves / [ ] Partial / [ ] Misses
Practicality:[ ] Feasible / [ ] Difficult / [ ] Blocked
Constraints: [ ] Within / [ ] Exceeds / [ ] Conditional
Side Effects:[ ] Acceptable / [ ] Concerning / [ ] Blocker
```

### Step 4: Validate Against Real State
1. Check current system metrics
2. Verify assumptions still hold
3. Confirm resources available
4. Test small/safe if possible

### Step 5: Decision
- ✅ **Approved** - Ready for implementation
- ⚠️ **Conditional** - Approved if conditions met
- 🔄 **Needs Clarification** - Back to researchers
- ❌ **Rejected** - Unsafe or impractical

---

## Output Structure

```markdown
# Solution Validation: [Problem Name]

## Original Problem
[Brief recap]

## Validation Summary
- Recommendations reviewed: X
- Approved: Y
- Conditional: Z
- Rejected: N

---

## Validated Solutions

### Solution 1: [Name]
**Recommendation:** [What researchers proposed]

**Validation:**
- ✅ Safety: Safe, idempotent operation
- ✅ Problem Fit: Directly addresses disk pressure
- ✅ Practicality: Easy to implement
- ✅ Constraints: Within current resources
- ⚠️ Side Effects: Needs weekly scheduling

**Decision:** APPROVED
- Ready for implementation
- Add to Ansible cron tasks
- Monitor first few runs

---

### Solution 2: [Name]
**Recommendation:** [What researchers proposed]

**Validation:**
- ❌ Safety: Could break running pods
- ✅ Problem Fit: Would reclaim space
- ⚠️ Practicality: Requires careful coordination
- ✅ Constraints: Within resources
- ❌ Side Effects: High blast radius

**Decision:** REJECTED
- Use alternative: [safer approach]
- Reason: Risk outweighs benefit

---

## Implementation Guidance

**Approved solutions in priority order:**
1. [Solution A] - Immediate implementation
2. [Solution B] - After A validates
3. [Solution C] - Long-term optimization

**Rejected solutions + safe alternatives:**
- [Rejected X] → Use [Alternative Y] instead

**Conditional solutions + requirements:**
- [Solution Z] - Approved if [condition met]

## Risk Summary
- High-risk changes: [list]
- Safety validations needed: [tests]
- Rollback plan: [how to undo]
```

---

## Example: Storage Optimization Validation

### Solution 1: Containerd Cleanup
```markdown
**Recommendation:** Weekly `crictl rmi --prune` automation

**Validation:**
- ✅ Safety: Only removes unreferenced images, safe operation
- ✅ Problem Fit: Addresses 33GB containerd bloat
- ✅ Practicality: Simple Ansible cron task
- ✅ Constraints: No resources needed
- ⚠️ Side Effects: May need to re-pull images if pruned incorrectly
  (but prune is conservative)

**Real State Check:**
- Ran test prune: recovered 2.3MB (most images in use)
- Confirms approach is safe
- Expected 5-10GB from stale layers over time

**Decision:** APPROVED
- Create `playbooks/cleanup_containerd_images.yaml`
- Schedule weekly via cron
- Add monitoring for disk space trend
```

### Solution 2: Network Share for Models (Wi-Fi)
```markdown
**Recommendation:** Move model cache to network share

**Validation:**
- ✅ Safety: Non-destructive, reversible
- ⚠️ Problem Fit: Solves capacity, but creates new problems
- ❌ Practicality: Wi-Fi performance unacceptable
- ✅ Constraints: Share exists, accessible
- ❌ Side Effects: 
  - Model load: minutes → hours
  - Network dependency for inference startup
  - Wi-Fi reliability concerns

**Real State Check:**
- Current load time: 5 seconds on NVMe
- Network path would be: VM → Wi-Fi → Windows host → USB drive
- Estimated: 30+ minutes per model load
- Unacceptable for pod restarts

**Decision:** REJECTED
- Alternative: USB 3.0 VHDX directly attached
- Rationale: Eliminates network hop, acceptable 9min load
- Validated with user: startup penalty OK
```

### Solution 3: USB 3.0 Model Cache Offload
```markdown
**Recommendation:** Second VHDX on USB 3.0 for model cache

**Validation:**
- ✅ Safety: Non-destructive, adds capacity
- ✅ Problem Fit: Solves capacity constraint
- ✅ Practicality: Standard Hyper-V operation
- ⚠️ Constraints: USB 3.0 slower than NVMe
- ✅ Side Effects: Startup slower, but acceptable

**Real State Check:**
- Measured USB 3.0 write: 36 MB/s
- Model size: 19GB
- Estimated load: ~9 minutes (vs 5 seconds NVMe)
- User validated: 9min acceptable (one-time at pod start)
- Inference from VRAM (disk speed irrelevant after load)

**Performance Trade-off:**
- Lose: Fast startup (5s → 9min)
- Gain: Massive capacity (875GB available)
- Gain: Keep OS/containerd on fast NVMe

**Decision:** APPROVED (Conditional)
- Condition: Create second VHDX on HVH-02 USB
- Condition: Mount as /mnt/model-cache in guest
- Condition: Update vLLM PVC mount
- Ready for: Implementation planning
```

---

## Safety Checklist

Before approving ANY solution:

✅ **Read-only validation passed:**
- No destructive operations without validation
- Tested in safe/isolated context when possible
- Reversibility confirmed

✅ **Blast radius assessed:**
- What breaks if this fails?
- How many systems affected?
- Can we roll back?

✅ **Dependencies verified:**
- Required tools/access available?
- Upstream services healthy?
- No hidden dependencies?

✅ **User expectations aligned:**
- User understands trade-offs?
- Performance impacts acceptable?
- Maintenance burden OK?

✅ **Problem actually solved:**
- Root cause addressed (not just symptoms)?
- Metrics will improve?
- Edge cases considered?

---

## Validation Anti-Patterns

### ❌ Don't: Approve Without Real State Check
```
Bad: "Researchers say it's safe, approve it"
Good: "Check current state, validate assumptions still hold"
```

### ❌ Don't: Accept First Solution
```
Bad: "This technically works, ship it"
Good: "This works, but is there a better/safer alternative?"
```

### ❌ Don't: Ignore Side Effects
```
Bad: "Solves the immediate problem, approved"
Good: "Solves problem, but creates maintenance burden - worth it?"
```

### ❌ Don't: Over-Optimize Prematurely
```
Bad: "Might need this someday, add complexity now"
Good: "Solve current problem simply, optimize when needed"
```

---

## Integration Points

**Receives from:**
- Researchers - Findings and recommendations
- `multi-agent-coordination-checkpoint` - Interim validations

**Feeds into:**
- Implementation planning - Approved solutions
- Researchers (if needs clarification)

---

## Notes for Implementation

When ready to implement:

1. **Validation framework:**
   - Checklist templates by solution type
   - Risk scoring rubric
   - Decision documentation format

2. **Real state integration:**
   - Live system probes
   - Metric validation
   - Constraint verification

3. **User alignment:**
   - Trade-off presentation
   - Approval workflows
   - Expectation management

---

## Related Skills

- `multi-agent-onsite-expert-intake` (provides problem context)
- `multi-agent-research-query-formulator` (scoped the research)
- `multi-agent-coordination-checkpoint` (validation loops)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
