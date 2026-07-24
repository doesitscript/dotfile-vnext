# Sources And Precedence

When analyzing Cursor traffic through LiteLLM, prefer:

1. LiteLLM pod stdout lines from the pre-call hook (`trim_messages hook`, `tools_breakdown`)
2. Pod filesystem dumps under `/tmp/litellm-tools-capture/`
3. Role contract and diagnostics docs in-repo
4. Langfuse traces when the success callback is enabled
5. Cursor UI text last — it shows operator-visible history, not the post-trim API payload

Do not rank training recall above collected hook output for this stack.
