#!/usr/bin/env python3
from __future__ import annotations

import json
import os
from pathlib import Path
import platform
import pwd
import subprocess
import sys


def run(cmd: list[str]) -> dict[str, object]:
    try:
        result = subprocess.run(
            cmd,
            check=False,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        return {"ok": False, "error": "command not found", "cmd": cmd}

    return {
        "ok": result.returncode == 0,
        "returncode": result.returncode,
        "stdout": result.stdout.strip(),
        "stderr": result.stderr.strip(),
        "cmd": cmd,
    }


def first_line(text: str) -> str:
    return text.splitlines()[0] if text else ""


def file_contains(path: Path, needle: str) -> bool | None:
    if not path.exists():
        return None
    try:
        return needle in path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False


def main() -> int:
    home = Path.home()
    user = pwd.getpwuid(os.getuid()).pw_name
    shell_env = os.environ.get("SHELL", "")

    bash_path_result = run(["bash", "-lc", "command -v bash"])
    bash_path = bash_path_result.get("stdout", "") if bash_path_result.get("ok") else ""
    bash_version_result = run(["bash", "--version"])

    dscl_result = run(["dscl", ".", "-read", f"/Users/{user}", "UserShell"])
    login_shell = ""
    if dscl_result.get("ok"):
        text = str(dscl_result.get("stdout", ""))
        if ":" in text:
            login_shell = text.split(":", 1)[1].strip()

    brew_prefix_result = run(["brew", "--prefix"])
    brew_prefix = brew_prefix_result.get("stdout", "") if brew_prefix_result.get("ok") else ""

    completion_dir = Path(brew_prefix) / "etc" / "bash_completion.d" if brew_prefix else None
    profile_script = Path(brew_prefix) / "etc" / "profile.d" / "bash_completion.sh" if brew_prefix else None
    loader_path = home / ".bashrc.d" / "bash_completion.bash"
    bash_profile = home / ".bash_profile"
    bashrc = home / ".bashrc"
    etc_shells = Path("/etc/shells")

    summary = {
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
        },
        "user": user,
        "env_shell": shell_env,
        "login_shell": login_shell,
        "preferred_bash_path": bash_path,
        "bash_version": first_line(str(bash_version_result.get("stdout", ""))),
        "etc_shells_contains_login_shell": file_contains(etc_shells, login_shell) if login_shell else None,
        "etc_shells_contains_preferred_bash": file_contains(etc_shells, bash_path) if bash_path else None,
        "brew_prefix": brew_prefix,
        "completion_directory": str(completion_dir) if completion_dir else "",
        "completion_directory_exists": completion_dir.exists() if completion_dir else False,
        "completion_profile_script": str(profile_script) if profile_script else "",
        "completion_profile_script_exists": profile_script.exists() if profile_script else False,
        "managed_loader_path": str(loader_path),
        "managed_loader_exists": loader_path.exists(),
        "bash_profile_path": str(bash_profile),
        "bash_profile_sources_bashrc": file_contains(bash_profile, ".bashrc"),
        "bashrc_path": str(bashrc),
        "bashrc_sources_bashrcd": file_contains(bashrc, ".bashrc.d"),
        "managed_completion_files": [],
        "raw": {
            "bash_path_result": bash_path_result,
            "bash_version_result": bash_version_result,
            "dscl_result": dscl_result,
            "brew_prefix_result": brew_prefix_result,
        },
    }

    if completion_dir and completion_dir.exists():
        managed = []
        for name in ("gonzo", "dstl8", "kubectl", "k9s", "stern"):
            if (completion_dir / name).exists():
                managed.append(name)
        summary["managed_completion_files"] = managed

    print(json.dumps(summary, indent=2, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
