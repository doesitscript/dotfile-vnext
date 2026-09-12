#!/usr/bin/env bash
# Run the shared LiteLLM model-lane skill against all five pending candidates.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GLOBAL_SKILLS_ROOT="${GLOBAL_SKILLS_ROOT:-$HOME/develop/global-skills}"
RUNNER="$GLOBAL_SKILLS_ROOT/skills/validation/homelab-litellm-model-lane-pytest/scripts/run_model_lane_pytest.py"
MANIFEST="$REPO_ROOT/model-lane-acceptance/gateway/pending/model-iteration-2026-09-11.yml"

if [[ ! -f "$RUNNER" ]]; then
  echo "error: shared model-lane harness not found at $RUNNER" >&2
  exit 2
fi

export LITELLM_MODEL_LANE_MANIFEST="$MANIFEST"
export LITELLM_GATEWAY_ROOT="${LITELLM_GATEWAY_ROOT:-http://litellm.hom.lab}"

if [[ -x "$REPO_ROOT/bin/codex-env" ]]; then
  exec "$REPO_ROOT/bin/codex-env" python3 "$RUNNER" "$@"
fi
exec python3 "$RUNNER" "$@"
