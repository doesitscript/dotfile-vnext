#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import sys

from packet_manifest import collect_manifest_files, resolve_with_repo_root, run_contract_validation


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument(
        "--packet-manifest",
        default="exports/work-laptop-ai-tools/export-manifest.yml",
    )
    parser.add_argument("--target-dir", default="")
    return parser.parse_args()


def ensure_outside_repo(path: Path, repo_root: Path) -> None:
    try:
        path.relative_to(repo_root)
    except ValueError:
        return
    raise ValueError(f"Target directory must be outside the repo: {path}")


def load_state(path: Path) -> dict[str, object]:
    if not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"State file is not a mapping: {path}")
    return data


def prune_empty_parents(path: Path, stop_at: Path) -> None:
    current = path.parent
    while current != stop_at and current.exists():
        try:
            current.rmdir()
        except OSError:
            break
        current = current.parent


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    manifest_path = resolve_with_repo_root(repo_root, args.packet_manifest)
    run_contract_validation(repo_root, manifest_path)
    manifest, _, packet_name, files = collect_manifest_files(repo_root, manifest_path)

    repo_sync = manifest.get("repo_sync") or {}
    if not isinstance(repo_sync, dict):
        raise ValueError(f"Manifest repo_sync must be a mapping: {manifest_path}")

    default_target_dir = repo_sync.get("default_target_dir", "../work-laptop-ai-tools")
    if not isinstance(default_target_dir, str) or not default_target_dir:
        raise ValueError("Manifest repo_sync.default_target_dir must be a non-empty string.")
    state_file_name = repo_sync.get("state_file", ".build-target-sync-state.json")
    if not isinstance(state_file_name, str) or not state_file_name:
        raise ValueError("Manifest repo_sync.state_file must be a non-empty string.")
    require_git_checkout = bool(repo_sync.get("require_git_checkout", True))

    target_dir = (
        resolve_with_repo_root(repo_root, args.target_dir)
        if args.target_dir
        else resolve_with_repo_root(repo_root, default_target_dir)
    )
    ensure_outside_repo(target_dir, repo_root)
    target_dir.mkdir(parents=True, exist_ok=True)

    if require_git_checkout and not (target_dir / ".git").is_dir():
        raise FileNotFoundError(
            f"Target directory is not a git checkout required by the manifest: {target_dir}"
        )

    state_path = target_dir / state_file_name
    previous_state = load_state(state_path)
    previous_managed = previous_state.get("managed_paths", [])
    if not isinstance(previous_managed, list):
        raise ValueError(f"State managed_paths must be a list: {state_path}")

    current_managed = sorted(relative_path.as_posix() for _, relative_path in files)
    current_managed_set = set(current_managed)

    removed = 0
    for relative_text in previous_managed:
        if not isinstance(relative_text, str):
            raise ValueError(f"State managed path must be a string: {relative_text!r}")
        if relative_text in current_managed_set or relative_text.startswith(".git/"):
            continue
        stale_path = target_dir / relative_text
        if stale_path.is_file() or stale_path.is_symlink():
            stale_path.unlink()
            prune_empty_parents(stale_path, target_dir)
            removed += 1

    copied = 0
    for source_path, relative_path in files:
        target_path = target_dir / relative_path
        target_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, target_path)
        copied += 1

    github_repo = repo_sync.get("github_repo", "")
    if github_repo and not isinstance(github_repo, str):
        raise ValueError("Manifest repo_sync.github_repo must be a string when present.")

    state_payload = {
        "packet_name": packet_name,
        "source_repo": str(repo_root),
        "packet_manifest": str(manifest_path.relative_to(repo_root)),
        "github_repo": github_repo,
        "managed_paths": current_managed,
    }
    state_path.write_text(json.dumps(state_payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(f"Target repo: {target_dir}")
    print(f"Packet name: {packet_name}")
    if github_repo:
        print(f"GitHub repo: {github_repo}")
    print(f"Copied files: {copied}")
    print(f"Removed stale files: {removed}")
    print(f"State file: {state_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
