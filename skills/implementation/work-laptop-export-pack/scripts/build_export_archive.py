#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
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
    parser.add_argument("--output-dir", default="")
    parser.add_argument("--archive-path", default="")
    parser.add_argument("--overwrite", action="store_true")
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


def require_relative_to(path: Path, root: Path, label: str) -> Path:
    try:
        return path.relative_to(root)
    except ValueError as exc:
        raise ValueError(f"{label} escapes {root}: {path}") from exc


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    manifest_path = resolve_with_repo_root(repo_root, args.packet_manifest)
    manifest = load_manifest(manifest_path)

    packet_root = manifest_path.parent.resolve()
    packet_name = str(manifest.get("packet_name") or packet_root.name)
    archive_name = str(manifest.get("archive_name") or f"{packet_name}.zip")

    if args.archive_path:
        archive_path = resolve_with_repo_root(repo_root, args.archive_path)
    else:
        output_dir = (
            resolve_with_repo_root(repo_root, args.output_dir)
            if args.output_dir
            else (packet_root / "dist").resolve()
        )
        archive_path = output_dir / archive_name

    include_entries = manifest.get("include")
    if not isinstance(include_entries, list) or not include_entries:
        raise ValueError(f"Manifest include list is missing or empty: {manifest_path}")

    files_to_zip: list[tuple[Path, Path]] = []
    seen_archive_paths: set[str] = set()
    for raw_entry in include_entries:
        if not isinstance(raw_entry, str):
            raise ValueError(f"Manifest include entry must be a string: {raw_entry!r}")

        source_path = resolve_with_repo_root(repo_root, raw_entry)
        if not source_path.is_file():
            raise FileNotFoundError(f"Manifest include file is missing: {source_path}")

        relative_packet_path = require_relative_to(source_path, packet_root, "Manifest include")
        archive_member = Path(packet_name) / relative_packet_path
        archive_member_text = archive_member.as_posix()
        if archive_member_text in seen_archive_paths:
            raise ValueError(f"Duplicate archive member path: {archive_member_text}")
        seen_archive_paths.add(archive_member_text)
        files_to_zip.append((source_path, archive_member))

    archive_path.parent.mkdir(parents=True, exist_ok=True)
    if archive_path.exists() and not args.overwrite:
        raise FileExistsError(f"Archive already exists, pass --overwrite: {archive_path}")

    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED) as handle:
        for source_path, archive_member in files_to_zip:
            handle.write(source_path, archive_member.as_posix())

    print(f"Archive: {archive_path}")
    print(f"Packet root: {packet_root}")
    print(f"Included files: {len(files_to_zip)}")
    for _, archive_member in files_to_zip:
        print(f"- {archive_member.as_posix()}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
