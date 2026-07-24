#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path


def load_shared_module(repo_root: Path):
    shared_path = repo_root / "skills" / "_shared" / "automation-memory" / "shared_automation.py"
    spec = importlib.util.spec_from_file_location("shared_automation", shared_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def render_block(title: str, result: dict[str, object]) -> str:
    return "\n".join(
        [
            f"## {title}",
            "",
            f"- command: `{result['command']}`",
            f"- rc: `{result['rc']}`",
            "",
            "```text",
            str(result["combined"]).strip() or "(no output)",
            "```",
            "",
        ]
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--playbook", required=True)
    parser.add_argument("--inventory", default="inventory/inventory.yaml")
    parser.add_argument("--limit", default="mac-dev")
    parser.add_argument("--tags", default="")
    parser.add_argument("--receipt-name", default="")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    shared = load_shared_module(repo_root)
    repo_root = shared.ensure_repo_root(str(repo_root))

    wrapper = repo_root / "bin" / "codex-env"
    base = [
        str(wrapper),
        "ansible-playbook",
        args.playbook,
        "-i",
        args.inventory,
        "--limit",
        args.limit,
    ]
    if args.tags:
        base.extend(["--tags", args.tags])

    previews = [
        ("syntax-check", base + ["--syntax-check"]),
        ("list-hosts", base + ["--list-hosts"]),
        ("list-tasks", base + ["--list-tasks"]),
    ]
    preview_results = [(label, shared.run_command(command, cwd=repo_root)) for label, command in previews]
    apply_result = shared.run_command(base, cwd=repo_root) if args.apply else None

    shared.RECEIPTS_ROOT.mkdir(parents=True, exist_ok=True)
    slug = args.receipt_name or Path(args.playbook).stem
    receipt_path = shared.RECEIPTS_ROOT / f"{shared.iso_now().replace(':', '-')}--{slug}.md"

    body = [
        f"# Verification Receipt: {slug}",
        "",
        f"- Scope: `{args.tags or '(none)'}`",
        f"- Target host: `{args.limit}`",
        f"- Playbook: `{args.playbook}`",
        f"- Inventory: `{args.inventory}`",
        f"- Apply requested: `{args.apply}`",
        "",
    ]
    for label, result in preview_results:
        body.append(render_block(label, result))
    if apply_result is not None:
        body.append(render_block("apply", apply_result))
    receipt_path.write_text("\n".join(body).rstrip() + "\n", encoding="utf-8")

    memory = shared.read_memory()
    repo_receipts = memory.setdefault("apply_receipts", {}).setdefault(str(repo_root), [])
    repo_receipts.append(
        {
            "playbook": args.playbook,
            "inventory": args.inventory,
            "limit": args.limit,
            "tags": args.tags,
            "apply_requested": args.apply,
            "receipt_path": str(receipt_path),
            "created_at": shared.iso_now(),
        }
    )
    shared.write_memory(memory)

    print(f"Receipt: {receipt_path}")
    for label, result in preview_results:
        print(f"- {label}: rc={result['rc']}")
    if apply_result is not None:
        print(f"- apply: rc={apply_result['rc']}")


if __name__ == "__main__":
    main()
