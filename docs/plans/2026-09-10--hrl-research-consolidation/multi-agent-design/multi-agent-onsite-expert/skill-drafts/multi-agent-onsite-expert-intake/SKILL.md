---
name: multi-agent-onsite-expert-intake
description: Structured problem intake and initial investigation for multi-agent research coordination
status: draft
priority: high
---

# Multi-Agent Onsite Expert Intake

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Onsite Expert  
**Phase:** Problem intake and initial investigation

---

## ⚠️ Draft Status

This skill is **draft work** documenting the intake pattern used in the storage optimization project. It is not yet implemented as an executable skill and should be treated as a workflow template.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Transform a raw problem statement into a structured investigation report that can be used to scope research queries. This is the critical first phase where vague issues become actionable multi-agent work.

---

## When to Use

Use this skill when:
- ✅ A new problem or issue is reported
- ✅ The problem involves infrastructure, storage, or system constraints
- ✅ Multiple technologies may be involved (requires investigation)
- ✅ Research will be needed to solve the problem
- ✅ You're acting as the Onsite Expert / first responder

Do NOT use when:
- ❌ Problem is already well-scoped and understood
- ❌ Solution is straightforward (no research needed)
- ❌ This is a follow-up on existing investigation

---

## Inputs

**Required:**
- `problem_statement` - Raw problem description from user
- `system_context` - Which systems/hosts are affected (optional but helpful)

**Optional:**
- `symptoms` - Observable symptoms (disk full, pod crashing, etc.)
- `urgency` - How critical is this issue

---

## Workflow

### Phase 1: Problem Understanding
1. Read the problem statement
2. Identify the affected systems/components
3. Note observable symptoms
4. Determine urgency/priority

### Phase 2: Initial Investigation
1. **Probe affected systems:**
   - Disk usage: `df -h`, `du -sh`
   - Container/K8s state: `kubectl get pods/pvc/nodes`
   - Process state: `ps aux`, resource usage
   - Logs: Recent errors or warnings

2. **Collect key data surfaces:**
   - Disk usage breakdown by directory
   - Running vs failed workloads
   - Cache/artifact locations
   - Configuration states

3. **Identify involved technologies:**
   - What systems are in the stack? (K8s, containerd, vLLM, etc.)
   - What components interact?
   - Where are the boundaries?

### Phase 3: Surface Documentation
1. **List key surfaces identified:**
   - Each major consumer (e.g., "33GB containerd")
   - Each configuration concern (e.g., "PVC claims 120Gi")
   - Each artifact location (e.g., "31GB build artifacts on host")

2. **Map technology relationships:**
   - How do components interact?
   - What depends on what?
   - Where are the constraints?

### Phase 4: Knowledge Gap Identification
1. **What do we NOT know?**
   - How does X work under the hood?
   - What are safe cleanup patterns?
   - What are the configuration options?

2. **What needs research?**
   - Which topics require deep dives?
   - Which are standard practice vs. novel?
   - Which are high-risk vs. low-risk?

---

## Outputs

### Investigation Report Structure

```markdown
# Investigation Report: [Problem Name]

## Problem Statement
[Raw problem from user]

## Affected Systems
- System 1: [details]
- System 2: [details]

## Observable Symptoms
- Symptom 1: [metric/state]
- Symptom 2: [metric/state]

## Key Surfaces Identified
1. **Surface Name** - XGB / issue description
   - Location: [path or component]
   - Current state: [metrics]
   - Concern: [why this matters]

## Technologies Involved
- Technology 1: [role in problem]
- Technology 2: [role in problem]

## Knowledge Gaps
- Gap 1: [what we need to research]
- Gap 2: [what we need to understand]

## Next Steps
- Research topics to scope (hand off to query formulation)
- Immediate actions (if any safe quick wins)
- Escalations (if critical/blocking)
```

---

## Example: Storage Optimization Intake

### Input
```
problem_statement: "vLLM has 13GB free, disk at 84%"
system_context: "k3s-02 VM running vLLM inference"
symptoms: "Disk usage high, pod restarts"
```

### Investigation Performed
```bash
# Disk usage
df -h /  # Result: 77G total, 64G used, 13G free (84%)

# K8s storage
kubectl get pvc --all-namespaces  # vllm-primary-hf-cache: 120Gi

# Breakdown
sudo du -sh /var/lib/rancher/k3s/agent/containerd/  # 33GB
sudo du -sh /var/lib/rancher/k3s/storage/pvc-*/  # 19GB
```

### Output Report
```markdown
# Investigation Report: vLLM k3s-02 Storage Constraints

## Problem Statement
vLLM has 13GB free space, disk at 84% utilization

## Affected Systems
- k3s-02 VM (Ubuntu guest on Hyper-V)
- vLLM inference workload
- K3s single-node cluster

## Observable Symptoms
- Disk usage: 64G / 77G (84%)
- Free space: 13GB (critically low)
- vLLM pod: 4 restarts in 8 days

## Key Surfaces Identified
1. **Containerd Images** - 33GB
   - Location: /var/lib/rancher/k3s/agent/containerd/
   - Breakdown: 24GB overlayfs, 9.3GB blobs
   - Concern: Potential stale images/layers

2. **HuggingFace Cache** - 19GB
   - Location: /var/lib/rancher/k3s/storage/pvc-*/
   - Model: Qwen2.5-Coder-32B-AWQ
   - Concern: Growth potential, offload options

3. **PVC Behavior** - Claims 120Gi on 77GB disk
   - K3s local-path StorageClass
   - Concern: No enforcement, overcommit possible

4. **Build Artifacts** - 31GB (on Hyper-V host)
   - Location: D:\ProgramData\Ansible\hyperv_ubuntu_vm\
   - Files: livecd VHD, cloud image archives
   - Concern: One-time provisioning artifacts still present

## Technologies Involved
- Kubernetes (K3s): Storage architecture, PVC behavior
- Containerd: Image storage, garbage collection
- vLLM: Model caching, startup behavior
- HuggingFace Hub: Cache structure, management
- Ansible: Automation for cleanup
- Hyper-V: VM provisioning, artifact storage

## Knowledge Gaps
- How does containerd GC work? Safe cleanup?
- HF cache structure and management commands?
- K8s kubelet disk pressure handling?
- vLLM cache offload options?
- Ansible patterns for recurring cleanup?

## Next Steps
- Scope 25+ research queries across 6 technologies
- Immediate: Check Hyper-V host for reclaimable artifacts
- Research: Deep dive on each technology's storage patterns
```

---

## Success Criteria

A good intake produces:
- ✅ Clear problem articulation (not just symptoms)
- ✅ Quantified surfaces (sizes, paths, states)
- ✅ Technology map (what's involved, how they relate)
- ✅ Specific knowledge gaps (not generic "research X")
- ✅ Actionable next steps (research topics OR quick wins)

---

## Integration Points

**Feeds into:**
- `multi-agent-research-query-formulator` - Uses knowledge gaps to create queries
- Investigation report becomes context for research handoff

**Receives from:**
- User problem statement
- System monitoring/alerts (if automated)

---

## Notes for Implementation

When this skill is ready to implement:

1. **Tool integration needed:**
   - SSH/kubectl access to probe systems
   - File system inspection
   - Log aggregation

2. **Safety considerations:**
   - All probes should be read-only
   - Don't make changes during investigation
   - Validate access before running commands

3. **Customization points:**
   - Technology-specific probe patterns
   - Report template adaptations
   - Integration with existing monitoring

---

## Related Skills

- `multi-agent-research-query-formulator` (next phase)
- `multi-agent-solution-validator` (later validation phase)
- System-specific probe skills (if created)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
