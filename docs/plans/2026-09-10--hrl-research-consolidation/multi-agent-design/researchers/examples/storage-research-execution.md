# Example: Storage Optimization Research Execution

**Date:** September 10, 2026  
**Problem:** vLLM k3s-02 VM storage constraints (from Onsite Expert)  
**Researchers Role Demonstration**

---

## Handoff from Onsite Expert

### Research Package Received

**Problem Context:**
```
Original Issue: vLLM k3s-02 disk 84% full (13GB free / 77GB total)
Investigation Found:
  - Containerd: 33GB (24GB overlayfs, 9.3GB blobs)
  - HF Cache: 19GB model weights
  - Build artifacts: 31GB on Hyper-V host
  
Technologies Involved:
  - Kubernetes (K8s, K3s)
  - Containerd
  - vLLM
  - Hugging Face Hub
  - Ansible (for automation)
  - Hyper-V (VM provisioning)

Priority: High - disk pressure affecting pod stability
```

### Scoped Research Queries (25+ topics)

Researchers received precise queries across technologies:

#### Containerd (1 query)
```
Query: How does containerd garbage collection reclaim disk space? 
       Content store vs overlayfs snapshotter disk usage, 
       gc scheduler config, gc.ref labels, 
       pruning unused images and snapshots with ctr and crictl rmi --prune

Context: 33GB consumed, need safe cleanup patterns
Priority: High
```

#### Hugging Face Hub (3 queries)
```
Query 1: Manage the local HF cache disk usage: hf cache scan, hf cache delete, 
         HF_HUB_CACHE and HF_HOME layout, blobs snapshots refs symlink structure

Query 2: Hugging Face Hub Python client and CLI for listing models, 
         model cards, and downloading weights

Query 3: Practical recipes: HfApi list_models filters, hf CLI models list, 
         snapshot_download, HF_TOKEN

Context: 19GB model cache, need management strategies
Priority: Medium (offload option)
```

#### Kubernetes (9 queries)
```
Query 1: kubelet image garbage collection configuration: 
         imageGCHighThresholdPercent, imageGCLowThresholdPercent, 
         imageMinimumGCAge, how kubelet reclaims disk space

Query 2: Kubernetes kubelet FreeDiskSpaceFailed / DiskPressure: 
         image garbage collection triggers

Query 3: Kubernetes DaemonSet: tolerations, update strategy, 
         RollingUpdate OnDelete, nodeSelector

(+ 6 more K8s queries)

Context: k3s-02 at 84% capacity, PVC overcommit concerns
Priority: High
```

#### vLLM (4 queries)
```
Query 1: vLLM cache and artifact offload: drive implementation targets

Query 2: vLLM GPU memory utilization, tensor parallel, model loading, 
         quantization options, memory management

Query 3: vLLM Kubernetes deployment: GPU nodes, runtime class, 
         health checks, liveness readiness probes

Query 4: vLLM OpenAI compatible API server: command line arguments, 
         served models, API endpoints

Context: vLLM pod restarting, model startup time considerations
Priority: High
```

#### Ansible (9 queries, 5 pending)
```
Query 1: Ansible facts for disk management: ansible_mounts, ansible_devices

Query 2: ansible.builtin.cron scheduled recurring jobs, ansible-pull 
         periodic runs via crontab, find with age plus file state absent 
         to delete old cached files

Query 3: ansible.windows win_command and win_shell modules: 
         parameters, idempotency, when to use each

(+ 6 more Ansible queries)

Context: Need automation for cleanup, recurring tasks
Priority: Medium (after immediate fixes)
```

---

## Research Execution Process

### Phase 1: Parallel Research Streams

Multiple researchers worked simultaneously on different technologies:

**Researcher A: Containerd**
- Tools: Context7 `containerd` library
- Time: ~1 hour
- Output: 1 comprehensive entry

**Researcher B: Kubernetes**
- Tools: Context7 `kubernetes` library
- Time: ~2 hours
- Output: 9 entries (storage, GC, pods, deployments)

**Researcher C: vLLM**
- Tools: Context7 `vllm` library
- Time: ~1.5 hours
- Output: 4 entries (cache, GPU, K8s, API)

**Researcher D: Hugging Face Hub**
- Tools: Context7 `huggingface-hub` library
- Time: ~1 hour
- Output: 3 entries (cache mgmt, APIs, recipes)

**Researcher E: Ansible**
- Tools: Context7 `ansible` library
- Time: ~2 hours (ongoing)
- Output: 9 entries (4 more pending)

### Phase 2: Research Artifact Creation

#### Example: Containerd Research

**Created:** `generated/context7/containerd/image-store-disk-reclamation/`

**Files:**
```
query.md:
  Original question from Onsite Expert about containerd GC

result.md:
  - Two storage layers explained (content store + snapshotter)
  - GC trigger mechanisms
  - gc.ref label usage
  - Safe vs unsafe cleanup commands
  - Expected disk reclamation

decision.yaml:
  selected_approach: "Weekly crictl rmi --prune automation"
  confidence_level: "high"
  reasoning: "Safe, idempotent, targets only unused images"
  alternatives_considered:
    - "Manual overlayfs cleanup (rejected: breaks running pods)"
    - "Stop/remove all pods then cleanup (rejected: too disruptive)"
  safety_considerations:
    - "Never delete snapshots manually"
    - "Prune only removes unreferenced images"
    - "Failed pod snapshots need separate investigation"

receipt.yaml:
  library_id: "containerd"
  sources: ["Context7: containerd official docs"]
  retrieval_date: "2026-09-10"
  version: "1.7.x"
  confidence: "high"
  
README.md:
  Summary linking to problem (k3s-02 disk pressure)
  Cross-references to K8s kubelet GC research
  Implementation pointer to future Ansible playbook
```

#### Example: Hugging Face Hub Research

**Created:** `generated/context7/huggingface-hub/cache-disk-management/`

**Key Findings:**
```
Cache Structure:
  blobs/          - Actual model file chunks (immutable)
  snapshots/      - Revision-specific symlink trees
  refs/           - Branch/tag pointers
  .locks/         - Prevents concurrent corruption

Management Commands:
  hf cache scan                    - Show disk usage by model/revision
  hf cache delete --revision <id>  - Remove specific revision
  hf cache delete --model <name>   - Remove entire model

Environment:
  HF_HUB_CACHE    - Cache root (default: ~/.cache/huggingface/hub)
  HF_HOME         - Parent directory (default: ~/.cache/huggingface)

Safety:
  - Deleting blobs is safe (only unused ones removed)
  - Symlinks auto-clean with blob removal
  - .locks prevent corruption during writes
```

**Decision:**
```yaml
selected_approach: "Offload model cache to USB 3.0 VHDX"
confidence_level: "medium-high"
reasoning: |
  Model loading is one-time at pod startup (disk→VRAM).
  Inference runs entirely from VRAM (disk speed irrelevant).
  USB 3.0 startup penalty (~9 min vs ~5 sec) is acceptable.
  Gains: Large capacity, keeps OS/containerd on fast NVMe.
alternatives_considered:
  - "Network share over Wi-Fi (rejected: too slow, unreliable)"
  - "Keep on NVMe (rejected: limited growth headroom)"
implementation_notes: |
  - Add second VHDX attached to USB 3.0 drive
  - Mount as /mnt/model-cache in k3s-02 guest
  - Update vLLM PVC to use new mount
```

---

## Phase 3: Organization by Technology

### Directory Structure Created

```
generated/context7/
├── ansible/
│   ├── disk-management-inventory/
│   ├── recurring-runs-and-artifact-retention/
│   ├── galaxy-collection-install/
│   ├── inventory-and-variable-precedence/
│   ├── kubernetes-core-helm/
│   ├── kubernetes-core-k8s-apply/
│   ├── module-findability/
│   ├── roles-and-collections/
│   └── windows-command-execution/
│
├── containerd/
│   └── image-store-disk-reclamation/
│
├── huggingface-hub/
│   ├── cache-disk-management/
│   ├── docs-and-apis/
│   └── recipes/
│
├── kubernetes/
│   ├── daemonsets/
│   ├── deployments-services-ingress/
│   ├── k3s-dns-architecture/
│   ├── kubelet-image-garbage-collection/
│   ├── kubelet-storage-offload/
│   ├── node-disk-pressure-freediskspacefailed/
│   ├── pod-dns/
│   ├── replicasets/
│   └── runtime-class/
│
└── vllm/
    ├── cache-and-artifact-offload/
    ├── gpu-memory-and-model-loading/
    ├── kubernetes-deployment/
    └── openai-compatible-server/
```

**Organization Principles:**
- Group by primary technology
- Keep related topics together
- Consistent naming (lowercase-with-dashes)
- Self-documenting directory names

---

## Phase 4: Creating Navigable Indexes

### Research Index (`research-index.md`)

Comprehensive location map:

```markdown
# HRL Research Index - Storage and Infrastructure Topics

## Ansible (Storage and Automation)
**Base Path:** `generated/context7/ansible/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Disk Management Inventory | `disk-management-inventory/` | ✅ Complete | ansible_mounts, ansible_devices |
| Recurring Runs | `recurring-runs-and-artifact-retention/` | ✅ Complete | cron, find+age, cleanup |
| (7 more entries...)

## Containerd (Image Management)
**Base Path:** `generated/context7/containerd/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Image Store Reclamation | `image-store-disk-reclamation/` | ✅ Complete | GC config, crictl prune |

## Hugging Face Hub (Model Cache)
**Base Path:** `generated/context7/huggingface-hub/`

(3 entries with locations and focus areas)

## Kubernetes (Storage & Scheduling)
**Base Path:** `generated/context7/kubernetes/`

(9 entries with locations and focus areas)

## vLLM (Model Serving)
**Base Path:** `generated/context7/vllm/`

(4 entries with locations and focus areas)
```

**Navigation Features:**
- Click-through paths to research entries
- Status at a glance (complete/pending/needs-review)
- Key focus summary for each entry
- Technology grouping for easy browsing

---

## Phase 5: Findings Report

### Comprehensive Findings (`findings-report.md`)

Organized summary connecting research to solutions:

```markdown
## Key Findings by Technology

### 1. Containerd Image Management
**Research Location:** `generated/context7/containerd/image-store-disk-reclamation/`

**Findings:**
- Two storage layers: content store (blobs) + snapshotter (overlayfs)
- GC triggered by gc.ref labels
- Safe cleanup: crictl rmi --prune

**Current State:**
- k3s-02 containerd: 33GB (24GB overlayfs, 9.3GB blobs)
- Prune test: recovered 2.3 MB (most images in use)

**Recommendation:**
- Weekly automated cleanup playbook
- Investigate stale snapshots from failed pods

---

### 2. Hugging Face Cache Management
**Research Locations:**
- `generated/context7/huggingface-hub/cache-disk-management/`
- (2 more entries)

**Findings:**
- Cache structure: blobs, snapshots, refs, .locks
- Management: hf cache scan/delete
- Safe to remove unused revisions

**Current State:**
- vLLM HF cache: 19GB on NVMe
- Single model: Qwen2.5-Coder-32B-AWQ

**Recommendation:**
- Offload to USB 3.0 second VHDX
- Accept startup penalty for capacity gain
- Keep OS/containerd on NVMe

(Continue for each technology...)
```

---

## Phase 6: Problem Connection

### Traceability Matrix

Every research entry connected back to original problem:

```markdown
## Problem → Research → Solution Path

**Original Problem:** vLLM k3s-02 disk 84% full, 13GB free

**Investigation Surfaces (Onsite Expert):**
- Containerd: 33GB
- HF Cache: 19GB
- Build artifacts: 31GB (Hyper-V host)
- PVC behavior: local-path doesn't enforce limits

**Research Conducted:**
1. Containerd GC → `containerd/image-store-disk-reclamation/`
   - Solution: Weekly prune automation
   
2. HF Cache → `huggingface-hub/cache-disk-management/`
   - Solution: USB 3.0 offload strategy
   
3. K8s Storage → `kubernetes/kubelet-image-garbage-collection/`
   - Solution: Understand PVC behavior, document limits
   
4. vLLM Deployment → `vllm/cache-and-artifact-offload/`
   - Solution: Confirm USB acceptable for models

5. Ansible Automation → `ansible/recurring-runs-and-artifact-retention/`
   - Solution: Cron patterns for cleanup

**Solutions Enabled:**
✅ Immediate: 31GB reclaimed (build artifacts moved/deleted)
📋 Near-term: Containerd cleanup playbook (research complete)
📋 Near-term: HF cache management playbook (research complete)
📋 Long-term: Second VHDX for model cache (researched, pending provision)

**Research Status:**
- Complete: Containerd, HF Hub, K8s, vLLM (20+ entries)
- Pending: Ansible execution patterns (5 topics remaining)
```

---

## Phase 7: Coordination with Onsite Expert

### Validation Checkpoints

Researchers submitted findings back to Onsite Expert for validation:

**Checkpoint 1: Containerd Research Complete**
```
Researcher: "Containerd research done. Safe cleanup is crictl rmi --prune.
             Expected reclaim: 5-10GB from stale layers."

Onsite Expert: "Validated against k3s-02 state. Prune is safe. 
                Question: What about the 4 failed vLLM pods? 
                Do they leave snapshots?"

Researcher: "Added note about failed pod snapshots. Flagged for 
             manual investigation. Updated decision file."
```

**Checkpoint 2: HF Cache Strategy**
```
Researcher: "Three HF cache entries complete. Recommend USB 3.0 offload.
             Startup: 5s (NVMe) vs 9min (USB). Is 9min acceptable?"

Onsite Expert: "Validated with user. 9min acceptable because:
                - Model loading is one-time at pod start
                - Inference runs from VRAM (disk irrelevant)
                - Gains massive capacity for future models
                Approved for implementation planning."
```

**Checkpoint 3: Research Gaps**
```
Researcher: "Ansible research 80% complete. 5 topics pending:
             - Role interface contracts
             - Import vs include reuse
             - Execution scaling
             - Quality gates
             - Project layout
             Should I continue or report current state?"

Onsite Expert: "Report current state. Document the gaps clearly.
                We can proceed with consolidation for completed research.
                Pending topics can be added when finished."
```

---

## Phase 8: Final Consolidation

### Deliverables to Planning Phase

Researchers provided complete package:

1. **25+ Research Entries**
   - Organized by technology
   - Standardized structure
   - Decision files complete

2. **Research Index** (`research-index.md`)
   - All locations mapped
   - Status clear
   - Navigation easy

3. **Findings Report** (`findings-report.md`)
   - Key findings by technology
   - Current state vs recommendations
   - Implementation readiness

4. **Problem Traceability**
   - Each research → problem area
   - Solutions enabled documented
   - Gaps flagged

5. **Implementation Guidance**
   - Ansible role targets identified
   - Playbook needs scoped
   - Safety considerations noted

---

## Outcomes & Metrics

### Research Coverage

**Complete:**
- ✅ Containerd: 1 entry (100%)
- ✅ HF Hub: 3 entries (100%)
- ✅ Kubernetes: 9 entries (100%)
- ✅ vLLM: 4 entries (100%)
- ⚠️ Ansible: 9 entries (64% - 5 pending)

**Total:** 26 entries created, 21 complete, 5 pending

### Organization Quality

- ✅ Consistent directory structure
- ✅ Technology grouping clear
- ✅ Indexes comprehensive
- ✅ Navigation time: < 30 seconds to any entry

### Actionability

- ✅ Containerd cleanup: Ready for playbook implementation
- ✅ HF cache: Strategy clear, approved by expert
- ✅ K8s understanding: PVC behavior documented
- ✅ vLLM deployment: USB offload validated

### Problem Connection

- ✅ Every entry traces to storage optimization
- ✅ Solution paths clear
- ✅ Implementation owners identified (Ansible roles)
- ✅ Traceability maintained in decision files

---

## Lessons Learned

### What Worked Well

1. **Clear Scoping from Onsite Expert**
   - Precise queries eliminated ambiguity
   - Context provided prevented scope creep
   - Priority flags helped sequence work

2. **Parallel Execution**
   - 5 researchers worked simultaneously
   - No blocking dependencies
   - Faster completion (2 hours vs sequential 10+ hours)

3. **Standardized Structure**
   - Consistent artifacts across all entries
   - Easy to navigate and consolidate
   - Decision files enabled validation

4. **Continuous Validation**
   - Checkpoints with Onsite Expert caught issues early
   - Safety concerns addressed before implementation
   - Gaps flagged promptly

5. **Problem Connection Maintained**
   - Never lost sight of original issue
   - Every research entry tied to real need
   - Solutions directly implementable

### Improvements for Next Time

1. **Earlier Coordination Between Researchers**
   - Could have identified overlaps sooner
   - Some cross-technology topics could merge

2. **More Frequent Checkpoints**
   - Validate assumptions earlier
   - Catch scope drift faster

3. **Research Template**
   - Pre-defined decision.yaml schema would help
   - Standard traceability fields

---

## Conclusion

The researcher role successfully transformed 25+ scoped queries into organized, actionable knowledge by:
- Executing focused research across multiple technologies
- Creating standardized, navigable artifacts
- Maintaining connection to the original problem
- Coordinating with Onsite Expert for validation
- Delivering comprehensive indexes and findings reports

This enabled the next phase (planning) to proceed with high-quality, well-organized research that directly addressed the storage optimization problem.

---

**Research Phase Duration:** ~2 hours (parallel execution)  
**Entries Created:** 26  
**Technologies Covered:** 10  
**Implementation-Ready Solutions:** 4+ playbooks scoped  
**Validation Cycles:** 3 checkpoints with Onsite Expert
