#!/usr/bin/env python3
"""Compare CANDIDATES (+ optional CHAT_COMPARE) for edit and apply roles."""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib_gateway import (  # noqa: E402
    APPLY_PROMPT,
    CANDIDATES,
    CHAT_COMPARE,
    EDIT_PROMPT,
    SELECTED_EDIT_APPLY,
    chat_completion,
    score_apply,
    score_edit,
    write_json,
)


def _eval(model: str, role: str, prompt: str, scorer) -> dict:
    result = chat_completion(
        model,
        [{"role": "user", "content": prompt}],
        role=role,
        max_tokens=256,
        temperature=0.2,
    )
    content = result.content_preview.replace("\\n", "\n")
    passed = bool(result.ok and scorer(content))
    row = result.to_dict()
    row["score_pass"] = passed
    return row


def main() -> int:
    models = list(CANDIDATES)
    if CHAT_COMPARE and CHAT_COMPARE not in models:
        models.append(CHAT_COMPARE)

    edit_rows = [_eval(m, "edit", EDIT_PROMPT, score_edit) for m in models]
    apply_rows = [_eval(m, "apply", APPLY_PROMPT, score_apply) for m in models]

    by_model: dict[str, dict] = {}
    for row in edit_rows:
        by_model.setdefault(row["model"], {})["edit"] = row
    for row in apply_rows:
        by_model.setdefault(row["model"], {})["apply"] = row

    dual_pass: list[dict] = []
    for model, roles in by_model.items():
        edit = roles.get("edit") or {}
        apply = roles.get("apply") or {}
        both = bool(edit.get("score_pass") and apply.get("score_pass"))
        # Prefer desktop candidates for the Continue edit/apply recommendation.
        is_desktop = model.endswith("@desktop")
        if both and is_desktop:
            dual_pass.append(
                {
                    "model": model,
                    "edit_latency_s": edit.get("latency_s"),
                    "apply_latency_s": apply.get("latency_s"),
                    "combined_latency_s": round(
                        float(edit.get("latency_s") or 0) + float(apply.get("latency_s") or 0),
                        3,
                    ),
                }
            )

    dual_pass.sort(key=lambda r: (r["combined_latency_s"], r["model"]))
    recommended = dual_pass[0]["model"] if dual_pass else None

    payload = {
        "ok": recommended is not None,
        "selected_edit_apply": SELECTED_EDIT_APPLY,
        "candidates": CANDIDATES,
        "chat_compare": CHAT_COMPARE,
        "edit": edit_rows,
        "apply": apply_rows,
        "dual_pass_desktop": dual_pass,
        "recommended_fastest_desktop_dual_pass": recommended,
        "recommendation_matches_selected": recommended == SELECTED_EDIT_APPLY,
    }
    path = write_json("candidate_comparison.json", payload)
    print(json.dumps(payload, indent=2))
    print(f"wrote {path}")
    return 0 if payload["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
