# Sources And Precedence

1. Playbook: `playbooks/deploy_dev_workstation_ollama_runtime.yaml`
2. Role: `roles/windows_ollama_runtime/` (install via `windows_artifact_download` + `win_package`)
3. Download helper: `roles/windows_artifact_download/`
4. Host gate: `inventory/host_vars/dev-workstation-win.yaml`
5. Run log: `logs/runs/<UTC>--deploy-dev-workstation-ollama-runtime.log` (gitignored)

Do not use `/tmp/desktop-*.log` as the durable apply surface.
Do not treat Chocolatey as the Ollama install authority for this capability.
