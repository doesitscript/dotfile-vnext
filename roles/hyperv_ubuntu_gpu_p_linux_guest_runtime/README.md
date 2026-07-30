# hyperv_ubuntu_gpu_p_linux_guest_runtime

Converge Hyper-V Ubuntu GPU-P guest runtime: WSL DriverStore sync, dxgkrnl DKMS,
ld.so configuration, and runtime state manifest.

## Lifecycle

- `hyperv_ubuntu_gpu_p_linux_guest_runtime_state: present|absent`

## SMB artifact sync

Windows artifacts publish to the host public share. Guests mount via SMB using
the parent hypervisor guest gateway as the default share host.

The guest runtime resolves its Windows partner from
`hyperv_ubuntu_gpu_p_linux_guest_runtime_windows_host`, which defaults to
`parent_hypervisor` and falls back to `physical_node`.

On `hom-lab-ctl-k3s-02`, `hyperv_ubuntu_gpu_p_linux_guest_runtime_share_host_override`
resolves from `hostvars[parent_hypervisor].hyperv_config.guest_gateway_ipv4` (SSOT).

When Windows LAN SSH is down but the guest gateway is reachable, run Windows-side
plays with `HOM-LAB-HVH-02-guest-gw` and keep the guest share override aligned
to `192.168.137.1`.

## Partial converge

When artifact sync is blocked, set `hyperv_ubuntu_gpu_p_linux_guest_runtime_skip_artifact_sync: true`
and seed `publish-receipt.json` locally (see troubleshoot converge playbook).
No controller-side runtime receipt seed is required.

## Reapply hardening

The present path now probes dpkg state for the active kernel packages before
running DKMS. If packages for the running kernel are unpacked or half-configured,
the role fails early with the package list instead of proceeding into a noisy
DKMS error.

Set `hyperv_ubuntu_gpu_p_guest_kernel_package_autorepair: true` to let the role
run `dpkg --configure -a` and `apt-get install -f -y` before re-checking package
health.

When DKMS still fails, the role now surfaces tailed `make.log` content in the
Ansible failure so reapply diagnostics stay in the play output.

If the repo-assembled `dxgkrnl` DKMS path still fails, the role can fall back
to the upstream `dxgkrnl-dkms` `install.sh` workflow via
`hyperv_ubuntu_gpu_p_guest_dxgkrnl_upstream_fallback: true`. This uses the
sanctioned `clean all` reset path before reinstalling against the current
target kernel.

## Tags

- `hyperv_ubuntu_gpu_p_linux_guest_runtime`

## Related

- [gpu-p-operational-contracts.md](../../docs/reference/gpu-p-operational-contracts.md)
- [hyperv_gpu_partition_adapter](../hyperv_gpu_partition_adapter/README.md)
- Pinned pipeline: `playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh02_k3s02.yaml`
