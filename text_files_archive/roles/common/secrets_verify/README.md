# Common Secrets Verification Role

Verifies that required .env keys exist on each node without printing secret values.

## Purpose

- Checks that all required environment variables are present in .env files
- Does not print secret values (uses `no_log: true` where appropriate)
- Fails verification if required keys are missing

## Required Keys by Node

### Network Node
- COMPOSE_PROJECT_NAME
- POSTGRES_USER
- POSTGRES_PASSWORD
- POSTGRES_DB
- MINIO_ROOT_USER
- MINIO_ROOT_PASSWORD
- NEXTAUTH_SECRET
- SALT
- LANGFUSE_PUBLIC_KEY
- LANGFUSE_SECRET_KEY
- MINIO_ACCESS_KEY
- MINIO_SECRET_KEY

### Dev Node
- COMPOSE_PROJECT_NAME
- LANGFUSE_PUBLIC_KEY
- LANGFUSE_SECRET_KEY
- LANGFUSE_HOST
- OLLAMA_API_BASE

### Main Node
- COMPOSE_PROJECT_NAME
- LANGFUSE_PUBLIC_KEY
- LANGFUSE_SECRET_KEY
- LANGFUSE_HOST

## Usage

This role is automatically included in `verify_fabric.yaml` playbook.



