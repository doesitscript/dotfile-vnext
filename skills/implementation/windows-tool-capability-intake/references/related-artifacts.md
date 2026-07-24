# Related Artifacts

Typical repo surfaces:

- `inventory/host_vars/hom-lab-hvh-01.yaml`
- `inventory/host_vars/hom-lab-hvh-02.yaml`
- `roles/python/tasks/windows.yml`
- `roles/huggingface_hub/`
- `roles/windows_ollama_runtime/`
- `playbooks/deploy_huggingface_hub.yaml`
- `playbooks/deploy_hvh01_secondary_model_runtime.yaml`
- `playbooks/llm_compute_windows_hvh01.yaml`

Validation:

- `bin/codex-env ansible-playbook playbooks/deploy_huggingface_hub.yaml --limit HOM-LAB-HVH-01 --list-hosts`
- `bin/codex-env ansible-playbook ... --check --diff`
- Live apply with `present`, then optional `-e *_state=absent` undo probe when safe
