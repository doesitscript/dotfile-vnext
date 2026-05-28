#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

failures=()

while IFS= read -r plan_file; do
  [[ -z "${plan_file}" ]] && continue

  if ! rg -q '^## Mandatory NetBox slice$' "${plan_file}"; then
    failures+=("${plan_file}: missing '## Mandatory NetBox slice'")
  fi

  if ! rg -q 'Declared / Applied / Verified|Declared, Applied, Verified|declared-applied-verified' "${plan_file}"; then
    failures+=("${plan_file}: missing Declared / Applied / Verified evidence language")
  fi

  if ! rg -q '^## Plan verification receipt$' "${plan_file}"; then
    failures+=("${plan_file}: missing '## Plan verification receipt'")
  fi

  if ! rg -q 'artifacts/netbox|artifacts/netbox-service-inventory|artifacts/netbox-reconciliation' "${plan_file}"; then
    failures+=("${plan_file}: missing NetBox artifact reference")
  fi
done < <(rg -l '^netbox_scope: true' docs/plans -g 'README.md')

if ((${#failures[@]} > 0)); then
  printf 'NetBox plan governance check failed.\n\n' >&2
  printf '%s\n' "${failures[@]}" >&2
  exit 1
fi

printf 'NetBox plan governance check passed for all netbox_scope plan packets.\n'
