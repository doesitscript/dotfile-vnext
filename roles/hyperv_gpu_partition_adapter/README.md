# hyperv_gpu_partition_adapter

Attach, size, and remove Hyper-V GPU partition adapters for Ubuntu K3s guests.

## Lifecycle

- `hyperv_gpu_partition_adapter_state: present|absent`

## GPU policy registry preflight

When `hyperv_gpu_partition_adapter_require_hyperv_gpu_policy_keys: true`, the role
ensures these DWORD keys are `0` before partition work:

- `HKLM:\SOFTWARE\Policies\Microsoft\Windows\HyperV\RequireSecureDeviceAssignment`
- `HKLM:\SOFTWARE\Policies\Microsoft\Windows\HyperV\RequireSupportedDeviceAssignment`

Set on `hom-lab-hvh-02` in host_vars. See
[ReqSecDevAssign.md](../../docs/lessons-learned/hyper-v-ubuntu-gpu/ReqSecDevAssign.md).

Optional `hyperv_gpu_partition_adapter_restart_vmms_when_policy_keys_change` restarts
`vmms` only when a key changes.

## Partition VRAM sizing

Override partition sizing per host in `inventory/host_vars/`. hvh-02 uses 500MB
optimal/max values because the partitionable VRAM pool is ~1GB.

## Connection fallback

When LAN SSH to `hom-lab-hvh-02` fails, target the guest-gateway surface:

```bash
ansible-playbook playbooks/deploy_gpu_infrastructure.yaml \
  --limit hom-lab-hvh-02-guest-gw,hom-lab-ctl-k3s-02 \
  --tags hyperv_gpu_partition_adapter
```

See [gpu-p-operational-contracts.md](../../docs/reference/gpu-p-operational-contracts.md).

## Tags

- `hyperv_gpu_partition_adapter`

## Related

- [hyperv_ubuntu_gpu_p_linux_guest_runtime](../hyperv_ubuntu_gpu_p_linux_guest_runtime/README.md)
- [gpu-p-operational-contracts.md](../../docs/reference/gpu-p-operational-contracts.md)
