#!/usr/bin/env python3
"""Extract a Windows-created ZIP payload while normalizing backslash paths.

This avoids heredoc-heavy one-off shell extraction logic and keeps the
supported GPU-P flow non-interactive and PTY-free on the controller.
"""

from __future__ import annotations

import argparse
import pathlib
import shutil
import sys
import zipfile


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--zip", dest="zip_path", required=True)
    parser.add_argument("--dest", dest="dest_path", required=True)
    parser.add_argument("--reset", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    zip_path = pathlib.Path(args.zip_path)
    dest_path = pathlib.Path(args.dest_path)

    if not zip_path.is_file():
        print(f"ZIP_NOT_FOUND {zip_path}", file=sys.stderr)
        return 1

    if args.reset and dest_path.exists():
        shutil.rmtree(dest_path)
    dest_path.mkdir(parents=True, exist_ok=True)

    count = 0
    with zipfile.ZipFile(zip_path) as zf:
        for info in zf.infolist():
            normalized = info.filename.replace("\\", "/")
            rel = pathlib.PurePosixPath(normalized)
            target = dest_path.joinpath(*rel.parts)
            if info.is_dir() or normalized.endswith("/"):
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(info) as src, open(target, "wb") as dst:
                    shutil.copyfileobj(src, dst)
            count += 1

    print(f"EXTRACTED_COUNT {count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
