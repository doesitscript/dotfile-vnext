# Draft plan v1 (researched) — k3s-02 storage upgrade / offload

**Status:** revised implementation plan (v1.1) — reconciled with `draft-plan-v1-researched-suggestions.md`; storage, runtime cache, monitoring, native pod logs, and physical-SSD repurpose are applied and re-verified
**Supersedes for recommendations:** [draft-plan-v0.md](./draft-plan-v0.md) §2 brainstorm (problem context in v0 §1 still stands)  
**Source slice:** transcript ≈2164–2437  
`…/multi-agent-onsite-expert/transcripts/role-onsite-export-transcript-from-cursor_4_vllm_model_storage_capacity--initial-discussion.md`  
**Related:** [README.md](./README.md)
**Latest implementation update:** [post_2026-09-11.md](./post_2026-09-11.md)

---

## 0. How this relates to v0

| v0 (brainstorm) | v1 (researched) |
| --- | --- |
| Disk pressure while deploying AWQ on `hom-lab-ctl-k3s-02` | Unchanged — still the motivating incident ([v0 §1](./draft-plan-v0.md)) |
| Categories `ephemeral_cache` … `stateful_workloads` as tags | **Keep names**; add required **`durability`** axis before building |
| Flat `targets:` + `disk: /dev/sdb` example | **Reject as-is** — use `LABEL=`/`UUID=`; per-target **mechanism** field |
| RAID0 two “120GB” SSDs for HF cache | **Rejected**. No RAID0; use separate storage devices/VHDX-backed guest disks. The three SSDs may be wiped and repurposed under U-03, but each remains a separate filesystem and workload boundary. |
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
| PLEXTOR PX-256G7LeV #2 | `002516159306` | ~238 GB | User-authorized for wipe and repurpose as a separate cold/durable storage boundary |

**Strategy shift vs v0:** RAID0 is prohibited. The immediate implementation uses separate dynamic VHDX-backed guest disks on host `D:`: a 300 GiB cache disk and a 32 GiB logs/scratch disk. The three SSDs are now authorized for repurposing, including wiping observed contents, but direct pass-through or host-volume reformat remains a separate Ansible-owned capability until its module/safety contract is recorded.

---

## 2. Updated recommendations (authoritative for implementation)

### 2.1 Taxonomy — adopt with three mandatory fixes

Keep the five category names from v0 (`ephemeral_cache`, `logs_and_metrics`, `scratch_workspace`, `cold_artifacts`, `stateful_workloads`).

1. **Add `durability: reproducible | reproducible_expensive | durable`** on every offload mount/target. Load-bearing placement assert — not a comment.  
   - `logs_and_metrics` **splits**: pod logs = reproducible; Prometheus TSDB = **durable** (never same ephemeral cache disk).
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
| Dedicated dynamic VHDX on host `D:` (300 GiB) | **ephemeral_cache**: HF cache, containerd image store, and new local-path cache backing | `reproducible_expensive` |
| Dedicated dynamic VHDX on host `D:` (32 GiB) | **logs_and_metrics** pod-log-adjacent scratch only, or `scratch_workspace`; not Prometheus TSDB | `reproducible` |
| Samsung 840 EVO 120GB | Observed `F:` volume at 100%; user-authorized for wipe and repurpose as logs/scratch backing | reproducible |
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
    purpose: available_for_repurposing_logs_or_scratch
  - serial: "002516159857"
    model: PLEXTOR PX-256G7LeV
    size_gb: 256
    type: ssd
    purpose: available_for_repurposing_active_cache
  - serial: "002516159306"
    model: PLEXTOR PX-256G7LeV
    size_gb: 256
    type: ssd
    purpose: available_for_repurposing_cold_or_durable_storage

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
      - path: /mnt/k3s-logs/pods
        mechanism: native_config   # kubelet podLogsDir; do not invent a bind
# Prometheus TSDB: separate durable mount or leave on primary — never the ephemeral cache disk
```

Module palette (from disk-management research): `ansible.windows.win_powershell` for structured Hyper-V VHDX attach, `community.general.parted`, `community.general.filesystem`, and `ansible.posix.mount`. RAID/LVM is out of scope for this implementation.

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
- [x] Record the three `physical_disks` (serial/model/size/current occupancy/purpose) on `inventory/host_vars/hom-lab-hvh-02.yaml` (or equivalent NetBox-aligned facts); any wipe must be gated by exact serial verification and the U-03 authority.
- [x] Extend `hom-lab-ctl-k3s-02` host_vars beyond today’s `k3s_storage_offload_*` with **category + durability + device_by + mechanism** schema from §2.4.
- [x] Remove / avoid any `/dev/sdX`-only targeting in new vars.
- [x] Use gathered disk/mount facts where available; retain documented `findmnt` probes where the live mount source and filesystem root are the authoritative runtime check.

### 4.2 Ansible roles / playbooks
- [x] **`roles/k3s_storage_offload`** — bind-mounts containerd + local-path destinations under `/mnt/k3s-cache`, asserts the split, retains rollback, and documents the eviction accounting boundary.
- [x] **`roles/hyperv_vm_data_disk`** — uses separate dynamic VHDX files on host `D:` for the current recovery path; no RAID. Physical SSD repurpose is owned by the separate serial-bound workflow.
- [x] Extend **`roles/linux_data_disk_mount`** as the prep path: select/verify with by-id + serial, format with labels (`k3s-cache`, `k3s-logs`), then persist mounts with `LABEL=`.
- [x] **`roles/storage_capacity_monitor`** — keeps pressure visibility; it is not treated as the capacity fix.
- [x] Playbooks expose selective storage, logging, vLLM, physical-SSD, and cleanup tags; live mutation remains behind explicit state/apply gates.
- [x] Evaluate the current structured `ansible.windows.win_powershell` owner for physical SSD wipe/format; retain it because `gocallag.hyperv.vm_disk` covers VHDX attachment rather than physical-disk repurpose.

### 4.3 Runtime / model paths
- [x] Point HF / vLLM cache at ephemeral_cache mount (env and PVC `nodePathMap`) — see vLLM pack.
- [x] Keep the retained source PVC/stateful object separate from the ephemeral cache path; vLLM now uses the verified cache hostPath.
- [x] Do not relocate Windows pagefile/hiber as the host “free space” strategy.
- [x] Configure pod logs through native K3s `KubeletConfiguration.podLogsDir` at `/mnt/k3s-logs/pods`; document that this can change kubelet disk-pressure accounting.
- [x] Commission HF through the existing `k3s_vllm_runtime` native environment contract; do not add a second bind-based HF offload.

### 4.4 Docs / plan closeout
- [x] Update [README.md](./README.md) to point at this v1 as the implementable authority; keep v0 as incident brainstorm.
- [x] After apply: verify imagefs ≠ nodefs (`df` on containerd mount vs `/`), node not disk-pressure, vLLM pod is Ready, and monitor role is healthy.

---

## 5. Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | Document disks in inventory → Hyper-V attach / guest disk present → LABEL filesystem → `k3s_storage_offload` present with apply true for containerd (+ optional cache mounts) → retarget HF/vLLM paths |
| **Verify** | `du` probe; `df -hT` shows split filesystems; kubelet no disk-pressure; `crictl`/`kubectl` pod Ready; monitor role healthy |
| **Undo** | Role `absent` / restore containerd backup path; detach guest disks only after data migrated; inventory purposes reverted |
| **Change class** | Mix of **idempotent config** (mounts, role state) and **bootstrap** (first-time VHDX attach/partition/format) — treat attach/partition/format as bootstrap and mounts/offload as idempotent |

---

## 6. Explicit non-goals (carried + strengthened from v0)

- Cleanup-only (`crictl` / journal vacuum) as the long-term fix.
- Putting Prometheus TSDB or unique PVCs on the ephemeral cache disk.
- Using `/dev/sdX` as durable identity.
- Moving Windows pagefile / hibernation to free C: as primary relief.
- Cold-starting broad re-research instead of using the packs in §3.

---

## 7. Revised implementation order

1. **Reconcile and recover:** preserve prior apply evidence, restore K3s service availability through the repo playbook, and stop if containerd source/destination state is ambiguous. This recovery checkpoint is now complete: K3s is active and containerd is bound from the cache disk.
2. **Inventory and module fit:** record the three exact SSD serials and the user-authorized wipe disposition; retain the structured VHDX role for VHDX attachment and the dedicated serial-bound PowerShell owner for physical SSD repurpose.
3. **Bootstrap separate VHDXs:** attach the 300 GiB cache and 32 GiB logs/scratch VHDXs; verify by-id + serial; partition and format each once with labels `k3s-cache` and `k3s-logs`.
4. **Make mounts durable:** use `LABEL=k3s-cache` and `LABEL=k3s-logs` for steady-state mounts; retain by-id only for safe partition/format selection and assert gathered facts.
5. **Cut over containerd:** perform one explicit bounded rsync behind the apply gate, persist the bind with `ansible.posix.mount`, retain rollback, then verify imagefs source differs from nodefs and K3s is healthy.
6. **Commission native runtime paths:** migrate HF through `k3s_vllm_runtime`; configure pod logs with native `podLogsDir` under `/mnt/k3s-logs/pods`; do not bind `/var/log/pods` by invention. Complete.
7. **Monitor and verify workload:** run capacity monitoring against root/cache/logs, verify DiskPressure clears, and verify vLLM/AWQ scheduling and readiness.
8. **Close out:** update README, receipt, obligation inventory, undo path, and the no-RAID decision. Completed after the separately verified serial-bound SSD wipe/repartition.

## On Deck — user decisions to integrate

| ID | User decision / direction | Target integration | Status |
|----|---------------------------|---------------------|--------|
| U-01 | No RAID0 anywhere in this implementation | Separate VHDX inventory, playbook, and all plan references | Integrated |
| U-02 | Implement the optional logs/scratch slice | Separate 32 GiB VHDX and `/mnt/k3s-logs`; current VHDX path remains the safe immediate implementation | Integrated |
| U-03 | The three newly added SSDs are free for this project; their observed contents may be wiped and repurposed as needed | Exact-serial Ansible-owned host SSD repurpose completed; each remains a separate NTFS volume | Integrated |
