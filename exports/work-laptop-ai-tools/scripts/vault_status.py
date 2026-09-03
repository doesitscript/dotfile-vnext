#!/usr/bin/env python3
"""Names-only status for the work-laptop packet Ansible vault.

Never prints secret values. Decrypts in-process only.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

from vault_paths import discover_parent_root


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--packet-root", default="")
    parser.add_argument("--parent-root", default="")
    parser.add_argument("--map-file", default="")
    parser.add_argument("--dest", default="")
    parser.add_argument("--vault-password-file", default="")
    parser.add_argument("--ansible-vault", default="")
    return parser.parse_args()


def is_nonempty(value: object) -> bool:
    if value is None:
        return False
    if isinstance(value, (dict, list, str, bytes)):
        return len(value) > 0
    return True


def main() -> int:
    args = parse_args()
    script_dir = Path(__file__).resolve().parent
    packet_root = (
        Path(args.packet_root).expanduser().resolve()
        if args.packet_root
        else script_dir.parent
    )
    parent_root = (
        Path(args.parent_root).expanduser().resolve()
        if args.parent_root
        else discover_parent_root(packet_root)
    )
    map_file = (
        Path(args.map_file).expanduser().resolve()
        if args.map_file
        else packet_root / "vault" / "key-hydrate-map.yml"
    )
    dest = (
        Path(args.dest).expanduser().resolve()
        if args.dest
        else packet_root / "vault" / "shared.vault.yml"
    )
    password_file = (
        Path(args.vault_password_file).expanduser().resolve()
        if args.vault_password_file
        else parent_root / ".vault_pass"
    )
    ansible_vault = args.ansible_vault or shutil.which("ansible-vault")
    if not ansible_vault:
        raise SystemExit("ansible-vault not on PATH; pass --ansible-vault")

    if not dest.is_file():
        print(f"MISSING_DEST: {dest}")
        return 1
    head = dest.read_bytes()[:64]
    if b"$ANSIBLE_VAULT" not in head:
        print("FAIL: dest exists but is not whole-file ansible-vault ciphertext")
        return 1
    print(f"CIPHERTEXT: {dest}")

    gitignore = packet_root / ".gitignore"
    if gitignore.is_file() and "vault/shared.vault.yml" in gitignore.read_text(
        encoding="utf-8"
    ):
        print("GITIGNORE: vault/shared.vault.yml is listed")
    else:
        print("GITIGNORE_WARN: vault/shared.vault.yml not found in packet .gitignore")

    if not password_file.is_file():
        print(f"STATUS_KEYS_SKIP: password file missing ({password_file})")
        print("HINT: pass --vault-password-file or set WORK_LAPTOP_PARENT_ROOT")
        return 0

    result = subprocess.run(
        [
            ansible_vault,
            "decrypt",
            "--output",
            "-",
            "--vault-password-file",
            str(password_file),
            str(dest),
        ],
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        print(f"DECRYPT_FAIL: rc={result.returncode} (stderr omitted)")
        return 1
    loaded = yaml.safe_load(result.stdout)
    result.stdout = b""
    result.stderr = b""
    if not isinstance(loaded, dict):
        print("FAIL: decrypted vault is not a mapping")
        return 1

    expected = []
    if map_file.is_file():
        mapping = yaml.safe_load(map_file.read_text(encoding="utf-8")) or {}
        expected = [str(k) for k in (mapping.get("packet_keys") or [])]

    present_nonempty = []
    present_empty = []
    missing = []
    extra = []
    for key in expected:
        if key not in loaded:
            missing.append(key)
        elif is_nonempty(loaded[key]):
            present_nonempty.append(key)
        else:
            present_empty.append(key)
    if expected:
        expected_set = set(expected)
        extra = sorted(str(k) for k in loaded if str(k) not in expected_set)

    print(f"NONEMPTY: {', '.join(present_nonempty) if present_nonempty else '(none)'}")
    print(f"EMPTY: {', '.join(present_empty) if present_empty else '(none)'}")
    print(f"MISSING_EXPECTED: {', '.join(missing) if missing else '(none)'}")
    print(f"EXTRA_KEYS: {', '.join(extra) if extra else '(none)'}")
    loaded.clear()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SystemExit:
        raise
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise SystemExit(1)
