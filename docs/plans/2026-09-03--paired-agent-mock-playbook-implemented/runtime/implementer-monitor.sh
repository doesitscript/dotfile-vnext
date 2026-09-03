#!/usr/bin/env bash
set -euo pipefail

# Advisory implementer poller for this plan packet.
# Its files record last observed state only; they do not prove a live process to
# a static evaluator.

PLAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PLAN_DIR/runtime"
STATUS_FILE="$RUNTIME_DIR/IMPLEMENTER-RUNTIME-STATUS.txt"
HEARTBEAT_LOG="$RUNTIME_DIR/implementer-heartbeat.log"
POLL_SECONDS="${POLL_SECONDS:-5}"

mkdir -p "$RUNTIME_DIR"

last_next_actor=""
idle_since=""

mtime_of() {
  stat -f '%m' "$1"
}

latest_eval_file() {
  find "$PLAN_DIR" -maxdepth 1 -type f \
    \( -name 'feedback_for_review_by_evaluator_*' \
    -o -name 'waiting_for_review_by_evaluator_*' \
    -o -name 'ready_for_review_by_evaluator_*' \) \
    -exec stat -f '%m %N' {} + 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-
}

latest_impl_file() {
  find "$PLAN_DIR" -type f \
    ! -path "$RUNTIME_DIR/*" \
    ! -name 'EVALUATOR-WAIT-STATE.md' \
    ! -path "$PLAN_DIR/coordination/EVALUATOR-RUNTIME-STATUS.txt" \
    ! -path "$PLAN_DIR/coordination/evaluator-heartbeat.log" \
    ! -path "$PLAN_DIR/coordination/evaluator-monitor.sh" \
    ! -name 'feedback_for_review_by_evaluator_*' \
    ! -name 'waiting_for_review_by_evaluator_*' \
    ! -name 'ready_for_review_by_evaluator_*' \
    ! -name 'FINAL-POST-SIGNOFF-IMPROVEMENT-REPORT.md' \
    -exec stat -f '%m %N' {} + 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-
}

compute_next_actor() {
  local eval_file impl_file eval_mtime impl_mtime eval_base

  eval_file="$(latest_eval_file || true)"
  impl_file="$(latest_impl_file || true)"

  if [[ -z "$eval_file" ]]; then
    printf 'evaluator\n'
    return 0
  fi

  eval_mtime="$(mtime_of "$eval_file")"
  impl_mtime=0
  if [[ -n "$impl_file" ]]; then
    impl_mtime="$(mtime_of "$impl_file")"
  fi

  eval_base="$(basename "$eval_file")"
  case "$eval_base" in
    ready_for_review_by_evaluator_*)
      if (( eval_mtime >= impl_mtime )); then
        printf 'none\n'
      else
        printf 'evaluator\n'
      fi
      ;;
    feedback_for_review_by_evaluator_*|waiting_for_review_by_evaluator_*)
      if (( eval_mtime > impl_mtime )); then
        printf 'implementer\n'
      else
        printf 'evaluator\n'
      fi
      ;;
    *)
      printf 'evaluator\n'
      ;;
  esac
}

write_status() {
  local next_actor="$1"
  local monitor_state="$2"
  local now

  now="$(date '+%Y-%m-%dT%H:%M:%S')"
  if [[ "$next_actor" != "$last_next_actor" || -z "$idle_since" ]]; then
    idle_since="$now"
    last_next_actor="$next_actor"
  fi

  printf 'Status: implementer active | next actor: %s | monitor: %s | idle since: %s\n' \
    "$next_actor" "$monitor_state" "$idle_since" > "$STATUS_FILE"
}

shutdown() {
  local final_actor
  final_actor="$(compute_next_actor || printf 'evaluator\n')"
  write_status "$final_actor" "stopped"
}

trap shutdown EXIT INT TERM

while true; do
  next_actor="$(compute_next_actor)"
  write_status "$next_actor" "running"
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$(cat "$STATUS_FILE")" >> "$HEARTBEAT_LOG"
  cat "$STATUS_FILE"
  if [[ "$next_actor" == "none" ]]; then
    break
  fi
  sleep "$POLL_SECONDS"
done
