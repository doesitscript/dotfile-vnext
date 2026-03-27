#!/usr/bin/env node

import { spawn } from "node:child_process";

const [, , serverCommand, ...serverArgs] = process.argv;

if (!serverCommand) {
  console.error(
    "Usage: drawio-mcp-codex-stdio-wrapper.js <drawio-command> [args...]",
  );
  process.exit(2);
}

const child = spawn(serverCommand, serverArgs, {
  stdio: ["pipe", "pipe", "pipe"],
  env: process.env,
});

process.stdin.pipe(child.stdin);
child.stderr.pipe(process.stderr);

const protocolMarker = Buffer.from("Content-Length:");
let seenProtocol = false;
let buffered = Buffer.alloc(0);

child.stdout.on("data", (chunk) => {
  if (seenProtocol) {
    process.stdout.write(chunk);
    return;
  }

  buffered = Buffer.concat([buffered, chunk]);
  const markerIndex = buffered.indexOf(protocolMarker);

  if (markerIndex === -1) {
    const newlineIndex = Math.max(
      buffered.lastIndexOf(0x0a),
      buffered.lastIndexOf(0x0d),
    );

    if (newlineIndex >= 0) {
      process.stderr.write(buffered.subarray(0, newlineIndex + 1));
      buffered = buffered.subarray(newlineIndex + 1);
    }
    return;
  }

  if (markerIndex > 0) {
    process.stderr.write(buffered.subarray(0, markerIndex));
  }

  process.stdout.write(buffered.subarray(markerIndex));
  buffered = Buffer.alloc(0);
  seenProtocol = true;
});

child.on("error", (error) => {
  console.error(`[drawio-mcp-codex-wrapper] Failed to start child: ${error.message}`);
  process.exit(1);
});

child.on("close", (code, signal) => {
  if (!seenProtocol && buffered.length > 0) {
    process.stderr.write(buffered);
  }

  if (signal) {
    process.kill(process.pid, signal);
    return;
  }

  process.exit(code ?? 0);
});
