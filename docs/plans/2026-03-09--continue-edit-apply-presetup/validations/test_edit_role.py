#!/usr/bin/env python3
"""Simulate Continue edit prompts against SELECTED_EDIT_APPLY + CANDIDATES."""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib_gateway import (  # noqa: E402
    CANDIDATES,
    EDIT_PROMPT,
    SELECTED_EDIT_APPLY,
    chat_completion,
    score_edit,
    write_json,
)


def _run_one(model: str) -> dict:
    result = chat_completion(
        model,
        [{"role": "user", "content": EDIT_PROMPT}],
        role="edit",
        max_tokens=256,
        temperature=0.2,
    )
    passed = bool(result.ok and score_edit(result.content_preview.replace("\\n", "\n")))
    row = result.to_dict()
    row["score_pass"] = passed
    return row


def main() -> int:
    models = []
    seen: set[str] = set()
    for model in [SELECTED_EDIT_APPLY, *CANDIDATES]:
        if model in seen:
            continue
        seen.add(model)
        models.append(model)

    rows = [_run_one(m) for m in models]
    selected = next((r for r in rows if r["model"] == SELECTED_EDIT_APPLY), None)
    payload = {
        "ok": bool(selected and selected.get("score_pass")),
        "role": "edit",
        "selected": SELECTED_EDIT_APPLY,
        "candidates": CANDIDATES,
        "results": rows,
    }
    path = write_json("edit_role.json", payload)
    print(json.dumps(payload, indent=2))
    print(f"wrote {path}")
    return 0 if payload["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
