#!/bin/bash
# MCP stdio proxy for ansible (Red Hat Ansible extension)
# Tees stdin→server into ansible-in.log and server→stdout into ansible-out.log
# so we can see exactly what Cursor sends and what the server replies.
#
# To restore direct mode, replace .cursor/mcp.json with bin/debug/mcp.json.original

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs/mcp-debug"
IN_LOG="${LOG_DIR}/mcp-ansible-cursor-to-server.log"
OUT_LOG="${LOG_DIR}/mcp-ansible-server-to-cursor.log"

# Rotate previous logs
[[ -f "$IN_LOG" ]] && mv "$IN_LOG" "${IN_LOG}.prev"
[[ -f "$OUT_LOG" ]] && mv "$OUT_LOG" "${OUT_LOG}.prev"

echo "--- session started $(date -Iseconds) ---" >> "$IN_LOG"
echo "--- session started $(date -Iseconds) ---" >> "$OUT_LOG"

tee -a "$IN_LOG" \
  | node /home/joshc/.cursor-server/extensions/redhat.ansible-26.1.3-universal/out/mcp/cli.js --stdio \
  | tee -a "$OUT_LOG"
