# K3s-02 Storage Upgrade — status summary

**Date:** 2026-09-11
**Snapshot label:** `partial_pre_09-07`

This historical summary is superseded by [post_2026-09-11.md](./post_2026-09-11.md), which records the reapply instructions, completed implementation, and final live verification.

---

## Plans in scope

| Plan | Path |
| --- | --- |
| Storage upgrade design | `docs/plans/2026-09-10--k3s-02-storage-upgrade_partial_pre_09-07` |
| Research consolidation / implementation campaign | `docs/plans/2026-09-10--hrl-research-consolidation_partial_pre_09-07` |

---

## What we're solving

`hom-lab-ctl-k3s-02` hit DiskPressure during Qwen3-Coder-30B-A3B AWQ deployment.
Root cause: 77 GiB OS VHDX shared by OS + container images + model weights + logs.
Planning for 4 models (~82 GiB total) made the single-disk layout untenable.

---

## What has been applied (receipt-verified)

| Stage | What happened | Evidence |
| --- | --- | --- |
| **VHDX layout** | 300 GiB cache on host `G:` (`0:2`) + 200 GiB cold-artifacts on host `H:` (`0:4`) + 32 GiB logs/scratch on host `D:` (`0:3`) | Serials locked via `by-id` |
| **containerd offload** | K3s containerd bind-mounted to cache disk; `imagefs` ≠ `nodefs` confirmed | `crictl imagefsinfo` split verified |
| **local-path provisioner** | New PVCs route to `/mnt/k3s-cache/local-path` | ConfigMap updated; original retained |
| **vLLM HF cache** | `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`; hostPath deployment → Ready | Source PVC retained |
| **Pod logs dir** | `podLogsDir: /mnt/k3s-logs/pods` in KubeletConfiguration → `/dev/sdc1` | K3s restarted; path verified |
| **Monitoring** | Grafana Alloy 1.19.2-1 installed, `alloy.service` running | Capacity monitor playbook passed |
| **Physical SSDs** | Samsung → `LOGS-HOST` (F:), Plextor `857` → `HOT-DATA-HOST` (G:) backing the hot-data VHDX, Plextor `306` → `COLD-DATA-HOST` (H:) backing the cold-data VHDX | GPT/NTFS labels and VHDX attachments verified |
| **Root usage** | 21% used after stale ReplicaSet/cache cleanup | Live verification in `2026-09-11--update_new_infra.md` |

---

## Remaining non-storage work

- [ ] **Deploy remaining 3 planned models** — disk headroom is now available
  - Qwen3.6-35B-A3B NVFP4 (~23 GiB)
  - Devstral Small 2 GGUF Q4 (~14 GiB)
  - GLM-4.6 GGUF Q4 (~28 GiB)
- [x] **Update inventory** — document final disk configuration
- [x] **Monitoring/alerting thresholds** — storage monitoring is deployed; threshold policy remains in the monitor role
- [x] **Physical SSD wiring to K3s guest** — cache VHDX moved to `G:` and cold-artifacts VHDX attached from `H:`; guest filesystems remain separate and non-RAID
- [ ] **Prometheus/TSDB placement** — if Prometheus is added, must go on durable storage, *not* the cache VHDX
- [ ] **Campaign formal sign-off** — `hrl-storage-implementation-beta-01` Evaluator whole-campaign sign-off (C-03) was never closed

---

## Relevant playbooks

| Playbook | Purpose |
| --- | --- |
| `playbooks/deploy_k3s_data_disk.yaml` | Main entrypoint — VHDX attach + format + mount + K3s offload |
| `playbooks/verify_k3s_data_disk_safety.yaml` | Pre-apply safety preview (read-only) |
| `playbooks/deploy_k3s_storage_expansion.yaml` | Storage expansion orchestration |
| `playbooks/bootstrap_k3s_storage_disks.yaml` | First-time disk initialization |
| `playbooks/configure_k3s_pod_logs_dir.yaml` | Pod logs dir KubeletConfiguration |
| `playbooks/report_storage.yaml` | Live storage usage report across the node |
| `playbooks/deploy_storage_capacity_monitor.yaml` | Grafana Alloy monitor deployment |
| `playbooks/verify_storage_capacity_monitor_safety.yaml` | Monitor pre-apply check |

---

## Undo path (if needed)

```bash
# Data disk role with absent state + verified limit
ansible-playbook playbooks/deploy_k3s_data_disk.yaml \
  --limit hom-lab-ctl-k3s-02 \
  -e k3s_data_disk_state=absent
```

Role restores the retained containerd tree before unmount/detach.
**Do not detach either VHDX** until guest state and retained data are checked.

---

## Key design constraints (don't break these)

- Use `LABEL=` not `/dev/sdX` — SATA order changes when Hyper-V adds disks
- No RAID0 in this design — each disk is a separate filesystem and workload boundary
- Prometheus TSDB = `durable` — never on the cache VHDX
- Pod logs use the native configured `/mnt/k3s-logs/pods` path; disk-pressure accounting implications are documented in the receipt
