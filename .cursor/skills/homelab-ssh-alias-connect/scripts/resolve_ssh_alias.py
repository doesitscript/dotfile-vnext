#!/usr/bin/env python3
"""Resolve managed-host SSH as inventory_hostname → ~/.ssh/config Host alias.

Agents must not invent ssh -i user@ip. Print the exact command: ssh <alias>.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


def ssh_config_hosts(config_path: Path) -> set[str]:
    if not config_path.is_file():
        return set()
    hosts: set[str] = set()
    for line in config_path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"^\s*Host\s+(.+?)\s*$", line, flags=re.IGNORECASE)
        if not m:
            continue
        for token in m.group(1).split():
            if token != "*" and not token.startswith("!"):
                hosts.add(token)
    return hosts


def inventory_hint(repo: Path, host: str) -> str:
    """Best-effort: show ansible_connection from host_vars without full inventory."""
    candidates = [
        repo / "inventory" / "host_vars" / f"{host}.yaml",
        repo / "inventory" / "host_vars" / f"{host}.yml",
        repo / "inventory" / "host_vars" / host / "main.yml",
    ]
    for path in candidates:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        conn = re.search(r"^ansible_connection:\s*[\"']?(\S+?)[\"']?\s*$", text, re.M)
        ah = re.search(r"^ansible_host:\s*[\"']?(\S+?)[\"']?\s*$", text, re.M)
        parts = []
        if conn:
            parts.append(f"ansible_connection={conn.group(1)}")
        if ah:
            parts.append(f"ansible_host={ah.group(1)} (HostName in ssh config; do not ssh to this by hand)")
        if parts:
            return f"host_vars {path.name}: " + "; ".join(parts)
    return "host_vars: not found (ssh config Host is still authoritative for interactive ssh)"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", help="Inventory hostname / SSH Host alias")
    parser.add_argument(
        "--list-ssh-hosts",
        action="store_true",
        help="List Host entries from ~/.ssh/config",
    )
    parser.add_argument(
        "--ssh-config",
        default=os.path.expanduser("~/.ssh/config"),
        help="Path to ssh config (default: ~/.ssh/config)",
    )
    args = parser.parse_args()

    # .../dotfile-vnext/.cursor/skills/homelab-ssh-alias-connect/scripts/this.py
    repo = Path(__file__).resolve().parents[4]
    config_path = Path(args.ssh_config)
    hosts = ssh_config_hosts(config_path)

    print("=== homelab-ssh-alias-connect ===")
    print("Interactive SSH = inventory hostname as Host alias.")
    print("Do not invent user@ip / -i / -p — use ~/.ssh/config.\n")

    if args.list_ssh_hosts:
        for name in sorted(hosts):
            print(f"  Host {name}")
        return 0

    if not args.host:
        parser.error("--host or --list-ssh-hosts required")

    host = args.host.strip()
    print(f"Requested inventory hostname: {host}")
    print(inventory_hint(repo, host))

    in_config = host in hosts
    print(f"~/.ssh/config Host {host}: {'present' if in_config else 'MISSING'}")

    if not in_config:
        print(
            "\nFAIL: no SSH alias. Apply access_identity_controller SSH config "
            "(do not invent a one-off ssh command)."
        )
        return 2

    print("\nConnect with exactly:")
    print(f"  ssh {host}")
    print("\nNothing else is required for interactive OpenSSH.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
