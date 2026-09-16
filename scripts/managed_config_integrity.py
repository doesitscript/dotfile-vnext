#!/usr/bin/env python3
"""Validate managed config files: parse + optional Ansible marker integrity.

Used by roles (e.g. codex_user_config) and agents diagnosing client UI blocks
caused by unparseable local config.
"""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
import tomllib


def _check_markers(text: str, marker_name: str) -> list[str]:
    begin = f"BEGIN ANSIBLE MANAGED BLOCK: {marker_name}"
    end = f"END ANSIBLE MANAGED BLOCK: {marker_name}"
    begin_count = text.count(begin)
    end_count = text.count(end)
    errors: list[str] = []
    if begin_count != end_count:
        errors.append(
            f"marker imbalance for {marker_name!r}: begin={begin_count} end={end_count}"
        )
    if begin_count > 1:
        errors.append(
            f"duplicate managed blocks for {marker_name!r}: count={begin_count}"
        )
    return errors


def _parse(path: pathlib.Path, fmt: str) -> None:
    text = path.read_text(encoding="utf-8")
    if fmt == "toml":
        tomllib.loads(text)
        return
    if fmt == "json":
        json.loads(text)
        return
    if fmt == "yaml":
        try:
            import yaml  # type: ignore
        except ImportError as exc:  # pragma: no cover
            raise SystemExit(
                "PyYAML required for --format yaml; install in project venv"
            ) from exc
        yaml.safe_load(text)
        return
    raise SystemExit(f"unsupported format: {fmt}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", required=True, type=pathlib.Path)
    parser.add_argument(
        "--format",
        choices=("toml", "json", "yaml"),
        default="toml",
        dest="fmt",
    )
    parser.add_argument(
        "--marker",
        action="append",
        default=[],
        help="Ansible managed block name to check (repeatable)",
    )
    args = parser.parse_args(argv)

    path: pathlib.Path = args.path.expanduser()
    if not path.is_file():
        print(f"ERROR: missing file: {path}", file=sys.stderr)
        return 2

    text = path.read_text(encoding="utf-8")
    errors: list[str] = []
    try:
        _parse(path, args.fmt)
    except Exception as exc:  # noqa: BLE001 - surface parse errors to operators
        errors.append(f"parse failed ({args.fmt}): {exc}")

    for marker in args.marker:
        errors.extend(_check_markers(text, marker))

    if errors:
        for err in errors:
            print(f"ERROR: {err}", file=sys.stderr)
        return 1

    print(f"OK: {path} format={args.fmt} markers={args.marker or 'none'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
