# Local Bootstrap Key Files

Place non-secret controller public keys here for local machine bootstrap workflows.

## Required File

- `mac_dev_id_ed25519.pub`

`bootstrap/local/bootstrap.yml` reads this file and installs it into the local bootstrap user's `authorized_keys` on each machine where you run local bootstrap.

This keeps SSH key distribution aligned with your workflow of bootstrapping each machine locally.
