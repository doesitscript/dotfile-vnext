#!/usr/bin/env python3
"""Small user-perspective TDD smoke tests for the commissioned model lanes."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request


ROOT = os.environ.get("LITELLM_GATEWAY_ROOT", "http://litellm.hom.lab/v1").rstrip("/")
KEY = os.environ.get("LITELLM_API_KEY", "")
CHAT_MODELS = (
    "qwen3-coder-30b-a3b",
    "qwen2.5-coder-7b",
    "qwen2.5-coder-14b",
    "gpt-oss-20b",
    "ministral-3-8b",
)


def request(path: str, payload: dict[str, object]) -> tuple[int, dict[str, object]]:
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{ROOT}/{path}",
        data=data,
        headers={
            "Authorization": f"Bearer {KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as exc:
        try:
            return exc.code, json.loads(exc.read())
        except json.JSONDecodeError:
            return exc.code, {"error": {"message": str(exc)}}


def check_chat(model: str) -> bool:
    status, body = request(
        "chat/completions",
        {
            "model": model,
            "messages": [{"role": "user", "content": "Reply exactly with OK."}],
            # gpt-oss may spend a small output reserve on internal reasoning.
            "max_tokens": 256,
            "temperature": 0,
            "stream": False,
        },
    )
    choice = (body.get("choices") or [{}])[0]
    content = ((choice.get("message") or {}).get("content"))
    ok = status == 200 and isinstance(content, str) and bool(content.strip())
    print(f"MODEL: {model}")
    print(f"API: chat/completions HTTP {status}")
    print(f"CONTENT: {content!r}")
    print(f"RESULT: {'PASS' if ok else 'FAIL'}")
    print("---")
    return ok


def check_fim() -> bool:
    model = "qwen2.5-coder-1.5b-base-q8_0"
    status, body = request(
        "completions",
        {
            "model": model,
            "prompt": "<|fim_prefix|>def add(a, b):\n    <|fim_suffix|>\n<|fim_middle|>",
            "max_tokens": 64,
            "temperature": 0,
            "stream": False,
        },
    )
    text = ((body.get("choices") or [{}])[0]).get("text")
    ok = status == 200 and isinstance(text, str) and bool(text.strip())
    print(f"MODEL: {model}")
    print(f"API: completions (FIM) HTTP {status}")
    print(f"CONTENT: {text!r}")
    print(f"RESULT: {'PASS' if ok else 'FAIL'}")
    print("---")
    return ok


def check_embedding() -> bool:
    model = "nomic-embed-text"
    status, body = request(
        "embeddings", {"model": model, "input": "Basic embedding smoke test."}
    )
    vector = ((body.get("data") or [{}])[0]).get("embedding")
    ok = status == 200 and isinstance(vector, list) and bool(vector)
    print(f"MODEL: {model}")
    print(f"API: embeddings HTTP {status}")
    print(f"EMBEDDING_LENGTH: {len(vector) if isinstance(vector, list) else 0}")
    print(f"RESULT: {'PASS' if ok else 'FAIL'}")
    print("---")
    return ok


def main() -> int:
    if not KEY:
        print("LITELLM_API_KEY is required", file=sys.stderr)
        return 2
    results = [check_chat(model) for model in CHAT_MODELS]
    results.extend((check_fim(), check_embedding()))
    return 0 if all(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
