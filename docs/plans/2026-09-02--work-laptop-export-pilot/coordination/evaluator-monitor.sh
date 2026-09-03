#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plan_dir="$(cd "$script_dir/.." && pwd)"
coord_dir="$plan_dir/coordination"
status_file="$coord_dir/evaluator-monitor-status.md"
log_file="$coord_dir/evaluator-monitor-events.log"
poll_seconds="${POLL_SECONDS:-5}"
heartbeat_seconds="${HEARTBEAT_SECONDS:-60}"
last_sig=""
last_change="none yet"
last_heartbeat_epoch=0

iso_now() {
  date +%Y-%m-%dT%H:%M:%S
}

watched_signature() {
  {
    stat -f '%m %N' "$plan_dir/README.md" 2>/dev/null
    stat -f '%m %N' "$coord_dir/implementation-accounting.md" 2>/dev/null
    find "$coord_dir" -maxdepth 1 -type f \
      \( -name 'implementer-after-action-*.md' -o -name 'implementer-rereview-request-*.md' -o -name 'implementer-runtime-correction-*.md' \) \
      -exec stat -f '%m %N' {} + 2>/dev/null
    find "$plan_dir" -maxdepth 1 -type f \
      \( -name 'feedback_for_review_by_evaluator_*' -o -name 'waiting_for_review_by_evaluator_*' -o -name 'ready_for_review_by_evaluator_*' \) \
      -exec stat -f '%m %N' {} + 2>/dev/null
  } | sort
}

latest_evaluator_path() {
  find "$plan_dir" -maxdepth 1 -type f \
    \( -name 'feedback_for_review_by_evaluator_*' -o -name 'waiting_for_review_by_evaluator_*' -o -name 'ready_for_review_by_evaluator_*' \) \
    -exec stat -f '%m %N' {} + 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-
}

latest_evaluator_name() {
  local path
  path="$(latest_evaluator_path)"
  if [[ -n "$path" ]]; then
    basename "$path"
  else
    echo none
  fi
}

latest_evaluator_mtime() {
  local path
  path="$(latest_evaluator_path)"
  if [[ -n "$path" ]]; then
    stat -f '%m' "$path"
  else
    echo 0
  fi
}

latest_implementer_governed_mtime() {
  {
    stat -f '%m' "$plan_dir/README.md" 2>/dev/null
    stat -f '%m' "$coord_dir/implementation-accounting.md" 2>/dev/null
    find "$coord_dir" -maxdepth 1 -type f \
      \( -name 'implementer-after-action-*.md' -o -name 'implementer-rereview-request-*.md' -o -name 'implementer-runtime-correction-*.md' \) \
      -exec stat -f '%m' {} + 2>/dev/null
  } | sort -nr | head -n 1
}

computed_next_actor() {
  local evaluator_name evaluator_mtime implementer_mtime
  evaluator_name="$(latest_evaluator_name)"
  evaluator_mtime="$(latest_evaluator_mtime)"
  implementer_mtime="$(latest_implementer_governed_mtime)"

  if (( implementer_mtime > evaluator_mtime )); then
    echo evaluator
  elif [[ "$evaluator_name" == feedback_for_review_by_evaluator_* ]] || [[ "$evaluator_name" == waiting_for_review_by_evaluator_* ]]; then
    echo implementer
  elif [[ "$evaluator_name" == ready_for_review_by_evaluator_* ]]; then
    echo none
  else
    echo evaluator
  fi
}

write_status() {
  local now="$1"
  local disposition="$2"
  local actor="$3"
  local latest_evaluator_artifact
  latest_evaluator_artifact="$(latest_evaluator_name)"
  cat > "$status_file" <<EOF
---
title: evaluator monitor status
created_at: 2026-09-02T225344
updated_at: $now
author: evaluator-simple
mode: polling
poll_interval_seconds: $poll_seconds
plan: 2026-09-02--work-laptop-export-pilot
status: active
---

# Evaluator monitor status

- Purpose: visible runtime state for the evaluator-side polling loop
- Scope watched:
  - README.md
  - coordination/implementation-accounting.md
  - coordination/implementer-after-action-*.md
  - coordination/implementer-rereview-request-*.md
  - coordination/implementer-runtime-correction-*.md
- Resolver rule: newest review-relevant implementer change vs latest evaluator artifact decides the next actor
- Current disposition: $disposition
- Latest evaluator artifact: $latest_evaluator_artifact
- Computed next actor: $actor
- Last observed state change: $last_change
- Output files:
  - coordination/evaluator-monitor-status.md
  - coordination/evaluator-monitor-events.log
- Limitation: this monitor can detect and record changed plan state, but a real evaluator review still requires a new model execution turn
EOF
}

log_event() {
  local line="$1"
  printf '[%s] %s\n' "$(iso_now)" "$line" >> "$log_file"
}

log_event "live evaluator monitor script started"
write_status "$(iso_now)" "active polling; no new implementer change detected since script start" "$(computed_next_actor)"
echo "[$(iso_now)] live evaluator monitor started for $plan_dir"

while true; do
  now="$(iso_now)"
  sig="$(watched_signature)"
  if [[ "$sig" != "$last_sig" ]]; then
    last_change="$now"
    actor="$(computed_next_actor)"
    log_event "observed governed-state change; computed next actor: $actor"
    printf '%s\n' "$sig" | tail -n 10 >> "$log_file"
    write_status "$now" "change detected; computed next actor updated" "$actor"
    echo "[$now] evaluator monitor observed governed-state change; next actor: $actor"
    last_sig="$sig"
  else
    current_epoch="$(date +%s)"
    if (( last_heartbeat_epoch == 0 || current_epoch - last_heartbeat_epoch >= heartbeat_seconds )); then
      actor="$(computed_next_actor)"
      log_event "heartbeat: no new governed-state change; computed next actor: $actor"
      write_status "$now" "active polling; no new governed-state change detected" "$actor"
      echo "[$now] evaluator monitor heartbeat; next actor: $actor"
      last_heartbeat_epoch="$current_epoch"
    fi
  fi
  sleep "$poll_seconds"
done
