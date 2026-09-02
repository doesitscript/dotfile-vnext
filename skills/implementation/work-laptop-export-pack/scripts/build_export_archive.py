#!/usr/bin/env python3

from __future__ import annotations

import argparse
import fnmatch
from pathlib import Path
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


def run_contract_validation(repo_root: Path, manifest_path: Path) -> None:
    validator = (
        repo_root
        / "skills"
        / "implementation"
        / "work-laptop-export-pack"
        / "scripts"
        / "validate_export_contract.py"
    )
    packet_root = manifest_path.parent
    command = [
        sys.executable,
        str(validator),
        "--repo-root",
        str(repo_root),
        "--packet-root",
        str(packet_root.relative_to(repo_root)),
    ]
    result = subprocess.run(command, text=True, capture_output=True, check=False)
    if result.stdout:
        print(result.stdout.rstrip())
    if result.stderr:
        print(result.stderr.rstrip(), file=sys.stderr)
    if result.returncode != 0:
        raise RuntimeError(f"Contract validation failed for {packet_root}")


def require_relative_to(path: Path, root: Path, label: str) -> Path:
    try:
        return path.relative_to(root)
    except ValueError as exc:
        raise ValueError(f"{label} escapes {root}: {path}") from exc


def normalize_entry(raw_entry: object) -> tuple[str, str]:
    if isinstance(raw_entry, str):
        return raw_entry, ""
    if isinstance(raw_entry, dict):
        path_value = raw_entry.get("path")
        dest_value = raw_entry.get("dest", "")
        if not isinstance(path_value, str) or not path_value:
            raise ValueError(f"Manifest include mapping needs non-empty path: {raw_entry!r}")
        if not isinstance(dest_value, str):
            raise ValueError(f"Manifest include mapping dest must be a string: {raw_entry!r}")
        return path_value, dest_value
    raise ValueError(f"Manifest include entry must be a string or mapping: {raw_entry!r}")


def should_exclude(source_path: Path, repo_root: Path, exclude_patterns: list[str]) -> bool:
    try:
        relative_text = source_path.relative_to(repo_root).as_posix()
    except ValueError:
        relative_text = source_path.as_posix()
    return any(fnmatch.fnmatch(relative_text, pattern) for pattern in exclude_patterns)


def iter_sources(
    source_path: Path,
    packet_root: Path,
    repo_root: Path,
    dest_root: str,
    exclude_patterns: list[str],
) -> list[tuple[Path, Path]]:
    if source_path.is_file():
        if should_exclude(source_path, repo_root, exclude_patterns):
            return []
        if dest_root:
            archive_relative = Path(dest_root)
        else:
            archive_relative = require_relative_to(source_path, packet_root, "Manifest include")
        return [(source_path, archive_relative)]

    if source_path.is_dir():
        members: list[tuple[Path, Path]] = []
        base_dest = (
            Path(dest_root)
            if dest_root
            else require_relative_to(source_path, packet_root, "Manifest include")
        )
        for child in sorted(source_path.rglob("*")):
            if not child.is_file():
                continue
            if should_exclude(child, repo_root, exclude_patterns):
                continue
            members.append((child, base_dest / child.relative_to(source_path)))
        return members

    raise FileNotFoundError(f"Manifest include path is missing: {source_path}")


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    manifest_path = resolve_with_repo_root(repo_root, args.packet_manifest)
    run_contract_validation(repo_root, manifest_path)
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
    raw_exclude_patterns = manifest.get("exclude", [])
    if not isinstance(raw_exclude_patterns, list):
        raise ValueError(f"Manifest exclude list must be a list: {manifest_path}")
    exclude_patterns = []
    for pattern in raw_exclude_patterns:
        if not isinstance(pattern, str):
            raise ValueError(f"Manifest exclude entry must be a string: {pattern!r}")
        exclude_patterns.append(pattern)

    files_to_zip: list[tuple[Path, Path]] = []
    seen_archive_paths: set[str] = set()
    for raw_entry in include_entries:
        source_text, dest_root = normalize_entry(raw_entry)
        source_path = resolve_with_repo_root(repo_root, source_text)

        for resolved_source, relative_packet_path in iter_sources(
            source_path=source_path,
            packet_root=packet_root,
            repo_root=repo_root,
            dest_root=dest_root,
            exclude_patterns=exclude_patterns,
        ):
            archive_member = Path(packet_name) / relative_packet_path
            archive_member_text = archive_member.as_posix()
            if archive_member_text in seen_archive_paths:
                raise ValueError(f"Duplicate archive member path: {archive_member_text}")
            seen_archive_paths.add(archive_member_text)
            files_to_zip.append((resolved_source, archive_member))

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
