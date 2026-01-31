# Common Secrets Rendering Role

Loads vault files for secrets rendering. Used by stack deployment roles.

## Purpose

- Loads shared vault (vault/shared.vault.yml)
- Loads node-specific vaults (vault/network.vault.yml, vault/main.vault.yml, vault/dev.vault.yml)
- Makes vault variables available for template rendering

## Usage

This role is typically included in stack deployment roles before rendering .env files.

