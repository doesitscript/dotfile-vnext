# Storage implementation validation TODO

**Date:** 2026-09-11  
**Purpose:** Validate that the updated storage implementation is genuinely
Ansible-idempotent, repairs drift to the declared end state, and does not leave
obsolete one-off designs as active configuration.

## Review scope

Review the roles and playbooks that own or consume this implementation:

- Roles: `hyperv_vm_data_disk`, `linux_data_disk_mount`,
  `k3s_storage_offload`, `k3s_vllm_runtime`, `storage_capacity_monitor`, and
  `windows_physical_ssd_repurpose`.
- Playbooks: `bootstrap_k3s_storage_disks.yaml`,
  `deploy_k3s_data_disk.yaml`, `deploy_k3s_storage_expansion.yaml`,
  `deploy_vllm_runtime.yaml`, `configure_k3s_pod_logs_dir.yaml`,
  `repurpose_hyperv_physical_ssds.yaml`,
  `cleanup_vllm_stale_replicasets.yaml`,
  `deploy_storage_capacity_monitor.yaml`, `report_storage.yaml`, and the
  related safety-verification playbooks.
- Inventory contracts for `HOM-LAB-HVH-02` and
  `hom-lab-ctl-k3s-02`, including every variable consumed by those roles.

## Required checks

- [ ] Run each present-state playbook twice against the current live state;
  second run must report `changed=0` and must not restart services unnecessarily.
- [ ] Create controlled drift in a disposable or safely recoverable field
  (mount declaration, filesystem label, local-path destination, K3s config,
  vLLM cache declaration, and SSD label where safe), then confirm the owning
  role restores the declared state.
- [ ] Confirm serial-to-label matches are discovered and skipped; mismatches
  require explicit destructive apply and never silently format another disk.
- [ ] Confirm VHDX attachment, partition, filesystem, mount, bind mount,
  containerd, local-path, native `podLogsDir`, vLLM hostPath, and monitoring
  state each have one authoritative owner and a truthful absent/undo path.
- [ ] Search for obsolete `/dev/sdX` targeting, RAID-member language, symlink
  migrations, ad-hoc shell installers, temporary playbooks, and old one-off
  migration logic. Deprecate or clearly mark historical-only designs.
- [ ] Verify check mode does not claim to validate destructive bootstrap work
  that it cannot safely simulate; verify apply gates remain fail-closed.
- [ ] Re-run syntax checks, safety fixtures, live health checks, and the storage
  report after the review.

## Acceptance criteria

The implementation is accepted only when current state is reproducible from
Ansible, drift is repaired by the owning playbook, repeated convergence is a
no-op, destructive actions are identity-bound and explicit, and historical
designs cannot be mistaken for active implementation guidance.

Current evidence and implementation entrypoints are in
[post_2026-09-11.md](./post_2026-09-11.md) and
[implementation-receipt.md](./implementation-receipt.md).
