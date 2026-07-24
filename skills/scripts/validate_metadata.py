#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys

import yaml


ROOT = Path(__file__).resolve().parents[2]
SKILLS_DIR = ROOT / "skills"
REQUIRED_FIELDS = [
    "name",
    "description",
    "version",
    "author",
    "title",
    "technology",
    "document_type",
    "status",
    "authority",
    "source_type",
    "skill_scope",
    "last_reviewed_at",
]
VALID_STATUSES = {"draft", "reviewed", "deprecated"}
NAME_RE = re.compile(r"^[a-z0-9-]{1,64}$")
OPENAI_REQUIRED_FIELDS = ("display_name", "short_description", "default_prompt")


def parse_frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: missing frontmatter start")
    end = text.find("\n---\n", 4)
    if end == -1:
        raise ValueError(f"{path}: missing frontmatter end")
    return yaml.safe_load(text[4:end])


def validate_skill(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        frontmatter = parse_frontmatter(path)
    except Exception as exc:
        return [str(exc)]

    for field in REQUIRED_FIELDS:
        if field not in frontmatter or frontmatter[field] in ("", None):
            errors.append(f"{path}: missing required field '{field}'")

    name = frontmatter.get("name")
    if isinstance(name, str):
        if not NAME_RE.fullmatch(name):
            errors.append(f"{path}: invalid skill name '{name}'")
        if name != path.parent.name:
            errors.append(f"{path}: frontmatter name does not match directory name")

    status = frontmatter.get("status")
    if status not in VALID_STATUSES:
        errors.append(f"{path}: invalid status '{status}'")

    if frontmatter.get("document_type") != "skill":
        errors.append(f"{path}: document_type must be 'skill'")

    if frontmatter.get("skill_scope") != "project":
        errors.append(f"{path}: skill_scope must be 'project'")

    errors.extend(validate_agents_metadata(path.parent, name, status))

    return errors


def validate_agents_metadata(skill_dir: Path, skill_name: str | None, status: str | None) -> list[str]:
    errors: list[str] = []
    agents_dir = skill_dir / "agents"
    provider_files = sorted(agents_dir.glob("*.yaml")) + sorted(agents_dir.glob("*.yml"))

    if status == "reviewed":
        openai_path = agents_dir / "openai.yaml"
        if not openai_path.exists():
            errors.append(f"{skill_dir / 'SKILL.md'}: reviewed skills must include agents/openai.yaml")

    for provider_path in provider_files:
        try:
            data = yaml.safe_load(provider_path.read_text(encoding="utf-8"))
        except Exception as exc:
            errors.append(f"{provider_path}: invalid YAML ({exc})")
            continue

        if not isinstance(data, dict):
            errors.append(f"{provider_path}: provider metadata must be a YAML mapping")
            continue

        if provider_path.name != "openai.yaml":
            continue

        interface = data.get("interface")
        if not isinstance(interface, dict):
            errors.append(f"{provider_path}: interface must be a mapping")
            continue

        for field in OPENAI_REQUIRED_FIELDS:
            value = interface.get(field)
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{provider_path}: interface.{field} must be a non-empty string")

        short_description = interface.get("short_description")
        if isinstance(short_description, str) and short_description.strip():
            if not (25 <= len(short_description.strip()) <= 64):
                errors.append(
                    f"{provider_path}: interface.short_description must be 25-64 characters"
                )

        default_prompt = interface.get("default_prompt")
        if (
            isinstance(default_prompt, str)
            and default_prompt.strip()
            and isinstance(skill_name, str)
            and f"${skill_name}" not in default_prompt
        ):
            errors.append(
                f"{provider_path}: interface.default_prompt must mention ${skill_name}"
            )

    return errors


def main() -> int:
    errors: list[str] = []
    for path in sorted(SKILLS_DIR.glob("*/*/SKILL.md")):
        errors.extend(validate_skill(path))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("project skill metadata validation ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
