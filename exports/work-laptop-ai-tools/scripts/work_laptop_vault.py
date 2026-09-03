#!/usr/bin/env python3
"""Work-laptop packet vault CLI. Subcommands call the hydrate/status scripts.

Never prints secret values.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def script_dir() -> Path:
    return Path(__file__).resolve().parent


def run_python(script: Path, extra: list[str]) -> int:
    cmd = [sys.executable, str(script), *extra]
    return subprocess.call(cmd)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "command",
        choices=("hydrate", "init-empty", "status"),
        help="hydrate: copy parent values via hydrate_vault_from_parent.py; "
        "init-empty: encrypted empty schema only; status: names-only check",
    )
    parser.add_argument("--also-sibling", action="store_true")
    parser.add_argument("--packet-root", default="")
    parser.add_argument("--parent-root", default="")
    parser.add_argument("--vault-password-file", default="")
    parser.add_argument("--ansible-vault", default="")
    args, passthrough = parser.parse_known_args()

    hydrate = script_dir() / "hydrate_vault_from_parent.py"
    status = script_dir() / "vault_status.py"
    common: list[str] = []
    if args.packet_root:
        common.extend(["--packet-root", args.packet_root])
    if args.parent_root:
        common.extend(["--parent-root", args.parent_root])
    if args.vault_password_file:
        common.extend(["--vault-password-file", args.vault_password_file])
    if args.ansible_vault:
        common.extend(["--ansible-vault", args.ansible_vault])
    common.extend(passthrough)

    if args.command == "status":
        return run_python(status, common)
    if args.command == "init-empty":
        extra = ["--init-empty", *common]
        if args.also_sibling:
            extra.append("--also-sibling")
        return run_python(hydrate, extra)
    extra = ["--init-empty", "--hydrate", *common]
    if args.also_sibling:
        extra.append("--also-sibling")
    return run_python(hydrate, extra)


if __name__ == "__main__":
    if shutil.which("ansible-vault") is None and "--ansible-vault" not in sys.argv:
        print("WARN: ansible-vault not on PATH; skills should use bin/codex-env python", file=sys.stderr)
    raise SystemExit(main())
