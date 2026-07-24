#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib.util
import os
import sys
from pathlib import Path


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def shell_probe(shared, script: str) -> dict[str, object]:
    loader = str(Path.home() / ".bashrc.d" / "bash_completion.bash")
    result = shared.run_command(["/bin/bash", "-lc", f"source {loader} >/dev/null 2>&1; {script}"])
    return {"ok": result["rc"] == 0, "text": shared.shorten(result["combined"], 140)}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    shared = load_shared_module(repo_root)
    shared.ensure_repo_python(repo_root, [str(Path(__file__).resolve()), "--repo-root", str(repo_root)])
    repo_root = shared.ensure_repo_root(str(repo_root))

    defaults = shared.read_yaml(repo_root / "roles" / "common" / "bash_completion" / "defaults" / "main.yml")
    memory = shared.read_memory()
    surface_hints = memory.get("cli_surfaces", {}).get(str(repo_root), {})
    tools = list(dict.fromkeys(defaults.get("common_bash_completion_managed_files", []) + list(surface_hints.keys()) + ["kubectl"]))

    brew_prefix = shared.run_command(["brew", "--prefix"])["stdout"].strip() or "/usr/local"
    loader_path = Path.home() / ".bashrc.d" / "bash_completion.bash"
    formulas = shared.run_command(["brew", "list", "--versions", "bash-completion", "bash-completion@2"])

    rows = []
    repo_memory = memory.setdefault("completion_audits", {}).setdefault(str(repo_root), {})
    for tool in tools:
        command_path = shared.run_command(["/bin/bash", "-lc", f"command -v {tool}"])
        completion_file = Path(brew_prefix) / "etc" / "bash_completion.d" / tool
        registration = shell_probe(shared, f"complete -p {tool}")
        owner_hint = surface_hints.get(tool, {}).get("role", "unknown")

        if tool == "kubecolor":
            note = "not managed here; pair with kubectl completion if direct completion is needed"
        elif not command_path["stdout"].strip():
            note = "binary missing from PATH"
        elif completion_file.exists() and registration["ok"]:
            note = "file present and handler registered"
        elif completion_file.exists() and not registration["ok"]:
            note = "file present but handler not registered; inspect loader/runtime"
        elif not completion_file.exists() and registration["ok"]:
            note = "registered at runtime; likely lazy-loaded by Homebrew or wrapper logic"
        else:
            note = "no completion file and no registered handler"

        repo_memory[tool] = {
            "owner_hint": owner_hint,
            "command_path": command_path["stdout"].strip(),
            "completion_file": str(completion_file),
            "completion_file_exists": completion_file.exists(),
            "registration_ok": bool(registration["ok"]),
            "registration_text": str(registration["text"]),
            "note": note,
            "checked_at": shared.iso_now(),
        }
        rows.append(
            {
                "CLI": tool,
                "Owner hint": owner_hint,
                "Command path": f"`{command_path['stdout'].strip() or 'missing'}`",
                "Completion file": f"`{completion_file}`" if completion_file.exists() else "missing",
                "Bash registration": str(registration["text"]),
                "Notes": note,
            }
        )

    shared.write_memory(memory)

    print("Shell runtime")
    print(f"- SHELL: `{os.environ.get('SHELL', 'unset')}`")
    print(f"- Loader: `{loader_path}` ({'present' if loader_path.exists() else 'missing'})")
    print(f"- Homebrew completion formulas: `{shared.shorten(formulas['combined'])}`")
    print()
    print(shared.format_table(rows, ["CLI", "Owner hint", "Command path", "Completion file", "Bash registration", "Notes"]))


if __name__ == "__main__":
    main()
