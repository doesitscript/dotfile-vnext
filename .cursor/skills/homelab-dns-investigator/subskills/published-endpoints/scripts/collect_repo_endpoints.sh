#!/usr/bin/env bash
# Extract declared endpoint rows from repo SSOT into artifact dir.
# Read-only — lists catalog keys and portproxy names for the investigator report.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../../../../../" && pwd)"
ARTIFACT_DIR="${ARTIFACT_DIR:-}"
OUT="${ARTIFACT_DIR:-/tmp}/repo-endpoints.txt"

mkdir -p "$(dirname "$OUT")"

{
  echo "=== homelab_hosts_file_web_catalog (inventory/group_vars/all/homelab_hosts_file.yml) ==="
  rg -n "catalog_key:|hostname:|verify_url:|source:" \
    "$REPO_ROOT/inventory/group_vars/all/homelab_hosts_file.yml" || true

  echo
  echo "=== guest_published_tcp_ports hom-lab-ctl-hvh-01 ==="
  rg -n "name:|listen_address:|listen_port:|connect_address:|connect_port:" \
    "$REPO_ROOT/inventory/host_vars/hom-lab-ctl-hvh-01.yaml" \
    -A0 -B0 2>/dev/null | head -80 || true

  echo
  echo "=== guest_published_tcp_ports hom-lab-ctl-hvh-02 ==="
  rg -n "name:|listen_address:|listen_port:|connect_address:|connect_port:" \
    "$REPO_ROOT/inventory/host_vars/hom-lab-ctl-hvh-02.yaml" \
    -A0 -B0 2>/dev/null | head -80 || true

  echo
  echo "=== service-entrypoints doc ==="
  echo "$REPO_ROOT/docs/reference/service-entrypoints-and-ai-surfaces.md"
} | tee "$OUT"

echo "Wrote $OUT"
