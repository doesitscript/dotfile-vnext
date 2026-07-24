#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STATE_ROOT = Path.home() / ".cache" / "dotfile-vnext" / "skill-runtime"
MEMORY_PATH = STATE_ROOT / "automation-memory.json"
RECEIPTS_ROOT = STATE_ROOT / "receipts"
SCHEMA = "automation-memory-v1"


def iso_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def ensure_repo_root(repo_root: str | None) -> Path:
    candidate = Path(repo_root or os.getcwd()).expanduser().resolve()
    if not (candidate / "skills").exists():
        raise SystemExit(f"Repo root missing skills/: {candidate}")
    return candidate


def ensure_library_root(library_root: str | None) -> Path:
    candidate = Path(library_root or os.getcwd()).expanduser().resolve()
    if not (candidate / "notes").exists():
        raise SystemExit(f"Library root missing notes/: {candidate}")
    return candidate


def ensure_repo_python(repo_root: Path, argv: list[str]) -> None:
    if os.environ.get("DOTFILE_SKILL_REEXEC") == "1":
        return
    try:
        import yaml  # noqa: F401
        return
    except ImportError:
        wrapper = repo_root / "bin" / "codex-env"
        if not wrapper.exists():
            raise
        env = os.environ.copy()
        env["DOTFILE_SKILL_REEXEC"] = "1"
        os.execvpe(str(wrapper), [str(wrapper), "python3", *argv], env)


def read_yaml(path: Path) -> dict[str, Any]:
    import yaml

    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"Expected mapping YAML at {path}")
    return data


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def read_memory() -> dict[str, Any]:
    if not MEMORY_PATH.exists():
        return {
            "schema": SCHEMA,
            "created_at": iso_now(),
            "updated_at": iso_now(),
            "cli_surfaces": {},
            "completion_audits": {},
            "apply_receipts": {},
            "intakes": {},
            "metadata": {},
        }
    with MEMORY_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_memory(memory: dict[str, Any]) -> None:
    STATE_ROOT.mkdir(parents=True, exist_ok=True)
    memory["schema"] = SCHEMA
    memory["updated_at"] = iso_now()
    with MEMORY_PATH.open("w", encoding="utf-8") as handle:
        json.dump(memory, handle, indent=2, sort_keys=True)
        handle.write("\n")


def run_command(
    command: list[str],
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
) -> dict[str, Any]:
    result = subprocess.run(
        command,
        cwd=str(cwd) if cwd else None,
        env=env,
        capture_output=True,
        text=True,
    )
    return {
        "rc": result.returncode,
        "stdout": result.stdout or "",
        "stderr": result.stderr or "",
        "combined": ((result.stdout or "") + (result.stderr or "")).strip(),
        "command": shell_join(command),
    }


def shell_join(command: list[str]) -> str:
    return shlex.join(command)


def shorten(text: str, limit: int = 160) -> str:
    collapsed = " ".join(text.split())
    if len(collapsed) <= limit:
        return collapsed or "-"
    return collapsed[: limit - 3] + "..."


def markdown_link(path: Path, line: int, label: str) -> str:
    return f"[{label}]({path}:{line})"


def find_line(path: Path, needle: str) -> int:
    for idx, line in enumerate(read_text(path).splitlines(), start=1):
        if needle in line:
            return idx
    return 1


def format_table(rows: list[dict[str, str]], columns: list[str]) -> str:
    header = "| " + " | ".join(columns) + " |"
    separator = "| " + " | ".join(["---"] * len(columns)) + " |"
    body = ["| " + " | ".join(row.get(col, "") for col in columns) + " |" for row in rows]
    return "\n".join([header, separator, *body])
