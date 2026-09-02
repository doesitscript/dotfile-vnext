#!/usr/bin/env bash
# Run Codex CLI acceptance against dotfile-vnext manifests.
# Usage:
#   run-codex-acceptance.sh [relative-manifest-under-codex/] [pytest args...]
# Examples:
#   run-codex-acceptance.sh
#   run-codex-acceptance.sh pending/tool-loop.yml -v -s
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GLOBAL_SKILLS_ROOT="${GLOBAL_SKILLS_ROOT:-$HOME/develop/global-skills}"
CODEX_DIR="$REPO_ROOT/model-lane-acceptance/codex"
WRAPPER="$GLOBAL_SKILLS_ROOT/skills/validation/homelab-codex-cli-model-pytest/scripts/run_codex_cli_model_pytest.py"

MANIFEST_REL="${1:-profiles-approved.yml}"
if [[ "$MANIFEST_REL" == pending/* ]] || [[ "$MANIFEST_REL" == profiles-* ]]; then
  shift || true
  MANIFEST="$CODEX_DIR/$MANIFEST_REL"
else
  MANIFEST="$CODEX_DIR/profiles-approved.yml"
fi

if [[ ! -f "$WRAPPER" ]]; then
  echo "error: Codex wrapper not found at $WRAPPER" >&2
  exit 2
fi
if [[ ! -f "$MANIFEST" ]]; then
  echo "error: manifest not found at $MANIFEST" >&2
  exit 2
fi

export CODEX_CLI_MODEL_PROFILE_MANIFEST="$MANIFEST"
export LITELLM_GATEWAY_ROOT="${LITELLM_GATEWAY_ROOT:-http://litellm.hom.lab}"

if [[ -x "$REPO_ROOT/bin/codex-env" ]]; then
  exec "$REPO_ROOT/bin/codex-env" python3 "$WRAPPER" "$@"
else
  exec python3 "$WRAPPER" "$@"
fi
