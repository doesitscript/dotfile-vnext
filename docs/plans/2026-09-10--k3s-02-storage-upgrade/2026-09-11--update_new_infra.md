# Storage upgrade — infrastructure update

**Date:** 2026-09-11

Implementation is complete and documented in this plan folder.

- Separate 300 GiB cache and 32 GiB logs VHDXs are mounted on the K3s guest.
- Containerd and the vLLM/HF cache use the cache filesystem; native pod logs
  use `/mnt/k3s-logs/pods`.
- The three SSDs were wiped and formatted as separate NTFS host volumes:
  `LOGS-HOST`, `HOT-DATA-HOST`, and `COLD-DATA-HOST`.
- Stale vLLM ReplicaSets and old root-backed cache data were removed. Root is
  now 21% used; K3s is Ready with `DiskPressure=False`; vLLM is Ready.
- No RAID0, pagefile relocation, hibernation relocation, or Prometheus-on-cache
  change was made.

Detailed evidence: [implementation-receipt.md](./implementation-receipt.md).
Implementation entrypoints: `playbooks/deploy_k3s_data_disk.yaml`,
`playbooks/configure_k3s_pod_logs_dir.yaml`,
`playbooks/repurpose_hyperv_physical_ssds.yaml`, and
`playbooks/cleanup_vllm_stale_replicasets.yaml`.
