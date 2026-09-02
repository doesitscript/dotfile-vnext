#!/usr/bin/env bash
# Concurrent editing note: Codex owns this catalog renderer; Cursor should not rewrite it.
# Render a small Codex model catalog without copying the full cloud-model instruction set.

set -euo pipefail

codex_home="${CODEX_HOME:-$HOME/.codex}"
cache_path="${codex_home}/models_cache.json"
output_path="${1:-${codex_home}/local-model-catalog.json}"

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' 'jq is required to render the local Codex model catalog.' >&2
  exit 1
fi

if [[ ! -s "$cache_path" ]]; then
  printf 'Codex model cache is missing: %s\n' "$cache_path" >&2
  exit 1
fi

# Keep Codex's current schema fields, but use short local instructions and real service limits.
jq '
  (.models[0]) as $base
  | if $base == null then error("models_cache.json contains no models") else . end
  | {
      models: (
        [
          {slug: "qwen2.5-coder-7b@desktop", name: "Homelab Qwen2.5 Coder 7B", context: 24000},
          {slug: "qwen2.5-coder-14b@desktop", name: "Homelab Qwen2.5 Coder 14B", context: 12000},
          {slug: "ministral-3-8b@desktop", name: "Homelab Ministral 3 8B", context: 24000},
          {slug: "qwen2.5-coder-32b@k3s02-vllm", name: "Homelab Qwen2.5 Coder 32B", context: 28000}
        ]
        | map(
            . as $local
            | $base
            | .slug = $local.slug
            | .display_name = $local.name
            | .description = "Local model routed through the homelab LiteLLM gateway."
            | .context_window = $local.context
            | .max_context_window = $local.context
            | .effective_context_window_percent = 90
            | .base_instructions = "You are a local coding assistant. Use concise responses and only the tools supplied by Codex."
            | .supports_reasoning_summaries = false
            | .supports_parallel_tool_calls = false
            | .model_messages.instructions_template = "You are a local coding assistant. Use concise responses and only the tools supplied by Codex."
            | .model_messages.instructions_variables = {}
            | .include_skills_usage_instructions = false
            | .include_plugin_usage_instructions = false
            | .include_apps_usage_instructions = false
            | .input_modalities = ["text"]
            | .supports_search_tool = false
          )
      )
    }' "$cache_path" >"$output_path"

jq -e '.models | length == 4' "$output_path" >/dev/null
printf 'Rendered local Codex model catalog: %s\n' "$output_path"
