# Draft plan v1 (researched) — k3s-02 storage upgrade / offload

**Status:** researched implementable draft (v1) — intended to drive project work  
**Supersedes for recommendations:** [draft-plan-v0.md](./draft-plan-v0.md) §2 brainstorm (problem context in v0 §1 still stands)  
**Source slice:** transcript ≈2164–2437  
`…/multi-agent-onsite-expert/transcripts/role-onsite-export-transcript-from-cursor_4_vllm_model_storage_capacity--initial-discussion.md`  
**Related:** [README.md](./README.md)

---

## 0. How this relates to v0

| v0 (brainstorm) | v1 (researched) |
| --- | --- |
| Disk pressure while deploying AWQ on `hom-lab-ctl-k3s-02` | Unchanged — still the motivating incident ([v0 §1](./draft-plan-v0.md)) |
| Categories `ephemeral_cache` … `stateful_workloads` as tags | **Keep names**; add required **`durability`** axis before building |
| Flat `targets:` + `disk: /dev/sdb` example | **Reject as-is** — use `LABEL=`/`UUID=`; per-target **mechanism** field |
| RAID0 two “120GB” SSDs for HF cache | Corrected hardware: **two Plextor ~256GB** → ~480GB RAID0 *or* separate; Samsung 120GB for single-purpose offload |
| Pagefile/hiber offload as host relief | Confirmed **non-goal** / trap (pagefile move breaks dumps; `hiberfil.sys` not relocatable) |
| “Implement Ansible offload later” | Concrete owners already exist — **improve and commission them** (below) |

v0 remains the incident narrative. **Do not implement from v0 §2 alone** — implement from this v1 + HRL packs.

---

## 1. Verified host facts (replace v0 guesses)

Probed on `HOM-LAB-HVH-02` (all healthy, uninitialized / blank):

| Model | Serial | Approx size | Notes |
| --- | --- | --- | --- |
| Samsung SSD 840 EVO 120GB | `S1D5NSBF438394N` | ~112 GB | Single-purpose offload candidate |
| PLEXTOR PX-256G7LeV #1 | `002516159857` | ~238 GB | Was misremembered as 120GB |
| PLEXTOR PX-256G7LeV #2 | `002516159306` | ~238 GB | Pair for RAID0 **cache** or separate durable-ish roles |

**Strategy shift vs v0:** Prefer RAID0 of the **two Plextors (~480GB)** for reproducible model/image cache, **or** use them separately; Samsung 120GB for a narrow offload (e.g. logs/scratch), not as the main K3s data plane.

---

## 2. Updated recommendations (authoritative for implementation)

### 2.1 Taxonomy — adopt with three mandatory fixes

Keep the five category names from v0 (`ephemeral_cache`, `logs_and_metrics`, `scratch_workspace`, `cold_artifacts`, `stateful_workloads`).

1. **Add `durability: reproducible | reproducible_expensive | durable`** on every offload mount/target. Load-bearing placement assert — not a comment.  
   - `logs_and_metrics` **splits**: pod logs = reproducible; Prometheus TSDB = **durable** (never same cheap RAID0 disk).  
   - `stateful_workloads` (local-path PVCs, notebooks) = **durable** — not an “offload next to cache” peer of `ephemeral_cache`.
2. **Never pin `disk: /dev/sdX` in inventory** for attach/mount automation. Use `LABEL=` / `UUID=` (SATA order changes when Hyper-V attaches disks).
3. **Replace flat `targets:` lists** with per-target rows that name the **mechanism**:
   - native config key (must *not* bind-mount), or
   - bind mount / fstab, or
   - **not relocatable → cleanup/retention list**, not offload.

Authority: HRL `implementation-guides/storage/storage-offload-taxonomy.md`.

### 2.2 Primary technical fix for disk pressure (K3s)

| Recommendation | Why |
| --- | --- |
| **Split `imagefs` from `nodefs`** | Supported / auto-detected when container image store is on another filesystem. Shared FS today means non-image growth trips image GC and deletes the vLLM image without freeing the real full path. |
| Relocate containerd via **bind mount** at `/var/lib/rancher/k3s/agent/containerd` | K3s has **no flag** to move containerd root independently (derived from `--data-dir`). |
| Probe first | `du -xh --max-depth=2 /var \| sort -h` on the node before committing — if containerd dominates, OS offloads alone are not the fix. |

Traps (must encode in roles / docs):

- Partial `evictionHard` override **zeroes** unspecified signals unless `mergeDefaultEvictionSettings: true`.
- Moving pod logs off `/var` can stop kubelet tracking that FS’s usage.
- Ephemeral-storage accounting does **not** follow the imagefs split.
- Windows: moving pagefile off `C:` breaks dumps unless `CrashControl\DedicatedDumpFile` is set; **`hiberfil.sys` cannot be relocated**.

### 2.3 Suggested physical layout (implementable default)

| Disks | Role | Durability |
| --- | --- | --- |
| Two Plextor PX-256G7LeV | RAID0 (or dedicated VHDX-backed guest disks) for **ephemeral_cache** (HF + containerd image store) | `reproducible` / `reproducible_expensive` |
| Samsung 840 EVO 120GB | Narrow offload (`logs_and_metrics` **pod logs only**, or `scratch_workspace`) — **not** Prometheus TSDB | matching class |
| Spinning HDD (if still in scope) | `cold_artifacts` only | cold |
| Existing ~77GB OS VHDX | OS + K3s control paths; avoid growing HF PVC onto it | keep thin |

Interim options from v0 still allowed until layout lands: SMB HF cache from host; temporary root expand; keep Qwen2.5-Coder-32B lane.

### 2.4 Inventory shape to implement (corrected)

```yaml
# host_vars/HOM-LAB-HVH-02.yaml (physical truth)
physical_disks:
  - serial: S1D5NSBF438394N
    model: Samsung SSD 840 EVO 120GB
    size_gb: 120
    type: ssd
    purpose: scratch_or_logs_offload
  - serial: "002516159857"
    model: PLEXTOR PX-256G7LeV
    size_gb: 256
    type: ssd
    purpose: k3s-ephemeral-cache-member
  - serial: "002516159306"
    model: PLEXTOR PX-256G7LeV
    size_gb: 256
    type: ssd
    purpose: k3s-ephemeral-cache-member

# host_vars/hom-lab-ctl-k3s-02.yaml (guest mounts — LABEL/UUID, not /dev/sdX)
storage_offload_mounts:
  - category: ephemeral_cache
    durability: reproducible_expensive
    mount: /mnt/k3s-cache
    filesystem: ext4
    device_by: LABEL=k3s-cache   # or UUID=
    targets:
      - path: /var/lib/rancher/k3s/agent/containerd
        mechanism: bind_mount
      - path: huggingface_cache   # via env / PVC nodePath — see vLLM/HF packs
        mechanism: native_config
  - category: logs_and_metrics
    durability: reproducible      # pod logs only on this mount
    mount: /mnt/k3s-logs
    device_by: LABEL=k3s-logs
    targets:
      - path: /var/log/pods
        mechanism: native_or_bind  # per kubelet pack
# Prometheus TSDB: separate durable mount or leave on primary — never RAID0 cache disk
```

Module palette (from disk-management research): `community.general.parted`, `community.general.filesystem`, `ansible.posix.mount`, `community.general.mdadm` (RAID0), `community.general.lvg`/`lvol` if LVM chosen; Windows attach via existing Hyper-V / `community.windows` disk surfaces.

---

## 3. Research artifacts to use while implementing

| Artifact | Use for |
| --- | --- |
| `homelab-reference-library/implementation-guides/storage/storage-offload-taxonomy.md` | Two-axis model, inventory pattern, placement asserts |
| `generated/context7/ansible/disk-management-inventory/` | Inventory modeling, parted/filesystem/mount/mdadm playbooks |
| `generated/context7/k3s/storage-offload-targets/` | containerd root/state, `--data-dir`, Docker `data-root`, overlayfs gates |
| `generated/context7/kubernetes/kubelet-storage-offload/` | `--root-dir`, `podLogsDir`, separate-imagefs, local-path `nodePathMap` |
| `generated/context7/systemd/os-directory-offload/` | journald, `/tmp`, apt cache, swap, coredumps; symlink traps |
| `generated/context7/windows-server/storage-offload-targets/` | pagefile/dumps/Hyper-V VHDX — host side |
| `generated/context7/vllm/cache-and-artifact-offload/` | `VLLM_CACHE_ROOT`, HF env precedence, pip/uv/npm |
| `generated/context7/prometheus/tsdb-storage-and-retention/` | Why TSDB ≠ pod-log durability |

**Known library debt (do not ignore):** `hyper-v` catalog entry flagged `registration_incomplete` (empty vendor/guide). Populate or narrow when Hyper-V attach automation is built. HF CLI surface is `hf cache …` (not dead `huggingface-cli`). containerd 2.x template is `config-v3.toml.tmpl`, not `config.toml.tmpl`.

---

## 4. Project surfaces to improve (implementation checklist)

Existing repo owners — extend; do not invent parallel one-offs.

### 4.1 Inventory / facts
- [ ] Record the three `physical_disks` (serial/model/size/purpose) on `inventory/host_vars/HOM-LAB-HVH-02.yaml` (or equivalent NetBox-aligned facts).
- [ ] Extend `hom-lab-ctl-k3s-02` host_vars beyond today’s `k3s_storage_offload_*` with **category + durability + device_by + mechanism** schema from §2.4.
- [ ] Remove / avoid any `/dev/sdX`-only targeting in new vars.

### 4.2 Ansible roles / playbooks
- [ ] **`roles/k3s_storage_offload`** — already bind-mounts containerd + local-path destinations under `/mnt/k3s-cache`; align with taxonomy (durability asserts, LABEL mounts, imagefs/nodefs split verification, evictionHard merge trap docs in README).
- [ ] **`roles/hyperv_storage_layout`** — fill README + tasks to attach/partition host SSDs → guest disks using serial identity (today README empty).
- [ ] **`roles/k3s_storage_prep`** — ensure prep path creates LABEL’d filesystems before offload apply.
- [ ] **`roles/storage_capacity_monitor`** — keep pressure visibility; do not treat as capacity fix.
- [ ] Playbook tags: `ephemeral_cache`, `logs_and_metrics`, … as selective run tags matching category names.
- [ ] Gate live mutate with existing `*_state: present|absent` and `*_apply` / preview patterns (`k3s_storage_offload_apply` is currently `false` on k3s-02 — correct until disks exist).

### 4.3 Runtime / model paths
- [ ] Point HF / vLLM cache at ephemeral_cache mount (env or PVC `nodePathMap`) — see vLLM pack.
- [ ] Keep durable PVC / stateful data **off** RAID0 cache disks.
- [ ] Do not relocate Windows pagefile/hiber as the host “free space” strategy.

### 4.4 Docs / plan closeout
- [ ] Update [README.md](./README.md) to point at this v1 as the implementable authority; keep v0 as incident brainstorm.
- [ ] After apply: verify imagefs ≠ nodefs (`df` on containerd mount vs `/`), node not disk-pressure, vLLM pod schedules without eviction.

---

## 5. Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | Document disks in inventory → Hyper-V attach / guest disk present → LABEL filesystem → `k3s_storage_offload` present with apply true for containerd (+ optional cache mounts) → retarget HF/vLLM paths |
| **Verify** | `du` probe; `df -hT` shows split filesystems; kubelet no disk-pressure; `crictl`/`kubectl` pod Ready; monitor role healthy |
| **Undo** | Role `absent` / restore containerd backup path; detach guest disks only after data migrated; inventory purposes reverted |
| **Change class** | Mix of **idempotent config** (mounts, role state) and **bootstrap** (first-time partition/RAID/attach) — treat attach/RAID as bootstrap, mounts/offload as idempotent |

---

## 6. Explicit non-goals (carried + strengthened from v0)

- Cleanup-only (`crictl` / journal vacuum) as the long-term fix.
- Putting Prometheus TSDB or unique PVCs on RAID0 / “cheap SSD cache.”
- Using `/dev/sdX` as durable identity.
- Moving Windows pagefile / hibernation to free C: as primary relief.
- Cold-starting broad re-research instead of using the packs in §3.

---

## 7. Suggested implementation order

1. Inventory facts for the three host SSDs (no host mutate).  
2. Hyper-V layout role: attach → guest sees disks.  
3. Prep: partition/format/LABEL (RAID0 Plextors only if durability=`reproducible*`).  
4. Enable `k3s_storage_offload` apply for containerd bind (imagefs split).  
5. Wire HF/vLLM cache to same or sibling ephemeral mount.  
6. Optional: Samsung for logs/scratch with durability asserts.  
7. Verify AWQ / model lane no longer evicts on load.
