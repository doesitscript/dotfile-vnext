# Artifact contract

## Required keys

```yaml
windows_artifact:
  id: "<stable-id>"
  url: "<pinned https url>"
  destination: 'C:\ProgramData\Ansible\artifacts\<name>\<file>'
  checksum:
    algorithm: sha256
    value: "<hex digest of the final file>"
```

## Recommended for multi-GB

```yaml
  resume: true
  force: false
  retries: 20
  retry_delay_seconds: 10
  connect_timeout_seconds: 30
  stalled_transfer:
    minimum_bytes_per_second: 1024
    timeout_seconds: 120
  async:
    enabled: true
    timeout_seconds: 28800   # 8h
    poll_interval_seconds: 30
  preserve_partial_on_failure: true
  create_destination_directory: true
```

## Pinning checklist

1. Prefer a **versioned** release asset URL (not floating `latest` without pin).
2. Record sha256 from upstream release notes or `sha256sum` of a trusted copy.
3. Destination under `C:\ProgramData\Ansible\artifacts\...` (not user Desktop).
4. Partial path is `destination + .partial` — do not delete on stall unless
   force re-download is intentional (`force: true`).

## After publish

Owning role installs:

- `ansible.windows.win_package` for Setup.exe / MSI
- extract/copy for ZIPs
- **Not** this skill’s job: `ollama pull` / HF Hub weights

## Anti-patterns

| Don’t | Do |
| --- | --- |
| `_tmp_*` playbook with curl | `include_role: windows_artifact_download` |
| Role `files/*.ps1` downloader | Role contract + this reusable role |
| Skip checksum “to go faster” | Pin sha256 before apply |
| Blame Ansible when Wi‑Fi loses packets | Hop + CDN triage; keep partial |
| Use this for `ollama pull` | Product role `/api/pull` |
