#!/usr/bin/env python3
"""Refresh the work-laptop downstream update command card.

Default step of sibling sync: keep scripts/recent_and_next.md concise and
current so the work Mac always has full + grouped update commands after pull.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

from packet_manifest import resolve_with_repo_root

DOWNSTREAM_UPDATE_COMMANDS = """# Downstream update commands (work Mac)

Run from the sibling checkout after `git pull`. Vault via `vault_pass.sh`.
Always skip `hosts_file` on day-2 unless refreshing the hosts catalog.

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
```

## Full update

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file
```

## Grouped updates (capability tags)

Prefer the smallest group that covers the change. Catalog:
`group_vars/all/work_laptop_capabilities.yml`.

```bash
# Default AI refresh (clients + related MCP integrations).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags ai_tools --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags ai_tools

# Clients only (Continue/Cline/Codex/OpenCode/Kilo/Aider/Zed).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags ai_clients

# Jan local runtime/RAG only (no weight download).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags model_runtime

# AI MCP integrations only.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags mcp
```

## Recent-change windows (playbook role-list tail)

Use when the sync only touched the sequential day-2 role tail.

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags recent_10
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \\
  --skip-tags hosts_file --tags recent_15
```

Authority: packet `AGENTS.md`. Apply skill: `work-laptop-day2-apply`.
This file is refreshed on every `work-laptop-packet-ops` / export-pack sync.
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".")
    parser.add_argument(
        "--packet-dir",
        default="exports/work-laptop-ai-tools",
        help="Packet root relative to repo root (source authority).",
    )
    parser.add_argument(
        "--target-dir",
        default="",
        help="Optional sibling checkout to write the same card into.",
    )
    return parser.parse_args()


def write_card(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(DOWNSTREAM_UPDATE_COMMANDS, encoding="utf-8")
    print(f"OK: wrote {path}")


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    packet_dir = resolve_with_repo_root(repo_root, args.packet_dir)
    write_card(packet_dir / "scripts" / "recent_and_next.md")
    if args.target_dir:
        target_dir = resolve_with_repo_root(repo_root, args.target_dir)
        write_card(target_dir / "scripts" / "recent_and_next.md")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
