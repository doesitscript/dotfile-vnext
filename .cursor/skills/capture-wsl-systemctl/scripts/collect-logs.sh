#!/usr/bin/env bash
# Runs INSIDE WSL via: ssh hom-lab-ctl-dkr-02 'bash -s' < collect-logs.sh
set -euo pipefail

echo "=== systemctl capture ==="
echo "host: $(hostname)"
echo "time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo ""

echo "--- systemctl status (top-level) ---"
systemctl status --no-pager || true
echo ""

echo "--- systemctl list-units --type=service --all ---"
systemctl list-units --type=service --all --no-pager
echo ""

echo "--- systemctl list-units --failed ---"
systemctl list-units --failed --no-pager
echo ""

echo "--- keepwsl.service status ---"
systemctl status keepwsl.service --no-pager || true
echo ""

echo "--- journalctl -b (last 150 lines) ---"
journalctl -b --no-pager -n 150
