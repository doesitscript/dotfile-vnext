# Physical SSD wiring and cold-artifact migration

**Date:** 2026-09-16
**Status:** applied and live-verified

## Applied layout

- The existing 300 GiB cache VHDX was moved from host `D:` to
  `G:\HOT-DATA-HOST\k3s-02-cache.vhdx` without changing its guest identity.
- Hyper-V still presents that disk at SCSI `0:2`; the guest keeps serial
  `60022480737317e55fd3cd8e3fafbe4a`, label `k3s-cache`, and mount
  `/mnt/k3s-cache`.
- A new 200 GiB dynamic cold-artifacts VHDX was created at
  `H:\COLD-DATA-HOST\k3s-02-cold-artifacts.vhdx` and attached at SCSI `0:4`.
- The guest disk serial is `600224809dde1833df85e1e26e53dfa3`; it was
  partitioned, formatted `ext4` with label `k3s-cold`, and mounted at
  `/mnt/k3s-cold`.

## Data migration

The inactive `models--nvidia--Qwen3.6-35B-A3B-NVFP4` Hugging Face tree was
copied from `/mnt/k3s-cache/hf/hub` to
`/mnt/k3s-cold/models/huggingface`, verified with an rsync dry run reporting no
differences, and then removed from the cache. The active Qwen3-Coder model and
containerd remain on `/mnt/k3s-cache`.

## Live verification

- Host `G:`: 53% used after the cache VHDX relocation.
- Host `H:`: 10% used after the cold VHDX creation.
- Guest `/mnt/k3s-cache`: 23% used, 216 GiB available.
- Guest `/mnt/k3s-cold`: 12% used, 164 GiB available.
- Guest `/mnt/k3s-logs`: 1% used.
- `k3s.service`: active; node `hom-lab-ctl-k3s-02`: `Ready`.
- Containerd remains bind-mounted from `/mnt/k3s-cache/containerd`.

## Owning playbooks

- `playbooks/move_k3s_selected_vhdx_storage.yaml`
- `playbooks/attach_k3s_cold_artifacts_disk.yaml`
- `playbooks/mount_k3s_cold_artifacts.yaml`
- `playbooks/migrate_k3s_cold_artifacts.yaml`
