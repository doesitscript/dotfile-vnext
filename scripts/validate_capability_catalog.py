#!/usr/bin/env python3
"""Validate cross-platform capability metadata without selecting or mutating hosts."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

import yaml


VALID_STATUSES = {"commissioned", "candidate", "documented_only", "deferred"}
VALID_PLATFORMS = {"macos", "linux", "windows", "kubernetes"}


def load_yaml_document(path: Path) -> object:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def load_yaml_mapping(path: Path) -> dict:
    data = load_yaml_document(path)
    if not isinstance(data, dict):
        raise ValueError(f"{path} must be a YAML mapping")
    return data


def role_tags(playbook: dict) -> set[str]:
    tags: set[str] = set()
    for play in playbook if isinstance(playbook, list) else []:
        for role in play.get("roles", []):
            if not isinstance(role, dict):
                continue
            for tag in role.get("tags", []):
                if isinstance(tag, str):
                    tags.add(tag)
    return tags


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = args.repo_root.resolve()

    source_layout = root / "inventory/group_vars/all/work_laptop_capabilities.yml"
    if source_layout.exists():
        laptop_path = source_layout
        packet_playbook_path = root / "exports/work-laptop-ai-tools/playbook.yaml"
    else:
        laptop_path = root / "group_vars/all/work_laptop_capabilities.yml"
        packet_playbook_path = root / "playbook.yaml"

    catalog = load_yaml_mapping(root / "policy/capability_catalog.yml")
    laptop = load_yaml_mapping(laptop_path)
    execution_roles = load_yaml_mapping(root / "policy/execution_roles.yml").get("execution_roles", {})
    packet_playbook = load_yaml_document(packet_playbook_path)
    packet_tags = role_tags(packet_playbook)
    errors: list[str] = []

    if catalog.get("schema_version") != 1:
        errors.append("policy/capability_catalog.yml must declare schema_version: 1")
    boundary = catalog.get("netbox_boundary", {})
    if boundary.get("labels_are_not_netbox_tags") is not True:
        errors.append("catalog must explicitly distinguish labels from NetBox tags")

    capabilities = catalog.get("capability_catalog", {})
    if not isinstance(capabilities, dict) or not capabilities:
        errors.append("capability_catalog must be a non-empty mapping")
        capabilities = {}

    for capability_id, capability in capabilities.items():
        if not isinstance(capability, dict):
            errors.append(f"{capability_id}: capability entry must be a mapping")
            continue
        surfaces = capability.get("platform_surfaces", {})
        if not isinstance(surfaces, dict) or not surfaces:
            errors.append(f"{capability_id}: platform_surfaces must be a non-empty mapping")
            continue
        for platform, surface in surfaces.items():
            label = f"{capability_id}.{platform}"
            if platform not in VALID_PLATFORMS:
                errors.append(f"{label}: unsupported platform")
            if not isinstance(surface, dict):
                errors.append(f"{label}: surface must be a mapping")
                continue
            status = surface.get("status")
            if status not in VALID_STATUSES:
                errors.append(f"{label}: invalid status {status!r}")
            implementation = surface.get("implementation")
            if status == "commissioned" and not implementation:
                errors.append(f"{label}: commissioned surface needs an implementation")
            tags = surface.get("execution_tags", [])
            if not isinstance(tags, list) or not all(isinstance(tag, str) for tag in tags):
                errors.append(f"{label}: execution_tags must be a string list")
                tags = []
            if status != "commissioned" and tags:
                errors.append(f"{label}: only commissioned surfaces may expose execution_tags")
            if platform == "macos" and implementation == "work_laptop_packet":
                missing_tags = sorted(set(tags) - packet_tags)
                if missing_tags:
                    errors.append(f"{label}: packet playbook lacks tags {missing_tags}")
            roles = surface.get("execution_roles", [])
            if not isinstance(roles, list) or not all(isinstance(role, str) for role in roles):
                errors.append(f"{label}: execution_roles must be a string list")
                roles = []
            missing_roles = sorted(set(roles) - set(execution_roles))
            if missing_roles:
                errors.append(f"{label}: unknown execution roles {missing_roles}")

    laptop_capabilities = laptop.get("work_laptop_capabilities", [])
    if not isinstance(laptop_capabilities, list):
        errors.append("work_laptop_capabilities must be a list")
        laptop_capabilities = []
    for entry in laptop_capabilities:
        if not isinstance(entry, dict):
            errors.append("work-laptop capability entry must be a mapping")
            continue
        capability_id = entry.get("capability_id")
        catalog_ref = entry.get("catalog_ref")
        if capability_id != catalog_ref:
            errors.append(f"{capability_id}: catalog_ref must equal capability_id")
        if catalog_ref not in capabilities:
            errors.append(f"{capability_id}: catalog_ref {catalog_ref!r} is unknown")
            continue
        tags = entry.get("execution_tags", [])
        if not isinstance(tags, list) or not all(isinstance(tag, str) for tag in tags):
            errors.append(f"{capability_id}: execution_tags must be a string list")
            continue
        missing_tags = sorted(set(tags) - packet_tags)
        if missing_tags:
            errors.append(f"{capability_id}: packet playbook lacks tags {missing_tags}")
        macos = capabilities[catalog_ref].get("platform_surfaces", {}).get("macos", {})
        if tags and macos.get("status") != "commissioned":
            errors.append(f"{capability_id}: non-commissioned macOS entry cannot expose execution tags")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(
        "OK: capability catalog validates "
        f"({len(capabilities)} capabilities, {len(laptop_capabilities)} work-laptop projections, "
        f"{len(packet_tags)} packet tags)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
