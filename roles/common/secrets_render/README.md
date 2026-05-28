# Common Secrets Rendering Role

Loads vault files for secrets rendering. Used by stack deployment roles.

## Purpose

- Loads shared vault (vault/shared.vault.yml)
- Loads node-specific vaults (vault/network.vault.yml, vault/main.vault.yml, vault/dev.vault.yml)
- Makes vault variables available for template rendering
- Supports rendering real runtime `.env` or equivalent config artifacts from
  vault-backed values for implemented capabilities

## Project standard

- For implemented capabilities, the primary output is the real managed runtime
  artifact, such as `.env`, not a placeholder or demo stub.
- If a capability also ships a schema/reference file, that file is secondary
  and must not replace the real managed artifact.
- Roles should verify the required keys for their rendered runtime artifact
  after deployment without printing secret values.

## Usage

This role is typically included in stack deployment roles before rendering .env files.
