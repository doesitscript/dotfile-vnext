# troubleshooting_collectors

Optional artifact collectors for troubleshooting runs.

Purpose:

- keep mandatory troubleshooting-mode reporting in the normal role/playbook path
- provide an on-demand Ansible artifact-harvesting layer for failed or noisy
  investigations
- save artifacts under a controller-local, gitignored tree

Current collector task files:

- none active

Default artifact root:

```yaml
troubleshooting_artifact_root: artifacts/troubleshooting
```

The legacy Multipass collector was removed after the Multipass teardown work
completed. Historical artifacts under `artifacts/troubleshooting/` remain as
background evidence, but this role no longer exposes a live Multipass-specific
collector surface.

This role is intentionally collector-oriented, not a long-term centralized
logging system.
