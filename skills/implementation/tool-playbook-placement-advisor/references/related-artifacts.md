# Related Artifacts

Primary playbook homes:

- `playbooks/deploy_development_nodes.yaml`
- `playbooks/deploy_k8s_cli_tools.yaml`
- `playbooks/role_only.yaml`

Current adjacent capability owners:

- `roles/k8s_cli_tools`
- `roles/gonzo_cli`
- `roles/dstl8_cli`
- `roles/k3s_mac_client`
- `roles/common/bash_completion`
- `roles/common/shell_config`

Common decision pattern:

- Kubeconfig- and cluster-facing operator tools usually belong with `deploy_k8s_cli_tools.yaml`
- General controller-local developer tools usually belong with `deploy_development_nodes.yaml`
- Shared shell/runtime substrate belongs with `common/*` roles and is composed into playbooks, not bundled as a tool role
