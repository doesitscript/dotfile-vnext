# windows_comfyui_amd — **DEPRECATED**

Phase B pixels moved to **`k3s_comfyui_runtime`** on `hom-lab-ctl-k3s-02`
(RTX 5090 time-share). Do not commission this role for new still work.

- Inventory: `windows_comfyui_amd_state: absent` on `dev-workstation-win`
- Replacement: `playbooks/deploy_comfyui_runtime.yaml` + `roles/k3s_comfyui_runtime`
- Lab E2E plans: `docs/plans/2026-08-06--comfyui-lab-setup-diagrams-implemented/`

Kept only for teardown (`absent`) of any leftover `E:\ai\comfyui` install.
