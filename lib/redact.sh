#!/usr/bin/env bash
# Stream redaction for logs.

redact_stream() {
  sed -E \
    -e 's/([Pp]assword[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/([Tt]oken[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/([Ss]ecret[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/([Kk]ey[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/(ansible_password[[:space:]]*:[[:space:]]*).*/\1"[REDACTED]"/g' \
    -e 's/(ansible_winrm_password[[:space:]]*:[[:space:]]*).*/\1"[REDACTED]"/g' \
    -e 's/(win_password[[:space:]]*:[[:space:]]*).*/\1"[REDACTED]"/g'
}
