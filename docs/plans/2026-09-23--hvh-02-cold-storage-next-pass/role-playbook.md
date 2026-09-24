# Bucket: Role / playbook

Use when the same move, restore, retention, discovery, or verification behavior
will recur. Prefer extending an existing role/playbook and keep lifecycle state,
targeting, preview, apply, verify, and undo explicit.

| Gap or candidate path | Owning role/playbook | Desired state / interface | Preview | Verification | Status |
|---|---|---|---|---|---|
| Reclaim reclaimable content under `*\ProgramData\Ansible\` on HVH-02 (artifacts, downloads, rebuild bases) — linked from Keep on `C:\ProgramData\Ansible` root | `windows_artifact_cache` (+ Hyper-V cold root `hyperv_ubuntu_vm_cold_data_root` / `H:\COLD-DATA-HOST\hyperv-cache`) | Keep root; offload only profile-matched hot copies to cold; never touch live guest `.vhdx` / `.VMRS` | Reclaim preview play/tags already used on HVH-01 (`docs/diagnostics/2026-09-23--hvh-01-windows-artifact-cache-reclaim.md`) | Preview → apply → post-preview zero candidates; live VMs still Running | pending — awaiting user accept; execute only after Keep root accepted |
