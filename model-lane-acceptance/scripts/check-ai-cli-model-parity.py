#!/usr/bin/env python3
"""Check AI CLI client catalogs include commissioned LiteLLM model ids.

SSOT: inventory/group_vars/all/ai_cli_apps.yml → ai_cli_commissioned_model_ids_enabled
Continue role defaults are the per-client schema authority; this script checks that
enabled commissioned ids appear in each multi-model client list (role defaults +
work-laptop host_vars overrides).

Exit 0 = pass, 1 = gaps found.
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML required", file=sys.stderr)
    sys.exit(2)

ROOT = Path(__file__).resolve().parents[2]


def load(path: Path):
    return yaml.safe_load(path.read_text())


def enabled_continue(entries):
    return {
        e["model"]
        for e in (entries or [])
        if e.get("enabled", True) is not False and e.get("model")
    }


def enabled_ids(entries, key="id"):
    return {
        e[key]
        for e in (entries or [])
        if e.get("enabled", True) is not False and e.get(key)
    }


def main() -> int:
    ssot = load(ROOT / "inventory/group_vars/all/ai_cli_apps.yml")
    required = set(ssot["ai_cli_commissioned_model_ids_enabled"])

    cont = load(ROOT / "roles/continue_ide/defaults/main.yml")
    cline = load(ROOT / "roles/cline_ide/defaults/main.yml")
    opc = load(ROOT / "roles/opencode_cli/defaults/main.yml")
    kilo = load(ROOT / "roles/kilo_ide/defaults/main.yml")
    wl = load(ROOT / "exports/work-laptop-ai-tools/host_vars/work-laptop.yaml")

    catalogs = {
        "continue_ide/defaults": enabled_continue(cont.get("continue_ide_models")),
        "cline_ide/defaults": enabled_continue(cline.get("cline_ide_models")),
        "opencode_cli/defaults": enabled_ids(opc.get("opencode_cli_models"), "id"),
        "kilo_ide/defaults": enabled_ids(kilo.get("kilo_ide_models"), "id"),
        "work-laptop continue_ide_models": enabled_continue(wl.get("continue_ide_models")),
        "work-laptop cline_ide_models": enabled_continue(wl.get("cline_ide_models")),
        "work-laptop opencode_cli_models": enabled_ids(wl.get("opencode_cli_models"), "id"),
        "work-laptop kilo_ide_models": enabled_ids(wl.get("kilo_ide_models"), "id"),
        "work-laptop zed_ide_models": {
            e["name"] for e in (wl.get("zed_ide_models") or []) if e.get("name")
        },
    }

    # Single-default clients: only check default points at chat model
    defaults = {
        "aider/defaults": load(ROOT / "roles/aider/defaults/main.yml").get(
            "aider_default_model", ""
        ),
        "work-laptop aider_default_model": wl.get("aider_default_model", ""),
        "work-laptop zed_ide_default_model": (wl.get("zed_ide_default_model") or {}).get(
            "model", ""
        ),
    }
    chat = ssot["ai_cli_default_chat_model"]

    failed = False
    print(f"Required commissioned models ({len(required)}):")
    for mid in sorted(required):
        print(f"  - {mid}")
    print()

    for name, present in catalogs.items():
        missing = sorted(required - present)
        status = "PASS" if not missing else "FAIL"
        if missing:
            failed = True
        print(f"[{status}] {name}")
        if missing:
            for mid in missing:
                print(f"       missing: {mid}")

    print()
    for name, val in defaults.items():
        ok = chat in str(val)
        status = "PASS" if ok else "FAIL"
        if not ok:
            failed = True
        print(f"[{status}] {name} contains {chat!r}: {val!r}")

    print()
    print("FAIL" if failed else "PASS")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
