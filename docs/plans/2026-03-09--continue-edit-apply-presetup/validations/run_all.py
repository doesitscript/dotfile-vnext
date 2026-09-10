#!/usr/bin/env python3
"""Run Continue edit/apply validation scripts and write results/summary.json."""
from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib_gateway import write_json  # noqa: E402

HERE = Path(__file__).resolve().parent
SCRIPTS = [
    "test_models_present.py",
    "test_edit_role.py",
    "test_apply_role.py",
    "compare_candidates.py",
]


def _run(script: str) -> dict:
    t0 = time.perf_counter()
    proc = subprocess.run(
        [sys.executable, str(HERE / script)],
        cwd=str(HERE),
        check=False,
        capture_output=True,
        text=True,
    )
    return {
        "script": script,
        "exit_code": proc.returncode,
        "ok": proc.returncode == 0,
        "latency_s": round(time.perf_counter() - t0, 3),
        "stdout_tail": (proc.stdout or "")[-2000:],
        "stderr_tail": (proc.stderr or "")[-1000:],
    }


def main() -> int:
    # Space scripts: curl --interface en0 can burn ephemeral ports (errno 49).
    results: list[dict] = []
    for i, script in enumerate(SCRIPTS):
        if i:
            time.sleep(12)
        results.append(_run(script))
        # One immediate retry per script when bind flakiness empties the pass.
        if not results[-1]["ok"] and "errno 49" in (
            results[-1].get("stderr_tail", "") + results[-1].get("stdout_tail", "")
        ):
            time.sleep(15)
            results[-1] = _run(script)
    payload = {
        "ok": all(r["ok"] for r in results),
        "scripts": results,
        "result_files": [
            "models_present.json",
            "edit_role.json",
            "apply_role.json",
            "candidate_comparison.json",
            "summary.json",
        ],
    }
    path = write_json("summary.json", payload)
    print(json.dumps(payload, indent=2))
    print(f"wrote {path}")
    return 0 if payload["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
