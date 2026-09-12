#!/usr/bin/env python3
"""Download one Hugging Face weight tree and write its completion receipt."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

from huggingface_hub import snapshot_download


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-id", required=True)
    parser.add_argument("--allow-pattern", action="append", required=True)
    parser.add_argument("--local-dir", required=True, type=Path)
    parser.add_argument("--state-file", required=True, type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    args.local_dir.mkdir(parents=True, exist_ok=True)
    try:
        snapshot_path = snapshot_download(
            repo_id=args.repo_id,
            allow_patterns=args.allow_pattern,
            local_dir=str(args.local_dir),
            local_dir_use_symlinks=False,
            resume_download=True,
        )
    except Exception as exc:
        print(f"Download failed for {args.repo_id}: {exc}", file=sys.stderr)
        return 1

    receipt = {
        "schema": "huggingface_model_weight_download_receipt",
        "repo_id": args.repo_id,
        "allow_patterns": args.allow_pattern,
        "local_dir": str(args.local_dir),
        "snapshot_path": str(snapshot_path),
        "completed_at": datetime.now(timezone.utc).isoformat(),
    }
    args.state_file.parent.mkdir(parents=True, exist_ok=True)
    temporary_state = args.state_file.with_suffix(args.state_file.suffix + ".tmp")
    temporary_state.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    temporary_state.replace(args.state_file)
    print(json.dumps(receipt, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
