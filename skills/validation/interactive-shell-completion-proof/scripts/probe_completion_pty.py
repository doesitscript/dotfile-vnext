#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import select
import subprocess
import sys
import time


READY_MARKER = "__interactive_shell_ready__"
DONE_MARKER = "__interactive_shell_done__"
PROMPT = "__interactive_shell_prompt__ "


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Probe interactive shell completion in a real PTY."
    )
    parser.add_argument(
        "--shell",
        default=os.environ.get("SHELL", "/usr/local/bin/bash"),
        help="Shell binary to launch in interactive login mode.",
    )
    parser.add_argument(
        "--probe-text",
        required=True,
        help="Exact text to type before sending Tab twice, usually quoted with a trailing space.",
    )
    parser.add_argument(
        "--expect",
        action="append",
        default=[],
        help="Substring that must appear in the transcript. Repeat for multiple expectations.",
    )
    parser.add_argument(
        "--forbid",
        action="append",
        default=[],
        help="Substring that must not appear in the transcript. Repeat for multiple forbidden strings.",
    )
    parser.add_argument(
        "--startup-timeout",
        type=float,
        default=8.0,
        help="Seconds to wait for the shell to become interactive.",
    )
    parser.add_argument(
        "--settle-time",
        type=float,
        default=1.5,
        help="Seconds to wait for completion output after the second Tab.",
    )
    return parser.parse_args()


def write_all(fd: int, text: str) -> None:
    os.write(fd, text.encode("utf-8"))


def read_some(fd: int, transcript: list[bytes], timeout: float) -> bytes:
    deadline = time.time() + timeout
    chunks: list[bytes] = []

    while time.time() < deadline:
        ready, _, _ = select.select([fd], [], [], 0.1)
        if not ready:
            continue
        chunk = os.read(fd, 4096)
        if not chunk:
            break
        transcript.append(chunk)
        chunks.append(chunk)

    return b"".join(chunks)


def wait_for(fd: int, transcript: list[bytes], marker: str, timeout: float) -> None:
    deadline = time.time() + timeout
    marker_bytes = marker.encode("utf-8")
    observed = b"".join(transcript)

    while time.time() < deadline:
        if marker_bytes in observed:
            return
        observed += read_some(fd, transcript, 0.25)

    raise TimeoutError(f"Timed out waiting for marker: {marker}")


def main() -> int:
    args = parse_args()
    master_fd, slave_fd = os.openpty()
    transcript: list[bytes] = []

    proc = subprocess.Popen(
        [args.shell, "-li"],
        stdin=slave_fd,
        stdout=slave_fd,
        stderr=slave_fd,
        close_fds=True,
    )
    os.close(slave_fd)

    try:
        write_all(master_fd, f"export PS1='{PROMPT}'\n")
        write_all(master_fd, "bind 'set show-all-if-ambiguous on'\n")
        write_all(master_fd, "bind 'set show-all-if-unmodified on'\n")
        write_all(master_fd, "bind 'set page-completions off'\n")
        write_all(master_fd, f"printf '{READY_MARKER}\\n'\n")
        wait_for(master_fd, transcript, READY_MARKER, args.startup_timeout)

        write_all(master_fd, args.probe_text)
        time.sleep(0.2)
        write_all(master_fd, "\t")
        time.sleep(0.2)
        write_all(master_fd, "\t")
        read_some(master_fd, transcript, args.settle_time)

        write_all(master_fd, "\x15\n")
        time.sleep(0.1)
        write_all(master_fd, f"printf '{DONE_MARKER}\\n'\nexit\n")
        wait_for(master_fd, transcript, DONE_MARKER, 4.0)
        read_some(master_fd, transcript, 0.5)
    finally:
        os.close(master_fd)
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait(timeout=2)

    rendered = b"".join(transcript).decode("utf-8", errors="replace").replace("\r", "")
    print(rendered)

    missing = [item for item in args.expect if item not in rendered]
    forbidden = [item for item in args.forbid if item in rendered]

    if missing:
        for item in missing:
            print(f"missing expected text: {item}", file=sys.stderr)
    if forbidden:
        for item in forbidden:
            print(f"found forbidden text: {item}", file=sys.stderr)

    if missing or forbidden:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
