# Redeploy checklist — Docker Model Runner (human, idempotent)

**Do not** turn this into Ansible until
`work_laptop_docker_model_runner_automation` is commissioned.

Target: work laptop (`a805120` / `MLLXLJJ2XVFJ`).

## Apply (converge)

1. Docker Desktop installed and running.
2. Enable Model Runner (Desktop Settings → Features / Models — follow current
   Docker docs: https://docs.docker.com/ai/model-runner/get-started/).
3. Confirm CLI:
   ```bash
   docker model version || docker model --help
   ```
4. Pull required models (repeat-safe; cached after first success):
   ```bash
   docker model pull <oci-or-hf-ref>
   ```
5. Optional Compose converge (example file):
   ```bash
   docker compose -f helpers/docker-model-runner/examples/compose.models.example.yml pull
   docker compose -f helpers/docker-model-runner/examples/compose.models.example.yml up -d --remove-orphans
   ```
6. Point Continue at `http://127.0.0.1:12434/engines/v1` using the snippet
   example (or future managed block). Reload VS Code / Continue.

## Verify

```bash
docker model list
curl -sS http://127.0.0.1:12434/engines/v1/models
# Continue: chat / edit / apply using the local DMR model name from /models
```

Re-run Apply + Verify after wipe: pulls should hit local cache when present;
API `/models` must list the same logical set.

## Undo

```bash
# Stop using DMR in Continue (remove or disable local openai apiBase entries)
# Optional: remove models (destructive — only when intentional)
docker model rm <model-id>    # if supported by installed CLI
# Or Desktop UI → Models → remove
```

Leave Docker Desktop installed unless the user asked for full teardown.

## Change class

Bootstrap / semi-manual until an Ansible role exists. Future role must stay
`present|absent` and must not require the deprecated public-share rsync path.
