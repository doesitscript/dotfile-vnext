#!/usr/bin/env bash
set -euo pipefail

PLAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PLAN_DIR/runtime"
HARNESS_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/implementer-closeout-proof.XXXXXX")"
PROOF_FILE="$RUNTIME_DIR/IMPLEMENTER-CLOSEOUT-PROOF.txt"
STATUS_FILE="$HARNESS_ROOT/runtime/IMPLEMENTER-RUNTIME-STATUS.txt"
HEARTBEAT_FILE="$HARNESS_ROOT/runtime/implementer-heartbeat.log"

cleanup() {
  rm -rf "$HARNESS_ROOT"
}

trap cleanup EXIT

cp -R "$PLAN_DIR/." "$HARNESS_ROOT/"

rm -f "$HARNESS_ROOT"/feedback_for_review_by_evaluator_*.md
rm -f "$HARNESS_ROOT/EVALUATOR-WAIT-STATE.md"
rm -f "$HARNESS_ROOT/coordination/EVALUATOR-RUNTIME-STATUS.txt"
rm -f "$HARNESS_ROOT/coordination/evaluator-heartbeat.log"
rm -f "$HARNESS_ROOT/coordination/evaluator-monitor.sh"
rm -f "$HARNESS_ROOT/runtime/IMPLEMENTER-CLOSEOUT-PROOF.txt"

bash "$HARNESS_ROOT/runtime/implementer-monitor.sh" >/dev/null

status_after="$(cat "$STATUS_FILE")"
heartbeat_count_before="$(wc -l < "$HEARTBEAT_FILE" | tr -d ' ')"
sleep 1
heartbeat_count_after="$(wc -l < "$HEARTBEAT_FILE" | tr -d ' ')"

{
  printf 'proof_ran_at=%s\n' "$(date '+%Y-%m-%dT%H:%M:%S')"
  printf 'sandbox_root=%s\n' "$HARNESS_ROOT"
  printf 'resolver_target=latest ready artifact with no newer implementer change\n'
  printf 'status_after=%s\n' "$status_after"
  printf 'heartbeat_lines_before=%s\n' "$heartbeat_count_before"
  printf 'heartbeat_lines_after=%s\n' "$heartbeat_count_after"
  if [[ "$status_after" == *"next actor: none"* ]] && [[ "$status_after" == *"monitor: stopped"* ]] && [[ "$heartbeat_count_before" == "$heartbeat_count_after" ]]; then
    printf 'result=pass\n'
  else
    printf 'result=fail\n'
    exit 1
  fi
} > "$PROOF_FILE"
