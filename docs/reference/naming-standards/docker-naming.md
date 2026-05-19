# Docker Naming Conventions

## Source

- Docker Tag Command: https://docs.docker.com/engine/reference/commandline/tag/
- Docker Run Command: https://docs.docker.com/engine/reference/commandline/run/#assign-name-and-allocate-pseudo-tty

## Hard Requirements (MUST)

### Image Reference Format

A complete Docker image reference consists of:

```
[HOST[:PORT]/]NAMESPACE/REPOSITORY[:TAG]
```

**Components:**

| Component | Required | Description | Example |
|---|---|---|---|
| `HOST` | No | Registry location | `example.com`, `gcr.io`, `docker.io` (default) |
| `PORT` | No | Registry port if non-standard | `5000` |
| `NAMESPACE` | No | User or organization | `team`, `myorg` (defaults to `library` for Docker Hub) |
| `REPOSITORY` | Yes | Image name | `nginx`, `myapp` |
| `TAG` | No | Version or variant identifier | `latest` (default), `1.0`, `alpine` |

### Repository Names

- **Valid characters**: lowercase letters, digits, separators (`.`, `_`, `-`)
- **Separators**: Can have one or more separators between components
- **No consecutive separators**: `my--app` and `my__app` are invalid
- **Must start with**: lowercase letter or digit
- **Must end with**: lowercase letter or digit
- **Case**: Lowercase only

**Length limits:**
- Minimum: 2 characters
- Maximum: 255 characters (practical limit much shorter for usability)

**Examples:**
- ✅ `nginx`, `my-app`, `myapp`, `my.app`, `my_app`, `app-v2`
- ❌ `My-App`, `my--app`, `-myapp`, `myapp-`, `APP`

### Tag Names

- **Valid characters**: lowercase and uppercase ASCII letters, digits, underscores, periods, hyphens
- **Must start with**: letter or digit (NOT a separator)
- **Must end with**: letter or digit
- **Maximum length**: 128 characters

**Examples:**
- ✅ `latest`, `1.0.0`, `v2.1`, `stable`, `2023-03-15`, `build-42`
- ❌ `-latest`, `v1.0.`, `.stable`

### Container Names

When using `--name` with `docker run`:

- **Valid characters**: `[a-zA-Z0-9][a-zA-Z0-9_.-]`
- **Must start with**: alphanumeric character
- **Can contain**: letters, digits, underscores, dots, hyphens

**Examples:**
- ✅ `my-container`, `app_1`, `web.server`, `nginx-prod`
- ❌ `-container`, `.hidden`, `_test`

## Recommendations (SHOULD)

### Image Naming Patterns

**Application images:**
```
<app-name>:<version>
```

Examples:
- `myapp:1.0.0`
- `frontend:2.1.3`
- `api:latest`

**Service-specific images:**
```
<service-name>:<environment>-<version>
```

Examples:
- `auth-service:prod-1.2.0`
- `payment-api:staging-2.0.1`
- `user-db:dev-latest`

**Base images:**
```
<base>-<variant>:<version>
```

Examples:
- `python-slim:3.11`
- `node-alpine:20`
- `ubuntu-minimal:22.04`

### Tag Strategies

**Semantic versioning:**
```
<major>.<minor>.<patch>
```

Examples: `1.0.0`, `2.1.3`, `3.0.0-beta`

**Immutable tags (recommended):**
- Use specific versions: `myapp:1.2.3`
- Avoid mutable tags in production: `myapp:latest`

**Multi-tag strategy:**
- Tag releases with multiple specificity levels
- Example: Version `1.2.3` gets three tags:
  - `myapp:1.2.3` (patch-level)
  - `myapp:1.2` (minor-level)
  - `myapp:1` (major-level)
  - `myapp:latest` (rolling latest)

**Environment tags:**
```
<version>-<environment>
```

Examples:
- `1.2.3-prod`
- `2.0.0-staging`
- `latest-dev`

**Date-based tags:**
```
<version>-<YYYYMMDD>
```

Examples:
- `1.0.0-20260519`
- `latest-20260519`

### Container Naming Patterns

**Service-based:**
```
<service>-<instance>
```

Examples:
- `nginx-proxy`
- `redis-cache`
- `postgres-main`
- `app-worker-1`

**Stack-based:**
```
<stack>-<service>-<instance>
```

Examples:
- `myapp-frontend-1`
- `myapp-backend-1`
- `monitoring-prometheus-1`

**Environment-based:**
```
<service>-<environment>
```

Examples:
- `api-prod`
- `db-staging`
- `worker-dev`

### Registry Naming

**Private registry:**
```
<registry>/<namespace>/<repository>:<tag>
```

Examples:
- `registry.example.com/team/myapp:1.0.0`
- `gcr.io/myproject/api:latest`
- `myregistry:5000/apps/frontend:stable`

**Docker Hub:**
```
<namespace>/<repository>:<tag>
```

Examples:
- `myorg/myapp:1.0.0`
- `library/nginx:alpine` (official images use `library` namespace)
- `username/project:latest`

## Common Patterns

### Official Images (Docker Hub)

- No namespace (implicitly `library/`)
- Examples: `nginx`, `postgres`, `python`, `node`
- With tags: `nginx:alpine`, `postgres:15`, `python:3.11-slim`

### Development vs Production

**Development:**
- Mutable tags acceptable: `myapp:dev`, `myapp:latest`
- Descriptive, human-friendly

**Production:**
- Immutable tags required: `myapp:1.2.3`, `myapp:v1.2.3`
- Include commit SHA for traceability: `myapp:1.2.3-a1b2c3d`

### Multi-Stage Build Artifacts

```
<app>:<stage>-<version>
```

Examples:
- `myapp:build-1.0.0` (build stage artifact)
- `myapp:test-1.0.0` (test stage artifact)
- `myapp:runtime-1.0.0` (final runtime image)

## Constraints

| Element | Min Length | Max Length | Valid Characters | Must Start With | Case |
|---|---|---|---|---|---|
| Repository | 2 | 255 | `[a-z0-9._-]` | `[a-z0-9]` | lowercase |
| Tag | 1 | 128 | `[a-zA-Z0-9._-]` | `[a-zA-Z0-9]` | mixed |
| Container name | 1 | 255 (practical) | `[a-zA-Z0-9_.-]` | `[a-zA-Z0-9]` | mixed |
| Namespace | 2 | 255 | `[a-z0-9._-]` | `[a-z0-9]` | lowercase |

## Rationale

### Why Lowercase for Repository Names

- Registry paths are URLs
- DNS is case-insensitive
- Prevents confusion and collisions
- Standard across container registries

### Why Tags Can Be Mixed Case

- Tags are version identifiers, not URLs
- Allows semantic versioning conventions: `v1.0.0`
- Supports common patterns: `Alpine`, `Ubuntu`
- More flexible for human-readable variants

### Why Short Names Are Better

- Easier to type and remember
- Faster to pull/push
- Better in logs and output
- More readable in orchestration configs

### Why Immutable Tags in Production

- Ensures reproducibility
- Prevents unexpected updates
- Enables rollbacks
- Makes auditing possible
- `latest` tag can change unexpectedly

## Anti-Patterns to Avoid

- ❌ Uppercase in repository names: `MyApp` → Use `myapp`
- ❌ Consecutive separators: `my--app` → Use `my-app`
- ❌ Starting with separator: `-myapp`, `_myapp` → Use `myapp`
- ❌ Ending with separator: `myapp-`, `myapp.` → Use `myapp`
- ❌ Using `latest` in production without version tags
- ❌ Reusing version tags (changing `1.0.0` after publishing)
- ❌ Very long names: `my-application-with-very-long-descriptive-name` → Use `myapp`
- ❌ Special characters: `my@app`, `app#1` → Use `my-app`, `app-1`
- ❌ Spaces: `my app` → Use `my-app`
- ❌ Tags that look like commit SHAs alone: `a1b2c3d` → Use `1.0.0-a1b2c3d`

## Image Tagging Examples

### Full Tagging Strategy Example

For version `1.2.3` of `myapp`:

```bash
# Build
docker build -t myapp:1.2.3 .

# Tag with multiple specificity levels
docker tag myapp:1.2.3 myapp:1.2
docker tag myapp:1.2.3 myapp:1
docker tag myapp:1.2.3 myapp:latest

# Tag for registry
docker tag myapp:1.2.3 registry.example.com/team/myapp:1.2.3
docker tag myapp:1.2.3 registry.example.com/team/myapp:latest

# Push all tags
docker push registry.example.com/team/myapp:1.2.3
docker push registry.example.com/team/myapp:latest
```

### Private Registry Example

```bash
# Tag for private registry
docker tag 0e5574283393 myregistryhost:5000/team/myapp:1.0.0

# Push to private registry
docker push myregistryhost:5000/team/myapp:1.0.0
```

## Integration with Other Systems

### Kubernetes

- Image names used in pod specs must follow Docker naming
- Image pull secrets reference registry hostnames
- Image pull policy affected by tag (`:latest` triggers different behavior)

### Docker Compose

```yaml
services:
  web:
    image: myapp:1.0.0
    container_name: myapp-web-1
```

### CI/CD Pipelines

- Build: `myapp:${CI_COMMIT_SHA}`
- Test: `myapp:${CI_COMMIT_SHA}`
- Release: `myapp:${VERSION}` + `myapp:latest`

## References

- Docker CLI Reference: https://docs.docker.com/engine/reference/commandline/docker/
- Distribution Reference (canonical format): https://pkg.go.dev/github.com/distribution/reference
- Docker Hub Naming: https://docs.docker.com/docker-hub/repos/
- Image Naming Best Practices: https://docs.docker.com/develop/dev-best-practices/
