# Endpoint Verification Role

Verifies that endpoints are reachable from mac-dev node.

## Purpose

- Checks Langfuse endpoint (http://network-server:3000)
- Checks MinIO API endpoint (http://network-server:9000)
- Checks MinIO Console endpoint (http://network-server:9001)
- Checks LiteLLM endpoint (http://Server-225:4000)
- Checks Ollama endpoint (http://Server-225:11434) - optional
- Checks dev Ollama/LiteLLM endpoints - optional

## Usage

This role is automatically included in `verify_fabric.yaml` playbook for mac-dev host.



