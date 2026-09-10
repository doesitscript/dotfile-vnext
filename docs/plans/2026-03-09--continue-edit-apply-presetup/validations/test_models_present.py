#!/usr/bin/env python3
"""Assert Continue edit/apply LiteLLM model ids are published."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib_gateway import (  # noqa: E402
    CANDIDATES,
    SELECTED_EDIT_APPLY,
    list_model_ids,
    write_json,
)


REQUIRED = [SELECTED_EDIT_APPLY, *CANDIDATES]


def main() -> int:
    ids = list_model_ids()
    missing = sorted({m for m in REQUIRED if m not in ids})
    payload = {
        "ok": not missing,
        "required": REQUIRED,
        "missing": missing,
        "published_matching": [i for i in ids if i in set(REQUIRED) or i.endswith("@desktop")],
        "all_ids": ids,
    }
    path = write_json("models_present.json", payload)
    print(json_dumps(payload))
    print(f"wrote {path}")
    return 0 if payload["ok"] else 1


def json_dumps(obj: object) -> str:
    import json

    return json.dumps(obj, indent=2)


if __name__ == "__main__":
    raise SystemExit(main())
