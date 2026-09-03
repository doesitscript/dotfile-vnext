#!/usr/bin/env python3
"""Hydrate work-laptop packet Ansible vault from parent vaults.

Never prints secret values. Reports only key names and presence status.
Temp plaintext is mode 0600 and always deleted.
"""

from __future__ import annotations

import argparse
import os
import shutil
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

from vault_paths import discover_parent_root

STATUS_COPIED = "copied"
STATUS_EMPTY_PARENT = "empty_in_parent"
STATUS_MISSING_PARENT = "absent_in_parent"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--parent-root", default="")
    parser.add_argument("--packet-root", default="")
    parser.add_argument("--map-file", default="")
    parser.add_argument("--dest", default="")
    parser.add_argument("--vault-password-file", default="")
    parser.add_argument("--ansible-vault", default="")
    parser.add_argument(
        "--init-empty",
        action="store_true",
        help="Write encrypted empty schema (implied if no flags).",
    )
    parser.add_argument(
        "--hydrate",
        action="store_true",
        help="Copy matching parent values (implied if no flags).",
    )
    parser.add_argument(
        "--also-sibling",
        action="store_true",
        help="Copy encrypted dest to sibling work-laptop-ai-tools checkout.",
    )
    return parser.parse_args()


def resolve_defaults(args: argparse.Namespace) -> None:
    script_dir = Path(__file__).resolve().parent
    packet_root = (
        Path(args.packet_root).expanduser().resolve()
        if args.packet_root
        else script_dir.parent
    )
    args.packet_root = packet_root
    args.parent_root = (
        Path(args.parent_root).expanduser().resolve()
        if args.parent_root
        else discover_parent_root(packet_root)
    )
    args.map_file = (
        Path(args.map_file).expanduser().resolve()
        if args.map_file
        else packet_root / "vault" / "key-hydrate-map.yml"
    )
    args.dest = (
        Path(args.dest).expanduser().resolve()
        if args.dest
        else packet_root / "vault" / "shared.vault.yml"
    )
    args.vault_password_file = (
        Path(args.vault_password_file).expanduser().resolve()
        if args.vault_password_file
        else args.parent_root / ".vault_pass"
    )
    if not args.ansible_vault:
        found = shutil.which("ansible-vault")
        if not found:
            raise SystemExit("ansible-vault not on PATH; pass --ansible-vault")
        args.ansible_vault = found
    if not args.init_empty and not args.hydrate:
        args.init_empty = True
        args.hydrate = True


def load_map(path: Path) -> tuple[list[str], list[str]]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"Map is not a mapping: {path}")
    keys = data.get("packet_keys") or []
    sources = data.get("parent_sources") or []
    if not isinstance(keys, list) or not keys:
        raise SystemExit("packet_keys must be a non-empty list of names")
    if not isinstance(sources, list) or not sources:
        raise SystemExit("parent_sources must be a non-empty list of paths")
    return [str(k) for k in keys], [str(s) for s in sources]


def empty_schema(keys: list[str]) -> dict[str, object]:
    payload: dict[str, object] = {}
    for key in keys:
        payload[key] = {} if key.endswith("_extra_env") else ""
    return payload


def is_nonempty(value: object) -> bool:
    if value is None:
        return False
    if isinstance(value, (dict, list, str, bytes)):
        return len(value) > 0
    return True


def vault_lib(password_file: Path):
    from ansible.constants import DEFAULT_VAULT_ID_MATCH
    from ansible.parsing.vault import VaultLib, VaultSecret

    password = password_file.read_bytes().splitlines()[0]
    return VaultLib([(DEFAULT_VAULT_ID_MATCH, VaultSecret(password))])


def load_mixed_yaml_with_vault(source: Path, password_file: Path) -> dict[str, object]:
    lib = vault_lib(password_file)

    class VaultLoader(yaml.SafeLoader):
        pass

    def construct_vault(loader: yaml.SafeLoader, node: yaml.Node) -> str:
        raw = loader.construct_scalar(node)
        decrypted = lib.decrypt(raw.encode("utf-8"))
        if isinstance(decrypted, bytes):
            return decrypted.decode("utf-8")
        return str(decrypted)

    VaultLoader.add_constructor("!vault", construct_vault)
    loaded = yaml.load(source.read_text(encoding="utf-8"), Loader=VaultLoader)
    return loaded if isinstance(loaded, dict) else {}


def load_parent_file(
    ansible_vault: str, password_file: Path, source: Path
) -> dict[str, object]:
    result = subprocess.run(
        [
            ansible_vault,
            "decrypt",
            "--output",
            "-",
            "--vault-password-file",
            str(password_file),
            str(source),
        ],
        check=False,
        capture_output=True,
    )
    if result.returncode == 0:
        loaded = yaml.safe_load(result.stdout)
        result.stdout = b""
        result.stderr = b""
        return loaded if isinstance(loaded, dict) else {}
    return load_mixed_yaml_with_vault(source, password_file)


def write_encrypted_vault(
    ansible_vault: str,
    password_file: Path,
    dest: Path,
    payload: dict[str, object],
) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(
        prefix="wl-vault-", suffix=".yml", dir=str(dest.parent)
    )
    tmp_path = Path(tmp_name)
    try:
        os.fchmod(fd, stat.S_IRUSR | stat.S_IWUSR)
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            yaml.safe_dump(payload, handle, default_flow_style=False, sort_keys=True)
        encrypt = subprocess.run(
            [
                ansible_vault,
                "encrypt",
                "--encrypt-vault-id",
                "default",
                "--vault-password-file",
                str(password_file),
                str(tmp_path),
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if encrypt.returncode != 0:
            raise SystemExit(f"ansible-vault encrypt failed (rc={encrypt.returncode})")
        tmp_path.replace(dest)
        os.chmod(dest, stat.S_IRUSR | stat.S_IWUSR)
    finally:
        if tmp_path.exists():
            try:
                tmp_path.unlink()
            except OSError:
                pass


def sibling_vault_path(packet_root: Path) -> Path:
    # exports/work-laptop-ai-tools → develop/work-laptop-ai-tools
    return packet_root.parents[1].parent / "work-laptop-ai-tools" / "vault" / "shared.vault.yml"


def dest_is_ciphertext(path: Path) -> bool:
    head = path.read_bytes()[:64]
    return b"$ANSIBLE_VAULT" in head


def main() -> int:
    args = parse_args()
    resolve_defaults(args)

    if not args.vault_password_file.is_file():
        raise SystemExit(f"Vault password file missing: {args.vault_password_file}")
    if not args.map_file.is_file():
        raise SystemExit(f"Map file missing: {args.map_file}")

    keys, sources = load_map(args.map_file)
    payload = empty_schema(keys)
    statuses = {key: STATUS_MISSING_PARENT for key in keys}

    if args.hydrate:
        merged: dict[str, object] = {}
        for rel in sources:
            source = args.parent_root / rel
            if not source.is_file():
                print(f"SKIP_SOURCE: {rel} (missing)")
                continue
            print(f"READ_SOURCE: {rel}")
            parent_data = load_parent_file(
                args.ansible_vault, args.vault_password_file, source
            )
            for key in keys:
                if key in merged or key not in parent_data:
                    continue
                value = parent_data[key]
                if not is_nonempty(value):
                    statuses[key] = STATUS_EMPTY_PARENT
                    continue
                merged[key] = value
                statuses[key] = STATUS_COPIED
            parent_data.clear()
        payload.update(merged)
        merged.clear()

    if args.init_empty or args.hydrate:
        write_encrypted_vault(
            args.ansible_vault, args.vault_password_file, args.dest, payload
        )
        print(f"WROTE_ENCRYPTED: {args.dest}")
    payload.clear()

    copied = [k for k, s in statuses.items() if s == STATUS_COPIED]
    empty = [k for k, s in statuses.items() if s == STATUS_EMPTY_PARENT]
    missing = [k for k, s in statuses.items() if s == STATUS_MISSING_PARENT]
    print(f"COPIED: {', '.join(copied) if copied else '(none)'}")
    print(f"EMPTY_IN_PARENT: {', '.join(empty) if empty else '(none)'}")
    print(f"ABSENT_IN_PARENT: {', '.join(missing) if missing else '(none)'}")

    if args.also_sibling:
        sibling = sibling_vault_path(args.packet_root)
        if sibling.parent.parent.is_dir():
            sibling.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(args.dest, sibling)
            os.chmod(sibling, stat.S_IRUSR | stat.S_IWUSR)
            print(f"COPIED_ENCRYPTED_SIBLING: {sibling}")
        else:
            print("SIBLING_SKIP: checkout not found")

    if not dest_is_ciphertext(args.dest):
        raise SystemExit("FAIL: destination does not look whole-file encrypted")
    print("VERIFY: destination is ansible-vault ciphertext (no plaintext dump)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SystemExit:
        raise
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise SystemExit(1)
