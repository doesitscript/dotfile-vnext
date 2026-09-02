# ONE-OFF TRIAL — PYTHONPATH for Python REPL fzf tab completion
# Upstream: https://github.com/lincheney/fzf-tab-completion#python3

if [[ -z "${BASH_VERSION:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi

_ONE_OFF_PYTHON_FZF_TAB_PATH="${HOME}/.local/share/dotfile-vnext-one-off-tasks/pythonpath"
if [[ -f "${_ONE_OFF_PYTHON_FZF_TAB_PATH}/usercustomize.py" ]]; then
  case ":${PYTHONPATH:-}:" in
    *:"${_ONE_OFF_PYTHON_FZF_TAB_PATH}":*) ;;
    *)
      export PYTHONPATH="${_ONE_OFF_PYTHON_FZF_TAB_PATH}${PYTHONPATH:+:${PYTHONPATH}}"
      ;;
  esac
fi
