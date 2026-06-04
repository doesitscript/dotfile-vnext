# gpu_diagnostics_windows

Installs **HWiNFO64** (Chocolatey with winget fallback), creates `D:\ai\diagnostics\` (or `{{ windows_data_root }}\diagnostics`), deploys `collect-gpu-evidence.ps1`, and optionally registers a boot-time HWiNFO CSV logging task.

Does **not** configure AMD Adrenalin or MSI Afterburner UI — see [docs/diagnostics/amd-gpu-windows-desktop--diagnostics.md](../../docs/diagnostics/amd-gpu-windows-desktop--diagnostics.md).

## Lifecycle

| Variable | Values |
|----------|--------|
| `gpu_diagnostics_windows_state` | `present` \| `absent` |

## Playbook

```bash
bin/codex-env ansible-playbook playbooks/troubleshoot/deploy_dev_workstation_gpu_diagnostics.yaml \
  -i inventory/inventory.yaml --limit dev-workstation-win
```

## Tags

- `gpu_diagnostics` — role-wide
- `gpu_diagnostics_install` — install paths
- `presentmon_cli` — optional standalone PresentMon (off by default)

## Verify

```bash
bin/codex-env ansible-playbook playbooks/troubleshoot/collect_dev_workstation_gpu_artifacts.yaml \
  -i inventory/inventory.yaml --limit dev-workstation-win
```

## Apply / Verify / Undo / Class

| | |
|--|--|
| **Apply** | Playbook with `gpu_diagnostics_windows_state: present` |
| **Verify** | Collect playbook; HWiNFO CSV under `hwinfo\`; probe script runs |
| **Undo** | `state: absent`; optional `gpu_diagnostics_windows_purge_logs_on_absent: true` |
| **Class** | Bootstrap/semi-manual on edge desktop |
