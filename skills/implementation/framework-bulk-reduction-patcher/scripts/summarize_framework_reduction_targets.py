#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
from collections import defaultdict
from pathlib import Path
import sys


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


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

    memory = shared.read_memory()
    rows = memory.get("metadata", {}).get("framework_skill_routing_audits", {}).get("rows", [])
    if not rows:
        print("No routing audit rows found. Run framework-skill-routing-auditor first.")
        return 1

    if args.candidate_only:
        rows = [row for row in rows if row.get("State") != "routed"]

    grouped: dict[str, dict[str, set[str]]] = defaultdict(lambda: {"families": set(), "skills": set(), "states": set()})
    for row in rows:
        file_key = row["File"]
        grouped[file_key]["families"].add(row["Family"])
        grouped[file_key]["states"].add(row["State"])
        for skill_name in row["Suggested skills"].split(", "):
            grouped[file_key]["skills"].add(skill_name)

    summary_rows = []
    for file_key, data in grouped.items():
        summary_rows.append(
            {
                "File": file_key,
                "Families": ", ".join(sorted(data["families"])),
                "States": ", ".join(sorted(data["states"])),
                "Suggested skills": ", ".join(sorted(data["skills"])),
            }
        )

    print(shared.format_table(summary_rows, ["File", "Families", "States", "Suggested skills"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
