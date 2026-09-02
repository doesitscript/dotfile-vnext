#!/usr/bin/env bash
# ONE-OFF TRIAL — source: docs/one_off_tasks/codex-multi-terminal-workflow/deploy/bin/
# Install: deploy/install_one_off_tasks.sh → ~/bin/codex-homelab_one_off_tasks
# Homelab Codex launcher with _one_off_tasks profile names and isolated desktop home.

set -euo pipefail

profile_name="${1:-}"
if [[ -z "$profile_name" ]]; then
  printf '%s\n' \
    'Usage: codex-homelab_one_off_tasks <deep|desktop|fast|hvh01|tools> [codex arguments...]' >&2
  exit 2
fi
shift

case "$profile_name" in
  fast) codex_profile="local-fast_one_off_tasks" ;;
  desktop)
    export CODEX_HOME="${HOME}/.codex-homelab/desktop_one_off_tasks"
    codex_profile=""
    ;;
  hvh01) codex_profile="local-hvh01_one_off_tasks" ;;
  tools) codex_profile="local-tools_one_off_tasks" ;;
  deep) codex_profile="local-deep_one_off_tasks" ;;
  *)
    printf 'Unknown local profile: %s\n' "$profile_name" >&2
    printf '%s\n' 'Choose one of: deep, desktop, fast, hvh01, tools.' >&2
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

if [[ "${1:-}" == "exec" ]]; then
  shift
  if [[ -n "$codex_profile" ]]; then
    exec codex --profile "$codex_profile" exec "$@"
  fi
  exec codex exec "$@"
fi

if [[ -n "$codex_profile" ]]; then
  exec codex --profile "$codex_profile" "$@"
fi
exec codex "$@"
