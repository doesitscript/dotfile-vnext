# Sources And Precedence

1. `/tmp/litellm-tools-capture/*.json` on the LiteLLM pod (full schemas)
2. Hook stdout: `tools_breakdown`, `trim_messages tool:`, `tool_params:`, `tool_desc_preview:`
3. Combined `/tmp/litellm-tools-structure-dump.json`
4. Local copy under `logs/litellm-tools-capture/` after `collect_tools_capture.sh`

Client Settings UIs (Cursor, Cline, etc.) are not an authority for schema byte counts.
The dump does not currently record which client sent the request.
