#!/usr/bin/env bash
# Read-only terminal view for one parent-owned multiagents implementation run.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: watch-implementation-output.sh --session-id ID --run-dir DIR [--endpoint URL] [--interval SECONDS] [--once] [--clear]

Polls the multiagents broker's /slots/list and /list-peers endpoints with curl
and renders slot states, the current agent summaries, and newest durable runner
event. It never sends a message, releases a slot, starts a service, or changes
the campaign.
EOF
}

session_id='' run_dir='' endpoint='http://127.0.0.1:7899' interval=5 once=false clear=false
while (($#)); do
  case "$1" in
    --session-id) session_id=${2:?}; shift 2 ;;
    --run-dir) run_dir=${2:?}; shift 2 ;;
    --endpoint) endpoint=${2:?}; shift 2 ;;
    --interval) interval=${2:?}; shift 2 ;;
    --once) once=true; shift ;;
    --clear) clear=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done
[[ -n "$session_id" && -n "$run_dir" ]] || { usage >&2; exit 2; }
[[ "$interval" =~ ^[1-9][0-9]*$ ]] || { printf '%s\n' '--interval must be a positive integer' >&2; exit 2; }

color() { [[ -t 1 ]] && printf '\033[%sm' "$1"; }
reset() { [[ -t 1 ]] && printf '\033[0m'; }
say() { color "$1"; printf '%s' "$2"; reset; }
latest_event() {
  [[ -f "$run_dir/events.jsonl" ]] || return 0
  tail -n 1 "$run_dir/events.jsonl" | jq -r 'if type == "object" then [.time, .event, (.pass // .status // .next_actor // "")] | map(select(. != "")) | join("  ") else empty end' 2>/dev/null || true
}
render() {
  local raw=$1 peers_raw=$2 slots peers event
  slots=$(printf '%s' "$raw" | jq -c 'if type == "array" then . elif (.slots? | type) == "array" then .slots elif (.data? | type) == "array" then .data else [] end') || { say '31' 'Broker returned invalid slot JSON'; printf '\n'; return 1; }
  peers=$(printf '%s' "$peers_raw" | jq -c 'if type == "array" then . else [] end') || peers='[]'
  "$clear" && [[ -t 1 ]] && printf '\033[2J\033[H'
  say '1;36' 'Multiagents implementation monitor'; printf '  session %s  updated %s\n' "$session_id" "$(date '+%H:%M:%S')"
  printf '%-14s %-14s %-14s %s\n' 'ROLE' 'CONNECTION' 'TASK' 'DETAIL'
  printf '%-14s %-14s %-14s %s\n' '--------------' '--------------' '--------------' '----------------------------'
  while IFS=$'\t' read -r role connection task detail; do
    case "$connection/$task" in
      connected/working) say '32' "$(printf '%-14s' "$role")" ;;
      connected/approved) say '36' "$(printf '%-14s' "$role")" ;;
      disconnected/*) say '31' "$(printf '%-14s' "$role")" ;;
      *) say '33' "$(printf '%-14s' "$role")" ;;
    esac
    printf ' %-14s %-14s %s\n' "$connection" "$task" "$detail"
  done < <(printf '%s' "$slots" | jq -r --argjson peers "$peers" '
    .[] as $slot |
    (($peers | map(select(.id == $slot.peer_id)) | first | .summary) //
     (try ($slot.context_snapshot | fromjson | .last_summary) catch null) //
     $slot.health // $slot.adapter // "") as $detail |
    [($slot.display_name // $slot.role // "unknown"), ($slot.status // "unknown"), ($slot.task_state // "unknown"), $detail] | @tsv')
  event=$(latest_event)
  if [[ -n "$event" ]]; then say '35' 'Latest durable event: '; printf '%s\n' "$event"; fi
  printf 'Dashboard: http://127.0.0.1:7900  |  Ctrl-C stops this monitor only.\n'
}

while true; do
  if raw=$(curl --fail --silent --show-error --max-time 5 -X POST "$endpoint/slots/list" -H 'Content-Type: application/json' --data "{\"session_id\":$(jq -Rn --arg v "$session_id" '$v')}" 2>&1); then
    peers=$(curl --fail --silent --show-error --max-time 5 -X POST "$endpoint/list-peers" -H 'Content-Type: application/json' --data "{\"scope\":\"machine\",\"cwd\":$(jq -Rn --arg v "$run_dir" '$v'),\"git_root\":null,\"session_id\":$(jq -Rn --arg v "$session_id" '$v')}" 2>/dev/null || printf '[]')
    render "$raw" "$peers" || true
  else
    say '31' 'Broker query failed: '; printf '%s\n' "$raw"
  fi
  "$once" && exit 0
  sleep "$interval"
done
