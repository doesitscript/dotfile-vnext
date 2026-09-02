# ONE-OFF TRIAL — installed as ~/.local/share/dotfile-vnext-one-off-tasks/pythonpath/usercustomize.py
# Upstream: https://github.com/lincheney/fzf-tab-completion#python3

import os

_FZF_TAB = os.path.expanduser(
    os.environ.get(
        "FZF_TAB_COMPLETION_DIR",
        "~/.local/share/fzf-tab-completion",
    )
)
_SCRIPT = os.path.join(_FZF_TAB, "python", "fzf_python_completion.py")

if os.path.isfile(_SCRIPT):
    with open(_SCRIPT, encoding="utf-8") as file:
        exec(file.read())  # noqa: S102 — upstream install pattern
