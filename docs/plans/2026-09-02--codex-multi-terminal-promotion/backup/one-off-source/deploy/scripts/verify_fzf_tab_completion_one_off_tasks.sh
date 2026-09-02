#!/usr/bin/env bash
# ONE-OFF TRIAL — read-only verify for lincheney/fzf-tab-completion install

set -euo pipefail

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

check command -v fzf
check command -v gawk
check test -f "${FZF_TAB_DIR}/bash/fzf-bash-completion.sh"
check test -f "${HOME}/.bashrc.d/shell-completion_one_off_tasks.bash"
check bash -c 'shopt -s progcomp; [[ $(shopt -p progcomp) == *-s* ]]'
check bash --noprofile --norc -c "
  shopt -s progcomp
  export FZF_COMPLETION_AUTO_COMMON_PREFIX=true
  export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART=true
  source '${FZF_TAB_DIR}/bash/fzf-bash-completion.sh'
  declare -F fzf_bash_completion
"

exit "$fail"
