#!/bin/bash
set -euo pipefail

ORG="${ORG:-getbread}"
CLONE_PATH="${CLONE_PATH:-${HOME}/develop}"
PER_PAGE="${PER_PAGE:-100}"
TOKEN="${GITHUB_TOKEN:?Set GITHUB_TOKEN before running this script}"

GREEN='\033[0;32m'
NC='\033[0m'

for ((PAGE=1; ; PAGE+=1)); do
    INPUT=$(curl -H "Authorization: token $TOKEN" -s "https://api.github.com/orgs/$ORG/repos?per_page=$PER_PAGE&page=$PAGE" | jq -r ".[].clone_url")

    echo -ne "${GREEN}THE INPUT IS : ${INPUT}${NC}\n"
    if [[ -z "$INPUT" ]]; then
        echo -e "${GREEN}All repos processed, stopped at page=$PAGE, exiting loop${NC}"
        exit 0
    fi

    while read -r REPO_URL; do
        echo "$REPO_URL"
        temp=${REPO_URL##*/}
        repo_name=${temp%.*}
        gh repo clone "$REPO_URL" "$CLONE_PATH/$repo_name" -- -q 2>/dev/null || (
            mkdir -p "$CLONE_PATH/$repo_name"
            cd "$CLONE_PATH/$repo_name"
            git checkout -q main 2>/dev/null || true
            git checkout -q master 2>/dev/null || true
            git pull -q
        )
    done < <(echo "$INPUT")
done
