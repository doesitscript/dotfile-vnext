# hyperv_ubuntu_gpu_p_linux_guest_runtime

Converge Hyper-V Ubuntu GPU-P guest runtime: WSL DriverStore sync, dxgkrnl DKMS,
ld.so configuration, and runtime state manifest.

## Lifecycle

- `hyperv_ubuntu_gpu_p_linux_guest_runtime_state: present|absent`

## Kernel / DKMS pins (anti-drift)

GPU-P guests must **not** float with `linux-image-azure` or unattended upgrades.

Inventory (not role defaults) owns:

| Variable | Purpose |
| --- | --- |
| `hyperv_ubuntu_gpu_p_linux_guest_target_kernel` | Exact ABI (must equal `ansible_kernel`) |
| `hyperv_ubuntu_gpu_p_linux_guest_dxgkrnl_version` | Exact DKMS module version for that ABI |
| `hyperv_ubuntu_gpu_p_dxgkrnl_repo_version` | Pinned `dxgkrnl-dkms` git commit |

On `present`, the role asserts the pin matches the running kernel, holds kernel
packages, disables unattended upgrades / apt timers, and converges only the
pinned `dxgkrnl` version (upstream fallback must land on the pin).

Bump pins only via an explicit operator request, then re-apply Ansible.

## SMB artifact sync

If SMB sync fails because `F:\shares\public` / share `public` is missing,
restore via `playbooks/windows_file_shares.yml` then re-publish with
`playbooks/hyperv_ubuntu_gpu_p_artifact_publish.yaml`. Skip-sync is temporary
only and still requires guest `state.json` with `driverstore_folder`.

## Tags

- `hyperv_ubuntu_gpu_p_linux_guest_runtime`

## Related

- [gpu-p-operational-contracts.md](../../docs/reference/gpu-p-operational-contracts.md)
- Pinned pipeline: `playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh02_k3s02.yaml`
