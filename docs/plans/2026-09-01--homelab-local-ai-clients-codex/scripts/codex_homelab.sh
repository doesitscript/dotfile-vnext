#!/usr/bin/env bash
# Concurrent editing note: Codex owns this local launcher; Cursor should not rewrite it.
# Start a named local Codex profile with a short-lived key read from the live LiteLLM secret.

set -euo pipefail

profile_name="${1:-}"
if [[ -z "$profile_name" ]]; then
  printf '%s\n' 'Usage: codex-homelab <fast|tools|deep> [codex arguments...]' >&2
  exit 2
fi
shift

case "$profile_name" in
  fast) codex_profile="local-fast" ;;
  tools) codex_profile="local-tools" ;;
  deep) codex_profile="local-deep" ;;
  *)
    printf 'Unknown local profile: %s\n' "$profile_name" >&2
    printf '%s\n' 'Choose one of: fast, tools, deep.' >&2
    exit 2
    ;;
esac

gateway_key="$({
  ssh -o BatchMode=yes hom-lab-ctl-k3s-02 \
    "kubectl -n litellm get secret litellm-env-secret -o jsonpath='{.data.PROXY_MASTER_KEY}' | base64 -d"
} )"

if [[ -z "$gateway_key" ]]; then
  printf '%s\n' 'LiteLLM returned an empty gateway key.' >&2
  exit 1
fi

export LITELLM_API_KEY="$gateway_key"
exec codex --profile "$codex_profile" "$@"
