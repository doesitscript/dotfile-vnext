# k3s_nvidia_runtime

Installs NVIDIA container runtime packages on K3s GPU guest nodes.

## Lanes

| Guest model | `k3s_nvidia_runtime_install_guest_driver` | Driver source |
|-------------|-------------------------------------------|---------------|
| Bare-metal / PCI passthrough | `true` (default) | Apt `nvidia-driver-*` |
| Hyper-V GPU-P (`gpu_contract.passthrough_mode: gpu_p`) | `false` | Windows DriverStore via `hyperv_ubuntu_gpu_p_linux_guest_runtime` |

GPU-P guests must not install or hold the apt guest driver. That package blocks
`nvidia-smi` and the WSL driver-store path required by the NVIDIA device plugin.

## Lifecycle

- `k3s_nvidia_runtime_state: present|absent`
- `k3s_nvidia_runtime_remove_guest_driver: true` — one-time purge of conflicting apt driver packages
- apt package mutations now wait for `apt`/`dpkg` locks to clear before proceeding;
  tune with `k3s_nvidia_runtime_apt_lock_timeout`,
  `k3s_nvidia_runtime_apt_lock_wait_retries`, and
  `k3s_nvidia_runtime_apt_lock_wait_delay`

## Playbook

[`playbooks/deploy_gpu_infrastructure.yaml`](../../playbooks/deploy_gpu_infrastructure.yaml)

## Tags

- `k3s_nvidia_runtime`
