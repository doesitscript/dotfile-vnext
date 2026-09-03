"""Packet vs parent path discovery for work-laptop vault scripts."""

from __future__ import annotations

import os
from pathlib import Path


def discover_parent_root(packet_root: Path) -> Path:
    packet_root = packet_root.resolve()
    env = os.environ.get("WORK_LAPTOP_PARENT_ROOT", "").strip()
    if env:
        return Path(env).expanduser().resolve()

    if packet_root.parent.name == "exports":
        nested = packet_root.parent.parent
        if (nested / "vault").is_dir() or (nested / ".vault_pass").is_file():
            return nested

    sibling_parent = packet_root.parent / "dotfile-vnext"
    if (sibling_parent / "vault").is_dir() or (sibling_parent / ".vault_pass").is_file():
        return sibling_parent

    return packet_root.parent.parent
