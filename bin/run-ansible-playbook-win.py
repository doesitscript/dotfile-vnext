#!/usr/bin/env python3
# Wrapper to run ansible-playbook on Windows:
# - Patches os.get_blocking to avoid OSError in check_blocking_io().
# - Injects Unix-only module stubs (grp, pwd, fcntl, termios, tty) so Ansible can import.
# - Patches Origin path validation to accept Windows absolute paths.
# Usage: python run-ansible-playbook-win.py [ansible-playbook args...]
import os
import sys

# Ansible requires UTF-8 locale; on Windows report UTF-8 so the check passes
if sys.platform == "win32":
    os.environ.setdefault("PYTHONUTF8", "1")
    import locale as _locale
    _orig_getlocale = _locale.getlocale
    def _getlocale(category=None):
        lang, enc = _orig_getlocale(category)
        if enc is None or enc.lower() not in ("utf-8", "utf8"):
            enc = "UTF-8"
        return (lang or "en_US", enc)
    _locale.getlocale = _getlocale
    _orig_getfilesystemencoding = sys.getfilesystemencoding
    sys.getfilesystemencoding = lambda: "utf-8"

# 1) Patch os.get_blocking for Windows
_orig_get_blocking = getattr(os, "get_blocking", None)
if _orig_get_blocking is not None:

    def _safe_get_blocking(fd):
        try:
            return _orig_get_blocking(fd)
        except OSError:
            return True  # assume blocking on Windows

    os.get_blocking = _safe_get_blocking

# 2) Windows compatibility before any Ansible import
if sys.platform == "win32":
    import multiprocessing
    _orig_mp_get_context = multiprocessing.get_context
    def _get_context(method):
        if method == "fork":
            return _orig_mp_get_context("spawn")
        return _orig_mp_get_context(method)
    multiprocessing.get_context = _get_context

# 3) On Windows, Ansible's display.py uses find_library('c') and wcwidth; CRT has no wcwidth. Provide a mock.
if sys.platform == "win32":
    import ctypes
    import ctypes.util as _ctutil
    _cdll = ctypes.cdll
    _orig_find_library = _ctutil.find_library
    _orig_LoadLibrary = _cdll.LoadLibrary

    def _find_library(name):
        if name == "c":
            return "__win_ansible_libc_mock__"
        return _orig_find_library(name)

    def _LoadLibrary(name):
        if name == "__win_ansible_libc_mock__":
            # Mock CDLL with wcwidth/wcswidth so display.py can set argtypes (actual calls use default width)
            class _MockLib:
                @staticmethod
                def _wcwidth(_ch):
                    return 1
                @staticmethod
                def _wcswidth(_s, _n):
                    return 1
            _mock = _MockLib()
            _mock.wcwidth = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_wchar)(_MockLib._wcwidth)
            _mock.wcswidth = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_wchar_p, ctypes.c_int)(_MockLib._wcswidth)
            return _mock
        return _orig_LoadLibrary(name)

    _ctutil.find_library = _find_library
    _cdll.LoadLibrary = _LoadLibrary

# 4) Stub Unix-only modules so Ansible can import on Windows (used only when not running Unix modules)
def _unix_stub(name):
    def _fn(*args, **kwargs):
        raise OSError(0, f"{name} not available on Windows")

    return _fn


class _StructGroup:
    def __init__(self):
        self.gr_name = ""
        self.gr_passwd = ""
        self.gr_gid = 0
        self.gr_mem = ()


class _StructPasswd:
    def __init__(self):
        self.pw_name = ""
        self.pw_passwd = ""
        self.pw_uid = 0
        self.pw_gid = 0
        self.pw_gecos = ""
        self.pw_dir = ""
        self.pw_shell = ""


def _grp_getgrgid(gid):
    return _StructGroup()


def _grp_getgrnam(name):
    return _StructGroup()


def _grp_getgrall():
    return []


def _pwd_getpwnam(name):
    return _StructPasswd()


def _pwd_getpwuid(uid):
    return _StructPasswd()


def _fcntl_fcntl(fd, op, arg=0):
    raise OSError(0, "fcntl not available on Windows")


# Constants used by basic.py (only used when os.name == 'posix', but module must have them)
F_SETFL = 4
F_GETFL = 3
O_NONBLOCK = 2048

_grp = type(sys)("grp")
_grp.getgrgid = _grp_getgrgid
_grp.getgrnam = _grp_getgrnam
_grp.getgrall = _grp_getgrall
sys.modules["grp"] = _grp

_pwd = type(sys)("pwd")
_pwd.getpwnam = _pwd_getpwnam
_pwd.getpwuid = _pwd_getpwuid
sys.modules["pwd"] = _pwd

_fcntl = type(sys)("fcntl")
_fcntl.fcntl = _fcntl_fcntl
_fcntl.F_SETFL = F_SETFL
_fcntl.F_GETFL = F_GETFL
_fcntl.O_NONBLOCK = O_NONBLOCK
if hasattr(os, "O_NONBLOCK"):
    _fcntl.O_NONBLOCK = os.O_NONBLOCK
# ioctl may be used by display.py
def _fcntl_ioctl(fd, op, arg=0):
    raise OSError(0, "fcntl.ioctl not available on Windows")
_fcntl.ioctl = _fcntl_ioctl
sys.modules["fcntl"] = _fcntl

# termios/tty: Unix-only; stub so display.py can import (used only in interactive paths)
_termios = type(sys)("termios")
for _c in ("TCSAFLUSH", "TCSANOW", "TCSADRAIN", "TCIFLUSH", "BRKINT", "ICRNL", "INPCK",
           "ISTRIP", "IXON", "OPOST", "CSIZE", "PARENB", "CS8", "ECHO", "ICANON", "IEXTEN",
           "ISIG", "VMIN", "VTIME", "VINTR", "VERASE", "TIOCGWINSZ"):
    setattr(_termios, _c, 0)


def _termios_tcgetattr(fd):
    return [[0] * 4 for _ in range(7)]  # list of 7 lists, index 6 is CC


def _termios_tcsetattr(fd, when, mode):
    pass


def _termios_tcflush(fd, queue):
    pass


_termios.tcgetattr = _termios_tcgetattr
_termios.tcsetattr = _termios_tcsetattr
_termios.tcflush = _termios_tcflush
sys.modules["termios"] = _termios

_tty = type(sys)("tty")
_tty.IFLAG = 0
_tty.OFLAG = 1
_tty.CFLAG = 2
_tty.LFLAG = 3
_tty.CC = 6
sys.modules["tty"] = _tty

# 5) Patch Origin to accept Windows absolute paths before any Ansible code runs
def _post_validate_win(self):
    if self.path:
        if not (self.path.startswith("/") or os.path.isabs(self.path)):
            raise RuntimeError("The `src` field must be an absolute path.")
    elif not self.description:
        raise RuntimeError("The `src` or `description` field must be specified.")


# Import _tags first and patch; then playbook.cli (which loads config and uses Origin)
from ansible._internal._datatag import _tags

_tags.Origin._post_validate = _post_validate_win

# 6) Run ansible-playbook. On Windows, patch re.compile so dataloader's RE_TASKS pattern (uses os.path.sep '\\') compiles.
sys.argv = ["ansible-playbook"] + sys.argv[1:]
if sys.platform == "win32":
    import re as _re
    _orig_compile = _re.compile
    def _re_compile(pattern, flags=0):
        if isinstance(pattern, str) and "tasks" in pattern and "(?:^|" in pattern:
            # dataloader: '(?:^|%s)+tasks%s?$' % (os.path.sep, os.path.sep); on Windows \ breaks regex
            pattern = pattern.replace("\\", "/")
        return _orig_compile(pattern, flags)
    _re.compile = _re_compile

from ansible.cli.playbook import main

sys.exit(main())
