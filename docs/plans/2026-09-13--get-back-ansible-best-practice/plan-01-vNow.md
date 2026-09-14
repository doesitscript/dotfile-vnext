Yes. For Ansible, I would design this as an **inheritance/precedence system**, not as “configure the same knobs everywhere.”

The settings at the client, LiteLLM, and vLLM/Ollama are often **analogous**, and sometimes literally the same request parameters, but they live at different layers and have different authority.

For example, `temperature` can exist at several layers:

```text
Ansible model default
        ↓
LiteLLM default
        ↓
CLI-specific default
        ↓
individual API request
        ↓
vLLM executes the final value
```

vLLM exposes sampling parameters such as `temperature`, `top_p`, `top_k`, `max_tokens`, penalties, etc. A request can supply those values; if it doesn't, vLLM can fall back to its server/model generation defaults. ([vLLM][1])

So I would make your Ansible data model look roughly like this:

```yaml
ai_models:
  qwen3_coder_30b:
    model:
      context_window: 131072
      max_output_tokens: 16384
      supports_tools: true
      supports_reasoning: true

    defaults:
      temperature: 0.2
      top_p: 0.95

    runtime:
      vllm:
        max_model_len: 131072

    gateway:
      litellm:
        model_name: qwen3-coder-30b
        api_base: http://vllm-primary:8000/v1

    clients:
      default:
        context_window: 131072
        max_output_tokens: 16384
        temperature: 0.2

      codex:
        {}

      kilo:
        context_window: 114688

      continue:
        context_window: 32768
        max_output_tokens: 4096
```

Then your effective value calculation is basically:

```text
model defaults
    ↓ overridden by
client defaults
    ↓ overridden by
specific client/model overrides
```

So for Codex:

```text
temperature:
  model default = 0.2
  codex override = absent

effective = 0.2
```

But Kilo might be:

```text
context_window:
  model capability = 131072
  general CLI default = 131072
  kilo override = 114688

effective Kilo value = 114688
```

And Continue:

```text
context_window:
  model capability = 131072
  continue override = 32768

effective Continue value = 32768
```

That is exactly the pattern I'd recommend.

## One important distinction

I would split the variables into **capabilities/limits** and **defaults/preferences**.

A capability is something like:

```yaml
model:
  context_window: 131072
  max_output_tokens: 16384
  supports_tools: true
```

Those are facts about what you are deploying.

A default is:

```yaml
defaults:
  temperature: 0.2
  top_p: 0.95
```

Those are policies you have chosen.

And then there are **runtime deployment settings**:

```yaml
runtime:
  vllm:
    max_model_len: 131072
    gpu_memory_utilization: 0.90
    tensor_parallel_size: 1
```

Those belong to the vLLM instance rather than the abstract model.

Finally you have **client behavior**:

```yaml
clients:
  kilo:
    context_window: 114688
    compaction_threshold: ...
```

That's not really a model setting at all. It's how Kilo wants to use the model.

### Think of the hierarchy this way

```text
               ANSIBLE SOURCE OF TRUTH
                         │
            ┌────────────┴────────────┐
            │                         │
       MODEL FACTS                POLICY DEFAULTS
       131K context                temp = .2
       tools = yes                 top_p = .95
       reasoning = yes
            │                         │
            └────────────┬────────────┘
                         │
                 DEPLOYMENT OVERRIDES
                         │
           ┌─────────────┼──────────────┐
           ▼             ▼              ▼
         vLLM         LiteLLM        Ollama
      max_model_len    routing       num_ctx/etc.
                         │
                         ▼
                  CLIENT PROFILES
            ┌────────────┼────────────┐
            ▼            ▼            ▼
          Codex         Kilo       Continue
          default      override     override
```

The biggest rule I'd enforce in your Ansible implementation is:

> **A child layer may normally reduce or specialize a model capability, but it should not magically increase it.**

For example:

```yaml
model:
  context_window: 131072
```

This is sensible:

```yaml
clients:
  continue:
    context_window: 32768
```

This should trigger validation:

```yaml
clients:
  continue:
    context_window: 200000
```

because the client claiming 200K doesn't make the deployed model support 200K.

Similarly, you might deploy vLLM with:

```yaml
max_model_len: 65536
```

even though the underlying model supports:

```yaml
context_window: 131072
```

In that case the **effective infrastructure limit is 65,536**, and your client profile shouldn't advertise 131K against that particular deployment.

That gives you another useful concept:

```text
model capability      = 131072
deployment capability = 65536
client desired limit  = 32768

effective client limit = min(all applicable limits)
                       = 32768
```

That `min()` behavior is particularly appropriate for hard limits.

Generation preferences such as temperature work differently. Those use ordinary precedence:

```text
model recommendation:    0.2
environment default:     0.2
Kilo override:           0.1

effective Kilo temp:     0.1
```

And this maps nicely onto how vLLM actually works. vLLM can load generation defaults from the model's `generation_config.json`, use vLLM's own defaults instead, or apply server-side overrides; request-level sampling parameters can then supply values for generation. ([vLLM][2])

LiteLLM fits naturally in the middle because it's explicitly designed as a normalized interface translating a common OpenAI-style request format to different providers/backends. ([LiteLLM][3])

So I would **not** make your inventory look like:

```yaml
vllm_temperature: 0.2
litellm_temperature: 0.2
codex_temperature: 0.2
kilo_temperature: 0.2
continue_temperature: 0.2
```

That's exactly the duplication you're trying to eliminate.

Instead:

```yaml
ai_models:
  qwen3_coder_30b:

    capabilities:
      context_window: 131072
      output_tokens: 16384
      tools: true
      reasoning: true

    defaults:
      temperature: 0.2
      top_p: 0.95

    deployments:
      k3s02_vllm:
        runtime: vllm
        overrides:
          context_window: 114688

    clients:
      codex: {}
      kilo:
        context_window: 100000
      continue:
        context_window: 32768
        output_tokens: 4096
```

Then let your roles/templates calculate:

```text
effective value =
    specific client override
    ?? deployment override
    ?? model default
```

with hard capability limits validated separately.

That gives you **one model definition, multiple deployments, multiple clients, and sparse overrides**. You only write a client-specific value when it genuinely needs to differ.

For the architecture you're building, I think that's much cleaner than considering vLLM or LiteLLM the owner of the profile. **Ansible/your inventory should own the desired state; vLLM, LiteLLM, Ollama, Codex, Kilo, and Continue should be rendered consumers of that desired state.**

[1]: https://docs.vllm.ai/en/stable/api/vllm/sampling_params/?utm_source=chatgpt.com "sampling_params - vLLM"
[2]: https://docs.vllm.ai/en/latest/cli/serve/?utm_source=chatgpt.com "serve - vLLM"
[3]: https://docs.litellm.ai/?utm_source=chatgpt.com "LiteLLM - Getting Started | liteLLM"
