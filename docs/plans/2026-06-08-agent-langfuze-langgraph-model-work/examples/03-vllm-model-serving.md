# vLLM Model Serving Adaptation

## External sources

- `https://langfuse.com/integrations/model-providers/vllm`
- `https://langfuse.com/integrations/model-providers/qwen`
- `https://langfuse.com/integrations/model-providers/deepseek`
- local vendor references:
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/integrations-overview.md`

## Repo authority sources

- `/Users/joshc/develop/dotfile-vnext/AGENTS.md`
- `/Users/joshc/develop/dotfile-vnext/README.md`
- `/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md`

## Suggested pattern from upstream

Upstream Langfuse material treats `vLLM` as the model-serving layer and then
shows provider/model-specific patterns such as Qwen and DeepSeek as compatible
model integrations.

## Repo adaptation

For this repo:

- `vLLM` is the platform/runtime layer
- `Ornith`, `Qwen Coder`, and similar local models are model payloads behind
  that layer
- `DeepSeek` should be read as a provider/model integration example, not a
  separate infrastructure platform

This means product classification should look like:

- platform/runtime: `vLLM`
- models: `Ornith`, `Qwen Coder`
- provider/model example family: `DeepSeek`

## Conflicts with current infrastructure

- upstream examples do not define your GPU-lane placement rules
- examples do not encode the distinction between a model runtime and a model
  identity in your documentation
- examples do not say which repo-owned host/guest should carry the runtime

## Decision for this project

- normalize all local model discussion under the `vLLM` runtime layer
- document models as served workloads, not peer infrastructure products
- preserve DeepSeek and Qwen as adaptation examples for compatible model
  integration patterns

## Open verification items

- exact published model catalog for the first implementation slice
- exact model names and inference/runtime parameters for repo-owned deployment
- whether any model should bypass `vLLM` in this homelab
