# Draft plan v0 — k3s-02 storage pressure / upgrade

**Status:** draft brainstorm (v0)  
**Source slice:** `multi-agent-design/multi-agent-onsite-expert/transcripts/role-onsite-export-transcript-from-cursor_4_vllm_model_storage_capacity--initial-discussion.md` (≈1726–2164)  
**Related:** [README.md](./README.md) (later cleanup / upgrade notes)

---

## 1. Problems / context

### What was being tried
Deploy **Qwen3-Coder-30B AWQ** on K3s (`hom-lab-ctl-k3s-02`) end-to-end:

- AWQ weights already downloaded (~17GB, 4 safetensors shards)
- vLLM / LiteLLM / Continue configs pointed at the AWQ model
- vLLM manifest deployed so the runtime pod could schedule and load the model

### What went wrong
| Symptom | Detail from session |
| --- | --- |
| Disk pressure on node | Image filesystem ~87% (threshold 85%); node tainted `node.kubernetes.io/disk-pressure` |
| Pod stuck / evicted | Pending, then evicted again after brief schedule (`Available` ≈7.7GB vs threshold ≈7.8GB) |
| Hot path on disk | `/var/lib/rancher` ~28GB; HF cache PVC allocated 120Gi and grows with each model |
| Undersized root disk | VM disk ~77GB total — too small once model cache + container images + load scratch compete |
| Cleanup alone insufficient | Log prune (~195MB) cleared pressure briefly; load of ~17GB into local PVC re-triggered eviction |

### Why this mattered beyond one deploy
Planned multi-model cache (~82GB for four large models) cannot live sustainably on a ~77GB OS disk. Host (`HOM-LAB-HVH-02`) had free physical capacity; the gap was **VM/layout**, not “no disks in the lab.”

### Decisions already leaning in this slice
1. **Do A now** — cleanup (`crictl` prune / journal vacuum) for short-term relief.  
2. **Plan B/C this week** — longer-term scalable storage (expand root and/or attach dedicated data disk).  
3. Prefer **SSD for active K3s/model I/O**; spinning HDD only for cold/archive.  
4. Start naming **offload categories** so Ansible/inventory can tag mounts and playbooks.  
5. One-off inventory of physical drives on HVH-02 (Samsung 840 EVO 120GB + Plextor PX-256G7LeV units) for later inventory/Ansible wiring (request at end of slice).

---

## 2. Initial project surfaces brainstorming

Technical changes / surfaces suggested in this transcript slice (lite notes only — not an approved design lock).

### A. Immediate node relief (ops / one-off)
| Surface | Suggested address |
| --- | --- |
| `hom-lab-ctl-k3s-02` image/log bloat | `k3s crictl` image prune; `journalctl --vacuum-size=…` — temporary only |
| Stuck / old vLLM pods | Delete/evict cleanup so scheduler can retry after space returns |

### B. Capacity on the K3s VM
| Surface | Suggested address |
| --- | --- |
| Expand existing VHDX (root) | Grow Hyper-V VHDX (e.g. toward ≥200GB), then `growpart` + `resize2fs` in guest — prevents same pressure next model |
| Attach dedicated data disk | New VHDX (discussion: 200–500GB class) mounted for K3s storage / HF PVC — OS stays on smaller disk |
| Alternate: SMB HF cache from host | Mount cache from HVH-01 where weights already live — avoids copying 17GB into local PVC (interim path) |
| Revert lane | Keep working Qwen2.5-Coder-32B until storage layout lands |

### C. Physical disk layout on Hyper-V host (`HOM-LAB-HVH-02`)
| Surface | Suggested address |
| --- | --- |
| ~250GB-class SSD as primary K3s data | Best fit for model load I/O + local-path PVCs |
| Two ~120GB SSDs | Discussed as RAID 0 stripe (~240GB) for **reproducible** HF model cache only (re-download if stripe fails) |
| Spinning SATA (ex-USB enclosure) | Cold only: old models, backups, archives — not active vLLM/K8s paths |
| “Don’t mix” active tiers | Avoid SSD+HDD for the same hot workload; slow disk becomes the bottleneck |
| Smaller SSD offloads (if not RAID’d) | Move containerd image store, `/var/log`, `/tmp`, swap off root to free OS disk |

### D. Named offload categories (inventory / tags / playbooks)
Candidate group names from the session for metadata, tags, and role/playbook wiring:

| Category | Candidates to put there | Why |
| --- | --- | --- |
| `ephemeral_cache` | HF cache, containerd/Docker layers, pip/npm/apt caches, build caches | Large, high I/O, reproducible |
| `logs_and_metrics` | journal archives, pod logs, app logs, metrics stores | Grows over time, mostly sequential |
| `scratch_workspace` | `/tmp`, build/extract workspaces | High churn, temporary |
| `cold_artifacts` | old image tags, prior model versions, backup snapshots, fixtures | Infrequent access |
| `stateful_workloads` | non-DB PVCs, notebooks, uploads | Large; not always latency-critical |

Illustrative inventory shape discussed:

```yaml
storage_offload_mounts:
  - category: ephemeral_cache
    priority: high
    mount: /mnt/cache-ssd
    targets:
      - /var/lib/containerd
      - /var/cache/huggingface
  - category: logs_and_metrics
    priority: medium
    mount: /mnt/logs
    targets:
      - /var/log
```

### E. Repo / Ansible project surfaces to extend later
| Surface | Lite note from session |
| --- | --- |
| Inventory / host_vars for `hom-lab-ctl-k3s-02` | Record attached disks, mount points, categories |
| Inventory / facts for `HOM-LAB-HVH-02` | Serial/model/size for Samsung 840 EVO + Plextor PX-256G7LeV (probe requested at end of slice) |
| Roles/playbooks for storage offload | Drive by `storage_offload_*` categories/tags rather than one-off shell |
| K3s local-path / PVC placement | Point HF cache (and optionally containerd) at dedicated mounts |
| Plan packet under `docs/plans/` | This folder — capture findings so upgrade work is not only chat memory |

### F. Explicit non-goals from this slice
- Do **not** move Windows host pagefile/hibernation to secondary SSDs as the primary fix (performance/reliability sensitive).
- Do **not** treat cleanup (A) as the scalable solution.
- Mixing RAID/model-cache ideas with cold HDD for **active** paths was discouraged.

---

## Next (out of scope for this v0 draft)
- Formalize Option C vs RAID-0 cache vs root expand into one Apply/Verify/Undo packet.
- Wire drive probe results into inventory.
- Implement Ansible offload categories as real roles/tags.
