# Sources And Precedence

When analyzing Cursor traffic through LiteLLM, prefer:

1. LiteLLM pod stdout `litellm request_inspector` JSON (observe-only)
2. Pod filesystem dumps under `/tmp/litellm-tools-capture/` when capture is enabled
3. Role contract and current diagnostics stub in-repo
4. 5090 untuned→tuned model docs for weak coding-quality questions
5. Langfuse traces when the success callback is enabled
6. Cursor UI text last

**Do not** rank archived `trim_messages` mutate evidence as live remediation
(outdated 2026-09-09). Do not invent causes from training recall over hook output.
