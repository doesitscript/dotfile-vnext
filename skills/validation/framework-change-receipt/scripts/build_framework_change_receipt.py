#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
from pathlib import Path
import sys


ROUTING_SKILLS = [
    "single-host-apply-and-receipt",
    "single-host-ansible-rollout",
    "ansible-cli-surface-auditor",
    "macos-cli-completion-converger",
    "macos-cli-completion-pack",
    "interactive-shell-completion-proof",
    "context7-intake-or-emulate",
    "framework-skill-routing-auditor",
]

GOVERNANCE_SIGNALS = [
    "apply",
    "verify",
    "undo",
    "preview",
    "research",
    "context7",
    "validate",
    "governance",
]


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def changed_framework_files(shared, repo_root: Path) -> list[Path]:
    result = shared.run_command(
        [
            "git",
            "diff",
            "--name-only",
            "--",
            "AGENTS.md",
            "docs/codex_framework",
            ".cursor/rules",
        ],
        cwd=repo_root,
    )
    files = []
    for line in result["stdout"].splitlines():
        path = repo_root / line.strip()
        if path.exists():
            files.append(path)
    return files


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root")
    parser.add_argument("--files", nargs="*")
    args = parser.parse_args()

    repo_root = Path(args.repo_root or ".").expanduser().resolve()
    shared = load_shared_module(repo_root)
    shared.ensure_repo_python(repo_root, [str(Path(__file__).resolve()), *sys.argv[1:]])
    repo_root = shared.ensure_repo_root(str(repo_root))

    files = [repo_root / item for item in args.files] if args.files else changed_framework_files(shared, repo_root)
    files = [path for path in files if path.exists()]
    if not files:
        print("No changed framework files found.")
        return 0

    rows = []
    for path in files:
        text = shared.read_text(path)
        lower = text.lower()
        matched_skills = [skill for skill in ROUTING_SKILLS if skill in text]
        matched_governance = [signal for signal in GOVERNANCE_SIGNALS if signal in lower]
        state = "ok" if matched_skills or len(matched_governance) >= 2 else "review"
        rows.append(
            {
                "File": shared.markdown_link(path, 1, str(path.relative_to(repo_root))),
                "State": state,
                "Routing skills": ", ".join(matched_skills) if matched_skills else "-",
                "Governance signals": ", ".join(sorted(set(matched_governance))) if matched_governance else "-",
            }
        )

    memory = shared.read_memory()
    metadata = memory.setdefault("metadata", {})
    metadata["framework_change_receipt"] = {
        "row_count": len(rows),
        "rows": rows,
    }
    shared.write_memory(memory)

    print(shared.format_table(rows, ["File", "State", "Routing skills", "Governance signals"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
