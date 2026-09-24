# One-off request: HVH-02 GPU-P host Restart-VM / GooglePlayGames experiment

- Date / target: 2026-09-23 — `HOM-LAB-HVH-02` / `hom-lab-ctl-k3s-02`
- Request and explicit authorization: User authorized managed GPU-P restore with
  Ansible-first repair; bounded reversible diagnosis allowed before durable apply.
- Reason: Host showed `CurrentPartitionCompute=0` after reboot; hypothesis that
  host process hold + VM restart would reallocate compute.
- Action and result:
  - Stopped `GooglePlayGamesServices` (pid 5160); issued `Restart-VM` for
    `hom-lab-ctl-k3s-02`.
  - After restart, `CurrentPartitionCompute` remained `0`.
  - Real root cause was guest kernel `7.0.0-1014-azure` without `dxgkrnl` DKMS
    (module only for `6.17.0-1022-azure`). Guest Ansible converge + upstream
    fallback restored `/dev/dxg` and `nvidia-smi`.
- Remaining state: none durable from this experiment. GooglePlayGames was stopped
  for the probe only; adapter sizing was re-applied via
  `hyperv_gpu_partition_adapter`. Boot `dxgkrnl` load is now role-managed.
- Disposition: reconciled (root cause encoded in
  `roles/hyperv_ubuntu_gpu_p_linux_guest_runtime`)
- User decision on debt or deferral: not specified (repair completed via Ansible)
- Reconciliation or follow-up link:
  `docs/reference/gpu-p-operational-contracts.md`; residual risk notes in peer
  evaluation report for this incident
