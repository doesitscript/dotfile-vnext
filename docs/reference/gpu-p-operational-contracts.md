# GPU-P Operational Contracts

Reference for Hyper-V Ubuntu GPU-P (`gpu_contract.passthrough_mode: gpu_p`) automation
on this homelab. Maps operational patterns to concrete repo surfaces.

**Canonical remediation example:** [Track B receipt](../lessons-learned/k9s-broken-resources/findings.md#track-b-remediation-receipt--gpu-host-layer-2026-07-09)

**Connection policy:** [connection-surfaces.md](connection-surfaces.md)

---

## Layer stack (order of operations)

| Phase | Layer | Owner role / playbook | Pass criteria |
|-------|-------|----------------------|---------------|
| P0 | Apt driver purge | `roles/k3s_nvidia_runtime` | No `nvidia-driver-*` held; toolkit present |
| P1 | GPU partition adapter | `roles/hyperv_gpu_partition_adapter` | `Get-VMGpuPartitionAdapter` on target VM |
| P2 | Windows artifact publish | `roles/hyperv_ubuntu_gpu_p_windows_artifact_publish` | Share receipt current under `F:\shares\public\artifacts\...` |
| P3 | Guest GPU-P runtime | `roles/hyperv_ubuntu_gpu_p_linux_guest_runtime` | `state.json` written; `/usr/lib/wsl` converged |
| V | Verify play | `playbooks/hyperv_ubuntu_gpu_p_runtime.yaml` (final play) | `/dev/dxg`, `dxgkrnl`, `ldconfig`, WSL `nvidia-smi` rc=0 |
| P4 | Toolkit-only runtime | `roles/k3s_nvidia_runtime` (`install_guest_driver: false`) | containerd nvidia runtime; no apt driver |
| P5 | K8s GPU layer | `roles/k3s_nvidia_device_plugin`, `roles/k3s_node_gpu_prereqs` | `nvidia.com/gpu` capacity ≥ 1; DS ready |

**Rule:** Do not deploy the device plugin until verify play (V) passes.

---

## Seven techniques → repo surfaces

### 1. Operational state contracts

| Contract | Surface |
|----------|---------|
| Guest driver lane | `k3s_nvidia_runtime_install_guest_driver` in `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` |
| GPU-P vs apt guard | Assert in `roles/k3s_nvidia_runtime/tasks/main.yml` |
| Host runtime verify | Final play in `playbooks/hyperv_ubuntu_gpu_p_runtime.yaml` |
| K8s capacity | `roles/k3s_node_gpu_prereqs` — `k3s_node_gpu_prereqs_expected_count` |

### 2. Evidence-driven convergence

| Surface | Path |
|---------|------|
| Collector tasks | `roles/troubleshooting_collectors/tasks/hyperv_ubuntu_gpu_p.yml` |
| Collector playbook | `playbooks/troubleshoot/collect_hyperv_ubuntu_gpu_p_artifacts.yaml` |
| Mirror tag | `collect_hyperv_gpu_p` on `deploy_gpu_infrastructure.yaml`, `hyperv_ubuntu_gpu_p_runtime.yaml` |
| Artifacts | `artifacts/troubleshooting/hyperv_ubuntu_gpu_p/<host>/<timestamp>/` |
| Troubleshooting knobs | `-vvv`, `-e ansible_troubleshooting_mode=true`, `--tags collect_hyperv_gpu_p` |

### 3. Layer-isolated roles

Each layer owns one role. Roles must not fix another layer's contract.

| Layer | Role |
|-------|------|
| Windows partition + policy | `hyperv_gpu_partition_adapter` |
| Windows artifacts | `hyperv_ubuntu_gpu_p_windows_artifact_publish` |
| Linux guest runtime | `hyperv_ubuntu_gpu_p_linux_guest_runtime` |
| Container toolkit | `k3s_nvidia_runtime` (toolkit only on GPU-P) |
| K8s advertisement | `k3s_nvidia_device_plugin` |

### 4. Connectivity fallback

| Surface | When |
|---------|------|
| Primary Windows | `hom-lab-hvh-02` → `192.168.50.158` (LAN) |
| Guest gateway fallback | `hom-lab-hvh-02-guest-gw` → `192.168.137.1` |
| IPv6 fallback | `hom-lab-hvh-02-ipv6` |

Use guest-gateway surface when LAN SSH is refused but mac-dev can reach `192.168.137.1`.

Guest SMB sync uses `hyperv_config.guest_gateway_ipv4` SSOT via
`hyperv_ubuntu_gpu_p_linux_guest_runtime_share_host_override` on the guest host_vars.

### 5. Runtime artifact pipelines

| Entrypoint | Purpose |
|------------|---------|
| `playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh02_k3s02.yaml` | Pinned hvh-02 / k3s-02 full pipeline |
| `playbooks/hyperv_ubuntu_gpu_p_runtime.yaml` | Publish → converge → verify |
| `playbooks/troubleshoot/hyperv_ubuntu_gpu_p_guest_runtime_local_converge_hvh02_k3s02.yaml` | Partial: seed receipt + optional artifact sync |

**Publish → converge → verify** is the steady-state pattern. Do not run untagged
`deploy_gpu_infrastructure.yaml` on GPU-P guests (re-installs apt driver risk before guard).

### 6. Declarative GPU capacity

| Field | Location |
|-------|----------|
| `gpu_contract.passthrough_mode: gpu_p` | Guest `host_vars` |
| `k3s_node_gpu_prereqs_expected_count: 1` | `roles/k3s_node_gpu_prereqs/defaults/main.yml` |
| Node labels | `roles/k3s_node_config` via `deploy_gpu_infrastructure.yaml` |

### 7. Remediation receipts

| Surface | Purpose |
|---------|---------|
| Human narrative | `docs/lessons-learned/k9s-broken-resources/findings.md` |
| Machine receipt | `artifacts/troubleshooting/hyperv_ubuntu_gpu_p/.../receipt.json` |
| Tag | `gpu_p_receipt` on collector / verify play |

---

## Ordered entrypoints

### Full pipeline (preferred)

```bash
ansible-playbook playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh02_k3s02.yaml
```

When LAN SSH to hvh-02 fails, override Windows hosts:

```yaml
hyperv_ubuntu_gpu_p_runtime_windows_hosts: hom-lab-hvh-02-guest-gw
```

### Driver purge only (P0)

```bash
ansible-playbook playbooks/deploy_gpu_infrastructure.yaml \
  --limit hom-lab-ctl-k3s-02 \
  --tags k3s_nvidia_runtime \
  -e k3s_nvidia_runtime_remove_guest_driver=true
```

### Verify only

```bash
ansible-playbook playbooks/hyperv_ubuntu_gpu_p_runtime.yaml \
  --limit hom-lab-ctl-k3s-02 \
  -e hyperv_ubuntu_gpu_p_runtime_guest_hosts=hom-lab-ctl-k3s-02 \
  --start-at-task "Slurp runtime state manifest for verification"
```

### Partial guest converge (Windows unreachable)

```bash
ansible-playbook playbooks/troubleshoot/hyperv_ubuntu_gpu_p_guest_runtime_local_converge_hvh02_k3s02.yaml \
  -e hyperv_ubuntu_gpu_p_linux_guest_runtime_skip_artifact_sync=false
```

### Evidence collection

```bash
ansible-playbook playbooks/troubleshoot/collect_hyperv_ubuntu_gpu_p_artifacts.yaml \
  --limit hom-lab-ctl-k3s-02,hom-lab-hvh-02-guest-gw
```

---

## Hyper-V policy registry

GPU partition attach may fail with `0x800705AA` until policy keys are set. See
[ReqSecDevAssign.md](../lessons-learned/hyper-v-ubuntu-gpu/ReqSecDevAssign.md).

Automated by `roles/hyperv_gpu_partition_adapter` when
`hyperv_gpu_partition_adapter_require_hyperv_gpu_policy_keys: true` (set on hvh-02).

---

## Related inventory

| Host | Key vars |
|------|----------|
| `hom-lab-hvh-02` | `hyperv_config.guest_gateway_ipv4`, partition VRAM sizing |
| `hom-lab-hvh-02-guest-gw` | Fallback `ansible_host: 192.168.137.1` |
| `hom-lab-ctl-k3s-02` | `k3s_nvidia_runtime_install_guest_driver: false`, share_host SSOT |
