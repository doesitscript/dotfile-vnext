#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import zipfile

from packet_manifest import collect_manifest_files, resolve_with_repo_root, run_contract_validation


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


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    manifest_path = resolve_with_repo_root(repo_root, args.packet_manifest)
    run_contract_validation(repo_root, manifest_path)
    manifest, packet_root, packet_name, files_to_zip = collect_manifest_files(repo_root, manifest_path)
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

    archive_members: list[tuple[Path, Path]] = [
        (source_path, Path(packet_name) / relative_packet_path)
        for source_path, relative_packet_path in files_to_zip
    ]

    archive_path.parent.mkdir(parents=True, exist_ok=True)
    if archive_path.exists() and not args.overwrite:
        raise FileExistsError(f"Archive already exists, pass --overwrite: {archive_path}")

    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED) as handle:
        for source_path, archive_member in archive_members:
            handle.write(source_path, archive_member.as_posix())

    print(f"Archive: {archive_path}")
    print(f"Packet root: {packet_root}")
    print(f"Included files: {len(archive_members)}")
    for _, archive_member in archive_members:
        print(f"- {archive_member.as_posix()}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
