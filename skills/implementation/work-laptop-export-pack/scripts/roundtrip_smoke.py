#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime
import os
from pathlib import Path
import shlex
import stat
import subprocess
import sys
import zipfile

from packet_manifest import load_manifest, resolve_with_repo_root


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument(
        "--packet-manifest",
        default="exports/work-laptop-ai-tools/export-manifest.yml",
    )
    parser.add_argument(
        "--packet-dir",
        default="",
        help="External sibling-repo or extracted packet directory to validate.",
    )
    parser.add_argument(
        "--archive-path",
        default="",
        help="Explicit zip archive path for opt-in archive-mode validation.",
    )
    parser.add_argument("--destination-root", default="")
    parser.add_argument("--ansible-command", default="")
    parser.add_argument("--inventory-file", default="inventory.yaml")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Run the extracted playbook apply step. Leave off for preview-only proof.",
    )
    return parser.parse_args()


def timestamp_label() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def run_command(command: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command,
        cwd=cwd,
        env=os.environ.copy(),
        text=True,
        capture_output=True,
        check=False,
    )
    combined = (result.stdout or "") + (result.stderr or "")
    print(f"$ {' '.join(shlex.quote(part) for part in command)}")
    print(combined.rstrip() or "(no output)")
    if result.returncode != 0:
        raise RuntimeError(f"Command failed with rc={result.returncode}: {' '.join(command)}")
    return result


def ensure_outside_repo(path: Path, repo_root: Path) -> None:
    try:
        path.relative_to(repo_root)
    except ValueError:
        return
    raise ValueError(f"Destination must be outside the repo: {path}")


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    manifest_path = resolve_with_repo_root(repo_root, args.packet_manifest)
    manifest = load_manifest(manifest_path)
    packet_name = str(manifest.get("packet_name") or manifest_path.parent.name)
    archive_path: Path | None = None
    run_root: Path | None = None

    if args.packet_dir:
        packet_dir = Path(args.packet_dir).expanduser().resolve()
        ensure_outside_repo(packet_dir, repo_root)
        if not packet_dir.is_dir():
            raise FileNotFoundError(f"Packet directory not found: {packet_dir}")
    else:
        if not args.archive_path:
            raise ValueError(
                "No validation target provided. Use --packet-dir for the default sibling-repo path, "
                "or pass --archive-path explicitly for the opt-in archive branch."
            )

        archive_path = resolve_with_repo_root(repo_root, args.archive_path)

        if not archive_path.is_file():
            raise FileNotFoundError(f"Archive not found: {archive_path}")

        destination_root = (
            Path(args.destination_root).expanduser().resolve()
            if args.destination_root
            else (Path.home() / "develop" / "work-laptop-export-roundtrip").resolve()
        )
        ensure_outside_repo(destination_root, repo_root)

        run_root = destination_root / timestamp_label()
        run_root.mkdir(parents=True, exist_ok=False)
        with zipfile.ZipFile(archive_path) as handle:
            handle.extractall(run_root)

        packet_dir = (run_root / packet_name).resolve()
        if not packet_dir.is_dir():
            raise FileNotFoundError(f"Extracted packet directory is missing: {packet_dir}")

    ansible_command = args.ansible_command or f"{repo_root / 'bin' / 'codex-env'} ansible-playbook"
    ansible_parts = shlex.split(ansible_command)
    extracted_playbook = str(packet_dir / "playbook.yaml")
    extracted_inventory = str(packet_dir / args.inventory_file)
    extracted_bootstrap = packet_dir / "bootstrap" / "bootstrap-macos-ansible.sh"
    base_command = ansible_parts + [extracted_playbook, "-i", extracted_inventory]

    if not extracted_bootstrap.is_file():
        raise FileNotFoundError(f"Extracted bootstrap script is missing: {extracted_bootstrap}")
    extracted_bootstrap.chmod(extracted_bootstrap.stat().st_mode | stat.S_IXUSR)

    run_command([str(extracted_bootstrap), "--help"], cwd=packet_dir)
    run_command(
        [str(extracted_bootstrap), "--dry-run", "--bootstrap-only"],
        cwd=packet_dir,
    )
    run_command(base_command + ["--syntax-check"], cwd=packet_dir)
    run_command(base_command + ["--list-hosts"], cwd=packet_dir)
    run_command(base_command + ["--list-tasks"], cwd=packet_dir)
    if args.apply:
        run_command(base_command, cwd=packet_dir)

        marker_path = Path.home() / ".work-laptop-export-targeting.txt"
        if not marker_path.is_file():
            raise FileNotFoundError(f"Marker file not found after round-trip apply: {marker_path}")

        marker_text = marker_path.read_text(encoding="utf-8")
        expected_line = f"playbook_dir={packet_dir}"
        if expected_line not in marker_text:
            raise RuntimeError(
                "Marker file does not prove extracted execution.\n"
                f"Expected line: {expected_line}\n"
                f"Marker path: {marker_path}"
            )
        print(f"Marker: {marker_path}")
        print(f"Verified marker line: {expected_line}")

    print(f"Archive: {archive_path if archive_path else '(not used)'}")
    print(f"Round-trip root: {run_root if run_root else '(not used)'}")
    print(f"Packet directory: {packet_dir}")
    print(f"Apply run: {'yes' if args.apply else 'no'}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
