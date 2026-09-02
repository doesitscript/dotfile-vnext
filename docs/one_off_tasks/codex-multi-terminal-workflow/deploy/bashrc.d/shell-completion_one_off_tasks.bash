# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/codex-multi-terminal-workflow/deploy/bashrc.d/
# Auto-sourced by ~/.bashrc.d loop (Ansible common/shell_config). Remove via uninstall_one_off_tasks.sh.
#
# Tab completion: lincheney/fzf-tab-completion (works with bash-completion / progcomp).
#   https://github.com/lincheney/fzf-tab-completion#bash
#
# Load order: bash_completion.bash must load first (alphabetical .bashrc.d).

if [[ -z "${BASH_VERSION:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
  printf '%s\n' \
    'shell-completion_one_off_tasks: fzf not found — brew install fzf' >&2
  return 0 2>/dev/null || exit 0
fi

_FZF_TAB_COMPLETION_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
if [[ ! -f "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh" ]]; then
  printf '%s\n' \
    'shell-completion_one_off_tasks: missing clone — run install_one_off_tasks.sh' >&2
  return 0 2>/dev/null || exit 0
fi

shopt -s progcomp 2>/dev/null || true

# Upstream-supported env (fzf-tab-completion README + junegunn/fzf settings).
export FZF_COMPLETION_AUTO_COMMON_PREFIX="${FZF_COMPLETION_AUTO_COMMON_PREFIX:-true}"
export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART="${FZF_COMPLETION_AUTO_COMMON_PREFIX_PART:-true}"
export FZF_TAB_COMPLETION_PROMPT="${FZF_TAB_COMPLETION_PROMPT:-'> '}"
export FZF_COMPLETION_OPTS="${FZF_COMPLETION_OPTS:---layout=reverse --border --height=40% --bind tab:down,shift-tab:up,enter:accept}"

# shellcheck disable=SC1090
source "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh"

# Upstream bash tip: reduce flicker while bash clears the input line during completion.
_fzf_bash_completion_loading_msg() {
  echo "${PS1@P}${READLINE_LINE}" | tail -n1
}

bind 'set bell-style none' 2>/dev/null || true
bind -x '"\t": fzf_bash_completion' 2>/dev/null || true
