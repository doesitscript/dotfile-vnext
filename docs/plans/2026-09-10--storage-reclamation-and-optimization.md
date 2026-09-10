# Storage Reclamation and Optimization

**Status:** Executed (Phase 1 complete)  
**Date:** September 10, 2026  
**Target:** `hom-lab-ctl-k3s-02` VM and HVH-02 Hyper-V host

---

## Problem Statement

vLLM k3s-02 VM was at 84% disk usage (64G used / 77G total) with only 13GB free. Investigation revealed:

- **PVC overcommit:** `local-path` StorageClass doesn't enforce PVC size limits
- **Containerd bloat:** 33GB in container images (24GB overlayfs snapshots, 9.3GB blobs)
- **Build artifacts:** 31GB of VM provisioning artifacts left in per-VM directories
- **Shared cache underutilized:** Azure VHD cloud images not using the shared cache

---

## Immediate Actions Taken

### Phase 1: Build Artifact Cleanup (Executed Sep 10, 2026)

**Files moved to shared cache:**
- `ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz` (576 MB) → `F:\shares\public\hyperv-cache\ubuntu-cloud-images\`

**Build artifacts deleted:**
- `livecd.ubuntu-cpc.azure.vhd` (30.7 GB) - extracted source VHD
- `azure-offline-seed.sh` + `.signature` (3 KB) - cloud-init bootstrap scripts

**Space reclaimed:**
- k3s-02 VM directory: 118 GB → 96 GB (**22 GB freed on D: drive**)
- D: drive free space: 69 GB → 367 GB

**USB 3.0 shared cache verified:**
- Device: TOSHIBA External USB 3.0
- Capacity: 1,130 GB
- Free: 875 GB (77% free)
- Location: `F:\shares\public\hyperv-cache\`

---

## Role Updates

### `hyperv_ubuntu_vm` Enhancements

Added shared cache support for Azure VHD cloud images in `roles/hyperv_ubuntu_vm/tasks/present.yml`:

1. **Check shared cache before download**
   - Probe `{{ hyperv_ubuntu_vm_shared_cache_cloud_images }}\{{ hyperv_ubuntu_vm_cloud_image_filename }}`
   - Copy from shared cache to VM directory if available
   - Skip external download when cache hit

2. **Populate shared cache after download**
   - Copy newly downloaded archive to shared cache
   - Future VMs reuse the cached archive
   - Eliminates redundant downloads

**Benefits:**
- Faster VM provisioning (no re-download)
- Reduced bandwidth usage
- Automatic cleanup: artifacts moved to USB drive, not NVMe
- Consistent with existing ISO-based VM shared cache pattern

---

## Storage Architecture

### Current State

```
Hyper-V Host HOM-LAB-HVH-02:
├── D: (NVMe SSD - 367 GB free)
│   └── ProgramData\Ansible\hyperv_ubuntu_vm\
│       ├── hom-lab-ctl-k3s-02\
│       │   ├── hom-lab-ctl-k3s-02.vhdx (86 GB) ← Active OS disk
│       │   └── hom-lab-ctl-k3s-02-cidata.iso (1 MB) ← Cloud-init
│       └── hom-lab-ctl-dkr-02\
│           └── server-225-ubuntu.vhdx (36 GB) ← Active OS disk
│
└── F: (USB 3.0 - 875 GB free)
    └── shares\public\hyperv-cache\
        ├── ubuntu-cloud-images\
        │   └── ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz (576 MB)
        ├── remastered-isos\
        │   └── hom-lab-ctl-k3s-02-autoinstall.iso.upload (470 MB)
        └── ubuntu-isos\ (empty)

k3s-02 Guest (77G root filesystem, 13G free):
├── /var/lib/rancher/k3s/agent/containerd/ (33 GB)
│   ├── snapshots/ (24 GB overlayfs layers)
│   └── blobs/ (9.3 GB image content)
├── /var/lib/rancher/k3s/storage/ (19 GB)
│   └── vllm-primary-hf-cache PVC → HF model cache
└── /var/log/ (369 MB)
    └── journal/ (291 MB)
```

---

## Recommendations

### Priority 1: Containerd Image Cleanup

**Opportunity:** 33 GB in containerd (only 11 images, 8 pods running)

**Actions:**
1. Prune unused images: `sudo crictl rmi --prune`
   - Already ran: freed 2.3 MB (pause/busybox)
2. Clean exited containers: 9 exited containers found
3. Remove stale Langfuse/vLLM pod artifacts (4 failed pods)

**Expected reclaim:** 5-10 GB from unused image layers

### Priority 2: vLLM Model Cache Strategy

**Current:** 19 GB HF cache on NVMe (k3s-02 guest root filesystem)  
**Issue:** Model startup reads this at pod launch (~5 sec on NVMe, ~9 min on USB 3.0)

**Options:**
1. **Keep on NVMe** (current) - fast startup, limited growth headroom
2. **Second VHDX on USB 3.0** - large capacity, slower startup (acceptable per user)
3. **Network share** - slowest, over Wi-Fi currently (not recommended)

**Recommended:** Add second VHDX on HVH-02's local USB 3.0 drive
- Mount as `/mnt/model-cache` inside k3s-02 guest
- Update vLLM PVC to use this mount
- OS/containerd stay on NVMe
- Models tolerate USB 3.0 read speed at startup (36 MB/s write, caching helps reads)

### Priority 3: PVC Rightsizing

**Completed:** `k3s_comfyui_runtime_models_pvc_size: 200Gi → 60Gi` in defaults
**Status:** Live PVC remains 200Gi until deleted/recreated
**Action when needed:** `kubectl delete pvc comfyui-models -n comfyui-runtime` (currently absent, no data loss)

### Priority 4: Log Rotation

**Current:** 369 MB in `/var/log`, 291 MB journal
**Action:** Verify `systemd-journald` log retention (already managed by systemd)

---

## Containerd Image Analysis

### Images in use:
```
vllm/vllm-openai:latest                8.63 GB
docker.litellm.ai/berriai/litellm      386 MB
langfuse/langfuse-worker:3.174.1       330 MB
langfuse/langfuse:3.174.1              278 MB
nvidia-device-plugin                   199 MB
traefik                                56.6 MB
coredns                                22.4 MB
metrics-server                         22.5 MB
local-path-provisioner                 20.7 MB
```

**Total active:** ~10 GB  
**Overlayfs overhead:** 24 GB (deduplicated layers + snapshots)  
**Content blobs:** 9.3 GB

**Cleanup target:** Stale snapshots from failed pod restarts

---

## vLLM Pod Restart Investigation

**Observation:** vLLM pod restarted 4 times in 8 days
**Failed pods:**
- `vllm-primary-9bf9d94b4-4gk6l` - ContainerStatusUnknown
- `vllm-primary-9bf9d94b4-k2v7c` - UnexpectedAdmissionError
- `vllm-primary-9bf9d94b4-zjkms` - ContainerStatusUnknown
- `vllm-primary-9bf9d94b4-rgfgp` - Running (current)

**Likely causes:**
- Disk space pressure (resolved by this cleanup)
- GPU contention or memory exhaustion
- Node restarts (HVH-02 reboots?)

**Action:** Monitor after cleanup; investigate if restarts continue

---

## Validation

### Pre-cleanup State
- k3s-02 VM directory: 118 GB
- D: drive free: 69 GB
- Shared cache cloud-images: 0 MB

### Post-cleanup State
- k3s-02 VM directory: 96 GB (**22 GB freed**)
- D: drive free: 367 GB (**298 GB freed** - may include other cleanup)
- Shared cache cloud-images: 576 MB

### Next Verification
- Run `hyperv_ubuntu_vm` provisioning on a new VM
- Verify shared cache is used (no re-download)
- Confirm artifacts stay on F: drive

---

## Ansible Playbook Execution

**Cleanup script:** `/tmp/verify_and_move_cache.ps1`  
**Execution:** `run_remote_command.py --host HOM-LAB-HVH-02 --shell powershell --stdin-file`  
**Result:** Clean success, all artifacts moved/deleted

**Role changes committed:**
- `roles/hyperv_ubuntu_vm/tasks/present.yml` (shared cache integration)
- Follows existing pattern from `present_server_iso.yml`

---

## Future Opportunities

1. **Extend cleanup to other VMs:**
   - `hom-lab-ctl-dkr-02` likely has similar build artifacts
   - `server-225-ubuntu` (if still exists) check for unused ISOs

2. **Automate build artifact cleanup:**
   - Add post-provisioning cleanup task to `hyperv_ubuntu_vm` role
   - Delete source VHD/ISO after VHDX creation succeeds

3. **Containerd periodic cleanup:**
   - Add Ansible playbook: `playbooks/cleanup_k3s_images.yaml`
   - Schedule via cron or manual run

4. **Second VHDX for model cache:**
   - Plan and implement USB 3.0 VHDX mount for `/mnt/model-cache`
   - Update vLLM PVC to use host path mount

---

## Completion Status

- ✅ Phase 1: Build artifact cleanup and shared cache migration
- ✅ Role updates: `hyperv_ubuntu_vm` shared cache for cloud images
- ✅ Documentation: Storage architecture and recommendations
- ⏸️ Phase 2: Containerd image cleanup (pending user approval)
- ⏸️ Phase 3: Second VHDX for model cache (pending planning)
- ⏸️ Phase 4: Automated cleanup integration (future enhancement)

---

## References

- Original investigation: `docs/diagrams/cst-hom-lab-ctl-dia-vllmcache-*.md`
- Shared cache plan: `docs/intake/jupyter-devops-implementation-plans/00b-shared-hyperv-cache-infrastructure.md`
- Role: `roles/hyperv_ubuntu_vm/`
- Cleanup script: `/tmp/verify_and_move_cache.ps1` (executed on HVH-02)
