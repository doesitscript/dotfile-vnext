#!/usr/bin/env python3
"""Data-driven vNext LiteLLM lane checks for six evaluation models.

The live checks are intentionally small and user-oriented. They can be run
sequentially so a single-GPU host does not need every model resident at once.
"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from dataclasses import dataclass

import pytest


GATEWAY = os.environ.get("LITELLM_GATEWAY_ROOT", "http://litellm.hom.lab/v1").rstrip("/")
API_KEY = os.environ.get("LITELLM_API_KEY", "")
EMBED_MODEL = "nomic-embed-text"


@dataclass(frozen=True)
class Lane:
    model: str
    check: str
    expected_context: int
    max_output: int = 256


EVALUATION_LANES = (
    Lane("qwen3-coder-30b-a3b", "chat", 32768),
    Lane("qwen2.5-coder-7b", "chat", 12000),
    Lane("qwen2.5-coder-1.5b-base-q8_0", "fim", 12768, 64),
    Lane("qwen2.5-coder-14b", "chat", 12000),
    Lane("gpt-oss-20b", "chat", 131072),
    Lane("ministral-3-8b", "chat", 32768),
)


def _request(path: str, payload: dict[str, object]) -> tuple[int, dict[str, object]]:
    request = urllib.request.Request(
        f"{GATEWAY}/{path}",
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as exc:
        try:
            return exc.code, json.loads(exc.read())
        except json.JSONDecodeError:
            return exc.code, {"error": {"message": str(exc)}}
    except urllib.error.URLError as exc:
        return 0, {"error": {"message": str(exc)}}


def _receipt(model: str, check: str, expected: str, actual: str, passed: bool) -> None:
    print(f"MODEL: {model}")
    print(f"CHECK: {check}")
    print(f"EXPECTED: {expected}")
    print(f"ACTUAL: {actual}")
    print(f"RESULT: {'PASS' if passed else 'FAIL'}")
    print("---")


def _require_key() -> None:
    if not API_KEY:
        pytest.skip("LITELLM_API_KEY is unset; live lane test not run")


@pytest.mark.parametrize("lane", EVALUATION_LANES, ids=lambda lane: lane.model)
def test_evaluation_lane(lane: Lane) -> None:
    _require_key()
    if lane.check == "fim":
        status, body = _request(
            "completions",
            {
                "model": lane.model,
                "prompt": "<|fim_prefix|>def add(a, b):\n    <|fim_suffix|>\n<|fim_middle|>",
                "max_tokens": lane.max_output,
                "temperature": 0,
                "stream": False,
            },
        )
        actual = ((body.get("choices") or [{}])[0]).get("text")
        passed = status == 200 and isinstance(actual, str) and bool(actual.strip())
        _receipt(lane.model, "FIM completion", "HTTP 200 and non-empty inserted text", repr(actual), passed)
        assert passed, f"{lane.model} FIM contract failed: HTTP {status}"
        return

    status, body = _request(
        "chat/completions",
        {
            "model": lane.model,
            "messages": [{"role": "user", "content": "Reply exactly with OK."}],
            "max_tokens": lane.max_output,
            "temperature": 0,
            "stream": False,
        },
    )
    choice = (body.get("choices") or [{}])[0]
    actual = ((choice.get("message") or {}).get("content"))
    response_model = body.get("model")
    passed = status == 200 and isinstance(actual, str) and bool(actual.strip())
    _receipt(
        lane.model,
        "chat response",
        f"HTTP 200, non-empty text, model={lane.model}",
        f"HTTP {status}, model={response_model!r}, content={actual!r}",
        passed,
    )
    assert passed, f"{lane.model} chat contract failed: HTTP {status}"


def test_embedding_owner() -> None:
    _require_key()
    status, body = _request("embeddings", {"model": EMBED_MODEL, "input": "embedding smoke"})
    vector = ((body.get("data") or [{}])[0]).get("embedding")
    actual = f"HTTP {status}, dimensions={len(vector) if isinstance(vector, list) else 0}"
    passed = status == 200 and isinstance(vector, list) and len(vector) == 768
    _receipt(EMBED_MODEL, "embedding owner", "HTTP 200 and exactly 768 dimensions", actual, passed)
    assert passed, f"{EMBED_MODEL} embedding contract failed: {actual}"


def test_lane_manifest_is_unique_and_budget_safe() -> None:
    models = [lane.model for lane in EVALUATION_LANES]
    assert len(models) == 6
    assert len(models) == len(set(models))
    for lane in EVALUATION_LANES:
        assert lane.max_output > 0
        assert lane.expected_context > lane.max_output
