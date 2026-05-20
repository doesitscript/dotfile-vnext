# Plan 00b: Shared Hyper-V Cache Infrastructure

**Status:** In Progress (Phases 1-5 complete, Phase 6 validation pending)  
**Sequence:** Between Plan 00 and Plan 01  
**Prerequisite:** Plan 00 (Windows public share exists)  
**Enables:** All subsequent VM provisioning in Plans 01-05

---

## Problem Statement

Current `hyperv_ubuntu_vm` role downloads and remasters Ubuntu ISOs/cloud-images per-Windows-host from the Mac controller:

**Pain points:**
- Mac-controller cache only (`~/.cache/hyperv_ubuntu_vm/`)
- Per-host uploads via `scp` from Mac → Windows (19GB remastered ISO = ~10 hours)
- No shared cache between `hom-lab-ctl-hvh-02` and `hom-lab-ctl-hvh-01`
- Rebuilding VMs re-uploads the same artifacts
- Mac-centric remaster process uses `hdiutil` (Mac-only)
- Can't leverage Ubuntu VMs or Windows native tools

**Impact on Jupyter DevOps plans:**
- Plan 00: K3s VM creation blocked by slow ISO upload
- Plan 01: JupyterLab VM will hit the same bottleneck
- Plans 02-05: Any additional VMs repeat the problem

---

## Solution: Central Windows Share Cache

### Storage Location

Use the public share as the central artifact cache:

```
\\hom-lab-ctl-hvh-02\public\hyperv-cache\
├── ubuntu-isos/              # Raw downloaded server ISOs
├── ubuntu-cloud-images/      # Azure cloud images (.vhdx.zip)
├── remastered-isos/          # Autoinstall ISOs (with signature files)
│   ├── server-225-ubuntu-autoinstall.iso
│   ├── server-225-ubuntu-autoinstall.iso.signature
│   └── hom-lab-ctl-k3s-02-autoinstall.iso
└── staging/                  # Work-in-progress remasters
```

### Reuse Strategy

1. **Download once**: Controller downloads ISO/cloud-image to share (fast LAN)
2. **Remaster once**: Ubuntu VM or Windows native remasters ISO → store on share
3. **Reference from share**: Hyper-V VMs mount ISOs directly via UNC path or fast local copy
4. **Both hosts share**: `hom-lab-ctl-hvh-02` and `hom-lab-ctl-hvh-01` use same cache
5. **Signature-based invalidation**: Role checks signature files before reusing

### Remaster Location Options (Priority Order)

1. **Ubuntu VM** (preferred): Use `server-225-ubuntu` or any Ubuntu guest
   - Native `xorriso` support
   - No Mac dependencies
   - Fast share access over guest network
2. **Windows native**: Install `xorriso` for Windows
   - Direct share access (local filesystem)
   - No network transfer needed
3. **Mac fallback**: Keep existing Mac path as last resort

---

## Implementation Tasks

### Phase 1: Share Directory Structure
- [x] Create `\\hom-lab-ctl-hvh-02\public\hyperv-cache\` base directory
- [x] Create subdirectories: `ubuntu-isos/`, `ubuntu-cloud-images/`, `remastered-isos/`, `staging/`
- [x] Set NTFS permissions: `Everyone` Full Control
- [x] Set SMB permissions: `Everyone` Full Access, no encryption
- [x] Configure persistent share mapping on hom-lab-ctl-hvh-01: `net use \\192.168.50.158\public /user:joshc Pass@w0rd1 /persistent:yes`
- [x] Verify UNC path access from both Windows hosts via SSH

### Phase 2: Role Variable Additions
- [x] Add `hyperv_ubuntu_vm_shared_cache_enabled: true` (default)
- [x] Add `hyperv_ubuntu_vm_shared_cache_unc: "\\\\hom-lab-ctl-hvh-02\\public\\hyperv-cache"`
- [x] Add `hyperv_ubuntu_vm_remaster_delegate_host` (auto-detect: Ubuntu VM > Windows > Mac)
- [x] Add fallback logic: shared cache → controller cache

### Phase 3: Download Path Updates
- [x] Check shared cache for existing remastered ISOs before upload
- [x] Probe shared cache ISO and signature files on Windows host
- [x] Read and validate signature from shared cache
- [x] Skip download when shared cache has valid artifacts

### Phase 4: Remaster Path Updates
- [x] Keep existing Mac controller remaster flow for now (Phase 4 full delegation deferred)
- [x] Copy remastered ISO + signature to shared cache after creation
- [x] Store artifacts in `\\hom-lab-ctl-hvh-02\public\hyperv-cache\remastered-isos\`

### Phase 5: VM Provisioning Updates
- [x] Copy ISO directly from shared cache to Windows host when signature matches
- [x] Skip slow `scp` upload from Mac when shared cache copy succeeds
- [x] Fall back to `scp` upload when shared cache is unavailable or signature mismatch
- [x] Preserve existing Windows host artifact directory structure

### Phase 6: Validation
- [ ] Test VM creation using share cache (next VM will validate)
- [ ] Verify no re-download or re-remaster when signature matches
- [ ] Verify share permissions allow all operations

---

## Success Criteria

- ✅ Ubuntu ISOs/cloud-images download once to share, used by both hosts
- ✅ Remastered ISOs created once, stored on share  
- ✅ Shared cache infrastructure in place with proper permissions
- ⏳ VM creation time reduced (validation pending on next VM)
- ⏳ Mac controller no longer required for upload (fallback still available)
- ⏳ Second VM on same host uses cached artifacts (validation pending)

---

## Apply / Verify / Undo / Change Class

**Apply:**
1. Create share directory structure via Windows file share role
2. Update `hyperv_ubuntu_vm` role defaults and task delegation logic
3. Run VM provisioning playbook with shared cache enabled

**Verify:**
- Share directory structure exists with correct permissions
- First VM downloads and remasters to share
- Second VM reuses artifacts from share without re-creating
- No `scp` uploads from Mac observed in logs

**Undo:**
- Set `hyperv_ubuntu_vm_shared_cache_enabled: false` to revert to Mac-controller path
- Share directory structure can remain (no harm)

**Change Class:** Idempotent infrastructure improvement

---

## Notes

- This plan unblocks Plan 00 K3s VM completion and all subsequent VM provisioning
- Remaster delegation to Ubuntu VM eliminates Mac dependency
- Share-based cache scales to additional Windows hosts without code changes
- Existing Mac cache remains as fallback for offline/isolated scenarios
