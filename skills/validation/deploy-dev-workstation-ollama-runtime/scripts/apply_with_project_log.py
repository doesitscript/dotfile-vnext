#!/usr/bin/env python3
"""Apply deploy_dev_workstation_ollama_runtime.yaml with a project logs/runs capture.

Canonical path (skills library authority):
  bin/codex-env python \\
    skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py

Replaces ad-hoc:
  bin/codex-env ansible-playbook ... | tee /tmp/desktop-artifact-ollama-apply2.log

Default log:
  logs/runs/YYYYMMDD-HHMMSS--deploy-dev-workstation-ollama-runtime.log
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def repo_root() -> Path:
    # .../dotfile-vnext/.cursor/skills/<skill>/scripts/this.py
    return Path(__file__).resolve().parents[4]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--limit",
        default="dev-workstation-win",
        help="Ansible --limit (default: dev-workstation-win)",
    )
    parser.add_argument(
        "--inventory",
        default="inventory/inventory.yaml",
        help="Inventory path relative to repo root",
    )
    parser.add_argument(
        "--playbook",
        default="playbooks/deploy_dev_workstation_ollama_runtime.yaml",
        help="Playbook path relative to repo root",
    )
    parser.add_argument(
        "--verbosity",
        default="-vv",
        help="Ansible verbosity flag(s), e.g. -v or -vv (default: -vv)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Pass --check (and --diff) for read-only preview",
    )
    parser.add_argument(
        "--extra-vars",
        action="append",
        default=[],
        help="Extra -e KEY=VALUE (repeatable)",
    )
    parser.add_argument(
        "--log-file",
        help="Override log path (default under logs/runs/)",
    )
    args, passthrough = parser.parse_known_args()

    root = repo_root()
    os.chdir(root)

    runs = root / "logs" / "runs"
    runs.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    log_path = (
        Path(args.log_file)
        if args.log_file
        else runs / f"{stamp}--deploy-dev-workstation-ollama-runtime.log"
    )
    log_path.parent.mkdir(parents=True, exist_ok=True)

    cmd = [
        str(root / "bin" / "codex-env"),
        "ansible-playbook",
        "-i",
        args.inventory,
        args.playbook,
        "--limit",
        args.limit,
    ]
    if args.verbosity:
        cmd.extend(args.verbosity.split())
    if args.check:
        cmd.extend(["--check", "--diff"])
    for item in args.extra_vars:
        cmd.extend(["-e", item])
    cmd.extend(passthrough)

    print("=== deploy-dev-workstation-ollama-runtime ===")
    print(f"cwd: {root}")
    print(f"cmd: {' '.join(cmd)}")
    print(f"log: {log_path}")
    print()

    with log_path.open("w", encoding="utf-8") as log_fh:
        log_fh.write(f"# command: {' '.join(cmd)}\n")
        log_fh.write(f"# started_utc: {datetime.now(timezone.utc).isoformat()}\n\n")
        log_fh.flush()
        proc = subprocess.Popen(
            cmd,
            cwd=str(root),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        assert proc.stdout is not None
        for line in proc.stdout:
            sys.stdout.write(line)
            log_fh.write(line)
        rc = proc.wait()
        log_fh.write(f"\n# finished_utc: {datetime.now(timezone.utc).isoformat()}\n")
        log_fh.write(f"# exit_code: {rc}\n")

    print()
    print(f"LOG_FILE={log_path}")
    print(f"EXIT_CODE={rc}")
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
