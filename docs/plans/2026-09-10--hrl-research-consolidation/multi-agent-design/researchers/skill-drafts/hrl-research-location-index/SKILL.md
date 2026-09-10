---
name: hrl-research-location-index
description: Create navigable indexes of research entries organized by technology and topic
status: draft
priority: medium
---

# HRL Research Location Index

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Researchers  
**Phase:** Research organization and navigation

---

## ⚠️ Draft Status

This skill is **draft work** documenting the research indexing pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Create clear, navigable indexes that connect research entries back to the technologies, topics, and problems they address. Make it easy to find "what research exists for X?" and "where did we learn about Y?"

---

## When to Use

Use this skill when:
- ✅ Multiple research entries have been created
- ✅ Need to organize research for navigation
- ✅ Want to report "what research exists"
- ✅ Creating plan folder or handoff documentation

Do NOT use when:
- ❌ Only one or two entries (index overhead not worth it)
- ❌ Research still in progress
- ❌ Index already exists and current

---

## Inputs

**Required:**
- `research_root` - Base path for research (e.g., `generated/context7/`)
- `scope` - Which research to index (all, by technology, by date range)

**Optional:**
- `index_type` - Technology-grouped, topic-grouped, chronological
- `output_path` - Where to save index

---

## Index Types

### 1. Technology-Grouped Index
Organize by technology, then topic:
```
Ansible
├── disk-management-inventory/
├── recurring-runs-and-artifact-retention/
└── galaxy-collection-install/

Containerd
└── image-store-disk-reclamation/

Kubernetes
├── kubelet-image-garbage-collection/
└── persistent-volume-claims/
```

### 2. Topic-Grouped Index
Organize by theme across technologies:
```
Storage Management
├── containerd/image-store-disk-reclamation/
├── kubernetes/kubelet-image-garbage-collection/
└── huggingface-hub/cache-disk-management/

Automation
├── ansible/recurring-runs-and-artifact-retention/
└── ansible/galaxy-collection-install/
```

### 3. Chronological Index
Organize by research date:
```
2026-09-10
├── containerd/image-store-disk-reclamation/
├── huggingface-hub/cache-disk-management/
└── kubernetes/kubelet-image-garbage-collection/
```

### 4. Status-Grouped Index
Organize by research completion status:
```
Complete (15)
├── containerd/image-store-disk-reclamation/
└── ...

Partial (5)
├── ansible/role-interface-contracts/
└── ...

Blocked (0)
```

---

## Workflow

### Phase 1: Research Discovery
1. Scan research root directory
2. Identify all research entries (by directory structure)
3. Read metadata files (decision.yaml, receipt.yaml)
4. Extract key info:
   - Technology
   - Topic
   - Status
   - Priority
   - Completion date

### Phase 2: Organization
1. **Group by chosen index type:**
   - Technology (most common)
   - Topic/theme
   - Date
   - Status

2. **Extract summary info for each entry:**
   - Topic name/description
   - Key findings (brief)
   - Decision outcome
   - Links to entry directory

### Phase 3: Index Generation
1. Create markdown table or hierarchical list
2. Include:
   - Technology/Topic names
   - Brief descriptions
   - Entry paths
   - Status indicators
   - Key focus areas

### Phase 4: Cross-References
1. Link related entries
2. Note dependencies
3. Highlight themes that span technologies

---

## Output Structure

```markdown
# HRL Research Location Index: [Scope Name]

## Overview
[What research is indexed here, when it was created, why]

**Scope:**
- Research root: `generated/context7/`
- Technologies: [list]
- Date range: [if applicable]
- Total entries: X

---

## Index by Technology

### Technology 1: [Name]
**Base Path:** `generated/context7/<technology>/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Topic 1 | `topic-slug/` | ✅ Complete | [Brief focus] |
| Topic 2 | `topic-slug/` | ⚠️ Partial | [Brief focus] |

**Summary:**
- X entries total
- Y complete, Z partial

**Key Findings:**
- [Notable finding 1]
- [Notable finding 2]

---

### Technology 2: [Name]
[Same structure...]

---

## Cross-Technology Themes

### Theme 1: [e.g., Storage Management]
Research entries spanning multiple technologies:
- `containerd/image-store-disk-reclamation/`
- `kubernetes/kubelet-image-garbage-collection/`
- `huggingface-hub/cache-disk-management/`

**Common patterns:**
- [Pattern 1]

---

## Research Status Summary

| Status | Count | Technologies |
|--------|-------|--------------|
| ✅ Complete | 15 | Containerd, HF Hub, K8s, vLLM |
| ⚠️ Partial | 5 | Ansible |
| 🚫 Blocked | 0 | - |

---

## Quick Reference by Topic

### Storage & Disk Management
- Containerd: `image-store-disk-reclamation/`
- Kubernetes: `kubelet-image-garbage-collection/`
- HF Hub: `cache-disk-management/`
- Ansible: `disk-management-inventory/`

### Automation & Scheduling
- Ansible: `recurring-runs-and-artifact-retention/`
- Ansible: `galaxy-collection-install/`

[... other topic groupings ...]

---

## Navigation Tips

**To find research on a technology:**
1. Go to base path: `generated/context7/<technology>/`
2. Browse directories by topic slug
3. Read `README.md` for entry overview

**To find research on a theme:**
1. Check "Cross-Technology Themes" section above
2. Follow links to relevant entries

**To understand an entry:**
1. Start with `README.md` (overview)
2. Read `query.md` (original question)
3. Read `result.md` (findings)
4. Read `decision.yaml` (selected approach)

---

## Appendix: All Entries

### Complete List (Alphabetical by Technology)

**Ansible (9 entries)**
- `disk-management-inventory/`
- `galaxy-collection-install/`
- `inventory-and-variable-precedence/`
- `kubernetes-core-helm/`
- `kubernetes-core-k8s-apply/`
- `module-findability/`
- `recurring-runs-and-artifact-retention/`
- `roles-and-collections/`
- `windows-command-execution/`

**Containerd (1 entry)**
- `image-store-disk-reclamation/`

**Hugging Face Hub (3 entries)**
- `cache-disk-management/`
- `huggingface-hub-python-client-and-cli/`
- `practical-recipes-hfapi/`

**Kubernetes (9 entries)**
- `kubelet-image-garbage-collection/`
- `persistent-volume-claims/`
- [... 7 more ...]

**vLLM (4 entries)**
- `cache-and-artifact-offload/`
- [... 3 more ...]
```

---

## Example: Storage Optimization Index

```markdown
# HRL Research Location Index: Storage Optimization Research

## Overview
This index covers research conducted to address vLLM k3s-02 storage
constraints. Research spanned 5 technologies and generated 20+ entries
between September 10-11, 2026.

**Scope:**
- Research root: `generated/context7/`
- Technologies: Ansible, Containerd, HF Hub, Kubernetes, vLLM
- Date range: 2026-09-10
- Total entries: 20

---

## Index by Technology

### Ansible (Storage and Automation)
**Base Path:** `generated/context7/ansible/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Disk Management Inventory | `disk-management-inventory/` | ✅ Complete | Ansible facts for disk info |
| Recurring Runs & Retention | `recurring-runs-and-artifact-retention/` | ✅ Complete | Cron, cleanup patterns |
| Galaxy Collection Install | `galaxy-collection-install/` | ✅ Existing | Community collections |
| Inventory & Vars | `inventory-and-variable-precedence/` | ✅ Existing | group_vars, host_vars |
| K8s Core - Helm | `kubernetes-core-helm/` | ✅ Existing | Helm module |
| K8s Core - Apply | `kubernetes-core-k8s-apply/` | ✅ Existing | k8s module |
| Module Findability | `module-findability/` | ✅ Existing | ansible-doc |
| Roles & Collections | `roles-and-collections/` | ✅ Existing | Role structure |
| Windows Commands | `windows-command-execution/` | ✅ Existing | win_command, win_shell |

**Summary:**
- 9 entries total
- 9 complete, 0 partial
- ⚠️ **Incomplete:** 5 additional topics mentioned but not yet researched:
  - Role interface contracts
  - Import vs include reuse
  - Execution scaling
  - Quality gates
  - Project layout

**Key Findings:**
- Ansible facts provide rich disk info (ansible_mounts, ansible_devices)
- Cron + find module for recurring cleanup
- Galaxy collections for K8s management

---

### Containerd (Image Store)
**Base Path:** `generated/context7/containerd/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Image Store Reclamation | `image-store-disk-reclamation/` | ✅ Complete | GC, crictl rmi --prune |

**Summary:**
- 1 entry total
- 1 complete, 0 partial

**Key Findings:**
- Two-layer storage: content store + overlayfs snapshotter
- Safe cleanup: `crictl rmi --prune` (only unused)
- Unsafe: Manual content store deletion

---

### Hugging Face Hub (Cache Management)
**Base Path:** `generated/context7/huggingface-hub/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Cache Disk Management | `cache-disk-management/` | ✅ Complete | hf cache scan/delete |
| HF Hub Python & CLI | `huggingface-hub-python-client-and-cli/` | ✅ Complete | HfApi, model listing |
| Practical Recipes | `practical-recipes-hfapi/` | ✅ Complete | list_models, snapshot_download |

**Summary:**
- 3 entries total
- 3 complete, 0 partial

**Key Findings:**
- HF cache structure: blobs, snapshots, refs, symlinks
- Official management: `hf cache scan`, `hf cache delete`
- API access: HfApi for model listing and downloading

---

### Kubernetes (Storage Architecture)
**Base Path:** `generated/context7/kubernetes/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Kubelet Image GC | `kubelet-image-garbage-collection/` | ✅ Complete | imageGC thresholds |
| PVC | `persistent-volume-claims/` | ✅ Complete | PVC architecture |
| [... 7 more ...] | | |

**Summary:**
- 9 entries total
- 9 complete, 0 partial

**Key Findings:**
- Kubelet GC triggers: imageGCHighThresholdPercent (85%)
- PVC with local-path: No size enforcement
- Disk pressure eviction: Node-level protection

---

### vLLM (Production Deployment)
**Base Path:** `generated/context7/vllm/`

| Topic | Directory | Status | Key Focus |
|-------|-----------|--------|-----------|
| Cache Offload | `cache-and-artifact-offload/` | ✅ Complete | Model loading, VRAM |
| [... 3 more ...] | | |

**Summary:**
- 4 entries total
- 4 complete, 0 partial

**Key Findings:**
- Model load: Disk → VRAM at pod start
- Inference: From VRAM (disk speed irrelevant after load)
- Offload: USB 3.0 acceptable (9min load vs 5s NVMe)

---

## Cross-Technology Themes

### Theme 1: Storage Management Patterns
Research entries spanning multiple technologies:
- `containerd/image-store-disk-reclamation/`
- `kubernetes/kubelet-image-garbage-collection/`
- `huggingface-hub/cache-disk-management/`

**Common patterns:**
- Layered storage (base + overlay/diff)
- Conservative GC (safety over space)
- Official tools preferred (avoid manual)
- Automation recommended (weekly cleanup)

---

### Theme 2: Automation Safety
Research entries addressing automation:
- `ansible/recurring-runs-and-artifact-retention/`
- `containerd/image-store-disk-reclamation/`
- `kubernetes/kubelet-image-garbage-collection/`

**Common patterns:**
- Idempotent operations
- Dry-run modes available
- Monitoring after changes
- Rollback capability

---

## Research Status Summary

| Status | Count | Technologies |
|--------|-------|--------------|
| ✅ Complete | 15 | Containerd, HF Hub, K8s, vLLM, Ansible (partial) |
| ⚠️ Partial | 5 | Ansible (5 topics pending) |
| 🚫 Blocked | 0 | - |

**Note:** Ansible research is incomplete. 5 topics identified but not yet researched:
- Role interface contracts
- Import vs include reuse
- Execution scaling
- Quality gates
- Project layout and collections

---

## Quick Reference by Topic

### Storage & Disk Management
- Containerd: `image-store-disk-reclamation/`
- Kubernetes: `kubelet-image-garbage-collection/`
- HF Hub: `cache-disk-management/`
- Ansible: `disk-management-inventory/`

### Model Management
- HF Hub: `huggingface-hub-python-client-and-cli/`
- HF Hub: `practical-recipes-hfapi/`
- vLLM: `cache-and-artifact-offload/`

### Automation & Scheduling
- Ansible: `recurring-runs-and-artifact-retention/`
- Ansible: `roles-and-collections/`

### Kubernetes Operations
- Kubernetes: `kubelet-image-garbage-collection/`
- Kubernetes: `persistent-volume-claims/`
- Ansible: `kubernetes-core-helm/`
- Ansible: `kubernetes-core-k8s-apply/`

---

## Navigation Tips

**To find research on a technology:**
1. Go to base path: `generated/context7/<technology>/`
2. Browse directories by topic slug
3. Read `README.md` for entry overview

**To find research on a theme:**
1. Check "Cross-Technology Themes" section above
2. Follow links to relevant entries

**To understand an entry:**
1. Start with `README.md` (overview)
2. Read `query.md` (original question)
3. Read `result.md` (findings)
4. Read `decision.yaml` (selected approach)
5. Read `receipt.yaml` (execution metadata)

---

## Appendix: All Entries (Full List)

### Ansible (9 entries)
- `disk-management-inventory/`
- `galaxy-collection-install/`
- `inventory-and-variable-precedence/`
- `kubernetes-core-helm/`
- `kubernetes-core-k8s-apply/`
- `module-findability/`
- `recurring-runs-and-artifact-retention/`
- `roles-and-collections/`
- `windows-command-execution/`

### Containerd (1 entry)
- `image-store-disk-reclamation/`

### Hugging Face Hub (3 entries)
- `cache-disk-management/`
- `huggingface-hub-python-client-and-cli/`
- `practical-recipes-hfapi/`

### Kubernetes (9 entries)
- `kubelet-image-garbage-collection/`
- `persistent-volume-claims/`
- [... 7 more K8s entries ...]

### vLLM (4 entries)
- `cache-and-artifact-offload/`
- [... 3 more vLLM entries ...]
```

---

## Quality Checklist

Before publishing index:

✅ **Complete coverage:**
- All research entries included
- Technologies properly grouped
- Status accurately reflected

✅ **Navigability:**
- Clear directory paths
- Topic descriptions helpful
- Cross-references working

✅ **Context:**
- Original problem connected
- Research scope clear
- Date range specified

✅ **Accuracy:**
- Status indicators correct
- Entry counts match reality
- Paths verified

---

## Integration Points

**Receives from:**
- `hrl-research-entry-create` - Research entries to index

**Feeds into:**
- `hrl-research-consolidator` - Uses index for synthesis
- Onsite Expert - Navigation during validation
- Plan folders - Documentation reference

---

## Notes for Implementation

When ready to implement:

1. **Automation:**
   - Scan filesystem for research entries
   - Parse metadata files (YAML frontmatter)
   - Group by specified index type

2. **Validation:**
   - Check entry completeness
   - Verify required files present
   - Validate metadata format

3. **Output formats:**
   - Markdown table (human-readable)
   - JSON/YAML (machine-readable)
   - Interactive HTML (if desired)

---

## Related Skills

- `hrl-research-entry-create` (produces entries to index)
- `hrl-research-consolidator` (consumes index)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
