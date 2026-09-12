# K3s storage offload

This role moves K3s containerd storage onto the explicitly selected data
filesystem by a bind mount at
`/var/lib/rancher/k3s/agent/containerd`. It also routes newly provisioned
local-path volumes to the selected cache path.

The role is deliberately separate-filesystem based; RAID0 and implicit
`/dev/sdX` identity are not supported. The source tree is retained at the
configured rollback path, and `absent` restores it before the data disk is
removed.

`k3s_storage_offload_apply` and `k3s_storage_offload_retain_containerd_backup`
must both be explicitly enabled. The role verifies the containerd bind source,
the K3s service, CRI imagefs visibility, and that imagefs differs from nodefs.
The migration is not a check-mode operation because it requires a bounded
copy, rename, and mount transition; use the repository safety/preview
playbooks before applying.

This role does not configure kubelet `podLogsDir`; that is a separate native
K3s configuration change and must not be replaced with an invented bind of
`/var/log/pods`.
