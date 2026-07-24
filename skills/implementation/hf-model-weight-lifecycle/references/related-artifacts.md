# Related Artifacts

Typical repo surfaces:

- `inventory/group_vars/model_catalog/manifest.yml`
- `inventory/group_vars/model_catalog/SOURCE-ROUTING.md`
- `inventory/host_vars/hom-lab-hvh-01.yaml`
- `roles/huggingface_hub/`
- `roles/k3s_litellm_gateway/defaults/main.yml`
- `roles/k3s_litellm_gateway/tasks/build_helm_values.yml`
- `roles/continue_ide/templates/config.yaml.j2`
- Share path pattern: `F:\shares\public\models\huggingface\<org>--<repo>`

Validation:

- Ansible present/absent play evidence for the weight tree
- `Test-Path` / directory listing via Ansible modules (not ad-hoc as the primary path)
- LiteLLM `GET /v1/models` must not list unpublished aliases
