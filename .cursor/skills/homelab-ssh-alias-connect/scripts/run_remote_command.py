#!/usr/bin/env python3
"""Run a remote command via inventory Host alias without shell-quoting hell.

Preferred over ansible -m win_shell -a "..." for probes: write the remote
script to a local temp file and feed it over ssh stdin.

Usage:
  bin/codex-env python .../run_remote_command.py --host dev-workstation-win \\
    --shell powershell --stdin-file /tmp/probe.ps1
  echo 'hostname' | bin/codex-env python .../run_remote_command.py \\
    --host HOM-LAB-HVH-01 --shell bash
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", required=True, help="Inventory hostname / SSH Host alias")
    parser.add_argument(
        "--shell",
        choices=("powershell", "bash", "cmd"),
        default="powershell",
        help="Remote shell interpreter (default: powershell for Windows hosts)",
    )
    parser.add_argument(
        "--stdin-file",
        help="Local file whose contents are sent on SSH stdin as the remote script",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=120,
        help="Seconds before aborting the SSH session (default: 120)",
    )
    args = parser.parse_args()

    host = args.host.strip()
    resolve = Path(__file__).resolve().parent / "resolve_ssh_alias.py"
    resolve_rc = subprocess.run(
        [sys.executable, str(resolve), "--host", host],
        check=False,
    )
    if resolve_rc.returncode != 0:
        return resolve_rc.returncode

    if args.stdin_file:
        script = Path(args.stdin_file).read_text(encoding="utf-8")
    else:
        script = sys.stdin.read()

    if not script.strip():
        print("FAIL: empty remote script (pass --stdin-file or pipe stdin)", file=sys.stderr)
        return 2

    if args.shell == "powershell":
        # Windows OpenSSH: pipe the script on stdin; -Command - reads stdin as script text.
        # Do not use an inline bootstrap with $variables — local shells may strip $p.
        remote = [
            "ssh",
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=15",
            host,
            "powershell",
            "-NoProfile",
            "-NonInteractive",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            "-",
        ]
    elif args.shell == "bash":
        remote = [
            "ssh",
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=15",
            host,
            "bash",
            "-s",
        ]
    else:
        remote = [
            "ssh",
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=15",
            host,
            "cmd",
            "/Q",
            "/C",
            "-",
        ]

    print(f"=== run_remote_command host={host} shell={args.shell} ===", flush=True)
    proc = subprocess.run(
        remote,
        input=script,
        text=True,
        timeout=args.timeout,
        check=False,
        capture_output=True,
    )
    if proc.stdout:
        sys.stdout.write(proc.stdout)
        if not proc.stdout.endswith("\n"):
            sys.stdout.write("\n")
    if proc.stderr:
        sys.stderr.write(proc.stderr)
        if not proc.stderr.endswith("\n"):
            sys.stderr.write("\n")
    return proc.returncode


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.TimeoutExpired:
        print("FAIL: SSH remote command timed out", file=sys.stderr)
        raise SystemExit(124)
