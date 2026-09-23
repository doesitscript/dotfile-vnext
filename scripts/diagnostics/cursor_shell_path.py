"""Collect only PATH-related Cursor settings and reproducible rg shell probes."""

import json
import os
from pathlib import Path
import re
import subprocess


def collect():
    home = Path.home()
    settings_path = home / "Library/Application Support/Cursor/User/settings.json"
    settings = json.loads(settings_path.read_text())
    overrides = settings.get("terminal.integrated.env.osx") or {}
    inherited_path = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    env = dict(os.environ, PATH=inherited_path, LC_ALL="en_US.UTF-8")
    # Resolve the VS Code env substitution against the parent environment.
    parent = dict(env)
    for key in ("PATH", "LANG", "LC_ALL", "LC_CTYPE"):
        value = overrides.get(key)
        if isinstance(value, str):
            env[key] = re.sub(r"\$\{env:([^}]+)\}", lambda m: parent.get(m[1], ""), value)
    probes = []
    for shell in ("/bin/bash", "/usr/local/bin/bash"):
        if not Path(shell).exists():
            continue
        result = subprocess.run(
            [shell, "-c", "command -v rg; rg --version && printf 'cursor-rg-proof\\n' | rg '^cursor-rg-proof$'"],
            env=env, text=True, capture_output=True, check=False,
        )
        probes.append(dict(shell=shell, returncode=result.returncode,
                           stdout=result.stdout, stderr=result.stderr))
    return dict(settings_path=str(settings_path),
                configured_path=overrides.get("PATH"),
                inherited_path=inherited_path, effective_path=env["PATH"],
                binary_exists=(home / ".local/bin/rg").is_file(), probes=probes,
                scope="Fresh non-login shells with Cursor terminal environment settings; not an agent UI invocation")


if __name__ == "__main__":
    print(json.dumps(collect(), indent=2))
