#!/usr/bin/env bash
# Run gateway model-lane acceptance against dotfile-vnext manifests.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GLOBAL_SKILLS_ROOT="${GLOBAL_SKILLS_ROOT:-$HOME/develop/global-skills}"
RUNNER="$GLOBAL_SKILLS_ROOT/skills/validation/homelab-litellm-model-lane-pytest/scripts/run_model_lane_pytest.py"
MANIFEST="$REPO_ROOT/model-lane-acceptance/gateway/manifest.yml"

if [[ ! -f "$RUNNER" ]]; then
  echo "error: harness not found at $RUNNER" >&2
  echo "set GLOBAL_SKILLS_ROOT to your global-skills checkout" >&2
  exit 2
fi

export LITELLM_MODEL_LANE_MANIFEST="$MANIFEST"
export LITELLM_GATEWAY_ROOT="${LITELLM_GATEWAY_ROOT:-http://litellm.hom.lab}"

if [[ -x "$REPO_ROOT/bin/codex-env" ]]; then
  exec "$REPO_ROOT/bin/codex-env" python3 "$RUNNER" "$@"
else
  exec python3 "$RUNNER" "$@"
fi
