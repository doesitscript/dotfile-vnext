#!/usr/bin/env bash
# ONE-OFF TRIAL — Python REPL fzf tab completion (lincheney/fzf-tab-completion#python3)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
deploy_root="$(cd "${script_dir}/.." && pwd)"

FZF_TAB_DIR="${FZF_TAB_COMPLETION_DIR:-${HOME}/.local/share/fzf-tab-completion}"
PYTHONPATH_DIR="${HOME}/.local/share/dotfile-vnext-one-off-tasks/pythonpath"
RL_HELPER="${FZF_TAB_DIR}/python/rl_custom_complete"

printf '%s\n' '=== Python REPL fzf-tab-completion one-off install ==='

if [[ ! -f "${FZF_TAB_DIR}/python/fzf_python_completion.py" ]]; then
  printf '  fail  fzf-tab-completion python scripts missing — run install_fzf_tab_completion_one_off_tasks.sh first\n' >&2
  exit 1
fi

mkdir -p "${PYTHONPATH_DIR}" "${HOME}/bin"
install -m 0644 "${deploy_root}/python/usercustomize_one_off_tasks.py" \
  "${PYTHONPATH_DIR}/usercustomize.py"
printf '  ok  %s/usercustomize.py\n' "$PYTHONPATH_DIR"

ln -sf "${RL_HELPER}" "${HOME}/bin/rl_custom_complete"
chmod +x "${RL_HELPER}" 2>/dev/null || true
printf '  ok  ~/bin/rl_custom_complete -> %s\n' "$RL_HELPER"

install -m 0644 "${deploy_root}/bashrc.d/python-fzf-tab-completion_one_off_tasks.bash" \
  "${HOME}/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash"
printf '  ok  ~/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash\n'

if ! command -v python3 >/dev/null 2>&1; then
  printf '  warn  python3 not found — usercustomize will load when python3 is available\n' >&2
else
  printf '  ok  python3 (%s)\n' "$(command -v python3)"
fi

printf '\n%s\n' 'Python REPL Tab completion ready after new shell or:'
printf '  source ~/.bashrc.d/python-fzf-tab-completion_one_off_tasks.bash\n'
printf '  python3   # then Tab in the REPL\n'
