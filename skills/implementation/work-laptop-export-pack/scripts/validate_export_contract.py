#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--packet-root", default="exports/work-laptop-ai-tools")
    return parser.parse_args()


def load_yaml(path: Path) -> object:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def load_shell_contract(path: Path) -> dict[str, str]:
    variables: dict[str, str] = {}
    pattern = re.compile(r'^([A-Z0-9_]+)="([^"]*)"$')
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = pattern.match(stripped)
        if not match:
            raise ValueError(f"Unsupported contract line in {path}: {stripped}")
        variables[match.group(1)] = match.group(2)
    return variables


def fail(messages: list[str]) -> int:
    for message in messages:
        print(f"FAIL: {message}")
    return 1


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    packet_root = (repo_root / args.packet_root).resolve()

    contract_path = packet_root / "bootstrap" / "bootstrap-contract.sh"
    inventory_path = packet_root / "inventory.yaml"
    host_vars_path = packet_root / "host_vars" / "work-laptop.yaml"
    ansible_cfg_path = packet_root / "ansible.cfg"
    manifest_path = packet_root / "export-manifest.yml"
    packet_requirements_path = packet_root / "scripts" / "requirements.txt"
    repo_requirements_path = repo_root / "scripts" / "requirements.txt"
    bootstrap_playbook_path = packet_root / "bootstrap" / "bootstrap-tooling.yaml"
    mac_dev_group_path = repo_root / "inventory" / "group_vars" / "mac_dev.yaml"
    python_defaults_path = repo_root / "roles" / "python" / "defaults" / "main.yml"
    ansible_dev_tools_defaults_path = repo_root / "roles" / "ansible_dev_tools" / "defaults" / "main.yml"

    contract = load_shell_contract(contract_path)
    inventory = load_yaml(inventory_path)
    host_vars = load_yaml(host_vars_path)
    manifest = load_yaml(manifest_path)
    mac_dev_group = load_yaml(mac_dev_group_path)
    python_defaults = load_yaml(python_defaults_path)
    ansible_dev_tools_defaults = load_yaml(ansible_dev_tools_defaults_path)
    bootstrap_playbook = load_yaml(bootstrap_playbook_path)

    errors: list[str] = []

    required_contract = {
        "PACKET_REFERENCE_HOST": "mac-dev",
        "PACKET_SYSTEM_PYTHON": "/usr/bin/python3",
        "PACKET_VENV_RELATIVE": ".venv",
        "PACKET_REQUIREMENTS_RELATIVE": "scripts/requirements.txt",
        "PACKET_COLLECTIONS_DIR_RELATIVE": "collections",
        "PACKET_COLLECTIONS_REQUIREMENTS_RELATIVE": "collections/requirements.yml",
        "PACKET_BOOTSTRAP_PLAYBOOK_RELATIVE": "bootstrap/bootstrap-tooling.yaml",
        "PACKET_MAIN_PLAYBOOK_RELATIVE": "playbook.yaml",
        "PACKET_INVENTORY_RELATIVE": "inventory.yaml",
        "PACKET_PUBLIC_BIN_RELATIVE": ".local/bin",
    }
    for key, expected in required_contract.items():
        if contract.get(key) != expected:
            errors.append(f"{contract_path}: expected {key}={expected!r}, found {contract.get(key)!r}")

    inventory_host = (((inventory or {}).get("all") or {}).get("hosts") or {}).get("work-laptop") or {}
    if inventory_host.get("ansible_python_interpreter") != contract["PACKET_SYSTEM_PYTHON"]:
        errors.append("Packet inventory ansible_python_interpreter does not match bootstrap contract.")
    if mac_dev_group.get("ansible_python_interpreter") != contract["PACKET_SYSTEM_PYTHON"]:
        errors.append("mac-dev ansible_python_interpreter does not match bootstrap contract.")

    if host_vars.get("pyenv_global_versions") != mac_dev_group.get("pyenv_global_versions"):
        errors.append("Packet pyenv_global_versions do not match mac-dev group vars.")
    if host_vars.get("python_vscode_extensions") != []:
        errors.append("Packet host_vars should disable python_vscode_extensions for bootstrap noise control.")
    if host_vars.get("vscode_cli_binary") != "code":
        errors.append("Packet host_vars should set vscode_cli_binary to code.")

    if ansible_dev_tools_defaults.get("ansible_dev_tools_venv_path") != "{{ dotfiles_home }}/.venv":
        errors.append("ansible_dev_tools default venv path drifted from packet contract assumptions.")
    if ansible_dev_tools_defaults.get("ansible_dev_tools_global_bin_dir") != "{{ ansible_env.HOME }}/.local/bin":
        errors.append("ansible_dev_tools global bin dir drifted from packet contract assumptions.")

    if python_defaults.get("pipx_packages") != ["poetry", "virtualenv"]:
        errors.append("python role pipx_packages no longer match the assumptions baked into this packet.")

    if (
        packet_requirements_path.read_text(encoding="utf-8").rstrip("\n")
        != repo_requirements_path.read_text(encoding="utf-8").rstrip("\n")
    ):
        errors.append("Packet scripts/requirements.txt does not match repo scripts/requirements.txt.")

    ansible_cfg_text = ansible_cfg_path.read_text(encoding="utf-8")
    if "roles_path = ./roles" not in ansible_cfg_text:
        errors.append("Packet ansible.cfg must keep roles_path = ./roles.")
    if "collections_path = ./collections" not in ansible_cfg_text:
        errors.append("Packet ansible.cfg must keep collections_path = ./collections.")

    manifest_include = manifest.get("include") or []
    include_paths = set()
    include_dests = set()
    for entry in manifest_include:
        if isinstance(entry, str):
            include_paths.add(entry)
            continue
        if isinstance(entry, dict):
            include_paths.add(entry.get("path"))
            include_dests.add(entry.get("dest"))
    required_paths = {
        "exports/work-laptop-ai-tools/bootstrap",
        "exports/work-laptop-ai-tools/scripts",
        "roles/python",
        "roles/ansible_dev_tools",
        "roles/package_manager",
    }
    for required_path in required_paths:
        if required_path not in include_paths:
            errors.append(f"Export manifest is missing required include path: {required_path}")
    for required_dest in {"roles/python", "roles/ansible_dev_tools", "roles/package_manager"}:
        if required_dest not in include_dests:
            errors.append(f"Export manifest is missing required mapped destination: {required_dest}")

    if not isinstance(bootstrap_playbook, list) or not bootstrap_playbook:
        errors.append("bootstrap-tooling.yaml is not a valid play list.")
    else:
        roles = [item.get("role") for item in (bootstrap_playbook[0].get("roles") or []) if isinstance(item, dict)]
        if "ansible_dev_tools" not in roles:
            errors.append("bootstrap-tooling.yaml must include ansible_dev_tools.")
        if "package_manager" not in roles:
            errors.append("bootstrap-tooling.yaml must include package_manager for explicit upgrade path.")

    if errors:
        return fail(errors)

    print("OK: export contract matches current repo work-laptop packet conventions")
    print(f"OK: packet root {packet_root}")
    print(f"OK: reference host {contract['PACKET_REFERENCE_HOST']}")
    print(f"OK: packet venv {contract['PACKET_VENV_RELATIVE']}")
    print(f"OK: public ansible bin {contract['PACKET_PUBLIC_BIN_RELATIVE']}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - CLI error path
        print(f"error: {exc}", file=sys.stderr)
        raise
