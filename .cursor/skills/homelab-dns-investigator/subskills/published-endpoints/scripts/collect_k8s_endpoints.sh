#!/usr/bin/env bash
# Collect Kubernetes ingress, services, and endpoints for homelab investigation.
set -euo pipefail

ARTIFACT_DIR="${ARTIFACT_DIR:-/tmp}"
CONTEXT="${CONTEXT:-}"
OUT="$ARTIFACT_DIR/k8s-endpoints.txt"

mkdir -p "$ARTIFACT_DIR"

ctx_args=()
[[ -n "$CONTEXT" ]] && ctx_args=(--context="$CONTEXT")

{
  echo "=== context: ${CONTEXT:-current} ==="
  date -u +"%Y-%m-%dT%H:%M:%SZ"

  echo
  echo "=== kubectl get ingress -A -o wide ==="
  kubectl "${ctx_args[@]}" get ingress -A -o wide 2>&1 || echo "BLOCKED: ingress query failed"

  echo
  echo "=== kubectl get svc -A (NodePort, LoadBalancer) ==="
  kubectl "${ctx_args[@]}" get svc -A -o wide 2>&1 | awk 'NR==1 || /NodePort|LoadBalancer/' || echo "BLOCKED: svc query failed"

  echo
  echo "=== kubectl get endpoints -A ==="
  kubectl "${ctx_args[@]}" get endpoints -A 2>&1 | head -200 || echo "BLOCKED: endpoints query failed"
} | tee "$OUT"

echo "Wrote $OUT"
