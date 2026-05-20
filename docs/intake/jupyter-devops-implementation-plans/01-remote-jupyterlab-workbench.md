# 01 - Remote JupyterLab Workbench

## Goal

Create an Ansible role for a lightweight remote JupyterLab workbench on an
Ubuntu VM using venv/pip or Poetry, not Docker.

## Preliminary Project Structure And Resources

Expected project areas:

- `roles/dev_jupyterlab_workbench/`: new capability-focused role for the remote
  notebook workbench.
- `playbooks/`: add or extend a development/workbench playbook entrypoint with
  tags such as `dev_jupyterlab_workbench`.
- `inventory/group_vars/` or host vars: define workbench target host, install
  path, venv path, notebook port, SSH tunnel preference, and SDK package list.
- `docs/intake/` or later `docs/plans/`: preserve this intake slice until it is
  promoted into an official implementation plan.
- Secret surface: use local vault or ignored `.env` handling for provider API
  keys; do not commit notebook secrets.
- NetBox: model the workbench VM/service endpoint when the target VM is known.

Expected resources:

- Python virtual environment
- JupyterLab service or user-level launch command
- registered `ipykernel` kernel
- Langfuse cookbook repo checkout or staged notebooks
- optional SSH tunnel documentation
- optional internal service endpoint

## Implementation Intent

- Role name candidate: `dev_jupyterlab_workbench`.
- Install Python venv tooling, JupyterLab, `ipykernel`, `python-dotenv`,
  `langfuse`, `anthropic`, and `openai`.
- Clone or stage the Langfuse cookbook repo content.
- Register a kernel such as `langfuse-cookbooks`.
- Prefer SSH tunnel access from the Mac browser before exposing public ingress.
- Keep SDK installs on the Mac optional; only install locally when code runs on
  the Mac instead of the remote VM.

## Acceptance Criteria

- JupyterLab runs on the Ubuntu VM.
- The Mac can open JupyterLab in a browser through a tunnel or controlled
  internal endpoint.
- A notebook can import the required SDKs and load `.env` values.
- The setup uses existing pip/Poetry patterns and does not require Conda.
