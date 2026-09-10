"""LiteLLM gateway helpers for Continue edit/apply validations.

This controller intermittently fails local TCP binds with errno 49 unless the
request goes through /usr/bin/curl --interface en0. Prefer that transport.
"""
from __future__ import annotations

import json
import os
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

DEFAULT_GATEWAY = os.environ.get(
    "LITELLM_GATEWAY_ROOT", "http://litellm.hom.lab:30400"
)
DEFAULT_API_KEY = os.environ.get("LITELLM_API_KEY", "sk-Pass@w0rd1")
DEFAULT_IFACE = os.environ.get("LITELLM_CURL_INTERFACE", "en0")
CURL_BIN = os.environ.get("LITELLM_CURL_BIN", "/usr/bin/curl")

# Continue edit/apply candidates on this lab (desktop-first via LiteLLM).
CANDIDATES = [
    "qwen2.5-coder-7b@desktop",
    "qwen2.5-coder-14b@desktop",
    "ministral-3-8b@desktop",
]
SELECTED_EDIT_APPLY = "qwen2.5-coder-7b@desktop"
CHAT_COMPARE = "qwen2.5-coder-32b@k3s02-vllm"

RESULTS_DIR = Path(__file__).resolve().parent / "results"


@dataclass
class TimedCompletion:
    model: str
    role: str
    ok: bool
    latency_s: float
    attempts: int
    http_status: int
    prompt_tokens: int | None
    completion_tokens: int | None
    total_tokens: int | None
    content_preview: str
    detail: str

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


def _curl_json(
    method: str,
    url: str,
    payload: dict[str, Any] | None = None,
    *,
    timeout_s: int = 180,
    attempts: int = 40,
    sleep_s: float = 0.6,
) -> tuple[int, Any, int]:
    """Return (http_status, parsed_or_text, attempts_used)."""
    last_err = "no attempts"
    for attempt in range(1, attempts + 1):
        cmd = [
            CURL_BIN,
            "-sS",
            "-m",
            str(timeout_s),
            "--interface",
            DEFAULT_IFACE,
            "-w",
            "\n__HTTP_STATUS__%{http_code}",
            "-X",
            method,
            "-H",
            f"Authorization: Bearer {DEFAULT_API_KEY}",
            "-H",
            "Content-Type: application/json",
            url,
        ]
        if payload is not None:
            cmd.extend(["--data-binary", json.dumps(payload)])
        try:
            proc = subprocess.run(
                cmd,
                check=False,
                capture_output=True,
                text=True,
            )
        except OSError as exc:
            last_err = str(exc)
            time.sleep(sleep_s)
            continue
        if proc.returncode != 0:
            last_err = (proc.stderr or proc.stdout or f"curl_rc={proc.returncode}").strip()
            time.sleep(sleep_s)
            continue
        raw = proc.stdout or ""
        if "__HTTP_STATUS__" not in raw:
            last_err = "missing status trailer"
            time.sleep(sleep_s)
            continue
        body, status_s = raw.rsplit("__HTTP_STATUS__", 1)
        body = body.strip()
        try:
            status = int(status_s.strip())
        except ValueError:
            last_err = f"bad status trailer: {status_s!r}"
            time.sleep(sleep_s)
            continue
        if status == 000 or status == 0:
            last_err = f"http_status={status}"
            time.sleep(sleep_s)
            continue
        parsed: Any
        try:
            parsed = json.loads(body) if body else None
        except json.JSONDecodeError:
            parsed = body
        return status, parsed, attempt
    raise RuntimeError(f"gateway request failed after {attempts} attempts: {last_err}")


def list_model_ids() -> list[str]:
    status, body, _ = _curl_json("GET", f"{DEFAULT_GATEWAY}/v1/models", timeout_s=30)
    if status != 200 or not isinstance(body, dict):
        raise RuntimeError(f"/v1/models status={status} body={body!r}")
    return sorted(m.get("id", "") for m in body.get("data", []) if m.get("id"))


def chat_completion(
    model: str,
    messages: list[dict[str, str]],
    *,
    role: str,
    max_tokens: int = 256,
    temperature: float = 0.2,
    timeout_s: int = 180,
) -> TimedCompletion:
    payload = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "stream": False,
    }
    t0 = time.perf_counter()
    try:
        status, body, attempts = _curl_json(
            "POST",
            f"{DEFAULT_GATEWAY}/v1/chat/completions",
            payload,
            timeout_s=timeout_s,
        )
        latency = time.perf_counter() - t0
    except Exception as exc:  # noqa: BLE001 — validation script surface
        return TimedCompletion(
            model=model,
            role=role,
            ok=False,
            latency_s=round(time.perf_counter() - t0, 3),
            attempts=0,
            http_status=0,
            prompt_tokens=None,
            completion_tokens=None,
            total_tokens=None,
            content_preview="",
            detail=str(exc),
        )
    if status != 200 or not isinstance(body, dict):
        return TimedCompletion(
            model=model,
            role=role,
            ok=False,
            latency_s=round(latency, 3),
            attempts=attempts,
            http_status=status,
            prompt_tokens=None,
            completion_tokens=None,
            total_tokens=None,
            content_preview="",
            detail=str(body)[:400],
        )
    content = (
        body.get("choices", [{}])[0].get("message", {}).get("content")
        or body.get("choices", [{}])[0].get("text")
        or ""
    )
    usage = body.get("usage") or {}
    return TimedCompletion(
        model=model,
        role=role,
        ok=True,
        latency_s=round(latency, 3),
        attempts=attempts,
        http_status=status,
        prompt_tokens=usage.get("prompt_tokens"),
        completion_tokens=usage.get("completion_tokens"),
        total_tokens=usage.get("total_tokens"),
        content_preview=content[:400].replace("\n", "\\n"),
        detail="ok",
    )


def write_json(name: str, payload: Any) -> Path:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    path = RESULTS_DIR / name
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return path


EDIT_PROMPT = (
    "Here is the code before editing:\n"
    "```python\n"
    "def greet(name):\n"
    "    return 'hi ' + name\n"
    "```\n\n"
    'Here is the edit requested:\n'
    '"Add a type hint for name and return Hello, {name} using an f-string"\n\n'
    "Here is the code after editing:"
)

APPLY_PROMPT = (
    "Original:\n"
    "def greet(name):\n"
    "    return 'hi ' + name\n\n"
    "New:\n"
    "def greet(name: str) -> str:\n"
    "    return f'Hello, {name}'\n\n"
    "Please generate the final code without any markers or explanations."
)


def score_edit(content: str) -> bool:
    lowered = content.lower()
    return "def greet" in content and ("hello" in lowered) and (
        "str" in lowered or "->" in content or "f'" in content or 'f"' in content
    )


def score_apply(content: str) -> bool:
    compact = content.replace(" ", "")
    has_fn = "def greet" in content and "Hello" in content
    return has_fn and ("name:str" in compact or "str" in content)
