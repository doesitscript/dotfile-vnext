# After — what changed and why it fixes it

Same **32,768 cup**. Continue still sends a big prompt, but now only reserves
**4,096** for the answer. ~24,577 + 4,096 stays **under** the rim, so LiteLLM
lets the request through.

Embeddings: **one teacher** — gateway `nomic-embed-text`. LM Studio stays in
the closet (`enabled: false`) until you deliberately compare it again.

LiteLLM also learned the cup size (`max_input` / `max_output`) and uses HF’s
`repetition_penalty: 1.05`. The model weight on vLLM did **not** need swapping.

![After](after_config.svg)

**Values that matter now:** vLLM 32768 (same) · Continue maxTokens **4096** ·
LiteLLM rep **1.05** · max_in **28672** / max_out **4096** · sole embed =
`nomic-embed-text`.
