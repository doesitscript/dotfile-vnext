#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import sys

import yaml


@dataclass
class BridgedSkill:
    name: str
    source_dir: Path
    runtime_name: str
    summary: str


REPO_ROOT = Path(__file__).resolve().parents[4]
SKILLS_CATALOG = REPO_ROOT / "skills" / "catalog.yaml"
CURSOR_SKILLS_DIR = REPO_ROOT / ".cursor" / "skills"
CURSOR_CATALOG = CURSOR_SKILLS_DIR / "catalog.yml"
MANAGED_FAMILY = "project-library"
MANAGED_STATUS = "runtime-symlink"
BACKUP_SUFFIX = ".before-project-skill-runtime-bridge-"


def load_yaml(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def save_yaml(path: Path, data: dict) -> None:
    rendered = yaml.safe_dump(
        data,
        sort_keys=False,
        allow_unicode=False,
        width=100,
    )
    path.write_text(rendered, encoding="utf-8")


def build_bridged_skills() -> list[BridgedSkill]:
    catalog = load_yaml(SKILLS_CATALOG)
    bridged: list[BridgedSkill] = []

    for name, entry in catalog["skills"].items():
        runtime = entry.get("runtime_bridge") or {}
        if not runtime.get("enabled", False):
            continue

        skill_path = REPO_ROOT / "skills" / entry["path"]
        source_dir = skill_path.parent
        runtime_name = runtime["cursor_skill_name"]

        if not source_dir.exists():
            raise FileNotFoundError(f"Missing source skill directory for {name}: {source_dir}")

        bridged.append(
            BridgedSkill(
                name=name,
                source_dir=source_dir,
                runtime_name=runtime_name,
                summary=entry["description"],
            )
        )

    return sorted(bridged, key=lambda item: item.runtime_name)


def timestamp_label() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def backup_target(path: Path) -> Path:
    backup = path.with_name(f"{path.name}{BACKUP_SUFFIX}{timestamp_label()}")
    path.rename(backup)
    return backup


def ensure_runtime_symlink(skill: BridgedSkill) -> None:
    target = CURSOR_SKILLS_DIR / skill.runtime_name
    link_value = Path("..") / ".." / skill.source_dir.relative_to(REPO_ROOT)

    if target.is_symlink():
        current = Path(target.readlink())
        if current == link_value:
            return None
        target.unlink()
    elif target.exists():
        backup = backup_target(target)
        print(f"backed up {target.relative_to(REPO_ROOT)} -> {backup.relative_to(REPO_ROOT)}")

    target.symlink_to(link_value)
    return None


def refresh_cursor_catalog(bridged_skills: list[BridgedSkill]) -> None:
    catalog = load_yaml(CURSOR_CATALOG)
    skills = catalog.get("skills", [])

    managed_names = {skill.runtime_name for skill in bridged_skills}
    retained = [
        item
        for item in skills
        if not (
            item.get("family") == MANAGED_FAMILY
            and item.get("name") in managed_names
        )
    ]

    for skill in bridged_skills:
        retained.append(
            {
                "name": skill.runtime_name,
                "family": MANAGED_FAMILY,
                "status": MANAGED_STATUS,
                "skill_file": f".cursor/skills/{skill.runtime_name}/SKILL.md",
                "summary": skill.summary,
            }
        )

    catalog["skills"] = retained
    save_yaml(CURSOR_CATALOG, catalog)


def verify_bridge(bridged_skills: list[BridgedSkill]) -> None:
    for skill in bridged_skills:
        target = CURSOR_SKILLS_DIR / skill.runtime_name
        if not target.is_symlink():
            raise RuntimeError(f"Expected symlink missing: {target}")
        resolved = target.resolve()
        if resolved != skill.source_dir.resolve():
            raise RuntimeError(
                f"Symlink target mismatch for {skill.runtime_name}: {resolved} != {skill.source_dir}"
            )


def main() -> int:
    bridged_skills = build_bridged_skills()
    if not bridged_skills:
        print("No runtime_bridge-enabled skills found in skills/catalog.yaml.")
        return 0

    CURSOR_SKILLS_DIR.mkdir(parents=True, exist_ok=True)

    for skill in bridged_skills:
        ensure_runtime_symlink(skill)

    refresh_cursor_catalog(bridged_skills)
    verify_bridge(bridged_skills)

    for skill in bridged_skills:
        print(f"bridged {skill.runtime_name} -> {skill.source_dir.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
