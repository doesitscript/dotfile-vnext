---
title: "HVH-01 windows_artifact_cache reclaim apply — rebuild bases to F: public"
status: verified
authority: internal
recorded_at: "2026-09-23"
host: HOM-LAB-HVH-01
---

# HVH-01 reclaim receipt (implementer)

## Constraints honored

- No `hyperv_ubuntu_*` lifecycle `present` / no VM rebuild
- Profiles: default `hyperv_ubuntu_rebuild_bases` + `windows_pinned_installers` only
- GPU-P zip reclaim remains **opt-in** (not used this run)
- Live guest `.vhdx` / `.VMRS` not touched

## Contract fixes (repo)

- Reclaim defaults: dropped `hyperv_gpu_p_payload` from default profiles
- README / playbook header: GPU-P zip reclaim ≠ GPU-P share publish path
- Pinned discover also scans `ProgramData\Ansible\downloads\`
- Remaster reclaim accepts legacy-dirname `{vm}-autoinstall.*` under `hyperv_ubuntu_vm\`

## Cold target choice

| Option | Result |
| --- | --- |
| A) `\\HOM-LAB-HVH-02\public\hyperv-cache` | **Failed** — HVH-01 Access Denied on UNC |
| B) `G:\` (TOSHIBA EXT) | **Not used** — requires operator approval |
| Local public share | **Used** — `F:\shares\public\hyperv-cache` (= `\\HOM-LAB-HVH-01\public\hyperv-cache`) |

Inventory: `inventory/host_vars/hom-lab-hvh-01.yaml` sets
`hyperv_ubuntu_vm_cold_data_root` + host-local `hyperv_ubuntu_vm_shared_cache_unc`.

## Preview → apply

- Preview count: **9** candidates, **96.25 GB** listed (hot sum; shared cold object for identical Azure VHD/archive)
- Apply: **9 changed**, `failed=0`
- Post-preview: **0** candidates

### Items moved (hot removed → cold)

| Class | Hot (removed) | Size | Cold |
| --- | --- | ---: | --- |
| cloud_source_vhd | `…\hom-lab-ctl-k3s-01\livecd.ubuntu-cpc.azure.vhd` | 30 GB | `F:\shares\public\hyperv-cache\ubuntu-cloud-images\livecd.ubuntu-cpc.azure.vhd` |
| cloud_source_vhd | `…\nsrv-dkr-01\livecd.ubuntu-cpc.azure.vhd` | 30 GB | same cold object (dedupe) |
| cloud_source_vhd | `…\nsrv-k3s-01\livecd.ubuntu-cpc.azure.vhd` | 30 GB | same cold object (dedupe) |
| cloud_image_archive | `…\hom-lab-ctl-k3s-01\ubuntu-24.04-…azure.vhd.tar.gz` | 0.56 GB | `…\ubuntu-cloud-images\ubuntu-24.04-…azure.vhd.tar.gz` |
| cloud_image_archive | `…\nsrv-dkr-01\…tar.gz` | 0.56 GB | same cold object (dedupe) |
| cloud_image_archive | `…\nsrv-k3s-01\…tar.gz` | 0.56 GB | same cold object (dedupe) |
| remastered_iso | `…\nsrv-dkr-01\nsrv-dkr-01-autoinstall.iso` | 3.17 GB | `…\remastered-isos\nsrv-dkr-01-autoinstall.iso` |
| remastered_signature | `…\nsrv-dkr-01\nsrv-dkr-01-autoinstall.signature` | ~0 | `…\remastered-isos\nsrv-dkr-01-autoinstall.signature` |
| pinned_installer | `C:\ProgramData\Ansible\downloads\ollama\ollama-windows-amd64.zip` | 1.4 GB | `…\pinned-installers\ollama-windows-amd64.zip` |

Hot disk freed ≈ sum of removed hot files (~96 GB listed); unique cold bytes ≈ ~35 GB (one VHD + one archive + remaster + ollama zip).

## HVH-02 server-225-ubuntu cleanup — **blocked**

Not an unused orphan. Live VM **`hom-lab-ctl-dkr-02` (Running)** still uses:

`C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\vm\server-225-ubuntu`

as ConfigurationLocation. Delete aborted (file lock). Needs a deliberate
VM config-path migrate (not reclaim; not done this turn).

## Evidence paths

- `/tmp/hvh01_reclaim_preview_f.txt`
- `/tmp/hvh01_reclaim_apply_f.txt`
- `/tmp/hvh01_reclaim_verify.txt`
- `/tmp/server225_probe.out` / `/tmp/probe_server225_lock.yml` output
