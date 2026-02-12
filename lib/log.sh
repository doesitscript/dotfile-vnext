#!/usr/bin/env bash
# Shared logging helpers for shell scripts.

LOG_LEVEL="${LOG_LEVEL:-info}"
NO_COLOR="${NO_COLOR:-0}"
LOG_TIMESTAMPS="${LOG_TIMESTAMPS:-1}"

_log_level_num() {
  case "$1" in
    error) echo 0 ;;
    warn) echo 1 ;;
    info) echo 2 ;;
    debug) echo 3 ;;
    *) echo 2 ;;
  esac
}

_LOG_CURRENT_LEVEL="$(_log_level_num "${LOG_LEVEL}")"

_log_ts() {
  if [ "${LOG_TIMESTAMPS}" = "1" ]; then
    date +"%Y-%m-%d %H:%M:%S"
  fi
}

_log_color() {
  if [ "${NO_COLOR}" = "1" ] || [ ! -t 2 ]; then
    return
  fi
  case "$1" in
    ERROR) printf '\033[0;31m' ;;
    WARN) printf '\033[1;33m' ;;
    INFO) printf '\033[0;34m' ;;
    DEBUG) printf '\033[0;36m' ;;
    STEP) printf '\033[0;34m' ;;
    CHECK) printf '\033[1;33m' ;;
    SET) printf '\033[0;34m' ;;
    SKIP) printf '\033[1;33m' ;;
    OK) printf '\033[0;32m' ;;
    SECTION) printf '\033[1;35m' ;;
    *) ;;
  esac
}

_log_reset() {
  if [ "${NO_COLOR}" = "1" ] || [ ! -t 2 ]; then
    return
  fi
  printf '\033[0m'
}

_log_emit() {
  local level="$1"
  shift || true
  local msg="$*"
  local ts=""
  ts="$(_log_ts)"

  _log_color "${level}"
  if [ -n "${ts}" ]; then
    printf '%s [%s] %s\n' "${ts}" "${level}" "${msg}" >&2
  else
    printf '[%s] %s\n' "${level}" "${msg}" >&2
  fi
  _log_reset
}

_log_allow() {
  local want_level="$1"
  local want_num
  want_num="$(_log_level_num "${want_level}")"
  [ "${_LOG_CURRENT_LEVEL}" -ge "${want_num}" ]
}

log_error() { _log_emit "ERROR" "$*"; }
log_warn() { _log_allow warn && _log_emit "WARN" "$*"; }
log_info() { _log_allow info && _log_emit "INFO" "$*"; }
log_debug() { _log_allow debug && _log_emit "DEBUG" "$*"; }
log_step() { _log_allow info && _log_emit "STEP" "$*"; }
log_check() { _log_allow info && _log_emit "CHECK" "$*"; }
log_set() { _log_allow info && _log_emit "SET" "$*"; }
log_skip() { _log_allow info && _log_emit "SKIP" "$*"; }
log_ok() { _log_allow info && _log_emit "OK" "$*"; }

section() {
  _log_allow info || return 0
  _log_emit "SECTION" "$*"
}

run() {
  if [ "$#" -lt 2 ]; then
    log_error "run requires description and command"
    return 2
  fi

  local desc="$1"
  shift || true
  log_step "${desc}"

  if _log_allow debug; then
    "$@" 2>&1 | while IFS= read -r line; do
      _log_emit "DEBUG" "${line}"
    done
    return "${PIPESTATUS[0]}"
  fi

  "$@"
}

die() {
  local code="${1:-1}"
  shift || true
  local msg="${*:-fatal error}"
  log_error "${msg} (exit=${code})"
  exit "${code}"
}
