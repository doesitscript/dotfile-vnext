# Langfuse Adaptation Examples

This folder captures repo-specific adaptation packs for the Langfuse examples
and cookbooks relevant to the agent, gateway, tracing, and infrastructure
surfaces in this plan family.

These are not raw mirrors of upstream examples. Each file records:

- the official Langfuse example or cookbook sources used
- the repo authority sources that constrain the implementation
- what the upstream material suggests
- what must change to fit this homelab
- what is rejected as non-authoritative here
- what still needs live verification

## Authority model

- Context7 is for documentation context only
- the existing Langfuse vendor pack is a durable local reference pack
- NetBox remains the live source of truth for infrastructure facts
- repo retrospectives and role/playbook patterns override cookbook topology

## Component packs

- [01-langfuse-platform.md](01-langfuse-platform.md)
- [02-litellm-gateway.md](02-litellm-gateway.md)
- [03-vllm-model-serving.md](03-vllm-model-serving.md)
- [04-editor-clients-cursor-vscode.md](04-editor-clients-cursor-vscode.md)
- [05-netbox-and-infra-authority.md](05-netbox-and-infra-authority.md)
- [source-map.md](source-map.md)
