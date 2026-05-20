# Jupyter DevOps Implementation Plan Set

This folder breaks the Jupyter/Langfuse/LiteLLM/vLLM intake conversation into
six implementable plan slices.

The key correction from the source conversation is that the work targets **two
upgraded servers**, not one:

- storage/network server: storage-heavy platform lane for Langfuse, MinIO,
  Postgres, ClickHouse, Redis/Valkey, LiteLLM, JupyterLab, model cache, and
  backups where appropriate.
- RTX 5090 server: GPU/inference lane for GPU-enabled k3s and vLLM runtime
  work.

Plan order:

1. [00 - Upgraded Server Ubuntu/Docker/K3s Baseline](00-upgraded-server-ubuntu-docker-k3s-baseline.md)
2. [00b - Shared Hyper-V Cache Infrastructure](00b-shared-hyperv-cache-infrastructure.md) ← Unblocks all VM provisioning
3. [01 - Remote JupyterLab Workbench](01-remote-jupyterlab-workbench.md)
3. [02 - Langfuse Platform On K3s](02-langfuse-platform-on-k3s.md)
4. [03 - LiteLLM Gateway](03-litellm-gateway.md)
5. [04 - vLLM Runtime And Hugging Face Model Cache](04-vllm-runtime-and-huggingface-cache.md)
6. [05 - End-To-End AI DevOps Validation](05-end-to-end-ai-devops-validation.md)

These are intake-level implementation slices. When one is approved for real
work, promote it into an official folder-backed plan under `docs/plans/`.
