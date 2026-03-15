#!/usr/bin/env python3
"""Save a provided conversation transcript into the conversation-context archive."""

from __future__ import annotations

import argparse
import datetime as dt
import pathlib
import re
import sys


DEFAULT_OUTPUT_DIR = "docs/lessons-learned/conversation-contexts"


def slugify(value: str) -> str:
    lowered = value.strip().lower()
    slug = re.sub(r"[^a-z0-9]+", "-", lowered).strip("-")
    return slug or "conversation-context"


def next_available_path(output_dir: pathlib.Path, filename: str) -> pathlib.Path:
    candidate = output_dir / filename
    if not candidate.exists():
        return candidate

    stem = candidate.stem
    suffix = candidate.suffix
    counter = 2
    while True:
        numbered = output_dir / f"{stem}-{counter}{suffix}"
        if not numbered.exists():
            return numbered
        counter += 1


def build_document(title: str, transcript: str, source: str, saved_on: str) -> str:
    return (
        f"# {title}\n\n"
        f"- Saved on: {saved_on}\n"
        f"- Source: {source}\n"
        f"- Archived by: archive-conversation-context skill\n\n"
        "---\n\n"
        f"{transcript.rstrip()}\n"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Archive a provided conversation transcript as markdown."
    )
    parser.add_argument("--input", required=True, help="Path to the transcript file")
    parser.add_argument("--title", required=True, help="Human title for the archive")
    parser.add_argument(
        "--output-dir",
        default=DEFAULT_OUTPUT_DIR,
        help="Directory where the archive markdown file will be written",
    )
    parser.add_argument(
        "--date",
        default=dt.date.today().isoformat(),
        help="Date prefix to use in the filename (default: today)",
    )
    parser.add_argument(
        "--source-label",
        default="provided transcript",
        help="Short source label recorded in the document header",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    input_path = pathlib.Path(args.input)
    if not input_path.exists():
        print(f"Input file does not exist: {input_path}", file=sys.stderr)
        return 1

    transcript = input_path.read_text(encoding="utf-8")
    output_dir = pathlib.Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{args.date}--{slugify(args.title)}.md"
    output_path = next_available_path(output_dir, filename)

    document = build_document(
        title=args.title,
        transcript=transcript,
        source=args.source_label,
        saved_on=args.date,
    )
    output_path.write_text(document, encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
