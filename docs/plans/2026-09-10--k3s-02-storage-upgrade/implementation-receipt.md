# K3s-02 storage upgrade implementation receipt

**Receipt status:** applied and verified

**Authority:** `draft-plan-v1-researched.md` v1.1, reconciled with
`draft-plan-v1-researched-suggestions.md`

**Latest concise update:** [post_2026-09-11.md](./post_2026-09-11.md)

## Applied evidence

The implementation was applied through the repository Ansible entrypoint with
an explicit `hom-lab-ctl-k3s-02` limit.

- Hyper-V discovery identified three user-authorized SSDs: Samsung SSD 840 EVO
  120GB, serial `S1D5NSBF438394N`, observed F: at 100% used; Plextor
  `002516159857`, observed G: at 100% used; and Plextor `002516159306`,
  observed H: at 90% used. The user authorized wiping and repurposing these
  drives. They were wiped and formatted as separate NTFS volumes by the
  serial-bound repurpose workflow.
- The immediate guest layout is two separate dynamic VHDXs on host `D:`:
  300 GiB cache at controller location `0:2` and 32 GiB logs/scratch at
  `0:3`. No RAID0 was created or retained.
- Guest identity was verified by stable serial/by-id paths. The cache disk is
  serial `60022480737317e55fd3cd8e3fafbe4a` and the logs disk is
  serial `60022480f30acb542946b808b5379d44`.
- Guest filesystems are labeled `k3s-cache` and `k3s-logs`, and persistent
  mounts use `LABEL=` rather than SATA device ordering.
- K3s containerd was copied to the cache filesystem, the original was retained
  at `/var/lib/rancher/k3s/agent/containerd.ansible-pre-offload`, and the
  K3s-owned path is now a bind mount from `/dev/sdb1[/containerd]`.
- The local-path provisioner now routes newly provisioned paths to
  `/mnt/k3s-cache/local-path`; the original ConfigMap is retained by the role.
- The latest storage report showed root at 21% used, cache at 29% used, and
  logs at approximately 1% used. K3s was active and the explicit role check
  verified imagefs and nodefs resolve to different backing sources.
- vLLM HF cache was migrated through the existing runtime role to
  `/mnt/k3s-cache/hf` with `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`. The vLLM
  hostPath deployment became Ready; the source PVC was retained.
- Grafana Alloy 1.19.2-1 was installed and `alloy.service` was enabled and
  running. The storage-capacity monitoring playbook completed successfully
  for the target host.
- Native pod logs are configured through the inventory-owned
  `/etc/rancher/k3s/kubelet-config.yaml` KubeletConfiguration with
  `podLogsDir: /mnt/k3s-logs/pods`; K3s restarted successfully and the path
  resolves to `/dev/sdc1`.
- The physical SSD workflow was applied through
  `repurpose_hyperv_physical_ssds.yaml` after exact serial discovery. Samsung
  is now `K3S-LOGS-HOST`, Plextor `002516159857` is `K3S-CACHE-HOST`, and
  Plextor `002516159306` is `K3S-COLD-HOST`; final volume-label verification
  passed. Each is a separate GPT/NTFS filesystem.
- A post-cutover cleanup removed ten zero-replica vLLM ReplicaSets and their
  stale kubelet pod-volume data. Root usage fell from 81% to 21%; kubelet pod
  data fell from approximately 47 GiB to 2.7 MiB. The node remained Ready with
  `DiskPressure=False`, and the active vLLM pod remained Ready.

## Corrections recorded

- The serial-bound physical-SSD role and Linux filesystem-label task were
  corrected for steady-state idempotence. Existing serial-to-label matches are
  verified and skipped; destructive formatting is selected only for mismatches
  and requires the explicit apply gate. A second full guest storage run and
  SSD apply-enabled run both completed with `changed=0`.

- An initial check-mode path exposed that first-time disk initialization cannot
  safely be simulated by the existing partition task; the role was tightened
  so migration apply refuses check mode and future previews do not pretend to
  validate a copy/rename/mount transition.
- vLLM cache verification initially saw changing incomplete, lock, and Xet
  log files. The migration verification now excludes those volatile control
  files and ignores timestamps while retaining checksum verification for the
  stable cache contents.
- K3s service recovery was added before the offload API query so a previously
  interrupted migration is recoverable through the bounded role.

## Remaining verification notes

- The dated post-change follow-up is [post_2026-09-11.md](./post_2026-09-11.md).
  It records the reapply order, current differences from the original plan,
  and the fact that no storage implementation work remains.

- The current structured `ansible.windows.win_powershell` owner was retained
  for physical disk operations because `gocallag.hyperv.vm_disk` addresses
  VHDX attachment, not physical-disk wipe/format. Exact serial discovery,
  non-boot/system assertions, and final labels are the fit/safety evidence.
- The native log change is intentionally documented as able to change kubelet
  disk-pressure accounting; the final workload and monitor checks remain the
  operational acceptance evidence.

## Undo

Use the repository data-disk playbook with an explicit verified limit and
`k3s_data_disk_state=absent`. The offload role restores the retained
containerd tree before unmount/detach. Do not detach either VHDX until the
guest state and any retained data have been checked.
