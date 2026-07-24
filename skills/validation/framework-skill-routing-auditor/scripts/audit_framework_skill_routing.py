#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
from pathlib import Path
import sys

PROCEDURE_FAMILIES = [
    {
        "name": "single-host-rollout",
        "keywords": ["preview", "apply", "verify", "receipt", "list-hosts", "list-tasks", "--check"],
        "min_hits": 2,
        "skills": ["single-host-apply-and-receipt", "single-host-ansible-rollout"],
    },
    {
        "name": "cli-surface-audit",
        "keywords": ["owning role", "verify command", "playbook lane", "completion path", "repo-managed cli"],
        "min_hits": 1,
        "skills": ["ansible-cli-surface-auditor"],
    },
    {
        "name": "macos-cli-completion",
        "keywords": ["bash completion", "tab completion", "interactive shell", "pty", "completion runtime"],
        "min_hits": 1,
        "skills": [
            "macos-cli-completion-converger",
            "macos-cli-completion-pack",
            "interactive-shell-completion-proof",
        ],
    },
    {
        "name": "context7-fallback",
        "keywords": ["context7", "library id", "best-effort", "emulated intake"],
        "min_hits": 2,
        "skills": ["context7-intake-or-emulate"],
    },
]


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def iter_targets(repo_root: Path) -> list[Path]:
    targets = [repo_root / "AGENTS.md"]
    targets.extend(sorted((repo_root / "docs" / "codex_framework").rglob("*.md")))
    targets.extend(sorted((repo_root / ".cursor" / "rules").glob("framework-*.mdc")))
    return [path for path in targets if path.exists()]


def first_signal(shared, path: Path, needles: list[str]) -> tuple[int, str]:
    text = shared.read_text(path)
    for needle in needles:
        line = shared.find_line(path, needle)
        if line != 1 or needle in text.splitlines()[0]:
            return line, needle
    return 1, needles[0]


def audit(shared, repo_root: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for path in iter_targets(repo_root):
        text = shared.read_text(path)
        lower = text.lower()
        rel = path.relative_to(repo_root)

        for family in PROCEDURE_FAMILIES:
            hits = [kw for kw in family["keywords"] if kw.lower() in lower]
            if len(hits) < family["min_hits"]:
                continue

            matched = [skill for skill in family["skills"] if skill in text]
            if not matched:
                state = "candidate"
            elif len(matched) < len(family["skills"]):
                state = "partial"
            else:
                state = "routed"

            line, signal = first_signal(shared, path, matched or hits)
            rows.append(
                {
                    "File": shared.markdown_link(path, line, str(rel)),
                    "Family": family["name"],
                    "State": state,
                    "Suggested skills": ", ".join(family["skills"]),
                    "Signal": shared.shorten(signal, 80),
                }
            )
    return rows


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root")
    parser.add_argument("--candidate-only", action="store_true")
    args = parser.parse_args()

    repo_root = Path(args.repo_root or ".").expanduser().resolve()
    shared = load_shared_module(repo_root)
    shared.ensure_repo_python(repo_root, [str(Path(__file__).resolve()), *sys.argv[1:]])
    repo_root = shared.ensure_repo_root(str(repo_root))

    rows = audit(shared, repo_root)
    if args.candidate_only:
        rows = [row for row in rows if row["State"] != "routed"]

    memory = shared.read_memory()
    metadata = memory.setdefault("metadata", {})
    metadata["framework_skill_routing_audits"] = {
        "row_count": len(rows),
        "rows": rows,
    }
    shared.write_memory(memory)

    if not rows:
        print("No framework skill-routing candidates found.")
        return 0

    print(
        shared.format_table(
            rows,
            ["File", "Family", "State", "Suggested skills", "Signal"],
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
