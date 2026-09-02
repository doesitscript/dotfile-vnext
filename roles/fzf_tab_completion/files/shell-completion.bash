# Managed by Ansible role fzf_tab_completion. Do not edit on the host.
# Upstream: https://github.com/lincheney/fzf-tab-completion#bash

if [[ -z "${BASH_VERSION:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
  printf '%s\n' 'shell-completion: fzf not found — enable fzf_tab_completion role' >&2
  return 0 2>/dev/null || exit 0
fi

_FZF_TAB_COMPLETION_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
if [[ ! -f "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh" ]]; then
  printf '%s\n' 'shell-completion: missing fzf-tab-completion clone' >&2
  return 0 2>/dev/null || exit 0
fi

shopt -s progcomp 2>/dev/null || true

export FZF_COMPLETION_AUTO_COMMON_PREFIX="${FZF_COMPLETION_AUTO_COMMON_PREFIX:-true}"
export FZF_COMPLETION_AUTO_COMMON_PREFIX_PART="${FZF_COMPLETION_AUTO_COMMON_PREFIX_PART:-true}"
export FZF_TAB_COMPLETION_PROMPT="${FZF_TAB_COMPLETION_PROMPT:-'> '}"
export FZF_COMPLETION_OPTS="${FZF_COMPLETION_OPTS:---layout=reverse --border --height=40% --bind tab:down,shift-tab:up,enter:accept}"

# shellcheck disable=SC1090
source "${_FZF_TAB_COMPLETION_DIR}/bash/fzf-bash-completion.sh"

_fzf_bash_completion_loading_msg() {
  echo "${PS1@P}${READLINE_LINE}" | tail -n1
}

bind 'set bell-style none' 2>/dev/null || true
bind -x '"\t": fzf_bash_completion' 2>/dev/null || true
