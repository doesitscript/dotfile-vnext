#!/usr/bin/env python3
"""Check that playbook recent_10 / recent_15 tags match the role-list tail.

New day-2 roles are appended above work_laptop_packet_receipt. This script
fails if those tags drift from the last 10 and last 15 role entries.
"""

from __future__ import annotations

import sys
from pathlib import Path


def role_entries(text: str) -> list[tuple[str, list[str]]]:
    entries: list[tuple[str, list[str]]] = []
    in_roles = False
    current_role: str | None = None
    current_tags: list[str] = []
    collecting_tags = False

    def flush() -> None:
        nonlocal current_role, current_tags, collecting_tags
        if current_role is not None:
            entries.append((current_role, current_tags))
        current_role = None
        current_tags = []
        collecting_tags = False

    for raw in text.splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not in_roles:
            if line.strip() == "roles:":
                in_roles = True
            continue
        if line and not line.startswith(" ") and not line.startswith("-"):
            flush()
            break
        stripped = line.strip()
        if stripped.startswith("- role:"):
            flush()
            current_role = stripped.split(":", 1)[1].strip()
            continue
        if current_role is None:
            continue
        if stripped.startswith("tags:"):
            collecting_tags = True
            rest = stripped.split(":", 1)[1].strip()
            if rest.startswith("[") and rest.endswith("]"):
                current_tags = [
                    part.strip()
                    for part in rest[1:-1].split(",")
                    if part.strip()
                ]
                collecting_tags = False
            continue
        if collecting_tags and stripped.startswith("- "):
            current_tags.append(stripped[2:].strip())
            continue
        if collecting_tags and stripped:
            collecting_tags = False
    flush()
    return entries


def main() -> int:
    playbook = Path(__file__).resolve().parents[1] / "playbook.yaml"
    entries = role_entries(playbook.read_text(encoding="utf-8"))
    if len(entries) < 15:
        print(f"expected at least 15 role entries, found {len(entries)}", file=sys.stderr)
        return 1

    last_10 = entries[-10:]
    last_15 = entries[-15:]
    errors: list[str] = []

    for role, tags in last_10:
        if "recent_10" not in tags:
            errors.append(f"last-10 role {role} is missing recent_10")
    for role, tags in last_15:
        if "recent_15" not in tags:
            errors.append(f"last-15 role {role} is missing recent_15")
    for role, tags in entries[:-10]:
        if "recent_10" in tags:
            errors.append(f"role {role} has recent_10 but is outside the last 10")
    for role, tags in entries[:-15]:
        if "recent_15" in tags:
            errors.append(f"role {role} has recent_15 but is outside the last 15")

    print("recent_10:")
    for role, _tags in last_10:
        print(f"  - {role}")
    print("recent_15:")
    for role, _tags in last_15:
        print(f"  - {role}")

    if errors:
        print("recent window mismatch:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1
    print("recent window matches playbook role-list tail")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
