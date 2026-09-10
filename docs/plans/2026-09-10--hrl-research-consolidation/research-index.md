# HRL Research Index - Storage and Infrastructure Topics

**Date:** September 10, 2026  
**Location:** `/Users/joshc/develop/homelab-reference-library/`  
**Status:** Research entries created, awaiting consolidation into implementation plans

---

## Overview

This index tracks Context7 research entries created by agents investigating storage optimization, disk management, and infrastructure automation topics. Research was conducted in response to the vLLM storage constraints and broader homelab resource management needs.

---

## Research Entries by Technology

### Ansible (Storage and Automation)

**Base Path:** `generated/context7/ansible/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Disk Management Inventory | `disk-management-inventory/` | ✅ Complete | Ansible facts for disk info, partition queries |
| Recurring Runs & Artifact Retention | `recurring-runs-and-artifact-retention/` | ✅ Complete | Cron scheduling, ansible-pull, artifact cleanup with find+state=absent |
| Galaxy Collection Install | `galaxy-collection-install/` | ✅ Existing | Community collections, requirements.yml |
| Inventory & Variable Precedence | `inventory-and-variable-precedence/` | ✅ Existing | group_vars, host_vars, merge order |
| Kubernetes Core - Helm | `kubernetes-core-helm/` | ✅ Existing | kubernetes.core.helm module |
| Kubernetes Core - K8s Apply | `kubernetes-core-k8s-apply/` | ✅ Existing | kubernetes.core.k8s for Deployments/Services |
| Module Findability | `module-findability/` | ✅ Existing | ansible-doc, galaxy search |
| Roles and Collections | `roles-and-collections/` | ✅ Existing | Role structure, defaults, vars, meta |
| Windows Command Execution | `windows-command-execution/` | ✅ Existing | win_command, win_shell modules |

**Ansible Research Status:**
- ⚠️ **Incomplete:** Additional topics mentioned in agent task (see screenshot)
  - Role interface contracts
  - Import vs include reuse
  - Execution scaling
  - Quality gates
  - Project layout and collections
- **Action needed:** Complete remaining Ansible research before plan consolidation

---

### Containerd (Image Management)

**Base Path:** `generated/context7/containerd/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Image Store Disk Reclamation | `image-store-disk-reclamation/` | ✅ Complete | GC config, crictl rmi --prune, content store vs snapshotter |

**Related Findings:**
- k3s-02 containerd: 33GB (24GB overlayfs, 9.3GB blobs)
- Prune recovered: 2.3 MB (minimal - most images in use)
- Opportunity: Clean stale snapshots from failed pod restarts

---

### Hugging Face Hub (Model Cache)

**Base Path:** `generated/context7/huggingface-hub/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Cache Disk Management | `cache-disk-management/` | ✅ Complete | `hf cache scan`, `hf cache delete`, blobs/snapshots/refs structure |
| Docs and APIs | `docs-and-apis/` | ✅ Complete | HfApi, model listing, downloads |
| Recipes | `recipes/` | ✅ Complete | Practical HfApi usage, CLI patterns |

**Current State:**
- vLLM HF cache: 19GB on k3s-02 guest NVMe
- Strategy researched: USB 3.0 offload for model weights

---

### Kubernetes (Storage & Scheduling)

**Base Path:** `generated/context7/kubernetes/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Kubelet Image GC | `kubelet-image-garbage-collection/` | ✅ Complete | imageGCHighThresholdPercent, disk pressure eviction |
| Kubelet Storage Offload | `kubelet-storage-offload/` | ✅ Complete | Drive implementation targets per tech |
| Node Disk Pressure | `node-disk-pressure-freediskspacefailed/` | ✅ Complete | FreeDiskSpaceFailed causes, image GC triggers |
| DaemonSets | `daemonsets/` | ✅ Complete | Tolerations, update strategies |
| Deployments/Services/Ingress | `deployments-services-ingress/` | ✅ Complete | Basic K8s workload patterns |
| K3s DNS Architecture | `k3s-dns-architecture/` | ✅ Complete | K3s-specific DNS setup |
| Pod DNS | `pod-dns/` | ✅ Complete | dnsConfig, dnsPolicy ClusterFirst |
| ReplicaSets | `replicasets/` | ✅ Complete | RS management |
| RuntimeClass | `runtime-class/` | ✅ Complete | GPU runtime, node selection |

**Key Insights:**
- local-path StorageClass doesn't enforce PVC limits
- Disk pressure triggers image GC
- K3s-02 at 84% capacity triggered investigation

---

### vLLM (Model Serving)

**Base Path:** `generated/context7/vllm/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Cache & Artifact Offload | `cache-and-artifact-offload/` | ✅ Complete | Drive implementation targets |
| GPU Memory & Model Loading | `gpu-memory-and-model-loading/` | ✅ Complete | Tensor parallel, quantization, memory tuning |
| Kubernetes Deployment | `kubernetes-deployment/` | ✅ Complete | GPU nodes, health checks, production config |
| OpenAI Compatible Server | `openai-compatible-server/` | ✅ Complete | Server startup, CLI args, API endpoints |

**Implementation Context:**
- vLLM pod restarting (4x in 8 days)
- Disk space pressure likely contributor
- Model loading: NVMe ~5s, USB 3.0 ~9min acceptable

---

### Additional Technologies Researched

**Other Context7 entries created but not yet indexed:**

| Technology | Base Path | Notes |
|------------|-----------|-------|
| K3s | `generated/context7/k3s/` | (needs inspection) |
| LLM Evaluation | `generated/context7/llm-evaluation/` | Pass/fail patterns |
| Prometheus | `generated/context7/prometheus/` | (needs inspection) |
| Systemd | `generated/context7/systemd/` | (needs inspection) |
| Windows Server | `generated/context7/windows-server/` | (needs inspection) |

---

## Implementation Guides Created

**Base Path:** `implementation-guides/storage/`

| Guide | Status | Notes |
|-------|--------|-------|
| Storage implementation guides | 🆕 New directory | Not yet inspected |

---

## Investigation Notes

**Location:** `notes/investigations/`

| Note | File | Date | Topic |
|------|------|------|-------|
| LLM Agent Pass/Fail Evaluation | `2026-09-10--llm-agent-pass-fail-evaluation-patterns.md` | Sep 10 | Evaluation patterns research |

---

## Skills & Framework Updates

**Skills:**
- `skills/research/observation-to-decision-research/` - New research skill (uncommitted)

**Catalogs:**
- `skills/catalog.yaml` - Modified
- `skills/evals/catalog.yaml` - Modified
- `catalog.yaml` (HRL root) - Modified

**Indexes:**
- `indexes/technologies.md` - Updated with new entries
- `indexes/sources.md` - Updated with Context7 sources
- `indexes/tasks.md` - Updated with new task patterns
- `indexes/relationships.md` - Updated with technology relationships

**Scripts:**
- `scripts/validate_metadata.py` - Modified (metadata validation updates)

---

## Cross-References

### Related Plans
- `docs/plans/2026-09-10--storage-reclamation-and-optimization.md` - Executed storage cleanup
- `docs/diagrams/cst-hom-lab-ctl-dia-vllmcache-*.{md,py,svg,png}` - Storage architecture diagrams
- `docs/intake/jupyter-devops-implementation-plans/00b-shared-hyperv-cache-infrastructure.md` - Shared cache plan

### Ansible Roles Affected
- `roles/hyperv_ubuntu_vm/` - Updated with shared cache support
- `roles/k3s_vllm_runtime/` - Model cache location
- `roles/k3s_comfyui_runtime/` - PVC rightsizing

---

## Action Items for Consolidation

1. **Complete Ansible research** (from screenshot topics)
   - Role interface contracts
   - Import vs include reuse
   - Execution scaling
   - Quality gates
   - Project layout and collections

2. **Review all Context7 decision.yaml files**
   - Extract selected approaches
   - Document rejected alternatives
   - Note confidence levels

3. **Create unified implementation plan**
   - Storage offload strategy (USB 3.0 VHDX)
   - Containerd cleanup automation
   - HF cache management playbook
   - Artifact retention policies

4. **Generate missing implementation guides**
   - Cross-reference with `implementation-guides/storage/`
   - Fill gaps identified in research

5. **Update Ansible roles**
   - Integrate disk management inventory queries
   - Add recurring cleanup tasks
   - Implement cache offload mounts

---

## Commit Status

**HRL Repository:** `/Users/joshc/develop/homelab-reference-library/`

**Uncommitted research:**
- All Context7 entries listed above (15+ new topics)
- Implementation guides (new directory)
- Investigation notes (1 new file)
- Skills and catalog updates
- Index rebuilds

**Action needed:** Review and commit HRL research before creating implementation plans

---

## Screenshot Reference

Research topics visible in agent task screenshot:
1. Research role interface contracts - Claude Opus 5 High
2. Research import vs include reuse - Claude Opus 5 High  
3. Research Ansible execution scaling - Claude Opus 5 High
4. Research Ansible quality gates - Claude Opus 5 High
5. Research project layout and collections - Claude Opus 5 High

Status: "Waiting for subagent" - indicates research was in progress

---

**Next Steps:**
1. Wait for Ansible research completion
2. Run planner to consolidate all research
3. Generate plan.md with architecture and implementation steps
4. Create Ansible automation from consolidated plan
