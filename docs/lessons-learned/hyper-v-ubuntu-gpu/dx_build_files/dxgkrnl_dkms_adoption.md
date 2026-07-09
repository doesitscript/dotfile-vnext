# Hyper-V Ubuntu GPU-P dxgkrnl-dkms Adoption Packet

## Summary

This mirrored plan copy is the operator-facing version of the governed packet at `docs/plans/2026-07-08--hyper-v-ubuntu-gpu-dxgkrnl-dkms-incomplete/README.md`.

Use this plan, not the imported upstream `README.md`, when running the `dxgkrnl-dkms` adoption experiment for `hom-lab-ctl-k3s-02`.

This slice is manual and evidence-first:

- reuse the existing WSL bridge/file-staging process as the driver-copy path
- skip upstream Step 2 as the primary repo workflow
- pin installation to the current guest kernel `6.17.0-1018-azure`
- perform guest-side config only until reboot
- reboot from outside the guest
- validate `/dev/dxg`, module load, library resolution, and `nvidia-smi`
- convert the workflow to Ansible only if the manual path succeeds

## Operator Runbook

### 1. Baseline and prerequisites

- Confirm the VM remains `hom-lab-ctl-k3s-02`.
- Confirm the current guest kernel is `6.17.0-1018-azure`.
- Confirm the host/VM baseline GPU-P state is still the same:
  - host can partition the GPU
  - VM can receive the GPU partition adapter
  - VM boots with it attached

### 2. Driver/file staging source

- Do not use the imported README's Step 2 as the primary repo flow.
- Instead, reuse:
  - `dx_build_from_wsl.md`
  - `playbooks/troubleshoot/hyperv_ubuntu_gpu_p_wsl_bridge_experiment.yaml`
- Any additional file requirement for `dxgkrnl-dkms` should be treated as a delta to that established process, not as a competing copy workflow.

### 3. Install dxgkrnl-dkms in the guest

- Primary install command:

```bash
curl -fsSL https://content.staralt.dev/dxgkrnl-dkms/main/install.sh | sudo bash -es
```

- Sanctioned clean/reset path before retry:

```bash
curl -fsSL https://content.staralt.dev/dxgkrnl-dkms/main/install.sh | sudo bash -es -- clean all
```

- This packet is pinned to the current guest kernel `6.17.0-1018-azure`.
- If the guest kernel no longer falls within the imported Ubuntu 24.04 support range, stop and record that as the new blocker.

### 4. Complete guest-side `/usr/lib/wsl` configuration before reboot

- Do the guest-side `/usr/lib/wsl` move, permissions, symlinks, loader config, and `ldconfig` inside the VM.
- Stop at that boundary.
- Reboot from outside the guest, not from inside it.

### 5. Post-reboot validation

- Success requires all of the following:
  - `/dev/dxg` exists
  - `lsmod` shows the expected `dxg` module path
  - `dmesg` shows expected initialization evidence
  - library resolution is correct
  - `nvidia-smi` succeeds

- Failure must classify the blocking layer:
  - host GPU-P config
  - guest module build/load
  - guest file/layout
  - post-reboot runtime validation

### 6. Stable return note

- If the experiment needs to be abandoned and the VM returned to the pre-dxgkrnl state:
  - use the clean-module path
  - remove guest-side `/usr/lib/wsl` and loader changes introduced by this slice
  - verify the guest is back to the pre-experiment runtime state
- This is experiment cleanup, not a Hyper-V snapshot/restore substitute.

### 7. Automation handoff

- If this manual workflow succeeds, the next slice is explicit:
  - codify the validated steps into repo-owned Ansible
  - replace manual/ad-hoc execution with automation

## References

- Authoritative packet:
  - `docs/plans/2026-07-08--hyper-v-ubuntu-gpu-dxgkrnl-dkms-incomplete/README.md`
- Existing WSL bridge/file staging support:
  - `docs/lessons-learned/hyper-v-ubuntu-gpu/dx_build_files/dx_build_from_wsl.md`
  - `playbooks/troubleshoot/hyperv_ubuntu_gpu_p_wsl_bridge_experiment.yaml`
- Deprecated upstream source:
  - `docs/lessons-learned/hyper-v-ubuntu-gpu/dx_build_files/README.md`

## Latest execution receipt

Run status from July 8, 2026:

- `dxgkrnl-dkms` install on `6.17.0-1018-azure`: success
- Guest `/usr/lib/wsl/lib` activation: success
- Guest `/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a` population: success
- External reboot boundary: success
- `/dev/dxg` after reboot: success
- `dxgkrnl` module loaded after reboot: success
- Loader resolution for `libdxcore.so`, `libd3d12.so`, `libcuda.so.1`, `libnvidia-ml.so.1`: success
- `nvidia-smi`: success

What changed materially:

- Before this run, the guest did not expose `/dev/dxg`.
- After this run, `/dev/dxg` existed and `lspci -nnk` showed the Microsoft Basic Render device bound to `dxgkrnl`.
- `sudo dmesg` showed `dxgkrnl` registering on Hyper-V during boot.
- `strace` on guest `nvidia-smi` showed the exact missing path:
  - `/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a/libnvidia-ml.so.1`
- After copying the full traced DriverStore subtree into that exact guest path, both:
  - `nvidia-smi`
  - `/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a/nvidia-smi`
  reported the RTX 5090 successfully.

What this proved:

- Stage 4 depended on `dxgkrnl-dkms` plus `/usr/lib/wsl/lib`.
- Stage 5 additionally depended on the exact traced NVIDIA DriverStore subtree under `/usr/lib/wsl/drivers/<reported-folder-name>`.
- The folder name mattered exactly:
  - `nvmdsi.inf_amd64_e82263d194ad754a`

Current ladder status:

- Host can partition GPU: pass
- VM can receive GPU partition adapter: pass
- VM can boot with it attached: pass
- Guest exposes usable GPU interface: pass
- Guest driver/runtime stack can actually use it: pass

Next slice:

- Convert the validated manual sequence into repo-owned Ansible.
- Preserve the traced dependency rule:
  - populate `/usr/lib/wsl/drivers/<exact-folder-reported-by-runtime>`
  - do not guess or rename the folder
