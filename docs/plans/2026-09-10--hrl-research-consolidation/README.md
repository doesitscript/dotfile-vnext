# Plan: HRL Research Consolidation

**Status:** Planning Phase - Research Collection Complete (Partial)  
**Date:** September 10, 2026  
**Type:** Multi-technology research consolidation

---

## Purpose

Consolidate scattered Context7 research entries from the Homelab Reference Library (HRL) into actionable implementation plans for storage optimization and infrastructure automation.

---

## Context

Research was triggered by vLLM k3s-02 storage constraints (84% disk usage, 13GB free). Investigation expanded into comprehensive study of:
- Container image management (Containerd)
- Model cache strategies (Hugging Face Hub)
- Kubernetes storage architecture
- vLLM production patterns
- Ansible automation capabilities

**Result:** 25+ Context7 entries created across 10 technologies, awaiting consolidation.

---

## Plan Contents

| File | Purpose | Status |
|------|---------|--------|
| `README.md` | This file - plan overview | ✅ Complete |
| `planner.md` | Future workflow notes for automation | ✅ Complete |
| `research-index.md` | HRL research location index | ✅ Complete |
| `findings-report.md` | Comprehensive findings summary | ✅ Complete |
| `plan.md` | Implementation plan (future) | ⏳ Pending planner run |

---

## Current Status

### Research Complete
- ✅ Containerd image management (1 entry)
- ✅ Hugging Face Hub cache (3 entries)
- ✅ Kubernetes storage (9 entries)
- ✅ vLLM deployment (4 entries)
- ✅ LLM evaluation patterns (1 entry)

### Research Partial
- ⚠️ **Ansible automation (9 of ~14 entries)**
  - Complete: Disk inventory, recurring runs, collections, roles, Windows commands
  - **Pending:** Role contracts, import/include, execution scaling, quality gates, project layout

### Research Needs Review
- 🔍 K3s (1+ entry)
- 🔍 Systemd (1+ entry)
- 🔍 Prometheus (1+ entry)
- 🔍 Windows Server (1+ entry)

---

## Key Findings Summary

**Storage Reclamation Executed:**
- 31GB freed from k3s-02 VM directory
- Shared cache implemented for cloud images
- D: drive free space: 69GB → 367GB

**Research Insights:**
- Containerd: GC automation patterns identified
- HF Cache: CLI tools and structure documented
- Kubernetes: PVC overcommit behavior explained
- vLLM: USB 3.0 acceptable for model cache (startup-only penalty)
- Ansible: Disk facts, cron patterns, artifact cleanup strategies

**Recommendations:**
1. Complete Ansible research (5 topics)
2. Add second VHDX on USB 3.0 for model cache
3. Create periodic containerd cleanup playbook
4. Implement HF cache management automation

---

## Next Steps

### Immediate
1. **Complete Ansible research** - 5 remaining topics from screenshot
2. **Review uninspected entries** - K3s, Systemd, Prometheus, Windows Server
3. **Commit HRL research** - 30+ uncommitted files

### Planner Phase
1. **Consolidate all Context7 decision.yaml files**
2. **Extract selected approaches** and confidence levels
3. **Group by implementation theme** (storage, cache, cleanup, monitoring)
4. **Generate plan.md** with unified architecture and steps

### Implementation Phase
1. **Create Ansible playbooks** from consolidated plan
2. **Update existing roles** with new capabilities
3. **Add verification receipts** and monitoring
4. **Execute and validate** each component

---

## References

### Related Plans
- `../2026-09-10--storage-reclamation-and-optimization.md` - Executed cleanup
- `../../diagrams/cst-hom-lab-ctl-dia-vllmcache-*.{md,py,svg}` - Architecture diagrams
- `../../intake/jupyter-devops-implementation-plans/00b-shared-hyperv-cache-infrastructure.md` - Shared cache

### HRL Research
- **Base Path:** `/Users/joshc/develop/homelab-reference-library/`
- **Context7 Entries:** `generated/context7/*/`
- **Implementation Guides:** `implementation-guides/storage/`
- **Investigation Notes:** `notes/investigations/2026-09-10--*.md`

### Ansible Roles
- `roles/hyperv_ubuntu_vm/` - Updated with shared cache
- `roles/k3s_vllm_runtime/` - Model cache location
- `roles/k3s_comfyui_runtime/` - PVC rightsizing

---

## Timeline

**Research Phase:**
- Started: During storage optimization work
- Context7 collection: September 10, 2026
- Status: 80% complete (Ansible partial)

**Planning Phase:**
- Current: Research indexing and findings
- Next: Await Ansible research completion
- Then: Planner consolidation

**Implementation Phase:**
- Estimated: 2-4 hours for playbook creation
- Testing: 1-2 hours validation
- Total: One working session post-planning

---

## Success Criteria

### Research Complete
- [ ] All Ansible topics finished (5 remaining)
- [x] Context7 entries for storage technologies
- [x] Containerd, HF Hub, K8s, vLLM covered
- [ ] Uninspected entries reviewed
- [ ] HRL research committed to version control

### Plan Generated
- [ ] `plan.md` created by planner
- [ ] Architecture diagrams included
- [ ] Apply/Verify/Undo steps documented
- [ ] Ansible role integration mapped
- [ ] Verification receipts defined

### Implementation Ready
- [ ] Playbooks created from plan
- [ ] Roles updated with new capabilities
- [ ] Monitoring and alerting configured
- [ ] Documentation complete

---

## Notes

**Planner Automation Vision:**
Future iterations should automate this workflow. The planner agent can scan Context7 entries, extract decisions, and generate implementation plans without manual consolidation.

**Ansible Research:**
Screenshot shows 5 Ansible topics were being researched by subagent. Those topics are not yet in HRL and should be added before plan consolidation.

**Version Control:**
HRL has 30+ uncommitted files (research entries, guides, skills). Commit after review to preserve research.

---

**Plan Folder Created:** September 10, 2026  
**Awaiting:** Ansible research completion → Planner consolidation → Implementation
