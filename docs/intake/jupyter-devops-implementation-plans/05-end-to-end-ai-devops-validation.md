# 05 - End-To-End AI DevOps Validation

## Goal

Prove the full AI DevOps path from notebook to model gateway to observability.

## Preliminary Project Structure And Resources

Expected project areas:

- `docs/validation/` or role-local docs: store the validated runbook, endpoint
  names, and troubleshooting notes.
- Jupyter notebook location: store a small validation notebook or notebook-cell
  markdown under a repo-approved docs or examples path.
- `playbooks/`: optionally add a read-only validation playbook for endpoint
  checks once the platform resources exist.
- `inventory/group_vars/`: collect endpoint variables for JupyterLab, LiteLLM,
  Langfuse, and vLLM.
- Vault or ignored `.env`: provide runtime API keys for notebook validation
  without committing secrets.
- NetBox: record final service endpoint facts if adopted as source of truth for
  service visibility.

Expected validation resources:

- notebook or documented cells
- `.env` template without secrets
- LiteLLM model route under test
- Langfuse project/API endpoint under test
- trace verification checklist
- server-lane placement summary

## Validation Flow

```text
Jupyter notebook
  -> LiteLLM Gateway
  -> provider API or vLLM local model

Jupyter notebook
  -> Langfuse SDK
  -> Langfuse API
  -> Redis/MinIO
  -> Langfuse worker
  -> ClickHouse/Postgres
```

## Implementation Intent

- Add a small validation notebook or documented notebook cells.
- Load environment variables with `python-dotenv`.
- Call LiteLLM using an OpenAI-compatible client.
- Enable Langfuse tracing for the notebook call.
- Confirm response content and trace visibility.
- Record the validated endpoint names, model route, and Langfuse project used.

## Acceptance Criteria

- Notebook imports succeed.
- LiteLLM returns a model response.
- Langfuse receives and displays the trace.
- The validated path documents what ran locally, what ran on k3s, and which
  server lane hosted each component.
