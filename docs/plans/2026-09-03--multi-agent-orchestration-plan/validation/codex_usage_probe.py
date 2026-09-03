#!/usr/bin/env python3
"""Quick Codex app-server probe: detect usage-limit / rate-limit before long smoke runs."""

from __future__ import annotations

import json
import os
import select
import subprocess
import sys
import time
from pathlib import Path

DEFAULT_CWD = Path.home() / "develop/oneoffs/phase1-multiagents-smoke"


def read_lines(stream, deadline: float) -> list[dict]:
    buf = ""
    out: list[dict] = []
    while time.time() < deadline:
        ready, _, _ = select.select([stream], [], [], 0.25)
        if not ready:
            continue
        chunk = stream.read(1)
        if not chunk:
            break
        if chunk == "\n":
            line = buf.strip()
            buf = ""
            if not line:
                continue
            try:
                out.append(json.loads(line))
            except json.JSONDecodeError:
                pass
        else:
            buf += chunk
    return out


def main() -> int:
    cwd = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CWD
    cwd.mkdir(parents=True, exist_ok=True)

    proc = subprocess.Popen(
        ["codex", "app-server", "--stdio"],
        cwd=str(cwd),
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=0,
    )
    assert proc.stdin and proc.stdout

    def send(obj: dict) -> None:
        proc.stdin.write(json.dumps(obj, separators=(",", ":")) + "\n")
        proc.stdin.flush()

    send(
        {
            "jsonrpc": "2.0",
            "method": "initialize",
            "id": 0,
            "params": {"clientInfo": {"name": "codex-usage-probe", "version": "0.1"}},
        }
    )
    send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
    send({"jsonrpc": "2.0", "method": "thread/start", "id": 1, "params": {}})

    thread_id: str | None = None
    turn_started = False
    deadline = time.time() + 45
    usage_limit = False
    rate_info: dict | None = None
    agent_text: str | None = None

    while time.time() < deadline:
        for msg in read_lines(proc.stdout, time.time() + 2):
            if msg.get("id") == 1 and "result" in msg:
                thread_id = (msg["result"].get("thread") or {}).get("id")

            if msg.get("method") == "account/rateLimits/updated":
                rate_info = (msg.get("params") or {}).get("rateLimits")

            if msg.get("method") == "error":
                err = (msg.get("params") or {}).get("error") or {}
                if "usage limit" in str(err.get("message", "")).lower():
                    usage_limit = True

            if msg.get("method") == "thread/status/changed":
                status = (msg.get("params") or {}).get("status") or {}
                if status.get("type") == "systemError":
                    usage_limit = True

            if msg.get("method") == "item/completed":
                item = (msg.get("params") or {}).get("item") or {}
                if item.get("type") == "agentMessage" and item.get("text"):
                    agent_text = item["text"]

        if thread_id and not turn_started:
            turn_started = True
            send(
                {
                    "jsonrpc": "2.0",
                    "method": "turn/start",
                    "id": 2,
                    "params": {
                        "threadId": thread_id,
                        "input": [{"type": "text", "text": "Reply with exactly: ok"}],
                        "cwd": str(cwd),
                        "approvalPolicy": "never",
                    },
                }
            )

        if agent_text or usage_limit:
            break

    proc.terminate()

    credits = None
    if rate_info and isinstance(rate_info.get("credits"), dict):
        credits = rate_info["credits"].get("balance")

    result = {
        "cwd": str(cwd),
        "usage_limit_hit": usage_limit,
        "agent_reply": agent_text,
        "credits_balance": credits,
        "ok_for_smoke": bool(agent_text) and not usage_limit,
    }
    print(json.dumps(result, indent=2))
    return 0 if result["ok_for_smoke"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
