# Managed by Ansible role fzf_tab_completion.
# Upstream: https://github.com/lincheney/fzf-tab-completion#python3
#
# IMPORTANT: Do not exec the upstream completer at import time.
# site.import usercustomize runs for every Python process (scripts, -c,
# agent runners). Upstream fzf_python_completion.init() touches
# _pyrepl/termios and raises:
#   RuntimeError: termios failure (Inappropriate ioctl for device)
# on non-TTY stdin. Gate via sys.__interactivehook__ (interactive REPL only).
# Authority: Python site / sys.__interactivehook__ docs (Context7 /python/cpython).

import os
import sys

_FZF_TAB = os.path.expanduser(
    os.environ.get(
        "FZF_TAB_COMPLETION_DIR",
        "~/.local/share/fzf-tab-completion",
    )
)
_SCRIPT = os.path.join(_FZF_TAB, "python", "fzf_python_completion.py")


def _enable_fzf_tab_completion() -> None:
    if not os.path.isfile(_SCRIPT):
        return
    try:
        if not sys.stdin.isatty():
            return
    except Exception:
        return
    with open(_SCRIPT, encoding="utf-8") as file:
        exec(file.read(), {"__name__": "__fzf_python_completion__"})  # noqa: S102


_previous_interactivehook = getattr(sys, "__interactivehook__", None)


def _fzf_tab_interactivehook() -> None:
    if callable(_previous_interactivehook):
        _previous_interactivehook()
    try:
        _enable_fzf_tab_completion()
    except Exception:
        # Optional REPL nicety must never break the interpreter.
        pass


sys.__interactivehook__ = _fzf_tab_interactivehook
