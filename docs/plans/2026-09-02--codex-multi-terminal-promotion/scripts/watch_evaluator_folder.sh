#!/usr/bin/env bash
# Watch codex multi-terminal promotion plan folder for evaluator feedback files.
# Emits AGENT_LOOP_WAKE lines when folder state changes or satisfactory sign-off detected.
set -euo pipefail

PLAN_DIR="/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-02--codex-multi-terminal-promotion"
PURPOSE="evaluator-folder-watch"
INTERVAL="${EVAL_WATCH_INTERVAL_SEC:-60}"
STATE_FILE="${PLAN_DIR}/.evaluator-watch-state"
LOG_FILE="${PLAN_DIR}/.evaluator-watch.log"

log() {
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | tee -a "$LOG_FILE"
}

snapshot() {
  find "$PLAN_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
    | while read -r f; do
        base="$(basename "$f")"
        case "$base" in
          EVALUATOR-WAIT-STATE.md|README.md|EXECUTION-RECEIPT.md) continue ;;
          AI-*|*EVALUATION*|feedback_for_review*|ready_for_review*) ;;
          *) continue ;;
        esac
        stat -f '%N|%m|%z' "$f" 2>/dev/null
      done | sort
}

check_satisfactory() {
  local f
  for f in "$PLAN_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    case "$(basename "$f")" in
      EVALUATOR-WAIT-STATE.md|.evaluator-watch*) continue ;;
    esac
    if grep -qiE 'satisfactory|work is complete|complete and (done|approved)|approved for (close|completion)|sign-off|signed off|passes evaluation|evaluation: pass' "$f" 2>/dev/null; then
      if grep -qiE 'not satisfactory|unsatisfactory|incomplete|open finding|status: partial|pending' "$f" 2>/dev/null; then
        continue
      fi
      echo "$f"
      return 0
    fi
  done
  return 1
}

emit_wake() {
  local reason="$1"
  local prompt
  prompt=$(cat <<EOF
EVALUATOR_FOLDER_WAKE: ${reason}

Re-scan: ${PLAN_DIR}
Read any new/changed evaluator markdown (exclude EVALUATOR-WAIT-STATE.md).
If correction directives exist, apply per AI-CORRECTION-EVALUATION.md (P1 first).
If a file clearly states satisfactory/complete/approved, finish corrections, run fresh verification, update EVALUATOR-WAIT-STATE.md, create ready_for_review_by_evaluator_<timestamp>.md, then stop this watcher.
If still waiting, log status only; do not ask the user to ping you.
EOF
)
  log "WAKE: ${reason}"
  printf 'AGENT_LOOP_WAKE_%s %s\n' "$PURPOSE" "$(python3 -c 'import json,sys; print(json.dumps({"prompt":sys.stdin.read()}))' <<<"$prompt")"
}

log "Starting watcher interval=${INTERVAL}s dir=${PLAN_DIR}"
prev="$(snapshot || true)"
printf '%s' "$prev" >"$STATE_FILE"

while true; do
  sleep "$INTERVAL"
  cur="$(snapshot || true)"
  if [[ "$cur" != "$(cat "$STATE_FILE" 2>/dev/null || true)" ]]; then
    printf '%s' "$cur" >"$STATE_FILE"
    emit_wake "folder_changed"
    prev="$cur"
    continue
  fi
  if sat_file="$(check_satisfactory)"; then
    emit_wake "satisfactory_detected:${sat_file}"
  fi
done
