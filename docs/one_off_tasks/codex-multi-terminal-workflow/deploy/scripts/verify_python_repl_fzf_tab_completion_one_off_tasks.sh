#!/usr/bin/env bash
# ONE-OFF TRIAL — verify Python REPL fzf-tab-completion install

set -euo pipefail

PYTHONPATH_DIR="${HOME}/.local/share/dotfile-vnext-one-off-tasks/pythonpath"
FZF_TAB_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
fail=0

check() {
  if "$@"; then
    printf 'PASS  %s\n' "$*"
  else
    printf 'FAIL  %s\n' "$*" >&2
    fail=1
  fi
}

check test -f "${PYTHONPATH_DIR}/usercustomize.py"
check test -f "${FZF_TAB_DIR}/python/fzf_python_completion.py"
check test -x "${HOME}/bin/rl_custom_complete"
check test -f "${HOME}/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash"
check command -v python3
check command -v fzf

if command -v python3 >/dev/null 2>&1; then
  check python3 -m py_compile "${PYTHONPATH_DIR}/usercustomize.py"
fi

exit "$fail"
