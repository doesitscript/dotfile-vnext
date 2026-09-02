#!/usr/bin/env python3
"""Resolve the active docs/plans packet for multi-agent-implementer bootstrap."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def repo_root_from(start: Path) -> Path | None:
    for parent in [start, *start.parents]:
        if (parent / "AGENTS.md").is_file() and (parent / "skills" / "catalog.yaml").is_file():
            return parent
    return None


def is_plan_packet_dir(path: Path) -> bool:
    if not path.is_dir():
        return False
    parent = path.parent
    return parent.name == "plans" and parent.parent.name == "docs"


def evaluator_signals(path: Path) -> bool:
    if (path / "EVALUATOR-WAIT-STATE.md").is_file():
        return True
    if any(path.glob("feedback_for_review_by_evaluator_*")):
        return True
    if any(path.glob("ready_for_review_by_evaluator_*")):
        return True
    if any(path.glob("AI-*EVALUATION*.md")):
        return True
    if (path / "AI-CORRECTION-EVALUATION.md").is_file():
        return True
    return False


def list_plan_dirs(repo_root: Path) -> list[Path]:
    plans_root = repo_root / "docs" / "plans"
    if not plans_root.is_dir():
        return []
    return sorted(
        p for p in plans_root.iterdir() if p.is_dir() and not p.name.startswith(".")
    )


def resolve_plan_dir(explicit: str | None, cwd: Path, repo_root: Path) -> tuple[Path | None, str]:
    if explicit:
        candidate = Path(explicit).expanduser()
        if not candidate.is_absolute():
            candidate = (repo_root / candidate).resolve()
        else:
            candidate = candidate.resolve()
        if is_plan_packet_dir(candidate):
            return candidate, "explicit"
        return None, "explicit_invalid"

    if is_plan_packet_dir(cwd):
        return cwd.resolve(), "cwd_inside_plan"

    for parent in cwd.parents:
        if is_plan_packet_dir(parent):
            return parent.resolve(), "ancestor_plan"

    active = [p for p in list_plan_dirs(repo_root) if evaluator_signals(p)]
    if len(active) == 1:
        return active[0], "single_evaluator_plan"
    if len(active) > 1:
        return None, "ambiguous_multiple_plans"

    packets = list_plan_dirs(repo_root)
    if len(packets) == 1:
        return packets[0], "single_plan_packet"

    return None, "unresolved"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--plan-dir",
        help="Explicit plan packet path (repo-relative or absolute)",
    )
    parser.add_argument(
        "--repo-root",
        help="Repo root (default: discover from cwd)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON {plan_dir, reason, repo_root}",
    )
    args = parser.parse_args()

    cwd = Path.cwd()
    repo_root = Path(args.repo_root).resolve() if args.repo_root else repo_root_from(cwd)
    if repo_root is None:
        print("error: could not locate dotfile-vnext repo root", file=sys.stderr)
        return 2

    plan_dir, reason = resolve_plan_dir(args.plan_dir, cwd, repo_root)
    payload = {
        "repo_root": str(repo_root),
        "plan_dir": str(plan_dir) if plan_dir else None,
        "reason": reason,
    }

    if args.json:
        print(json.dumps(payload, indent=2))
    elif plan_dir:
        print(plan_dir)
    else:
        print(f"unresolved: {reason}", file=sys.stderr)
        if reason == "ambiguous_multiple_plans":
            for p in list_plan_dirs(repo_root):
                if evaluator_signals(p):
                    print(f"  candidate: {p.relative_to(repo_root)}", file=sys.stderr)
        return 1

    return 0 if plan_dir else 1


if __name__ == "__main__":
    raise SystemExit(main())
