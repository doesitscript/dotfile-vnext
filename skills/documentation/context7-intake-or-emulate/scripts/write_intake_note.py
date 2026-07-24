#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--library-root", default="/Users/joshc/develop/homelab-reference-library")
    parser.add_argument("--slug", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--technology", required=True)
    parser.add_argument("--mode", choices=["context7", "emulated"], required=True)
    parser.add_argument("--upstream-url", default="")
    parser.add_argument("--upstream-repository", default="")
    parser.add_argument("--source-version", default="")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    shared = load_shared_module(repo_root)
    repo_root = shared.ensure_repo_root(str(repo_root))
    library_root = shared.ensure_library_root(args.library_root)
    mode_label = "context7" if args.mode == "context7" else "best-effort emulated intake"

    note_path = library_root / "notes" / "investigations" / f"{args.slug}.md"
    note_text = f"""---
title: {args.title}
technology: {args.technology}
document_type: investigation
status: draft
authority: internal
source_type: {'context7-derived' if args.mode == 'context7' else 'internal'}
upstream_url: "{args.upstream_url}"
upstream_repository: "{args.upstream_repository}"
source_version: "{args.source_version}"
retrieved_at: "{shared.iso_now()[:10]}"
last_reviewed_at: "{shared.iso_now()[:10]}"
tags:
  - {args.technology}
  - investigation
  - {mode_label}
---

# {args.title}

## Request

Describe the intake request here.

## Context7 result

- mode: **{mode_label}**
- library ID:
- resolve attempts:

## Selected source

-

## Observed doc surface

-

## Follow-up

-
"""
    note_path.write_text(note_text, encoding="utf-8")

    memory = shared.read_memory()
    memory.setdefault("intakes", {})[args.slug] = {
        "title": args.title,
        "technology": args.technology,
        "mode": mode_label,
        "note_path": str(note_path),
        "updated_at": shared.iso_now(),
    }
    shared.write_memory(memory)
    print(note_path)


if __name__ == "__main__":
    main()
