#!/usr/bin/env bash
# Collect LiteLLM pre-call tools dumps from the gateway pod to a local folder.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OUT="${OUT:-$REPO_ROOT/logs/litellm-tools-capture}"
HOST="${LITELLM_K8S_HOST:-hom-lab-ctl-k3s-02}"
NS="${LITELLM_NAMESPACE:-litellm}"

mkdir -p "$OUT"
cd "$REPO_ROOT"

echo "Collecting LiteLLM tools capture into $OUT (host=$HOST ns=$NS) ..."

bin/codex-env ansible "$HOST" -m shell -a \
  "kubectl -n ${NS} logs -l app.kubernetes.io/name=litellm --tail=400 | grep -E 'tools_breakdown|trim_messages tool:|tool_params:|tool_desc_preview:|tools_dump_path'" \
  > "$OUT/summary-logs.txt" 2>&1 || true

bin/codex-env ansible "$HOST" -m shell -a \
  "POD=\$(kubectl -n ${NS} get pod -l app.kubernetes.io/name=litellm -o jsonpath='{.items[0].metadata.name}'); kubectl -n ${NS} exec \"\$POD\" -- sh -c 'ls -la /tmp/litellm-tools-capture /tmp/litellm-tools-structure-dump.json 2>&1'" \
  > "$OUT/pod-ls.txt" 2>&1 || true

for f in summary.json tools-array-complete.json tool-Task.json tool-Shell.json; do
  bin/codex-env ansible "$HOST" -m shell -a \
    "POD=\$(kubectl -n ${NS} get pod -l app.kubernetes.io/name=litellm -o jsonpath='{.items[0].metadata.name}'); kubectl -n ${NS} exec \"\$POD\" -- cat /tmp/litellm-tools-capture/${f}" \
    > "$OUT/$f" 2>&1 || echo "MISSING $f" > "$OUT/$f"
done

bin/codex-env ansible "$HOST" -m shell -a \
  "POD=\$(kubectl -n ${NS} get pod -l app.kubernetes.io/name=litellm -o jsonpath='{.items[0].metadata.name}'); kubectl -n ${NS} exec \"\$POD\" -- cat /tmp/litellm-tools-structure-dump.json" \
  > "$OUT/litellm-tools-structure-dump.json" 2>&1 || true

# Strip ansible chatter: prefer payload after ">>", skip [WARNING]/[ERROR]/...
OUT_DIR="$OUT" "$REPO_ROOT/.venv/bin/python" - <<'PY'
import json
import os
import pathlib
import re

out = pathlib.Path(os.environ["OUT_DIR"])
for path in out.glob("*.json"):
    text = path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r">>\s*(\{|\[)", text)
    if match:
        cleaned = text[match.start(1) :]
    else:
        cleaned = None
        for m in re.finditer(r"[\{\[]", text):
            snippet = text[m.start() : m.start() + 20]
            if snippet.startswith(("[WARNING", "[ERROR", "[DEPREC")):
                continue
            cleaned = text[m.start() :]
            break
        if cleaned is None:
            continue
    json.loads(cleaned)  # fail loud if still not JSON
    path.write_text(cleaned, encoding="utf-8")
    print(f"cleaned {path.name} -> {path.stat().st_size} bytes")
print("done:", out)
PY
