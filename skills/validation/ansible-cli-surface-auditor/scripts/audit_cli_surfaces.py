#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib.util
import os
import sys
from pathlib import Path


K8S_MULTI_TOOL_MAP = {
    "k9s": {
        "completion_var": "k8s_cli_tools_k9s_bash_completion_path",
        "install_surface": "Homebrew formula `k9s`",
        "verify_command": "`k9s version`",
        "notes": "repo also generates managed completion",
    },
    "kubecolor": {
        "completion_var": "",
        "install_surface": "Homebrew formula `kubecolor`",
        "verify_command": "`kubecolor version`",
        "notes": "direct completion is optional; usually inherits kubectl behavior",
    },
    "stern": {
        "completion_var": "k8s_cli_tools_stern_bash_completion_path",
        "install_surface": "Homebrew formula `stern`",
        "verify_command": "`stern --version`",
        "notes": "repo also generates managed completion",
    },
    "kubectx": {
        "completion_var": "",
        "install_surface": "Homebrew formula `kubectx`",
        "verify_command": "`kubectx -h`",
        "notes": "completion typically comes from the Homebrew formula plus shared loader",
    },
    "kubens": {
        "completion_var": "",
        "install_surface": "Homebrew formula `kubectx`",
        "verify_command": "`kubens -h`",
        "notes": "paired with kubectx distribution",
    },
    "helm": {
        "completion_var": "",
        "install_surface": "Homebrew formula `helm`",
        "verify_command": "`helm version`",
        "notes": "completion usually supplied by the formula",
    },
    "krew": {
        "completion_var": "",
        "install_surface": "Homebrew formula `krew`",
        "verify_command": "`kubectl krew version`",
        "notes": "plugin manager; not all plugins are audited as first-class CLIs",
    },
    "kubeseal": {
        "completion_var": "",
        "install_surface": "Homebrew formula `kubeseal`",
        "verify_command": "`kubeseal --version`",
        "notes": "",
    },
    "kustomize": {
        "completion_var": "",
        "install_surface": "Homebrew formula `kustomize`",
        "verify_command": "`kustomize version`",
        "notes": "completion usually supplied by the formula",
    },
    "k8sgpt": {
        "completion_var": "",
        "install_surface": "Homebrew formula `k8sgpt`",
        "verify_command": "`k8sgpt version`",
        "notes": "completion usually supplied by the formula",
    },
}


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def playbook_refs(shared, repo_root: Path, role_name: str) -> str:
    result = shared.run_command(
        ["rg", "-n", f"- role: {role_name}", "playbooks", "-g", "*.yml", "-g", "*.yaml"],
        cwd=repo_root,
    )
    if not result["stdout"].strip():
        result = shared.run_command(["rg", "-n", role_name, "playbooks", "-g", "*.yml", "-g", "*.yaml"], cwd=repo_root)
    refs = []
    seen: set[tuple[str, str]] = set()
    for line in result["stdout"].splitlines():
        path_text, _, remainder = line.partition(":")
        line_no, _, _ = remainder.partition(":")
        if not path_text or not line_no:
            continue
        key = (path_text, line_no)
        if key in seen:
            continue
        seen.add(key)
        refs.append(shared.markdown_link(repo_root / path_text, int(line_no), Path(path_text).name))
        if len(refs) == 3:
            break
    return ", ".join(refs) if refs else "none"


def generic_rows(shared, repo_root: Path, role_name: str) -> list[dict[str, str]]:
    defaults_path = repo_root / "roles" / role_name / "defaults" / "main.yml"
    defaults = shared.read_yaml(defaults_path)
    cli_name = role_name.removesuffix("_cli")
    completion_var = next((key for key in defaults if key.endswith("_bash_completion_path")), "")
    completion_value = defaults.get(completion_var, "") if completion_var else ""

    install_surface = "role-managed"
    if f"{role_name}_homebrew_formula" in defaults:
        install_surface = f"Homebrew formula `{defaults[f'{role_name}_homebrew_formula']}`"
    elif f"{role_name}_archive_url" in defaults:
        install_surface = "direct archive download"
    elif role_name == "k3s_mac_client":
        install_surface = "official kubectl binary download"
        completion_value = "generated under Homebrew etc/bash_completion.d/kubectl"

    verify_command = f"`{cli_name} version`"
    if role_name == "k3s_mac_client":
        verify_command = "`~/.local/bin/kubectl version --client`"
        cli_name = "kubectl"

    notes = []
    if completion_value:
        notes.append("managed completion path defined")
    usage_note_var = next((key for key in defaults if key.endswith("_usage_note_path")), "")
    if usage_note_var:
        notes.append("usage note rendered by role")

    return [
        {
            "CLI": cli_name,
            "Owning role": role_name,
            "Install surface": install_surface,
            "Completion path": f"`{completion_value}`" if completion_value else "formula-provided or none",
            "Verify command": verify_command,
            "Playbook refs": playbook_refs(shared, repo_root, role_name),
            "Notes": "; ".join(notes) if notes else "",
        }
    ]


def k8s_rows(shared, repo_root: Path) -> list[dict[str, str]]:
    defaults = shared.read_yaml(repo_root / "roles" / "k8s_cli_tools" / "defaults" / "main.yml")
    refs = playbook_refs(shared, repo_root, "k8s_cli_tools")
    rows = []
    for cli_name, spec in K8S_MULTI_TOOL_MAP.items():
        completion_value = defaults.get(spec["completion_var"], "") if spec["completion_var"] else ""
        rows.append(
            {
                "CLI": cli_name,
                "Owning role": "k8s_cli_tools",
                "Install surface": spec["install_surface"],
                "Completion path": f"`{completion_value}`" if completion_value else "formula-provided or shared loader",
                "Verify command": spec["verify_command"],
                "Playbook refs": refs,
                "Notes": spec["notes"],
            }
        )
    return rows


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    shared = load_shared_module(repo_root)
    shared.ensure_repo_python(repo_root, [str(Path(__file__).resolve()), "--repo-root", str(repo_root)])
    repo_root = shared.ensure_repo_root(str(repo_root))

    rows = []
    for role_name in ["gonzo_cli", "dstl8_cli", "k3s_mac_client"]:
        rows.extend(generic_rows(shared, repo_root, role_name))
    rows.extend(k8s_rows(shared, repo_root))

    memory = shared.read_memory()
    repo_surfaces = memory.setdefault("cli_surfaces", {}).setdefault(str(repo_root), {})
    for row in rows:
        repo_surfaces[row["CLI"]] = {
            "role": row["Owning role"],
            "install_surface": row["Install surface"],
            "completion_path": row["Completion path"].strip("`"),
            "verify_command": row["Verify command"].strip("`"),
            "playbook_refs": row["Playbook refs"],
            "notes": row["Notes"],
            "checked_at": shared.iso_now(),
        }
    shared.write_memory(memory)

    print(shared.format_table(rows, ["CLI", "Owning role", "Install surface", "Completion path", "Verify command", "Playbook refs", "Notes"]))


if __name__ == "__main__":
    main()
