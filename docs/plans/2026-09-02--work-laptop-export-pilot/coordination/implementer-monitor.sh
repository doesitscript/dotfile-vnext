#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plan_dir="$(cd "$script_dir/.." && pwd)"
coord_dir="$plan_dir/coordination"
status_file="$coord_dir/implementer-monitor-status.md"
log_file="$coord_dir/implementer-monitor-events.log"
poll_seconds="${POLL_SECONDS:-5}"
heartbeat_seconds="${HEARTBEAT_SECONDS:-60}"
created_at="2026-09-02T230800"
last_sig=""
last_change="none yet"
last_heartbeat_epoch=0

iso_now() {
  date +%Y-%m-%dT%H:%M:%S
}

watched_signature() {
  {
    review_relevant_implementer_files | while read -r f; do
      [[ -n "$f" ]] && stat -f '%m %N' "$f" 2>/dev/null
    done
    review_relevant_evaluator_files | while read -r f; do
      [[ -n "$f" ]] && stat -f '%m %N' "$f" 2>/dev/null
    done
  } | sort
}

latest_file() {
  local pattern="$1"
  find "$plan_dir" -maxdepth 1 -type f -name "$pattern" | sort | tail -n 1
}

review_relevant_implementer_files() {
  printf '%s\n' \
    "$plan_dir/README.md" \
    "$coord_dir/implementation-accounting.md"
  find "$coord_dir" -maxdepth 1 -type f \
    \( -name 'implementer-after-action-*.md' \
    -o -name 'implementer-rereview-request-*.md' \
    -o -name 'implementer-runtime-correction-*.md' \) | sort
}

review_relevant_evaluator_files() {
  printf '%s\n' "$plan_dir/EVALUATOR-WAIT-STATE.md"
  find "$plan_dir" -maxdepth 1 -type f \
    \( -name 'feedback_for_review_by_evaluator_*.md' \
    -o -name 'waiting_for_review_by_evaluator_*.md' \
    -o -name 'ready_for_review_by_evaluator_*.md' \) | sort
}

frontmatter_value() {
  local file="$1"
  local key="$2"
  if [[ -f "$file" ]]; then
    awk -F': ' -v key="$key" '$1 == key {print $2; exit}' "$file"
  fi
}

mtime_epoch() {
  local file="$1"
  if [[ -f "$file" ]]; then
    stat -f '%m' "$file"
  else
    printf '0\n'
  fi
}

newest_implementer_governed_file() {
  local newest_file=""
  local newest_epoch=0
  while read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    local epoch
    epoch="$(mtime_epoch "$f")"
    if (( epoch >= newest_epoch )); then
      newest_epoch="$epoch"
      newest_file="$f"
    fi
  done < <(review_relevant_implementer_files)
  printf '%s\n' "$newest_file"
}

compute_disposition() {
  local evaluator_wait="$1"
  local latest_feedback="$2"
  local latest_waiting="$3"
  local latest_ready="$4"
  local evaluator_status
  local evaluator_loop_mode
  local action_state
  local disposition
  local latest_evaluator_artifact=""
  local latest_evaluator_class="none"
  local newest_implementer_file=""
  local next_actor="none"

  evaluator_status="$(frontmatter_value "$evaluator_wait" "status")"
  evaluator_loop_mode="$(frontmatter_value "$evaluator_wait" "loop_mode")"

  newest_implementer_file="$(newest_implementer_governed_file)"

  if (( $(mtime_epoch "$latest_ready") >= $(mtime_epoch "$latest_feedback") && $(mtime_epoch "$latest_ready") >= $(mtime_epoch "$latest_waiting") )); then
    latest_evaluator_artifact="$latest_ready"
    [[ -n "$latest_ready" ]] && latest_evaluator_class="ready"
  elif (( $(mtime_epoch "$latest_feedback") >= $(mtime_epoch "$latest_waiting") )); then
    latest_evaluator_artifact="$latest_feedback"
    [[ -n "$latest_feedback" ]] && latest_evaluator_class="feedback"
  else
    latest_evaluator_artifact="$latest_waiting"
    [[ -n "$latest_waiting" ]] && latest_evaluator_class="waiting"
  fi

  if (( $(mtime_epoch "$newest_implementer_file") > $(mtime_epoch "$latest_evaluator_artifact") )); then
    next_actor="evaluator"
    action_state="waiting-for-evaluator-review"
    disposition="review-relevant implementer change is newer than the latest evaluator artifact"
  elif [[ "$latest_evaluator_class" == "feedback" || "$latest_evaluator_class" == "waiting" ]]; then
    next_actor="implementer"
    action_state="implementer-action-required"
    disposition="latest evaluator artifact requires implementer action"
  elif [[ "$latest_evaluator_class" == "ready" ]]; then
    next_actor="none"
    action_state="approved-no-implementer-work-pending"
    disposition="approved; monitor active for reopen events only"
  else
    next_actor="implementer"
    action_state="waiting-for-evaluator-artifact"
    disposition="no evaluator artifact found yet"
  fi

  printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
    "$evaluator_status" \
    "$evaluator_loop_mode" \
    "$action_state" \
    "$disposition" \
    "$next_actor" \
    "$latest_evaluator_class" \
    "$newest_implementer_file"
}

write_status() {
  local now="$1"
  local evaluator_status="$2"
  local evaluator_loop_mode="$3"
  local action_state="$4"
  local disposition="$5"
  local next_actor="$6"
  local latest_evaluator_class="$7"
  local latest_feedback="$8"
  local latest_ready="$9"
  local newest_implementer_file="${10}"
  cat > "$status_file" <<EOF
---
title: implementer monitor status
created_at: $created_at
updated_at: $now
author: plan-implementer
mode: polling
poll_interval_seconds: $poll_seconds
plan: 2026-09-02--work-laptop-export-pilot
status: active
---

# Implementer monitor status

- Purpose: visible runtime state for the implementer-side polling loop
- Scope watched:
  - README.md
  - EVALUATOR-WAIT-STATE.md
  - review-relevant evaluator artifacts only
  - coordination/implementation-accounting.md
  - coordination/implementer-after-action-*.md
  - coordination/implementer-rereview-request-*.md
  - coordination/implementer-runtime-correction-*.md
- Resolver rule: newest review-relevant implementer change vs latest evaluator artifact decides the next actor
- Evaluator status: $evaluator_status
- Evaluator loop mode: ${evaluator_loop_mode:-unknown}
- Latest evaluator artifact class: $latest_evaluator_class
- Computed next actor: $next_actor
- Action state: $action_state
- Current disposition: $disposition
- Latest feedback artifact: ${latest_feedback##*/}
- Latest approved artifact: ${latest_ready##*/}
- Newest review-relevant implementer file: ${newest_implementer_file##*/}
- Last observed state change: $last_change
- Output files:
  - coordination/implementer-monitor-status.md
  - coordination/implementer-monitor-events.log
- Runtime correction: this monitor distinguishes approved-complete monitoring from
  waiting-on-evaluator so the two roles do not both present as blocked on each other
EOF
}

log_event() {
  local line="$1"
  printf '[%s] %s\n' "$(iso_now)" "$line" >> "$log_file"
}

log_event "implementer monitor script started"

while true; do
  now="$(iso_now)"
  sig="$(watched_signature)"
  evaluator_wait="$plan_dir/EVALUATOR-WAIT-STATE.md"
  latest_feedback="$(latest_file 'feedback_for_review_by_evaluator_*.md')"
  latest_waiting="$(latest_file 'waiting_for_review_by_evaluator_*.md')"
  latest_ready="$(latest_file 'ready_for_review_by_evaluator_*.md')"
  mapfile -t disposition_lines < <(compute_disposition "$evaluator_wait" "$latest_feedback" "$latest_waiting" "$latest_ready")
  evaluator_status="${disposition_lines[0]}"
  evaluator_loop_mode="${disposition_lines[1]}"
  action_state="${disposition_lines[2]}"
  disposition="${disposition_lines[3]}"
  next_actor="${disposition_lines[4]}"
  latest_evaluator_class="${disposition_lines[5]}"
  newest_implementer_file="${disposition_lines[6]}"

  if [[ "$sig" != "$last_sig" ]]; then
    last_change="$now"
    log_event "observed plan-folder state change; next_actor=$next_actor action_state=$action_state"
    write_status "$now" "$evaluator_status" "$evaluator_loop_mode" "$action_state" "$disposition" "$next_actor" "$latest_evaluator_class" "$latest_feedback" "$latest_ready" "$newest_implementer_file"
    echo "[$now] implementer monitor observed plan-folder state change ($next_actor / $action_state)"
    last_sig="$sig"
  else
    current_epoch="$(date +%s)"
    if (( last_heartbeat_epoch == 0 || current_epoch - last_heartbeat_epoch >= heartbeat_seconds )); then
      log_event "heartbeat: next_actor=$next_actor action_state=$action_state"
      write_status "$now" "$evaluator_status" "$evaluator_loop_mode" "$action_state" "$disposition" "$next_actor" "$latest_evaluator_class" "$latest_feedback" "$latest_ready" "$newest_implementer_file"
      echo "[$now] implementer monitor heartbeat ($next_actor / $action_state)"
      last_heartbeat_epoch="$current_epoch"
    fi
  fi
  sleep "$poll_seconds"
done
