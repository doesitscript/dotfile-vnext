#!/usr/bin/env bash
# Echo-only DMR status. Does not pull, run, or delete models.
set -euo pipefail

echo "# docker model list (expected after pulls)"
echo "docker model list"
echo
echo "# OpenAI-compatible models endpoint (Desktop DMR typical)"
echo "curl -sS http://127.0.0.1:12434/engines/v1/models"
echo
echo "# Compose models example (from packet root)"
echo "docker compose -f helpers/docker-model-runner/examples/compose.models.example.yml config"
