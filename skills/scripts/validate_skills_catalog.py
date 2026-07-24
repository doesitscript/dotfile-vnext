#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

import yaml


ROOT = Path(__file__).resolve().parents[2]
SKILLS_DIR = ROOT / "skills"
CATALOG_PATH = SKILLS_DIR / "catalog.yaml"
VALID_CATEGORIES = {"documentation", "implementation", "validation"}
VALID_STATUSES = {"draft", "reviewed", "deprecated"}


def main() -> int:
    catalog = yaml.safe_load(CATALOG_PATH.read_text(encoding="utf-8"))
    errors: list[str] = []

    if catalog.get("schema_version") != 2:
        errors.append("skills/catalog.yaml: schema_version must be 2")
    if not isinstance(catalog.get("description"), str) or not catalog["description"].strip():
        errors.append("skills/catalog.yaml: description must be a non-empty string")

    skills = catalog.get("skills")
    if not isinstance(skills, dict):
        errors.append("skills/catalog.yaml: skills must be a mapping")
        skills = {}

    for key, entry in skills.items():
        if key != entry.get("name"):
            errors.append(f"{key}: entry name mismatch")
        if entry.get("scope") != "project":
            errors.append(f"{key}: scope must be 'project'")
        if entry.get("category") not in VALID_CATEGORIES:
            errors.append(f"{key}: invalid category")
        if entry.get("status") not in VALID_STATUSES:
            errors.append(f"{key}: invalid status")
        path = SKILLS_DIR / entry.get("path", "")
        if not path.exists():
            errors.append(f"{key}: missing skill path {path}")
        for ref in entry.get("references", []):
            if not (SKILLS_DIR / ref).exists() and not (ROOT / ref).exists():
                errors.append(f"{key}: missing reference {ref}")
        for array_name in ["triggers", "do_not_use_when", "handoff_from", "handoff_to", "complements"]:
            if not isinstance(entry.get(array_name), list):
                errors.append(f"{key}: {array_name} must be a list")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("project skills catalog validation ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
