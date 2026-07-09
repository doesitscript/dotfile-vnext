#!/usr/bin/env bash
# Probe homelab name resolution across hom.lab, .local, and .lab suffixes.
# Read-only — safe to run from mac-dev during troubleshooting.
set -euo pipefail

ROUTER_DNS="${ROUTER_DNS:-192.168.50.1}"
OUT_DIR="${1:-}"

hosts=(
  HOM-LAB-HVH-01 HOM-LAB-HVH-02
  hom-lab-ctl-k3s-01 hom-lab-ctl-k3s-02
  hom-lab-ctl-dkr-01 hom-lab-ctl-dkr-02
  litellm langfuse netbox grafana jupyter semaphore loki
)

suffixes=("" ".hom.lab" ".local" ".lab")

output() {
  if [[ -n "$OUT_DIR" ]]; then
    tee -a "$OUT_DIR/dns-matrix.txt"
  else
    cat
  fi
}

{
  printf '%-36s %-10s %-22s %-22s\n' "FQDN" "suffix" "router_dns" "mac_resolver"
  printf '%.0s-' {1..95}; echo

  for base in "${hosts[@]}"; do
    for suf in "${suffixes[@]}"; do
      fqdn="${base}${suf}"
      label="${suf:-"(bare)"}"

      router="$(dig +short "$fqdn" @"$ROUTER_DNS" 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
      [[ -z "$router" ]] && router="-"

      mac="$(dscacheutil -q host -a name "$fqdn" 2>/dev/null | awk '/ip_address/{print $2}' | tr '\n' ',' | sed 's/,$//')"
      [[ -z "$mac" ]] && mac="-"

      printf '%-36s %-10s %-22s %-22s\n' "$fqdn" "$label" "$router" "$mac"
    done
  done

  echo
  echo "=== routes ==="
  for ip in 192.168.138.11 192.168.137.11 192.168.50.234 192.168.50.158; do
    echo "--- $ip"
    route -n get "$ip" 2>/dev/null | awk '/gateway:|interface:/{print}' || true
  done
} | output
