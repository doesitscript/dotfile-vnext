# Example: Storage Optimization Handoff

**Date:** September 10, 2026  
**Problem:** vLLM k3s-02 VM storage constraints  
**Onsite Expert Role Demonstration**

---

## Initial Problem (Intake)

**User Query:**
> "When I setup models that run on my vllm litellm setup, roughly how much storage is available where they get downloaded to before being loaded into the GPU on use"

**Raw Symptom:** vLLM has 13GB free, disk at 84%

---

## Phase 1: Investigation (Onsite Expert Active)

### Data Collection & System Probing

The Onsite Expert immediately began probing the k3s-02 system:

```bash
# Disk usage investigation
df -h /
# Result: 77G total, 64G used, 13G free (84% full)

# Kubernetes storage check
kubectl get pvc --all-namespaces
# Found: vllm-primary-hf-cache claiming 120Gi

# Container storage breakdown
sudo du -sh /var/lib/rancher/k3s/agent/containerd/
# Result: 33GB (24GB overlayfs, 9.3GB blobs)

# HuggingFace cache check
sudo du -sh /var/lib/rancher/k3s/storage/pvc-*/
# Result: 19GB model cache
```

### Key Surfaces Identified

1. **Containerd bloat:** 33GB in container images
2. **Model cache:** 19GB HuggingFace weights
3. **PVC behavior:** local-path doesn't enforce limits
4. **Build artifacts:** 31GB on Hyper-V host

---

## Phase 2: Context Building (Onsite Expert Active)

### Technologies Identified

The Onsite Expert mapped the problem across multiple technologies:

1. **Kubernetes (K8s):** Storage architecture, PVC behavior
2. **Containerd:** Image garbage collection
3. **vLLM:** Model loading and caching patterns
4. **Hugging Face Hub:** Cache management
5. **Ansible:** Automation capabilities for cleanup
6. **Hyper-V:** VM provisioning and artifact storage

### Knowledge Gaps Identified

- How does containerd GC actually work?
- What's the HF cache structure and cleanup process?
- How does K8s kubelet handle disk pressure?
- What are vLLM's cache offload options?
- Can Ansible automate recurring cleanup tasks?

---

## Phase 3: Research Scoping (Onsite Expert Active)

### Discrete Research Topics Formulated

The Onsite Expert broke the problem into **actionable research queries**:

#### Containerd Research
- Query: "How does containerd garbage collection reclaim disk space? Content store vs overlayfs snapshotter disk usage, gc scheduler config, gc.ref labels, pruning unused images and snapshots with ctr and crictl rmi --prune"

#### HuggingFace Hub Research
- Query: "Manage the local HF cache disk usage: hf cache scan, hf cache delete, HF_HUB_CACHE and HF_HOME layout, blobs snapshots refs symlink structure, .locks directory, scan_cache_dir and delete_revisions"

#### Kubernetes Research
- Query: "kubelet image garbage collection configuration: imageGCHighThresholdPercent, imageGCLowThresholdPercent, imageMinimumGCAge, imageMaximumGCAge, how the kubelet reclaims container image disk space on node disk pressure eviction"

#### vLLM Research
- Query: "vLLM cache and artifact offload: drive implementation targets per technology"

#### Ansible Research (5 topics)
1. Disk management inventory
2. Recurring runs and artifact retention
3. Role interface contracts
4. Import vs include reuse
5. Execution scaling
6. Quality gates
7. Project layout and collections

---

## Phase 4: Handoff (Onsite Expert Ownership)

### Quality Handoff Characteristics

The Onsite Expert ensured:

✅ **Clear queries:** Each research topic had specific questions  
✅ **Context provided:** Technologies and their relationships explained  
✅ **Scope defined:** What to research, not just "go research Kubernetes"  
✅ **Priority indicated:** Storage-critical items flagged  
✅ **Output format:** Context7 decision.yaml structure expected

### Handoff to Research Specialists

Research agents received:
- Scoped Context7 queries
- Technology context (why this matters)
- Current state facts (disk usage, sizes, paths)
- Expected deliverables (decision files, implementation guides)

**Result:** 25+ Context7 entries created successfully

---

## Phase 5: Guardian Role (Onsite Expert Available)

### Monitoring Research Progress

While researchers worked:
- Onsite Expert stepped back (less active)
- Maintained understanding of incoming findings
- Remained available for clarifications
- Monitored for gaps in research

### Example Clarification Interaction

**Researcher Question:** "Should we research all Ansible modules or focus on disk management?"

**Onsite Expert Response:** "Focus on disk management, recurring tasks, and artifact cleanup. We need automation patterns for the storage problem, not comprehensive Ansible coverage."

---

## Phase 6: Gatekeeping & Validation (Onsite Expert Active)

### Solution Quality Checks

The Onsite Expert validated:

❌ **Rejected:** "Just delete all containerd images" - Too aggressive, would break running pods

✅ **Accepted:** "Use crictl rmi --prune to remove only unused images" - Safe, targeted

❌ **Rejected:** "Move vLLM cache to network share over Wi-Fi" - Performance unacceptable

✅ **Accepted:** "USB 3.0 VHDX acceptable for model cache (startup-only penalty)" - Balanced solution

### Problem Space Protection

**Example Gatekeeping:**

When a solution proposed rightsizing the ComfyUI PVC from 200Gi to 60Gi, the Onsite Expert ensured:
- Live PVC impact documented (requires delete/recreate)
- Namespace state checked (currently absent, safe)
- Future reinstall path clear (default will be 60Gi)

**Not just "can we do it"** but **"should we, and what are the consequences?"**

---

## Phase 7: Synthesis Support (Onsite Expert Collaborative)

### Consolidation Assistance

The Onsite Expert helped:
- Organize 25+ research entries by theme
- Identify relationships between technologies
- Flag incomplete research (Ansible 5 topics pending)
- Recommend consolidation approach
- Create the `2026-09-10--hrl-research-consolidation` plan structure

---

## Outcomes Achieved

### Immediate Actions (Onsite Expert Validated)
- ✅ 31GB reclaimed from build artifacts
- ✅ Shared cache implemented for VM images
- ✅ D: drive freed: 69GB → 367GB

### Research Knowledge Base Created
- ✅ 25+ Context7 entries across 10 technologies
- ✅ Implementation guides for storage strategies
- ✅ Clear understanding of containerd, HF cache, K8s behavior

### Future Actions Scoped
- 📋 Containerd cleanup automation (research complete)
- 📋 HF cache management playbook (research complete)
- 📋 Second VHDX for model cache (researched, pending)
- ⏳ Ansible execution patterns (research 80% complete)

---

## Lessons: Why This Handoff Succeeded

### Good Onsite Expert Behaviors Demonstrated

1. **Didn't just ask researchers to "figure it out"**
   - Probed systems first
   - Identified specific knowledge gaps
   - Provided concrete context

2. **Broke down the monolithic problem**
   - "Storage is full" → 5+ discrete technologies
   - Each got targeted research scope

3. **Provided actionable queries**
   - Not "research Kubernetes storage"
   - But "how does kubelet GC work with these specific thresholds?"

4. **Stayed available**
   - Clarified when researchers had questions
   - Didn't disappear after handoff

5. **Validated solutions**
   - Caught unsafe approaches early
   - Protected project from degradation
   - Ensured "done" actually meant done

6. **Remained pragmatic**
   - Accepted that Ansible research is incomplete
   - Documented it rather than claiming completion
   - Plan reflects reality, not wishful thinking

---

## Anti-Patterns Avoided

### What the Onsite Expert DIDN'T Do

❌ **Didn't hand off vague problems**
- Not: "Disk is full, go research storage"
- But: "84% full k3s-02, 33GB containerd, 19GB models, need GC patterns"

❌ **Didn't disappear after handoff**
- Remained available for researcher questions
- Monitored progress
- Validated findings

❌ **Didn't accept poor solutions**
- Gatekept when solutions were unsafe
- Required evidence (not assumptions)
- Protected project quality

❌ **Didn't claim completion prematurely**
- Ansible research incomplete → documented as such
- Not "close enough" - actual state reflected

---

## Collaborative Dynamic (User + AI)

### How User & AI Shared This Role

**User contributions:**
- Initial problem statement
- Domain knowledge (vLLM, homelab setup)
- Validation of approaches
- Direction when stuck

**AI contributions:**
- System probing and data collection
- Technology identification
- Research query formulation
- Handoff orchestration
- Solution validation

**Together:** Neither could have done this alone as effectively. The collaboration made the handoff natural and successful.

---

## Metrics

**Time to Research Handoff:** ~2 hours (investigation + scoping)  
**Research Topics Generated:** 25+  
**Research Success Rate:** 80% complete (20% pending Ansible)  
**Immediate Problem Resolution:** ✅ Executed (31GB freed)  
**Solution Quality:** High (no project degradation, safe approaches)

---

**Conclusion:** This example demonstrates how a well-executed Onsite Expert role catalyzes successful multi-agent research workflows by providing clear context, actionable queries, and continuous guardianship of the problem space.
