#!/bin/bash

ORG="getbread" # Your organization
# CLONE_PATH="/home/user/Documents/..." # Path in your filesystem where you want to clone the repos
# CLONE_PATH="~/develop/..." # Path in your filesystem where you want to clone the repos
# CLONE_PATH="${HOME}/develop/..." # Path in your filesystem where you want to clone the repos
CLONE_PATH="${HOME}/develop" # Path in your filesystem where you want to clone the repos
PER_PAGE=100 # per_page maxes out at 100
# TOKEN="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" # Set your token from GH
# TOKEN="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" # Set your token from GH
TOKEN="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" # Set your token from GH
GREEN='\033[0;32m'
NC='\033[0m'
for ((PAGE=1; ; PAGE+=1)); do
    # Page 0 and 1 are the same
    # Change authorization method as needed
    INPUT=$(curl -H "Authorization: token $TOKEN" -s "https://api.github.com/orgs/$ORG/repos?per_page=$PER_PAGE&page=$PAGE" | jq -r ".[].clone_url")
    
    echo -ne "${GREEN}THE INPUT IS : ${INPUT}${NC}\n"
    if [[ -z "$INPUT" ]]; then
        echo "${GREEN}All repos processed, stopped at page=$PAGE$, exiting loop{NC}"
        exit
    fi
    while read REPO_URL ; do
        echo $REPO_URL
        temp=${REPO_URL##*/}
        repo_name=${temp%.*}
        gh repo clone "$REPO_URL" "$CLONE_PATH/$repo_name" -- -q 2>/dev/null || (
            # ← put the command whos exit code you want to check here &>/dev/null
            # if [ -n test -d "$CLONE_PATH/$repo_name" ]; then
            if [ -n "$CLONE_PATH/$repo_name" ]; then
                mkdir -d "$CLONE_PATH/$repo_name"
            fi
            cd "$CLONE_PATH/$repo_name"
            # Handle case where local checkout is on a non-main/master branch
            # - ignore checkout errors because some repos may have zero commits,
            # so no main or master
            git checkout -q main 2>/dev/null || true
            git checkout -q master 2>/dev/null || true
            git pull -q
            
        )
    done < <(echo "$INPUT")
done