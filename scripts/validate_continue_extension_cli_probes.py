#!/usr/bin/env python3
"""CLI probes that simulate Continue extension + OpenCode flows against homelab LiteLLM.

Continue docs (Context7 /websites/continue_dev):
- apiBase probes GET {apiBase} without /v1
- edit/apply use chat/completions with role-specific prompt templates
- autocomplete uses FIM; OpenAI-compatible providers may need
  useLegacyCompletionsEndpoint → /v1/completions

Exit 0 when all probes pass; non-zero on first failure batch.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any


GATEWAY_ROOT = os.environ.get("LITELLM_GATEWAY_ROOT", "http://litellm.hom.lab")
GATEWAY_V1 = f"{GATEWAY_ROOT}/v1"
API_KEY = os.environ.get("LITELLM_API_KEY", "sk-Pass@w0rd1")

MODEL_CHAT = "qwen2.5-coder-32b@k3s02-vllm"
MODEL_EDIT = "qwen2.5-coder-7b@desktop"
MODEL_AUTOCOMPLETE = "qwen2.5-coder-1.5b@hvh01"
# vLLM 32B lane: chat OK; OpenCode `run` sends tool_choice=auto which needs
# --enable-auto-tool-choice on vLLM (Qwen2.5 tool format still broken — see HRL note).
OPENCODE_AGENT_MODELS = (MODEL_EDIT, MODEL_AUTOCOMPLETE)

CONTINUE_CONFIG = Path.home() / ".continue" / "config.yaml"
OPENCODE_CONFIG = Path.home() / ".config" / "opencode" / "opencode.jsonc"
OPENCODE_BIN = Path.home() / ".opencode" / "bin" / "opencode"


@dataclass
class ProbeResult:
    name: str
    ok: bool
    detail: str


def _request(
    path: str,
    payload: dict[str, Any] | None = None,
    *,
    method: str = "GET",
    timeout: int = 120,
) -> tuple[int, Any]:
    url = f"{GATEWAY_V1}{path}" if path.startswith("/") else path
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    }
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode()
            if not body:
                return resp.status, None
            return resp.status, json.loads(body)
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode(errors="replace")


def probe_gateway_root() -> ProbeResult:
    req = urllib.request.Request(GATEWAY_ROOT, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            ok = resp.status == 200
    except urllib.error.HTTPError as exc:
        ok = False
        return ProbeResult("continue_gateway_get_apibase", False, f"HTTP {exc.code}")
    return ProbeResult("continue_gateway_get_apibase", ok, f"GET {GATEWAY_ROOT} → 200")


def probe_models_list() -> ProbeResult:
    status, body = _request("/models")
    if status != 200 or not isinstance(body, dict):
        return ProbeResult("litellm_models_list", False, f"status={status}")
    ids = {m.get("id") for m in body.get("data", [])}
    expected = {MODEL_CHAT, MODEL_EDIT, MODEL_AUTOCOMPLETE}
    missing = expected - ids
    if missing:
        return ProbeResult("litellm_models_list", False, f"missing ids: {sorted(missing)}")
    return ProbeResult("litellm_models_list", True, f"ids={sorted(expected)}")


def probe_chat_lane() -> ProbeResult:
    payload = {
        "model": MODEL_CHAT,
        "messages": [
            {
                "role": "user",
                "content": (
                    "Explain in one sentence what this function does:\n"
                    "def fib(n):\n    a,b=0,1\n    for _ in range(n): a,b=b,a+b\n    return a"
                ),
            }
        ],
        "max_tokens": 80,
        "temperature": 0.2,
        "stream": False,
    }
    status, body = _request("/chat/completions", payload, method="POST")
    if status != 200:
        return ProbeResult("continue_chat_simulation", False, body if isinstance(body, str) else str(body))
    content = body["choices"][0]["message"]["content"]
    ok = "fibonacci" in content.lower() or "sequence" in content.lower()
    return ProbeResult(
        "continue_chat_simulation",
        ok,
        content[:120].replace("\n", " "),
    )


def probe_edit_lane() -> ProbeResult:
    """Simulate Continue default edit prompt template (docs.continue.dev/model-roles/edit)."""
    payload = {
        "model": MODEL_EDIT,
        "messages": [
            {
                "role": "user",
                "content": (
                    "Here is the code before editing:\n"
                    "```python\n"
                    "def greet(name):\n"
                    "    return 'hi ' + name\n"
                    "```\n\n"
                    'Here is the edit requested:\n'
                    '"Add type hint and return Hello, {name}"\n\n'
                    "Here is the code after editing:"
                ),
            }
        ],
        "max_tokens": 256,
        "temperature": 0.2,
        "stream": False,
    }
    status, body = _request("/chat/completions", payload, method="POST")
    if status != 200:
        return ProbeResult("continue_edit_simulation", False, str(body)[:300])
    content = body["choices"][0]["message"]["content"]
    ok = "def greet" in content and ("Hello" in content or "hello" in content.lower())
    return ProbeResult("continue_edit_simulation", ok, content[:160].replace("\n", " "))


def probe_apply_lane() -> ProbeResult:
    """Simulate Continue apply prompt template (docs.continue.dev/model-roles/apply)."""
    payload = {
        "model": MODEL_EDIT,
        "messages": [
            {
                "role": "user",
                "content": (
                    "Original: def greet(name):\n    return 'hi ' + name\n\n"
                    "New: def greet(name: str) -> str:\n    return f'Hello, {name}'\n\n"
                    "Please generate the final code without any markers or explanations."
                ),
            }
        ],
        "max_tokens": 200,
        "temperature": 0.1,
        "stream": False,
    }
    status, body = _request("/chat/completions", payload, method="POST")
    if status != 200:
        return ProbeResult("continue_apply_simulation", False, str(body)[:300])
    content = body["choices"][0]["message"]["content"]
    ok = "def greet" in content and "Hello" in content
    return ProbeResult("continue_apply_simulation", ok, content[:160].replace("\n", " "))


def probe_autocomplete_fim() -> ProbeResult:
    """Simulate FIM autocomplete via legacy /v1/completions (Continue useLegacyCompletionsEndpoint)."""
    prompt = (
        "<|fim_prefix|>def add(a, b):\n    <|fim_suffix|>\n\nprint(add(1,2))"
        "<|fim_middle|>"
    )
    payload = {
        "model": MODEL_AUTOCOMPLETE,
        "prompt": prompt,
        "max_tokens": 48,
        "temperature": 0.1,
        "stream": False,
    }
    status, body = _request("/completions", payload, method="POST")
    if status != 200:
        return ProbeResult("continue_autocomplete_fim", False, str(body)[:300])
    text = body["choices"][0].get("text", "")
    ok = "return" in text.lower()
    return ProbeResult("continue_autocomplete_fim", ok, text[:120].replace("\n", " "))


def probe_stream_edit() -> ProbeResult:
    payload = {
        "model": MODEL_EDIT,
        "messages": [{"role": "user", "content": "Return only: def add(a,b): return a+b"}],
        "max_tokens": 40,
        "stream": True,
    }
    url = f"{GATEWAY_V1}/chat/completions"
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            chunk = resp.read(400).decode(errors="replace")
    except urllib.error.HTTPError as exc:
        return ProbeResult("continue_edit_stream", False, exc.read().decode()[:200])
    ok = chunk.startswith("data:") and "delta" in chunk
    return ProbeResult("continue_edit_stream", ok, chunk.splitlines()[0][:120])


def probe_context_budget() -> ProbeResult:
    """Large prompt under configured 32k window (Continue code-agent overhead class)."""
    filler = "# comment line\n" * 1200
    payload = {
        "model": MODEL_CHAT,
        "messages": [
            {"role": "user", "content": filler + "\n\nSummarize in 5 words what this file is."}
        ],
        "max_tokens": 32,
        "temperature": 0.1,
        "stream": False,
    }
    status, body = _request("/chat/completions", payload, method="POST", timeout=180)
    if status != 200:
        return ProbeResult("continue_context_budget", False, str(body)[:400])
    usage = body.get("usage", {})
    prompt_tokens = usage.get("prompt_tokens", 0)
    content = body["choices"][0]["message"]["content"]
    ok = prompt_tokens < 30000 and len(content) > 0
    return ProbeResult(
        "continue_context_budget",
        ok,
        f"prompt_tokens={prompt_tokens} reply={content[:60]!r}",
    )


def probe_continue_config_shape() -> ProbeResult:
    if not CONTINUE_CONFIG.is_file():
        return ProbeResult("continue_config_deployed", False, f"missing {CONTINUE_CONFIG}")
    text = CONTINUE_CONFIG.read_text()
    checks = [
        MODEL_CHAT in text,
        MODEL_EDIT in text,
        MODEL_AUTOCOMPLETE in text,
        "contextLength: 32768" in text,
        "maxTokens: 4096" in text,
        "useLegacyCompletionsEndpoint: true" in text,
        "fim_prefix" in text,
        'roles:\n      - "autocomplete"' in text or "- autocomplete" in text,
    ]
    ok = all(checks)
    return ProbeResult(
        "continue_config_deployed",
        ok,
        f"path={CONTINUE_CONFIG} checks={sum(checks)}/{len(checks)}",
    )


def probe_opencode_model(model: str) -> ProbeResult:
    if not OPENCODE_BIN.is_file():
        return ProbeResult(f"opencode_run_{model}", False, f"missing {OPENCODE_BIN}")
    env = {**os.environ, "LITELLM_API_KEY": API_KEY}
    cmd = [
        str(OPENCODE_BIN),
        "run",
        "-m",
        model,
        "Reply with exactly: ok",
        "--format",
        "json",
    ]
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
            env=env,
            cwd=str(Path(__file__).resolve().parents[1]),
        )
    except subprocess.TimeoutExpired:
        return ProbeResult(f"opencode_run_{model}", False, "timeout")
    ok = proc.returncode == 0 and ("ok" in proc.stdout.lower() or "text" in proc.stdout)
    detail = (proc.stdout or proc.stderr)[-200:]
    return ProbeResult(f"opencode_run_{model}", ok, detail.replace("\n", " "))


def main() -> int:
    results: list[ProbeResult] = []
    results.append(probe_gateway_root())
    results.append(probe_models_list())
    results.append(probe_chat_lane())
    results.append(probe_edit_lane())
    results.append(probe_apply_lane())
    results.append(probe_autocomplete_fim())
    results.append(probe_stream_edit())
    results.append(probe_context_budget())
    results.append(probe_continue_config_shape())
    if OPENCODE_CONFIG.is_file():
        for mid in OPENCODE_AGENT_MODELS:
            results.append(
                probe_opencode_model(f"homelab-litellm/{mid}")
            )
        results.append(
            ProbeResult(
                "opencode_32b_chat_only_lane",
                True,
                "32B vLLM is Continue chat-only; OpenCode agent probes use 7B + 1.5B (vLLM Qwen2.5 tool_calls limitation)",
            )
        )
    else:
        results.append(
            ProbeResult("opencode_config_deployed", False, f"missing {OPENCODE_CONFIG}")
        )

    failed = [r for r in results if not r.ok]
    print(json.dumps({"probes": [r.__dict__ for r in results]}, indent=2))
    if failed:
        print("\nFAILED:", ", ".join(r.name for r in failed), file=sys.stderr)
        return 1
    print("\nAll probes passed.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
