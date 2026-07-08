# Langfuse Platform Adaptation

## External sources

- `https://langfuse.com/guides`
- `https://langfuse.com/guides/cookbook/integration_litellm_proxy`
- `https://langfuse.com/guides/cookbook/integration_langgraph`
- `https://langfuse.com/integrations#overview`
- local vendor references:
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/guides-overview.md`
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/integrations-overview.md`

## Repo authority sources

- `/Users/joshc/develop/dotfile-vnext/AGENTS.md`
- `/Users/joshc/develop/dotfile-vnext/README.md`
- `/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md`

## Suggested pattern from upstream

Upstream Langfuse examples assume a clean observability platform that can be
connected to gateways, SDKs, and model runtimes with relatively direct
environment and topology choices.

The examples strongly support:

- tracing-first implementation
- prompt/version management
- evaluation and experiment workflows
- gateway and SDK integrations

## Repo adaptation

For this repo, Langfuse is not planned as a fresh standalone greenfield
platform. It must be interpreted through the current homelab lane model and the
existing playbook targets.

Current repo truth says:

- active Langfuse platform services are concentrated on the GPU lane
- the live K3s Langfuse surface is on `hom-lab-ctl-k3s-02`
- the active external PostgreSQL dependency path is on `hom-lab-ctl-dkr-02`

## Conflicts with current infrastructure

- upstream examples are topology-light; this repo is topology-heavy
- examples do not encode your lane split, VM ownership, or current service
  concentration
- examples do not override NetBox naming or repo execution patterns

## Decision for this project

- use Langfuse examples to shape capability and dependency understanding
- do not inherit cookbook placement language as deployment truth
- keep the repo's lane/guest model authoritative until a governed infra change
  says otherwise

## Open verification items

- whether Langfuse should remain concentrated on the GPU lane long term
- whether the storage lane should later absorb more authoritative data-plane
  services
- whether any repo-owned Langfuse role boundaries need refactoring after the
  current placement retrospective
