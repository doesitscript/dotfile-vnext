# hyperv_ubuntu_gpu_p_linux_guest_runtime

Converge Hyper-V Ubuntu GPU-P guest runtime: WSL DriverStore sync, dxgkrnl DKMS,
ld.so configuration, and runtime state manifest.

## Lifecycle

- `hyperv_ubuntu_gpu_p_linux_guest_runtime_state: present|absent`

## SMB artifact sync

Windows artifacts publish to the host public share. Guests mount via SMB using
the parent hypervisor guest gateway as the default share host.

On `hom-lab-ctl-k3s-02`, `hyperv_ubuntu_gpu_p_linux_guest_runtime_share_host_override`
resolves from `hostvars[parent_hypervisor].hyperv_config.guest_gateway_ipv4` (SSOT).

When Windows LAN SSH is down but the guest gateway is reachable, run Windows-side
plays with `hom-lab-hvh-02-guest-gw` and keep the guest share override aligned
to `192.168.137.1`.

## Partial converge

When artifact sync is blocked, set `hyperv_ubuntu_gpu_p_linux_guest_runtime_skip_artifact_sync: true`
and seed `publish-receipt.json` locally (see troubleshoot converge playbook).

## Tags

- `hyperv_ubuntu_gpu_p_linux_guest_runtime`

## Related

- [gpu-p-operational-contracts.md](../../docs/reference/gpu-p-operational-contracts.md)
- [hyperv_gpu_partition_adapter](../hyperv_gpu_partition_adapter/README.md)
- Pinned pipeline: `playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh02_k3s02.yaml`
