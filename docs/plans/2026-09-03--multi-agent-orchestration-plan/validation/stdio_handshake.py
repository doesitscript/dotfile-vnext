#!/usr/bin/env python3
"""Minimal Codex app-server stdio handshake for Phase 1 receipts.

Starts `codex app-server --stdio`, then:
  initialize -> initialized -> thread/start -> turn/start

Captures newline-delimited JSON-RPC lines to stdout until turn completes
or timeout. Does not require the managed standalone daemon install.
"""

from __future__ import annotations

import argparse
import json
import os
import select
import subprocess
import sys
import time
from pathlib import Path


def send(proc: subprocess.Popen, message: dict) -> None:
    line = json.dumps(message, separators=(",", ":"))
    assert proc.stdin is not None
    proc.stdin.write(line + "\n")
    proc.stdin.flush()
    print(f">>> {line}", flush=True)


def read_lines(proc: subprocess.Popen, deadline: float) -> list[dict]:
    assert proc.stdout is not None
    collected: list[dict] = []
    buf = ""
    while time.time() < deadline:
        remaining = max(0.0, deadline - time.time())
        ready, _, _ = select.select([proc.stdout], [], [], min(0.5, remaining))
        if not ready:
            if proc.poll() is not None:
                break
            continue
        chunk = proc.stdout.read(1)
        if chunk == "":
            if proc.poll() is not None:
                break
            continue
        if chunk == "\n":
            line = buf.strip()
            buf = ""
            if not line:
                continue
            print(f"<<< {line}", flush=True)
            try:
                collected.append(json.loads(line))
            except json.JSONDecodeError:
                collected.append({"_raw": line})
        else:
            buf += chunk
    return collected


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--cwd",
        default=str(Path.home() / "develop" / "dotfile-vnext"),
        help="cwd for turn/start sandbox",
    )
    parser.add_argument("--timeout", type=float, default=90.0)
    parser.add_argument(
        "--prompt",
        default="Reply with exactly one word: pong. Do not use tools.",
    )
    args = parser.parse_args()

    env = os.environ.copy()
    # Prefer the same CLI used in probes.
    codex = env.get("CODEX_BIN", "codex")

    proc = subprocess.Popen(
        [codex, "app-server", "--stdio"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=0,
        env=env,
    )

    started = time.time()
    deadline = started + args.timeout
    events: list[dict] = []

    try:
        send(
            proc,
            {
                "method": "initialize",
                "id": 0,
                "params": {
                    "clientInfo": {
                        "name": "dotfile-vnext-phase1-stdio",
                        "title": "Phase 1 stdio harness",
                        "version": "0.1.0",
                    }
                },
            },
        )
        send(proc, {"method": "initialized", "params": {}})
        send(proc, {"method": "thread/start", "id": 1, "params": {}})

        thread_id = None
        turn_started = False
        turn_done = False

        while time.time() < deadline and not turn_done:
            batch = read_lines(proc, min(deadline, time.time() + 2.0))
            events.extend(batch)
            for msg in batch:
                if msg.get("id") == 0 and "error" in msg:
                    print("initialize failed", file=sys.stderr)
                    return 2
                if msg.get("id") == 1 and "result" in msg and thread_id is None:
                    thread = msg["result"].get("thread") or {}
                    thread_id = thread.get("id")
                    if not thread_id:
                        print("thread/start missing thread.id", file=sys.stderr)
                        return 3
                    send(
                        proc,
                        {
                            "method": "turn/start",
                            "id": 2,
                            "params": {
                                "threadId": thread_id,
                                "input": [{"type": "text", "text": args.prompt}],
                                "cwd": args.cwd,
                                "approvalPolicy": "never",
                                "sandboxPolicy": {"type": "readOnly"},
                            },
                        },
                    )
                    turn_started = True
                if msg.get("id") == 2 and ("result" in msg or "error" in msg):
                    # turn accepted or rejected
                    if "error" in msg:
                        print("turn/start failed", file=sys.stderr)
                        return 4
                # Completion notifications vary by version; accept either.
                method = msg.get("method")
                if method in {"turn/completed", "turn/complete"}:
                    turn_done = True
                # Observed on 0.142.5: agentMessage can complete before a
                # turn/completed notification; treat final_answer text as done.
                if method == "item/completed" and turn_started:
                    item = (msg.get("params") or {}).get("item") or {}
                    if (
                        item.get("type") == "agentMessage"
                        and item.get("phase") == "final_answer"
                        and str(item.get("text") or "").strip()
                    ):
                        turn_done = True
                if (
                    turn_started
                    and msg.get("id") == 2
                    and isinstance(msg.get("result"), dict)
                    and (msg["result"].get("turn") or {}).get("status")
                    in {"completed", "failed", "interrupted"}
                ):
                    turn_done = True

            if proc.poll() is not None and not batch:
                break

        summary = {
            "argv": [codex, "app-server", "--stdio"],
            "elapsed_s": round(time.time() - started, 2),
            "thread_id": thread_id,
            "turn_started": turn_started,
            "turn_done": turn_done,
            "proc_returncode": proc.poll(),
            "event_count": len(events),
        }
        print("---SUMMARY---", flush=True)
        print(json.dumps(summary, indent=2), flush=True)

        # Drain a bit of stderr for the receipt if process exited.
        err = ""
        if proc.stderr is not None:
            try:
                # non-blocking-ish: only if already exited or short wait
                if proc.poll() is not None:
                    err = proc.stderr.read() or ""
            except Exception:
                err = ""
        if err.strip():
            print("---STDERR---", flush=True)
            print(err[-4000:], flush=True)

        if thread_id and turn_started:
            return 0
        return 5
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                proc.kill()


if __name__ == "__main__":
    raise SystemExit(main())
