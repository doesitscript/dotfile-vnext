#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime
import os
from pathlib import Path
import shlex
import subprocess
import sys
import zipfile

import yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument(
        "--packet-manifest",
        default="exports/work-laptop-ai-tools/export-manifest.yml",
    )
    parser.add_argument("--archive-path", default="")
    parser.add_argument("--destination-root", default="")
    parser.add_argument("--ansible-command", default="")
    parser.add_argument("--inventory-file", default="inventory.yaml")
    return parser.parse_args()


def resolve_with_repo_root(repo_root: Path, value: str) -> Path:
    candidate = Path(value).expanduser()
    if candidate.is_absolute():
        return candidate.resolve()
    return (repo_root / candidate).resolve()


def load_manifest(path: Path) -> dict[str, object]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"Manifest is not a mapping: {path}")
    return data


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

    if args.archive_path:
        archive_path = resolve_with_repo_root(repo_root, args.archive_path)
    else:
        archive_name = str(manifest.get("archive_name") or f"{packet_name}.zip")
        archive_path = (manifest_path.parent / "dist" / archive_name).resolve()

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
    base_command = ansible_parts + [extracted_playbook, "-i", extracted_inventory]

    run_command(base_command + ["--syntax-check"], cwd=packet_dir)
    run_command(base_command + ["--list-hosts"], cwd=packet_dir)
    run_command(base_command + ["--list-tasks"], cwd=packet_dir)
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

    print(f"Archive: {archive_path}")
    print(f"Round-trip root: {run_root}")
    print(f"Extracted packet: {packet_dir}")
    print(f"Marker: {marker_path}")
    print(f"Verified marker line: {expected_line}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
