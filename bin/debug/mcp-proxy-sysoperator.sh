#!/bin/bash
# MCP stdio proxy for sysoperator
# Tees stdin→server into sysoperator-in.log and server→stdout into sysoperator-out.log
# so we can see exactly what Cursor sends and what the server replies.
#
# To restore direct mode, replace .cursor/mcp.json with bin/debug/mcp.json.original

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs/mcp-debug"
IN_LOG="${LOG_DIR}/mcp-sysoperator-cursor-to-server.log"
OUT_LOG="${LOG_DIR}/mcp-sysoperator-server-to-cursor.log"

# Rotate previous logs
[[ -f "$IN_LOG" ]] && mv "$IN_LOG" "${IN_LOG}.prev"
[[ -f "$OUT_LOG" ]] && mv "$OUT_LOG" "${OUT_LOG}.prev"

echo "--- session started $(date -Iseconds) ---" >> "$IN_LOG"
echo "--- session started $(date -Iseconds) ---" >> "$OUT_LOG"

tee -a "$IN_LOG" \
  | node /home/joshc/.local/lib/mcp-sysoperator/build/index.js \
  | tee -a "$OUT_LOG"
