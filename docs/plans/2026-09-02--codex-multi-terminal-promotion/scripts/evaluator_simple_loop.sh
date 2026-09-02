#!/usr/bin/env bash
# Periodically evaluate the codex multi-terminal promotion packet and emit
# timestamped evaluator files until the work is satisfactory.

set -euo pipefail
unset LC_ALL
unset LC_CTYPE
export LANG="${LANG:-en_US.UTF-8}"

REPO_DIR="/Users/joshc/develop/dotfile-vnext"
PLAN_DIR="${REPO_DIR}/docs/plans/2026-09-02--codex-multi-terminal-promotion"
INTERVAL_SEC="${EVALUATOR_SIMPLE_INTERVAL_SEC:-3600}"
RUN_ONCE="${EVALUATOR_SIMPLE_ONCE:-0}"

PID_FILE="${PLAN_DIR}/.evaluator-simple-loop.pid"
STATE_FILE="${PLAN_DIR}/.evaluator-simple-loop.state"
LOG_FILE="${PLAN_DIR}/.evaluator-simple-loop.log"

PLAN_README="${PLAN_DIR}/README.md"
EXECUTION_RECEIPT="${PLAN_DIR}/EXECUTION-RECEIPT.md"
WAIT_STATE_DOC="${PLAN_DIR}/EVALUATOR-WAIT-STATE.md"
SELF_SCRIPT="${PLAN_DIR}/scripts/evaluator_simple_loop.sh"
FZF_ABSENT="${REPO_DIR}/roles/fzf_tab_completion/tasks/absent.yml"
CODEX_MAC="${REPO_DIR}/roles/codex_homelab_profiles/tasks/mac.yml"
CODEX_MULTI="${REPO_DIR}/roles/codex_homelab_profiles/tasks/multi_terminal.yml"
CODEX_ABSENT="${REPO_DIR}/roles/codex_homelab_profiles/tasks/multi_terminal_absent.yml"
SHELL_CONFIG="${REPO_DIR}/roles/common/shell_config/tasks/unix.yml"
FZF_README="${REPO_DIR}/roles/fzf_tab_completion/README.md"
CODEX_README="${REPO_DIR}/roles/codex_homelab_profiles/README.md"
SKILLS_CATALOG="${REPO_DIR}/skills/catalog.yaml"
SKILLS_ROOT="${REPO_DIR}/skills/one-off"
PERSISTENCE_PREVIOUS_FEEDBACK=""
PERSISTENCE_MATCHED="0"

log() {
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | tee -a "$LOG_FILE" >/dev/null
}

timestamp_compact() {
  date '+%Y-%m-%dT%H%M%S'
}

timestamp_human() {
  date '+%Y-%m-%d %H:%M:%S %Z'
}

cleanup() {
  rm -f "$PID_FILE"
}

already_running() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

snapshot() {
  local files=(
    "$PLAN_README"
    "$EXECUTION_RECEIPT"
    "$WAIT_STATE_DOC"
    "$SELF_SCRIPT"
    "$FZF_ABSENT"
    "$CODEX_MAC"
    "$CODEX_MULTI"
    "$CODEX_ABSENT"
    "$SHELL_CONFIG"
    "$FZF_README"
    "$CODEX_README"
    "$SKILLS_CATALOG"
  )
  while IFS= read -r file; do
    files+=("$file")
  done < <(find "$SKILLS_ROOT" -type f \( -name 'SKILL.md' -o -name '*.md' \) | sort)

  local file
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      shasum -a 256 "$file"
    else
      printf 'missing  %s\n' "$file"
    fi
  done
}

record_check() {
  local label="$1"
  local result="$2"
  local detail="$3"
  CHECK_ROWS+=("| \`$label\` | $result | $detail |")
}

add_blocker() {
  local msg="$1"
  BLOCKERS+=("$msg")
}

validator_output() {
  local cmd="$1"
  set +e
  local out
  out="$(bash -lc "cd '$REPO_DIR' && $cmd" 2>&1)"
  local rc=$?
  set -e
  printf '%s\nRC=%s\n' "$out" "$rc"
}

contains_all() {
  local text="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$text" == *"$item"* ]] || return 1
  done
}

extract_line() {
  local pattern="$1"
  local file="$2"
  rg -n "$pattern" "$file" | head -n 1 || true
}

feedback_blockers_text() {
  local file="$1"
  awk '
    /^## Open blockers/ { in_blockers=1; next }
    /^## / && in_blockers { exit }
    in_blockers && /^- / {
      sub(/^- /, "", $0)
      print
    }
  ' "$file"
}

assess_blocker_persistence() {
  PERSISTENCE_PREVIOUS_FEEDBACK=""
  PERSISTENCE_MATCHED="0"

  local latest current_text previous_text
  latest="$(ls -1t "${PLAN_DIR}"/feedback_for_review_by_evaluator_simple_*.md 2>/dev/null | head -n 1 || true)"
  [[ -n "$latest" ]] || return 0

  previous_text="$(feedback_blockers_text "$latest" | LC_ALL=C sort || true)"
  current_text="$(printf '%s\n' "${BLOCKERS[@]}" | sed '/^$/d' | LC_ALL=C sort || true)"

  if [[ -n "$current_text" && "$current_text" == "$previous_text" ]]; then
    PERSISTENCE_PREVIOUS_FEEDBACK="$(basename "$latest")"
    PERSISTENCE_MATCHED="1"
  fi
}

evaluate_status() {
  BLOCKERS=()
  CHECK_ROWS=()

  local meta_out meta_rc catalog_out catalog_rc
  meta_out="$(validator_output "bin/codex-env python skills/scripts/validate_metadata.py")"
  meta_rc="${meta_out##*RC=}"
  catalog_out="$(validator_output "bin/codex-env python skills/scripts/validate_skills_catalog.py")"
  catalog_rc="${catalog_out##*RC=}"

  if [[ "$meta_rc" == "0" ]]; then
    record_check "skills-metadata" "pass" "project skill metadata validation ok"
  else
    add_blocker "Project skill metadata validation failed."
    record_check "skills-metadata" "fail" "$(printf '%s' "$meta_out" | tail -n 2 | tr '\n' ' ')"
  fi

  if [[ "$catalog_rc" == "0" ]]; then
    record_check "skills-catalog" "pass" "project skills catalog validation ok"
  else
    add_blocker "Project skills catalog validation failed."
    record_check "skills-catalog" "fail" "$(printf '%s' "$catalog_out" | tail -n 2 | tr '\n' ' ')"
  fi

  local update_line apply_line undo_line
  update_line="$(extract_line 'Update behavior' "$PLAN_README")"
  apply_line="$(extract_line '\*\*Apply\*\*' "$PLAN_README")"
  undo_line="$(extract_line '\*\*Undo\*\*' "$PLAN_README")"

  if contains_all "$update_line" "shell_config" "bash_completion" "codex_homelab_profiles" "fzf_tab_completion"; then
    record_check "plan-update-behavior" "pass" "$update_line"
  else
    add_blocker "Plan Update behavior row is not self-contained."
    record_check "plan-update-behavior" "fail" "${update_line:-missing}"
  fi

  if contains_all "$apply_line" "shell_config" "bash_completion" "codex_homelab_profiles" "fzf_tab_completion"; then
    record_check "plan-apply-row" "pass" "$apply_line"
  else
    add_blocker "Plan Apply row is not self-contained."
    record_check "plan-apply-row" "fail" "${apply_line:-missing}"
  fi

  if rg -q '^## Disposition ledger' "$PLAN_README"; then
    record_check "plan-disposition-ledger" "pass" "Disposition ledger present"
  else
    add_blocker "Plan still uses a short promotion map instead of a full disposition ledger."
    record_check "plan-disposition-ledger" "fail" "Expected section: ## Disposition ledger"
  fi

  if contains_all "$undo_line" \
    "fzf_tab_completion_state: absent" \
    "codex_homelab_profiles_multi_terminal_state: absent" \
    "real removal path" \
    "shell-completion.bash" \
    "codex-multi-terminal.bash"; then
    record_check "plan-undo-contract" "pass" "Plan documents absent states and role-owned removal path"
  else
    add_blocker "Plan Undo contract still does not document the real removal path."
    record_check "plan-undo-contract" "fail" "${undo_line:-missing}"
  fi

  if rg -q 'Find bashrc\.d files contributed by roles|Deploy contributed bashrc\.d files to ~/.bashrc\.d/' "$SHELL_CONFIG"; then
    add_blocker "common/shell_config still sweeps roles/*/files/bashrc.d/*.bash, so static bashrc ownership is not truly role-local yet."
    record_check "shell-config-static-bash-ownership" "fail" "Generic bashrc.d contribution sweep still present in roles/common/shell_config/tasks/unix.yml"
  else
    record_check "shell-config-static-bash-ownership" "pass" "No generic shell_config sweep for role bashrc.d files"
  fi

  if rg -q 'fzf_tab_completion_bashrc_shell_completion|shell-completion\.bash' "$FZF_ABSENT"; then
    record_check "fzf-absent-static-bash" "pass" "shell-completion.bash removal present"
  else
    add_blocker "fzf_tab_completion absent tasks do not remove shell-completion.bash."
    record_check "fzf-absent-static-bash" "fail" "No shell-completion.bash removal in tasks/absent.yml"
  fi

  if rg -q 'codex_homelab_profiles_multi_terminal_bashrc|codex-multi-terminal\.bash' "$CODEX_ABSENT" && \
     rg -U -q 'codex_homelab_profiles_multi_terminal_bashrc[\s\S]{0,200}state: absent|state: absent[\s\S]{0,200}codex_homelab_profiles_multi_terminal_bashrc|codex-multi-terminal\.bash[\s\S]{0,200}state: absent|state: absent[\s\S]{0,200}codex-multi-terminal\.bash' "$CODEX_ABSENT"; then
    record_check "codex-absent-static-bash" "pass" "codex-multi-terminal.bash removal present"
  else
    add_blocker "codex_homelab_profiles does not remove codex-multi-terminal.bash on absent."
    record_check "codex-absent-static-bash" "fail" "No explicit absent removal for codex-multi-terminal.bash in multi_terminal_absent.yml"
  fi

  local fzf_apply_line fzf_undo_line
  fzf_apply_line="$(extract_line '\*\*Apply:\*\*' "$FZF_README")"
  fzf_undo_line="$(extract_line '\*\*Undo:\*\*' "$FZF_README")"

  if contains_all "$fzf_apply_line" "shell_config,bash_completion,fzf_tab_completion" && \
     [[ "$fzf_undo_line" == *"shell-completion.bash"* ]] && \
     ([[ "$fzf_undo_line" == *"same Apply command"* ]] || [[ "$fzf_undo_line" == *"same playbook command"* ]]); then
    record_check "fzf-readme-contract" "pass" "README documents apply command and role-owned removal"
  else
    add_blocker "fzf_tab_completion README still publishes the wrong undo/apply contract."
    record_check "fzf-readme-contract" "fail" "${fzf_apply_line:-missing} ${fzf_undo_line:-missing}"
  fi

  if grep -q 'codex-multi-terminal.bash' "$CODEX_README" && ! grep -q '| Undo | Set `codex_homelab_profiles_state: absent`, then rerun the playbook |' "$CODEX_README"; then
    record_check "codex-readme-contract" "pass" "README no longer claims simple absent-only undo"
  else
    add_blocker "codex_homelab_profiles README still publishes the wrong undo/apply contract."
    record_check "codex-readme-contract" "fail" "$(extract_line '\| Undo \|' "$CODEX_README")"
  fi

  if rg -q 'Truthful undo for bashrc drops \| done \|' "$PLAN_README"; then
    record_check "plan-undo-closeout" "pass" "Plan checklist marks truthful undo complete"
  else
    add_blocker "Plan checklist still marks truthful undo as in progress."
    record_check "plan-undo-closeout" "fail" "$(extract_line 'Truthful undo for bashrc drops' "$PLAN_README")"
  fi

  if rg -q 'Undo converge|absent converge|truthful undo verification|Undo verification' "$EXECUTION_RECEIPT"; then
    record_check "receipt-undo-verification" "pass" "Execution receipt includes undo verification evidence"
  else
    add_blocker "Execution receipt still lacks explicit absent-state or undo verification evidence."
    record_check "receipt-undo-verification" "fail" "Expected explicit undo/absent verification evidence in EXECUTION-RECEIPT.md"
  fi

  assess_blocker_persistence

  if (( ${#BLOCKERS[@]} == 0 )); then
    STATUS="satisfactory"
  else
    STATUS="partial"
  fi
}

write_wait_file() {
  local ts="$1"
  local out="${PLAN_DIR}/waiting_for_review_by_evaluator_simple_${ts}.md"
  cat >"$out" <<EOF
---
title: evaluator simple wait
created_at: ${ts}
author: evaluator-simple
status: waiting
decision: not yet satisfactory
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator wait

No relevant source changes were detected since the previous evaluator cycle.

Open blockers remain:
EOF
  local item
  for item in "${BLOCKERS[@]}"; do
    printf -- '- %s\n' "$item" >>"$out"
  done
}

write_feedback_file() {
  local ts="$1"
  local out="${PLAN_DIR}/feedback_for_review_by_evaluator_simple_${ts}.md"
  cat >"$out" <<EOF
---
title: evaluator simple feedback
created_at: ${ts}
author: evaluator-simple
status: partial
decision: not satisfactory
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator feedback

Work is still **not satisfactory**.

## Open blockers
EOF
  local item
  for item in "${BLOCKERS[@]}"; do
    printf -- '- %s\n' "$item" >>"$out"
  done

  cat >>"$out" <<'EOF'

## Check matrix

| Check | Result | Detail |
| --- | --- | --- |
EOF
  local row
  for row in "${CHECK_ROWS[@]}"; do
    printf '%s\n' "$row" >>"$out"
  done

  if [[ "$PERSISTENCE_MATCHED" == "1" ]]; then
    cat >>"$out" <<EOF

## Repeated blocker directive

The same blockers also appeared in \`${PERSISTENCE_PREVIOUS_FEEDBACK}\`.

Implementer must perform targeted research before the next correction pass:

1. Use Context7 for the blocking implementation surfaces and quote the exact docs used in the next correction artifact.
2. For the current blockers, prioritize Context7 research on Ansible absent-state verification, evidence/receipt wording, and plan-closeout conventions.
3. Use Firebase only if the blocker is actually tied to a Firebase-backed product, runtime, or hosted documentation surface. It does not appear applicable to the current repo-local blockers.
4. The next correction artifact must include: source consulted, exact command or pattern adopted, and which blocker it resolves.
EOF
  fi
}

write_ready_file() {
  local ts="$1"
  local out="${PLAN_DIR}/ready_for_review_by_evaluator_simple_${ts}.md"
  cat >"$out" <<EOF
---
title: evaluator simple sign-off
created_at: ${ts}
author: evaluator-simple
status: satisfactory
decision: approved
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator sign-off

The work is now considered **satisfactory and done**.

## Passing checks

| Check | Result | Detail |
| --- | --- | --- |
EOF
  local row
  for row in "${CHECK_ROWS[@]}"; do
    printf '%s\n' "$row" >>"$out"
  done
}

main_loop() {
  local current_snapshot previous_snapshot ts
  while true; do
    ts="$(timestamp_compact)"
    evaluate_status
    current_snapshot="$(snapshot)"
    previous_snapshot="$(cat "$STATE_FILE" 2>/dev/null || true)"

    if [[ "$STATUS" == "satisfactory" ]]; then
      write_ready_file "$ts"
      printf '%s\n' "$current_snapshot" >"$STATE_FILE"
      log "ready file written ts=${ts}"
      break
    fi

    if [[ "$current_snapshot" != "$previous_snapshot" ]]; then
      write_feedback_file "$ts"
      log "feedback file written ts=${ts}"
    else
      write_wait_file "$ts"
      log "wait file written ts=${ts}"
    fi

    printf '%s\n' "$current_snapshot" >"$STATE_FILE"
    if [[ "$RUN_ONCE" == "1" ]]; then
      break
    fi
    sleep "$INTERVAL_SEC"
  done
}

if already_running; then
  log "loop already running pid=$(cat "$PID_FILE")"
  exit 0
fi

trap cleanup EXIT
printf '%s\n' "$$" >"$PID_FILE"
log "starting evaluator simple loop interval=${INTERVAL_SEC}s"
main_loop
