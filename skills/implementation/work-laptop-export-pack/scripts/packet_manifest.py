#!/usr/bin/env python3

from __future__ import annotations

import fnmatch
from pathlib import Path
import subprocess
import sys

import yaml


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


def collect_manifest_files(
    repo_root: Path,
    manifest_path: Path,
) -> tuple[dict[str, object], Path, str, list[tuple[Path, Path]]]:
    manifest = load_manifest(manifest_path)
    packet_root = manifest_path.parent.resolve()
    packet_name = str(manifest.get("packet_name") or packet_root.name)

    include_entries = manifest.get("include")
    if not isinstance(include_entries, list) or not include_entries:
        raise ValueError(f"Manifest include list is missing or empty: {manifest_path}")

    raw_exclude_patterns = manifest.get("exclude", [])
    if not isinstance(raw_exclude_patterns, list):
        raise ValueError(f"Manifest exclude list must be a list: {manifest_path}")
    exclude_patterns: list[str] = []
    for pattern in raw_exclude_patterns:
        if not isinstance(pattern, str):
            raise ValueError(f"Manifest exclude entry must be a string: {pattern!r}")
        exclude_patterns.append(pattern)

    files: list[tuple[Path, Path]] = []
    seen_destinations: set[str] = set()
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
            relative_text = relative_packet_path.as_posix()
            if relative_text in seen_destinations:
                raise ValueError(f"Duplicate packet destination path: {relative_text}")
            seen_destinations.add(relative_text)
            files.append((resolved_source, relative_packet_path))

    return manifest, packet_root, packet_name, files
