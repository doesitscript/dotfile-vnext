#!/usr/bin/env bash
set -euo pipefail

context="${VLLM_CONTEXT:-hom-lab-ctl-k3s-02}"
namespace="${VLLM_NAMESPACE:-vllm-runtime}"
deployment="${VLLM_DEPLOYMENT:-vllm-primary}"
service="${VLLM_SERVICE:-vllm-primary}"
local_port="${VLLM_LOCAL_PORT:-8000}"

command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
args="$(kubectl --context "$context" -n "$namespace" get deployment "$deployment" -o jsonpath='{.spec.template.spec.containers[?(@.name=="vllm")].args[*]}')"
mode="$(kubectl --context "$context" -n "$namespace" get deployment "$deployment" -o jsonpath='{.spec.template.spec.containers[?(@.name=="vllm")].env[?(@.name=="VLLM_SERVER_DEV_MODE")].value}')"
[[ "$args" == *"--enable-sleep-mode"* && "$mode" == "1" ]] || {
  echo "vLLM sleep mode is not enabled on $context/$namespace/$deployment" >&2
  exit 1
}

port_log="$(mktemp -t vllm-wake-port-forward.XXXXXX)"
cleanup() { kill "$port_pid" 2>/dev/null || true; rm -f "$port_log"; }
trap cleanup EXIT
kubectl --context "$context" -n "$namespace" port-forward "svc/$service" "$local_port:8000" >"$port_log" 2>&1 &
port_pid=$!
for _ in {1..20}; do
  curl -fsS "http://127.0.0.1:$local_port/is_sleeping" >/dev/null 2>&1 && break
  sleep 1
done
curl -fsS -X POST "http://127.0.0.1:$local_port/wake_up"
echo
