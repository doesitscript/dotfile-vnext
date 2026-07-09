# LiteLLM Gateway Adaptation

## External sources

- `https://langfuse.com/integrations/gateways/litellm`
- `https://langfuse.com/guides/cookbook/integration_litellm_proxy`
- `https://langfuse.com/guides/cookbook/js_integration_litellm_proxy`
- local vendor references:
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/guides/cookbook/integration_litellm_proxy.md`
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/guides/cookbook/js_integration_litellm_proxy.md`

## Repo authority sources

- `/Users/joshc/develop/dotfile-vnext/AGENTS.md`
- `/Users/joshc/develop/dotfile-vnext/README.md`
- `/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md`

## Suggested pattern from upstream

Upstream LiteLLM guidance suggests:

- one OpenAI-compatible gateway
- many model/provider backends behind that gateway
- Langfuse attached for proxy-level tracing and observability

It also shows LiteLLM as a strong fit when you want to compare providers and
change routing without changing client code.

## Repo adaptation

That upstream gateway pattern is a good match for this repo's intent.

Repo-aligned interpretation:

- LiteLLM is a gateway layer, not the place to encode host naming truth
- clients should target the repo-approved LiteLLM surface
- local models should sit behind the gateway through `vLLM`
- cloud providers such as OpenAI and Anthropic/Claude should be treated as
  alternate provider paths behind the same gateway policy

## Conflicts with current infrastructure

- upstream proxy examples do not express your Windows host, VM, and K3s lane
  boundaries
- sample config assumes direct proxy bootstrap, while this repo requires
  playbook/role-aligned convergence
- gateway docs do not define NetBox metadata or service-ownership truth

## Decision for this project

- keep LiteLLM as the canonical model gateway concept
- route local models and cloud providers through the same gateway policy
- treat gateway publication, placement, and ownership as repo-controlled
  infrastructure concerns

## Open verification items

- exact client publication path for each editor/client surface
- whether additional model classes beyond the current local-first plan should be
  exposed immediately
- whether current LiteLLM placement remains the correct long-term lane choice
############### 
All of these are reporting changed:
'

TASK [hyperv_gpu_partition_adapter : Ensure VM has GPU-partition-compatible Hyper-V settings] ***
changed: [hom-lab-ctl-hvh-02]

TASK [hyperv_gpu_partition_adapter : Stop VM before adding GPU partition adapter when restart is allowed] ***
changed: [hom-lab-ctl-hvh-02]

TASK [hyperv_gpu_partition_adapter : Ensure VM firmware is GPU-partition-compatible while VM is stopped] ***
changed: [hom-lab-ctl-hvh-02]

TASK [hyperv_gpu_partition_adapter : Attach GPU partition adapter to target VM] ***
changed: [hom-lab-ctl-hvh-02]

TASK [hyperv_gpu_partition_adapter : Start VM after GPU partition adapter change when desired] ***
changed: [hom-lab-ctl-hvh-02]

TASK [hyperv_gpu_partition_adapter : Apply explicit GPU partition sizing for target VM] ***
changed: [hom-lab-ctl-hvh-02]
'
