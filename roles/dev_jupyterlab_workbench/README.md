# dev_jupyterlab_workbench

Deploy a JupyterLab workbench on a Linux host for exploring Langfuse recipes
from a browser with the repo's standard homelab endpoints and credentials.

## What it does

- creates a Python virtual environment and installs JupyterLab plus the SDKs
  used across the Langfuse/LiteLLM work
- clones the official `langfuse/langfuse-docs` repository and exposes its
  `cookbook/` directory in the JupyterLab file browser as `langfuse-cookbooks`
- renders a real managed local `.env` pointing at the live homelab Langfuse and
  LiteLLM operator endpoints
- configures JupyterLab as a systemd service with password authentication
- verifies that the required runtime env keys exist after deployment
- verifies that the required upstream cookbook path and operator hostnames are
  resolvable after deployment

## Defaults worth knowing

- Password: `Pass@w0rd1`
- Web URL: `http://jupyter.hom.lab:8888/lab`
- Default recipe entry: `langfuse-cookbooks`
- Langfuse endpoint: `http://langfuse.hom.lab`
- LiteLLM endpoint: `http://litellm.hom.lab/v1`

## Important variables

- `dev_jupyterlab_workbench_state`: `present|absent`
- `dev_jupyterlab_workbench_user`: Linux user that owns the workbench files
- `dev_jupyterlab_workbench_install_dir`: workbench root directory
- `dev_jupyterlab_workbench_password_plain`: Jupyter login password
- `dev_jupyterlab_workbench_cookbooks_repo`: upstream docs repository that
  contains the official `cookbook/` notebooks
- `dev_jupyterlab_workbench_operator_url`: browser URL for the workbench UI
- `dev_jupyterlab_workbench_langfuse_host`: Langfuse URL injected into
  `.env`
- `dev_jupyterlab_workbench_openai_base_url`: LiteLLM URL injected into
  `.env`
- `dev_jupyterlab_workbench_required_env_keys`: required keys that must exist in
  the managed `.env` artifact after deploy

## Secrets

This role loads `vault/shared.vault.yml` when available and uses:

- `vault_shared_langfuse_public_key`
- `vault_shared_langfuse_secret_key`
- `vault_k3s_litellm_gateway_master_key`

If those values are unset, the repo's standard fallback values are used so the
managed workbench `.env` still renders as a real runtime artifact for the lab.

## Runtime env contract

- The primary output is `<install_dir>/.env` on the target host.
- This role does not use `.env.example` as the delivered runtime surface.
- The role verifies the required keys after rendering the managed `.env`.

## Example playbook

```yaml
- hosts: hom-lab-ctl-k3s-02
  roles:
    - role: dev_jupyterlab_workbench
```

## Apply

```bash
ansible-playbook playbooks/deploy_jupyterlab_workbench.yaml
```
