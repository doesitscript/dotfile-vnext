# Hyper-V Ubuntu GPU-P Runtime Scale-Out Report

## Scope

This is a report-only verification pass for scaling the current Hyper-V Ubuntu GPU-P runtime flow from:

- Windows host: `hom-lab-ctl-hvh-02`
- Ubuntu guest: `hom-lab-ctl-k3s-02`

to the other Windows server in inventory:

- Windows host: `hom-lab-ctl-hvh-01`
- Paired Ubuntu guest: `hom-lab-ctl-k3s-01`

This report does **not** claim live success on `hom-lab-ctl-hvh-01`. It evaluates whether the current repo-native implementation is structurally reusable there, what is already compatible, and what must change before we should expect it to work.

## Executive Verdict

The current design is structurally reusable on `hom-lab-ctl-hvh-01`, but it is **not ready to run there unchanged**.

The implementation is now parameterized enough to target another Windows host and guest pair, but `hom-lab-ctl-hvh-01` is missing some of the runtime-specific declarations that `hom-lab-ctl-hvh-02` already has.

The biggest gaps are:

1. `hom-lab-ctl-hvh-01` does not currently declare the Hyper-V Ubuntu GPU-P artifact share directories that the publish role expects.
2. `hom-lab-ctl-hvh-01` is not currently modeled as a GPU lane host in the same way `hom-lab-ctl-hvh-02` is.
3. There is no live evidence in this report that `hom-lab-ctl-hvh-01` has:
   - a partitionable NVIDIA GPU
   - WSL installed in the expected Windows paths
   - the repo-managed NVIDIA driver contract present
   - host BIOS/Hyper-V settings passing the GPU-P precheck role
4. `hom-lab-ctl-k3s-01` has not been validated as the guest consumer for this path.

So the answer is:

- **Code path**: reusable
- **Inventory/runtime contract**: incomplete on `hom-lab-ctl-hvh-01`
- **Live readiness**: unverified

## Latest Live Precheck Result For `hom-lab-ctl-hvh-01`

The repo-native precheck path has now been executed against `hom-lab-ctl-hvh-01`.

Repo entrypoints now available:

- strict precheck:
  - [hyperv_gpu_p_host_precheck_hvh01.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_gpu_p_host_precheck_hvh01.yaml)
- probe mode that skips the driver-contract gate so host readiness evidence is still captured:
  - [hyperv_gpu_p_host_probe_hvh01.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_gpu_p_host_probe_hvh01.yaml)

Measured result:

- `HyperVisorPresent = true`
- `VirtualizationFirmwareEnabled = false`
- `IovSupport = false`
- `IovSupportReasons` returned:
  - BIOS must allow Windows to control PCI Express / SR-IOV
  - PCIe hardware does not expose ACS on any root port accepted by Hyper-V
- `Get-VMHostPartitionableGpu` equivalent result:
  - `partitionable_gpu_count = 0`
- display device evidence:
  - `NVIDIA GeForce GTX 1060 6GB`
  - `Status = Error`
- CPU:
  - `Intel(R) Xeon(R) CPU E5-2650 v3 @ 2.30GHz`
- BIOS:
  - SMBIOS version `4101`

The precheck receipt is now persisted on the host at:

- `C:\ProgramData\Ansible\hyperv_gpu_p_host_precheck\current.json`

So `hom-lab-ctl-hvh-01` is not blocked by missing repo wiring anymore. It is blocked by live platform readiness.

## Additional Driver Contract Finding

The repo-native NVIDIA contract role was also exercised on `hom-lab-ctl-hvh-01`.

The role is now split into:

- package-management path
- discovery-only contract publication path

What the current discovery contract proves:

- `nvidia-smi.exe` resolves from `C:\WINDOWS\system32\nvidia-smi.exe`
- Windows display-driver metadata currently reports:
  - raw driver version `32.0.15.8129`
  - normalized NVIDIA-style version `581.29`
- the repo contract now publishes even when policy checks are not fully satisfied

Current contract state:

- `driver_version_matches = true`
- `installed_driver_version = 581.29`
- `installed_package_version = null`
- `package_version_matches = false`
- `policy_passed = false`

So the strict GPU-P precheck is no longer blocked on missing driver-contract publication. It now fails at the real host GPU-P readiness gates.

## Attempted Repo-Native NVIDIA Repair

A repo-native reinstall attempt of the Chocolatey `nvidia-studio-driver` package was executed on `hom-lab-ctl-hvh-01`.

Result:

- NVIDIA installer launch failed from the Chocolatey package path
- upstream installer exit code:
  - `-469762016`

That means the repo-native repair attempt did not clear the host GPU problem automatically. Further NVIDIA repair on this host is now a Windows host troubleshooting task, not a missing-automation-path problem.

## Repo Changes Added For This Scale-Out Pair

The repo now includes the minimum routing/contract changes to target this pair explicitly without changing the current default lane:

- `hom-lab-ctl-hvh-01` now declares the same GPU-P artifact share directory tree used by the working `hvh-02` lane:
  - `F:\shares\public\artifacts`
  - `F:\shares\public\artifacts\hyperv_ubuntu_gpu_p_runtime`
  - `...\current`
  - `...\runs`
- New wrapper playbook:
  - [hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh01_k3s01.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline_hvh01_k3s01.yaml)

That wrapper binds:

- Windows host: `hom-lab-ctl-hvh-01`
- Ubuntu guest: `hom-lab-ctl-k3s-01`
- guest VM name: `hom-lab-ctl-k3s-01`

It is syntactically valid, but it is not expected to pass until the host-side GPU-P readiness gates pass on `hom-lab-ctl-hvh-01`.

## Why `hom-lab-ctl-hvh-01` Is The Right Scale-Out Target

The other Windows server that matches the current architecture is `hom-lab-ctl-hvh-01`, not `dev-workstation-win`.

Why:

- `hom-lab-ctl-hvh-01` is a `windows_host`
- it has `hyperv_host` enabled
- it already owns:
  - `hom-lab-ctl-dkr-01`
  - `hom-lab-ctl-k3s-01`
- it already uses the same repo-managed Hyper-V VM pattern as `hom-lab-ctl-hvh-02`

Relevant files:

- [hom-lab-ctl-hvh-01.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-ctl-hvh-01.yaml)
- [hom-lab-ctl-k3s-01.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-ctl-k3s-01.yaml)

## What Already Generalizes Cleanly

The current runtime orchestration is no longer hard-bound to `hom-lab-ctl-hvh-02` and `hom-lab-ctl-k3s-02` in the execution path. It accepts override targeting for:

- `hyperv_ubuntu_gpu_p_runtime_windows_hosts`
- `hyperv_ubuntu_gpu_p_runtime_guest_hosts`
- `hyperv_ubuntu_gpu_p_runtime_guest_vm_name`

Relevant playbooks:

- [hyperv_ubuntu_gpu_p_runtime_artifact_pipeline.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline.yaml)
- [hyperv_ubuntu_gpu_p_runtime.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_ubuntu_gpu_p_runtime.yaml)

The artifact transport model also now generalizes correctly:

- Windows host publishes to its own SMB share
- Ubuntu guest mounts that Windows share directly
- Ubuntu guest consumes the payload locally
- controller does not sit in the payload data path

That is the right site-wide shape for reuse.

## What Is Missing On `hom-lab-ctl-hvh-01`

### 1. Missing GPU-P artifact share directories

`hom-lab-ctl-hvh-02` declares:

- `F:\shares\public\artifacts`
- `F:\shares\public\artifacts\hyperv_ubuntu_gpu_p_runtime`
- `...\current`
- `...\runs`

`hom-lab-ctl-hvh-01` currently declares only model-share paths under:

- `F:\shares\public\models`
- `F:\shares\public\models\huggingface`

That gap is now addressed in inventory for `hom-lab-ctl-hvh-01`.

### 2. Missing GPU-lane host modeling

`hom-lab-ctl-hvh-02` declares:

- `node_classes` includes `gpu_host`
- `hardware_classes` includes:
  - `nvidia_gpu`
  - `high_vram`

`hom-lab-ctl-hvh-01` currently declares:

- `node_classes`:
  - `hyperv_host`
  - `docker_vm_host`
  - `docker_client`
  - `storage_observability`
- `hardware_classes`:
  - `bulk_storage`

That may be correct today. If `hom-lab-ctl-hvh-01` does not physically have the NVIDIA GPU and intended Hyper-V GPU-P role, we should **not** fake those classes. But if this server is meant to become a second GPU-P lane, then inventory needs to say so explicitly.

### 3. No report evidence yet that the Windows prerequisites exist on `hom-lab-ctl-hvh-01`

The current publish/runtime roles assume these Windows-side prerequisites:

- `C:\Windows\System32\wsl.exe`
- `C:\Program Files\WSL\lib`
- `C:\Windows\System32\lxss\lib`
- `C:\Windows\System32\DriverStore\FileRepository`
- repo-managed NVIDIA driver contract:
  - `C:\ProgramData\Ansible\llm_compute_windows\nvidia_driver_contract.json`

This report did not validate those on `hom-lab-ctl-hvh-01`.

### 4. No report evidence yet that the host-side GPU-P precheck would pass on `hom-lab-ctl-hvh-01`

The host precheck role still requires:

- Hyper-V present
- `IovSupport = True`
- a partitionable GPU present
- NVIDIA driver contract present

Relevant defaults:

- [hyperv_gpu_p_host_precheck/defaults/main.yml](/Users/joshc/develop/dotfile-vnext/roles/hyperv_gpu_p_host_precheck/defaults/main.yml)

This report did not validate those values on `hom-lab-ctl-hvh-01`.

### 5. No guest-side proof yet for `hom-lab-ctl-k3s-01`

`hom-lab-ctl-k3s-01` exists and is structurally the right Ubuntu guest peer, but this report did not validate:

- guest SMB mount to `hom-lab-ctl-hvh-01`
- guest direct payload sync
- guest DXG/DKMS/runtime path
- guest `nvidia-smi`

## What Needs To Change

### Change 1: Add artifact-share directories to `hom-lab-ctl-hvh-01`

Recommended host-vars addition in:

- [hom-lab-ctl-hvh-01.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-ctl-hvh-01.yaml)

Example:

```yaml
windows_file_shares_extra_directories:
  - path: 'F:\shares\public\models'
    purpose: AI model catalog root
  - path: 'F:\shares\public\models\huggingface'
    purpose: Hugging Face model weights
  - path: 'F:\shares\public\artifacts'
    purpose: Public share artifact root
  - path: 'F:\shares\public\artifacts\hyperv_ubuntu_gpu_p_runtime'
    purpose: Hyper-V Ubuntu GPU-P runtime artifact root
  - path: 'F:\shares\public\artifacts\hyperv_ubuntu_gpu_p_runtime\current'
    purpose: Current Hyper-V Ubuntu GPU-P runtime artifact set
  - path: 'F:\shares\public\artifacts\hyperv_ubuntu_gpu_p_runtime\runs'
    purpose: Timestamped Hyper-V Ubuntu GPU-P runtime artifact history
```

If we want this to be share-capability-wide instead of per-host duplication, we could also abstract it behind a host opt-in variable. Example pseudo-pattern:

```yaml
hyperv_ubuntu_gpu_p_runtime_artifact_share_enabled: true
```

and then have the Windows share role compose the directories when that flag is enabled.

### Change 2: Only mark `hom-lab-ctl-hvh-01` as a GPU lane if the hardware is real

If `hom-lab-ctl-hvh-01` is supposed to become a second GPU-P-capable Windows host, then inventory should say so. Example:

```yaml
node_classes:
  - hyperv_host
  - docker_vm_host
  - docker_client
  - storage_observability
  - gpu_host

hardware_classes:
  - bulk_storage
  - nvidia_gpu
  - high_vram
```

If that hardware is **not** actually present, do not add those classes. In that case, the correct report conclusion is that this server is not a valid scale-out target for this capability.

### Change 3: Validate Windows prerequisites on `hom-lab-ctl-hvh-01`

Before a real run, the equivalent of this must pass on `hom-lab-ctl-hvh-01`:

Pseudo-check:

```yaml
- name: Validate GPU-P Windows source paths
  ansible.windows.win_stat:
    path: "{{ item }}"
  loop:
    - C:\Windows\System32\wsl.exe
    - C:\Program Files\WSL\lib
    - C:\Windows\System32\lxss\lib
    - C:\Windows\System32\DriverStore\FileRepository
    - C:\ProgramData\Ansible\llm_compute_windows\nvidia_driver_contract.json
```

Expected result:

- all paths exist

### Change 4: Validate host precheck on `hom-lab-ctl-hvh-01`

This is the minimum host-side proof we need before trusting scale-out:

Pseudo-check:

```yaml
- hosts: hom-lab-ctl-hvh-01
  gather_facts: false
  roles:
    - role: hyperv_gpu_p_host_precheck
```

Expected result:

- Hyper-V present
- `IovSupport = True`
- partitionable GPU present
- NVIDIA driver contract present

### Change 5: Validate the paired guest `hom-lab-ctl-k3s-01`

The guest needs to be treated as the scale-out peer for `hom-lab-ctl-hvh-01`.

That means the run target should be:

```yaml
hyperv_ubuntu_gpu_p_runtime_windows_hosts: hom-lab-ctl-hvh-01
hyperv_ubuntu_gpu_p_runtime_guest_hosts: hom-lab-ctl-k3s-01
hyperv_ubuntu_gpu_p_runtime_guest_vm_name: hom-lab-ctl-k3s-01
```

## Recommended Report-Only Scale-Out Invocation

Once the inventory declarations above exist, this is the correct shape for a real scale-out test:

```bash
ansible-playbook playbooks/hyperv_ubuntu_gpu_p_runtime_artifact_pipeline.yaml \
  -e hyperv_ubuntu_gpu_p_runtime_state=present \
  -e hyperv_ubuntu_gpu_p_runtime_windows_hosts=hom-lab-ctl-hvh-01 \
  -e hyperv_ubuntu_gpu_p_runtime_guest_hosts=hom-lab-ctl-k3s-01 \
  -e hyperv_ubuntu_gpu_p_runtime_guest_vm_name=hom-lab-ctl-k3s-01
```

## Recommended Preflight-Only Scale-Out Invocation

If we want a lower-risk readiness pass before a real runtime attempt:

```bash
ansible-playbook playbooks/hyperv_ubuntu_gpu_p_runtime.yaml \
  -e hyperv_ubuntu_gpu_p_runtime_state=present \
  -e hyperv_ubuntu_gpu_p_runtime_windows_hosts=hom-lab-ctl-hvh-01 \
  -e hyperv_ubuntu_gpu_p_runtime_guest_hosts=hom-lab-ctl-k3s-01 \
  -e hyperv_ubuntu_gpu_p_runtime_guest_vm_name=hom-lab-ctl-k3s-01 \
  --tags hyperv_gpu_p_host_precheck,windows_file_shares,llm_compute_windows
```

That is not sufficient for full proof, but it is enough to expose:

- missing WSL paths
- missing artifact share paths
- missing driver contract
- missing host GPU-P readiness

## Final Assessment

`hom-lab-ctl-hvh-01` is the correct second Windows server to evaluate.

The current codebase is close enough that scale-out should be treated as a **host-contract problem**, not a rewrite problem.

The work will likely run on `hom-lab-ctl-hvh-01` **if and only if**:

1. the server really has the intended GPU/BIOS/Hyper-V readiness
2. the NVIDIA driver role is applied there and publishes its contract
3. the WSL path prerequisites exist there
4. the artifact-share directories are declared there
5. the paired guest is explicitly targeted as `hom-lab-ctl-k3s-01`

Without those changes, the report-only answer is:

- **portable in design**
- **not yet ready to claim runnable on `hom-lab-ctl-hvh-01`**
