# `automation_awx` Ansible Role

Deploys AWX on the repo's k3s cluster using AWX Operator.

The first value is playbook execution history: once playbooks run through AWX
job templates, AWX becomes the system of record for job status, timestamps,
stdout, and result history. This role also includes a history-query tag that
uses the `awx.awx` collection.

## Why k3s First

The supported AWX community install path is AWX Operator on Kubernetes. In this
repo, the matching prerequisite is:

```bash
ansible-playbook playbooks/k3s_bootstrap.yaml -i inventory/inventory.yaml
```

After k3s is healthy, preview the AWX target:

```bash
ansible-playbook playbooks/deploy_automation_awx.yml \
  -i inventory/inventory.yaml --tags automation_awx_preview
```

Then deploy:

```bash
ansible-playbook playbooks/deploy_automation_awx.yml -i inventory/inventory.yaml
```

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `automation_awx_state` | `present` | Desired state: `present` or `absent`. |
| `automation_awx_operator_version` | `2.19.1` | AWX Operator release tag. |
| `automation_awx_namespace` | `awx` | Kubernetes namespace for AWX. |
| `automation_awx_name` | `homelab-awx` | AWX custom resource name. |
| `automation_awx_manifest_path` | `/opt/automation-awx` | Rendered kustomize manifests on the k3s node. |
| `automation_awx_kubeconfig` | `/etc/rancher/k3s/k3s.yaml` | Kubeconfig used on the k3s node. |
| `automation_awx_service_type` | `NodePort` | AWX service type. |
| `automation_awx_nodeport_port` | `30080` | NodePort used for the web UI. |

## Tags

| Tag | Selects |
| --- | --- |
| `automation_awx` | Entire AWX capability. |
| `automation_awx_preview` | Read-only target and prerequisite preview. |
| `automation_awx_present` | Operator and AWX custom resource apply path. |
| `automation_awx_absent` | Remove AWX resources. |
| `automation_awx_smoke_test` | Report pod readiness and service endpoint. |
| `automation_awx_job_history` | Query AWX playbook execution history through the AWX API. |

## Query Job History

After AWX is reachable, set API credentials in the controller environment:

```bash
export CONTROLLER_HOST="http://192.168.50.158:30080"
export CONTROLLER_USERNAME="admin"
export CONTROLLER_PASSWORD="<admin password from homelab-awx-admin-password>"

ansible-playbook playbooks/deploy_automation_awx.yml \
  -i inventory/inventory.yaml --tags automation_awx_job_history
```

You can also use `CONTROLLER_OAUTH_TOKEN` instead of a password.

## Undo

```bash
ansible-playbook playbooks/deploy_automation_awx.yml \
  -i inventory/inventory.yaml -e automation_awx_state=absent
```

Treat PVC/data deletion as a separate explicit cleanup task. The first absent
path removes the AWX Kubernetes resources managed by this role.
