# Ansible WSL Reform Report

**Date:** 2026-05-28  
**Agent:** Ansible reform (WSL scope decoupling)  
**Policy:** WSL is desktop/bootstrap only. Hyper-V server lanes (`HOM-LAB-HVH-*`, `hom-lab-ctl-dkr-*`, `hom-lab-ctl-k3s-*`, `hyperv_*` roles) must not use `wsl.exe` or WSL distros as automation connection paths.

## Executive summary

Inventory, playbooks, `hyperv_networking`, and `access_identity_windows` were **already decoupled** from WSL before this pass. The only functional WSL dependency on server automation was **`hyperv_ubuntu_vm` Azure cloud-image offline seeding** via `wsl.exe --mount`.

This reform:

1. Defaults offline seed **off** with mount provider **`disabled`** (no implicit WSL on server runs).
2. Gates the legacy WSL mount task behind explicit `mount_provider: wsl` (desktop/bootstrap opt-in).
3. Documents and blocks the not-yet-built `linux_openssh_delegate` path.
4. Pins K3s VM on `HOM-LAB-HVH-02` to offline-seed-disabled server policy.

`wsl_hosts` is **absent** from active inventory YAML (already removed).

---

## Pre-reform findings

| Area | WSL state before |
|------|------------------|
| `inventory/inventory.yaml` | No `wsl_hosts` group; `linux_vm_hosts` for Hyper-V guests |
| `inventory/host_vars/*` | No WSL vars on server hosts |
| `playbooks/` | No WSL references |
| `roles/hyperv_networking/` | No WSL (decouple plan completed) |
| `roles/access_identity_windows/` | No WSL |
| `roles/hyperv_ubuntu_vm/` | **Active** `wsl.exe --mount` offline seed path; default `offline_seed_enabled: true` |
| `ansible.cfg` | Comment-only WSL mentions |
| Bootstrap scripts (`bin/bootstrap-*.ps1`) | WSL-centric; **not called by playbooks** (bootstrap-only) |

Guest access pattern already aligned with AGENTS.md:

- Windows OpenSSH → `HOM-LAB-HVH-02` at `192.168.50.158`
- Guest Linux SSH → `hom-lab-ctl-dkr-02` / `hom-lab-ctl-k3s-02` via routed subnet + `ProxyJump`

---

## Files touched

### `roles/hyperv_ubuntu_vm/defaults/main.yml`

| Before | After |
|--------|-------|
| `hyperv_ubuntu_vm_cloud_image_offline_seed_enabled: true` | `false` with server-lane comment |
| (no mount provider) | `hyperv_ubuntu_vm_cloud_image_offline_seed_mount_provider: disabled` |
| (no delegate host) | `hyperv_ubuntu_vm_cloud_image_offline_seed_linux_delegate_host: ""` |
| `/mnt/wsl/...` mount path uncommented | Same path retained with **WSL-only** comment |

### `roles/hyperv_ubuntu_vm/tasks/present.yml`

| Before | After |
|--------|-------|
| Offline seed always attempted when enabled | Assert when enabled + provider `disabled` |
| WSL task unconditional when seed enabled | WSL task only when `mount_provider == 'wsl'` |
| (no delegate guard) | Explicit `fail` when `linux_openssh_delegate` selected (not implemented) |
| Task name generic | Renamed to note legacy desktop/bootstrap WSL path |

### `roles/hyperv_ubuntu_vm/meta/argument_specs.yml`

Added public contract fields:

- `hyperv_ubuntu_vm_cloud_image_offline_seed_enabled` (default `false`)
- `hyperv_ubuntu_vm_cloud_image_offline_seed_mount_provider` (choices: `disabled`, `wsl`, `linux_openssh_delegate`)
- `hyperv_ubuntu_vm_cloud_image_offline_seed_linux_delegate_host`

### `roles/hyperv_ubuntu_vm/README.md`

Updated offline-seed documentation: WSL is legacy opt-in; server lanes use `disabled` or future `linux_openssh_delegate`.

### `inventory/host_vars/HOM-LAB-HVH-02.yaml`

Added explicit K3s VM offline-seed policy:

```yaml
hyperv_ubuntu_k3s_vm_cloud_image_offline_seed_enabled: false
hyperv_ubuntu_k3s_vm_cloud_image_offline_seed_mount_provider: disabled
```

### `playbooks/hyperv_ubuntu_k3s_vm.yaml`

Maps K3s-specific offline-seed vars into `hyperv_ubuntu_vm` include_role scope.

### `inventory/inventory.yaml`

Comment clarifying `linux_vm_hosts` replaces legacy `wsl_hosts` / `*-wsl` suffix model.

### `ansible.cfg`

Removed WSL-specific wording from vault and SSH keepalive comments (behavior unchanged).

---

## Remaining WSL hits in functional YAML

These are **expected** post-reform. None are active server automation paths unless explicitly opted in.

| File | Hit | Classification |
|------|-----|----------------|
| `roles/hyperv_ubuntu_vm/tasks/present.yml` | `wsl.exe --mount` PowerShell block | **Legacy opt-in** — runs only when `mount_provider: wsl` |
| `roles/hyperv_ubuntu_vm/defaults/main.yml` | `/mnt/wsl/...` mount root | **Legacy path variable** — used only by WSL provider |
| `roles/hyperv_ubuntu_vm/defaults/main.yml` | Comments referencing WSL | Documentation |
| `inventory/host_vars/HOM-LAB-HVH-02.yaml` | Comment "no wsl.exe" | Documentation |
| `inventory/inventory.yaml` | Comment on `wsl_hosts` legacy | Documentation |
| `contracts/fuzlang.contract.yaml` | Deprecated WSL runtime scaffolding | Contract archive — marked FIXME/deprecated |
| `.cursor/skills/catalog.yml` | `capture-wsl-systemctl` skill entry | **Retained per policy** (diagnostics skill, not server automation) |
| `docs/reports/.../state_snapshot.yaml` | Historical state report | Non-functional |

**Ubuntu 24.04 image URLs/filenames** in `hyperv_ubuntu_vm` defaults and host_vars are **cloud/ISO artifacts**, not WSL distro automation targets.

---

## Verification performed

```text
bin/codex-env ansible-playbook playbooks/hyperv_ubuntu_k3s_vm.yaml --syntax-check -i inventory/inventory.yaml
→ playbook: playbooks/hyperv_ubuntu_k3s_vm.yaml (exit 0)
```

Full ansible-lint/idempotence not run — reform is gating/defaults only; no live apply in this pass.

---

## Blockers needing human decision

### 1. Azure cloud-image bootstrap without WSL offline seed

**Context:** K3s VM on `HOM-LAB-HVH-02` uses `azure_cloud_image` with offline seed now **disabled**. Prior lab practice relied on WSL mount for deterministic first-boot seeding.

**Options:**

| Option | Tradeoff |
|--------|----------|
| **A.** Switch K3s VM to `server_iso_installer` (proven on same host for `hom-lab-ctl-dkr-02`) | Aligns with active server path; larger host_vars change |
| **B.** Implement `linux_openssh_delegate` offline seed via existing guest (`hom-lab-ctl-dkr-02`) + SMB/VHD mount | Keeps azure path; requires new task file and package deps (`guestmount`/nbd) |
| **C.** Explicit desktop-only WSL opt-in on a dev workstation host (`mount_provider: wsl`) | Violates server policy if applied to hvh hosts |
| **D.** Rely on NoCloud cidata only (offline seed off) | Simplest; may regress azure Hyper-V bootstrap reliability |

**Recommendation:** **A** or **B** for production server lanes. **D** acceptable only after live probe proves azure + NoCloud suffices on Hyper-V.

### 2. `linux_openssh_delegate` implementation

Planned replacement: mount VHDX from an **SSH-ready Linux companion** on the same physical node (OpenSSH pattern), not from WSL on Windows. Stub `fail` task is wired; implementation deferred.

### 3. Bootstrap scripts still WSL-centric

`bin/bootstrap-local.ps1`, `bin/bootstrap-wsl.ps1`, `bin/bootstrap-ansible-local.ps1` still install/configure WSL and write `*-wsl` host_vars. Playbooks do not invoke them. **Decision:** leave as desktop first-touch bootstrap, or add deprecation banners (not changed in this pass).

### 4. Stale documentation references

Docs still mention `wsl_hosts`, `server-225-wsl`, etc. (e.g. `docs/ansible/access_playbook.md`, `docs/ssh_requirements_checklist.md`). Docs sweep is a separate agent (`docs/archive/wsl-deprecating/MANIFEST.md`).

---

## Operator knobs (unchanged)

For troubleshooting Hyper-V Ubuntu VM runs:

- `-vvv`
- `-e ansible_troubleshooting_mode=true`
- `-e debug_remote_output=true`
- `--tags collect_hyperv`

To explicitly enable **legacy WSL offline seed** (desktop/bootstrap only):

```yaml
hyperv_ubuntu_vm_cloud_image_offline_seed_enabled: true
hyperv_ubuntu_vm_cloud_image_offline_seed_mount_provider: wsl
```

Do **not** set this on `HOM-LAB-HVH-01`, `HOM-LAB-HVH-02`, or other server inventory hosts.
