#!/usr/bin/env python3
"""Merge Ansible-managed Kilo slices into an existing kilo.jsonc without wiping user keys.

Usage:
  merge_kilo_config.py --existing PATH --overlay PATH --out PATH

- existing may be missing (then overlay is written as-is)
- existing may be JSONC (// and /* */ comments stripped)
- overlay is pure JSON (from the role template)
- Managed slices replaced from overlay; other top-level keys preserved
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


MANAGED_TOP_LEVEL = frozenset(
    {
        "$schema",
        "model",
        "small_model",
        "default_agent",
        "auto_collapse_reasoning",
        "terminal_command_display",
        "code_edit_display",
        "permission",
        "compaction",
        "disabled_providers",
    }
)


def strip_jsonc(text: str) -> str:
    """Remove // and /* */ comments outside strings (good enough for kilo.jsonc)."""
    out: list[str] = []
    i = 0
    n = len(text)
    in_string = False
    escape = False
    while i < n:
        ch = text[i]
        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            i += 2
            while i < n and text[i] not in "\r\n":
                i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i = min(i + 2, n)
            continue
        out.append(ch)
        i += 1
    # Also drop trailing commas before } or ] for slightly looser JSONC.
    cleaned = "".join(out)
    cleaned = re.sub(r",(\s*[}\]])", r"\1", cleaned)
    return cleaned


def load_jsonish(path: Path) -> dict[str, Any]:
    raw = path.read_text(encoding="utf-8")
    return json.loads(strip_jsonc(raw))


def merge_kilo(existing: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    result = dict(existing)

    for key in MANAGED_TOP_LEVEL:
        if key in overlay:
            result[key] = overlay[key]

    # Providers: replace only the managed provider id; keep others.
    overlay_providers = overlay.get("provider") or {}
    existing_providers = dict(result.get("provider") or {})
    for pid, pdata in overlay_providers.items():
        existing_providers[pid] = pdata
    if overlay_providers or existing_providers:
        result["provider"] = existing_providers

    # Agents: replace managed agent ids from overlay; keep custom agents.
    overlay_agents = overlay.get("agent") or {}
    existing_agents = dict(result.get("agent") or {})
    for aid, acfg in overlay_agents.items():
        existing_agents[aid] = acfg
    if overlay_agents or existing_agents:
        result["agent"] = existing_agents

    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--existing", required=True)
    parser.add_argument("--overlay", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    overlay_path = Path(args.overlay)
    out_path = Path(args.out)
    existing_path = Path(args.existing)

    overlay = load_jsonish(overlay_path)

    if existing_path.is_file() and existing_path.resolve() != overlay_path.resolve():
        try:
            existing = load_jsonish(existing_path)
        except (OSError, json.JSONDecodeError) as exc:
            print(
                f"WARN: could not parse existing {existing_path}: {exc}; "
                "writing managed overlay only",
                file=sys.stderr,
            )
            existing = {}
        merged = merge_kilo(existing, overlay)
    else:
        merged = overlay

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
