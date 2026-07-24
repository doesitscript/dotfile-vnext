# Related Artifacts

## Apply script

```bash
# From repo root; default log under logs/runs/
bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py

bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py \
  --check

bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py \
  --extra-vars 'windows_ollama_runtime_models_present=[]'
```

See `logs/README.md` for the project logs convention.

## Playbook / roles

- `playbooks/deploy_dev_workstation_ollama_runtime.yaml`
- `roles/windows_ollama_runtime/`
- `roles/windows_artifact_download/`

## Host

- Inventory host: `dev-workstation-win`
- Group: `windows_amd_gpu_hosts`
