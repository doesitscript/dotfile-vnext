#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json

import yaml


ROOT = Path(__file__).resolve().parents[4]
PROJECT_CATALOG = ROOT / "skills" / "catalog.yaml"
RUNTIME_CATALOG = ROOT / ".cursor" / "skills" / "catalog.yml"
RULES_DIR = ROOT / ".cursor" / "rules"
CURSOR_SKILLS_DIR = ROOT / ".cursor" / "skills"


def load_yaml(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def main() -> int:
    project_catalog = load_yaml(PROJECT_CATALOG)
    runtime_catalog = load_yaml(RUNTIME_CATALOG)

    project_skills = project_catalog.get("skills", {})
    runtime_skills = runtime_catalog.get("skills", [])

    summary = {
        "project_skill_count": len(project_skills),
        "project_skill_names": sorted(project_skills.keys()),
        "active_framework_rules": sorted(path.name for path in RULES_DIR.glob("framework-*.mdc")),
        "runtime_project_skills": sorted(
            item["name"]
            for item in runtime_skills
            if item.get("family") == "project-library" and item.get("status") == "runtime-symlink"
        ),
        "runtime_legacy_skills": sorted(
            item["name"]
            for item in runtime_skills
            if item.get("status") == "legacy-skill-only"
        ),
        "runtime_manifest_backed_framework_skills": sorted(
            item["name"]
            for item in runtime_skills
            if item.get("status") == "manifest-backed"
        ),
        "cursor_skill_dirs": sorted(
            path.name for path in CURSOR_SKILLS_DIR.iterdir() if path.is_dir() or path.is_symlink()
        ),
    }

    print(json.dumps(summary, indent=2, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
