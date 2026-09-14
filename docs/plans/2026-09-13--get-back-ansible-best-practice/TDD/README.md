# Model-lane TDD smoke tests

These tests are deliberately small user-perspective acceptance tests for the
seven commissioned LiteLLM lanes. They do not attempt to keep every model in
GPU memory simultaneously.

The test contract is:

- chat models receive a normal user message and must return non-empty text;
- the 1.5B base model receives the FIM `/v1/completions` shape used by
  autocomplete and must return non-empty inserted text;
- the embedding model receives `/v1/embeddings` and must return a non-empty
  vector;
- every request must return HTTP 200 without a context-window error;
- output is printed per model for the handoff receipt.

Run:

```bash
cd /Users/joshc/develop/dotfile-vnext
LITELLM_API_KEY='your-local-key' python3 TDD/test_model_lanes.py
```

The key is read from `LITELLM_API_KEY`; never commit a key or place one in the
test source. The default endpoint is `http://litellm.hom.lab/v1` and can be
overridden with `LITELLM_GATEWAY_ROOT`.
