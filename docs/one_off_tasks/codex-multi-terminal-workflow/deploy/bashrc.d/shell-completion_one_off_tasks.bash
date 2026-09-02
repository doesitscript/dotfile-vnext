# ONE-OFF TRIAL (non-permanent) — source: docs/one_off_tasks/codex-multi-terminal-workflow/deploy/bashrc.d/
# Auto-sourced by ~/.bashrc.d loop (Ansible common/shell_config). Remove via uninstall_one_off_tasks.sh.
#
# Tab completion: lincheney/fzf-tab-completion (vanilla bash setup + auto common prefix).
# https://github.com/lincheney/fzf-tab-completion

if [[ -z "${BASH_VERSION:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

_FZF_TAB_COMPLETION_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
if [[ ! -f "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh" ]]; then
  printf '%s\n' \
    'shell-completion_one_off_tasks: missing fzf-tab-completion — run install_one_off_tasks.sh' >&2
  return 0 2>/dev/null || exit 0
fi

# Upstream-supported env (see fzf-tab-completion README + junegunn/fzf settings).
export FZF_COMPLETION_AUTO_COMMON_PREFIX="${FZF_COMPLETION_AUTO_COMMON_PREFIX:-true}"
export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART="${FZF_COMPLETION_AUTO_COMMON_PREFIX_PART:-true}"
export FZF_TAB_COMPLETION_PROMPT="${FZF_TAB_COMPLETION_PROMPT:-'> '}"
# Optional fzf UI for the completion picker; does not change match logic.
export FZF_COMPLETION_OPTS="${FZF_COMPLETION_OPTS:---layout=reverse --border --height=40% --bind tab:accept}"

# shellcheck disable=SC1090
source "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh"

bind 'set bell-style none' 2>/dev/null || true
bind -x '"\t": fzf_bash_completion' 2>/dev/null || true
