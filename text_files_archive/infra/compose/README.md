# Role-Based Compose Deployment

This directory contains a role-based, scalable deployment structure that supports flexible configurations from monolith to distributed deployments.

## Structure

```
infra/compose/
├── base/           # Base compose files organized by role
│   ├── net.yml           # Network definition
│   ├── storage.yml       # Storage role (postgres, redis, clickhouse, minio)
│   ├── observability.yml # Observability role (langfuse)
│   ├── compute.yml       # Compute role (ollama)
│   ├── gateway.yml       # Gateway role (litellm)
│   └── ui.yml            # UI role (openwebui)
├── targets/        # Target selector files (documentation)
│   ├── mainpc.yml        # Main PC target
│   ├── network.yml       # Network Server target
│   ├── monolith.yml      # Monolith target
│   └── dev.yml           # Dev node target
└── scripts/       # Role-aware deployment scripts
    ├── up-mainpc.sh      # Start Main PC services
    ├── up-network.sh     # Start Network Server services
    ├── up-monolith.sh    # Start all services
    ├── down-mainpc.sh    # Stop Main PC services
    ├── down-network.sh   # Stop Network Server services
    ├── smoke-mainpc.sh   # Test Main PC services
    └── smoke-network.sh  # Test Network Server services
```

## Roles

### Gateway
- **Purpose**: Single stable OpenAI-compatible endpoint
- **Services**: litellm
- **Profile**: `gateway`

### UI
- **Purpose**: Human interaction layer
- **Services**: openwebui
- **Profile**: `ui`

### Compute
- **Purpose**: GPU-bound model execution
- **Services**: ollama
- **Profile**: `compute`

### Observability
- **Purpose**: Traces, sessions, analytics
- **Services**: langfuse, langfuse_worker
- **Profile**: `observability`

### Storage
- **Purpose**: Persistence and durability
- **Services**: postgres, redis, clickhouse, minio
- **Profile**: `storage`

### Network
- **Purpose**: Connectivity contract
- **Services**: Docker network definition
- **Profile**: (always included)

## Deployment Targets

### Main PC (server-225)
- **Profiles**: `gateway`, `compute`, `ui` (optional)
- **Services**: litellm, ollama, openwebui (optional)

### Network Server
- **Profiles**: `observability`, `storage`
- **Services**: langfuse, postgres, redis, clickhouse, minio

### Monolith
- **Profiles**: All profiles
- **Services**: All services on one host

### Dev Node (dev-3090)
- **Profiles**: `compute`, `gateway` (optional)
- **Services**: ollama, litellm (optional)

## Usage

### Using Scripts

**Main PC:**
```bash
# Start services
./infra/compose/scripts/up-mainpc.sh

# Stop services
./infra/compose/scripts/down-mainpc.sh

# Test services
./infra/compose/scripts/smoke-mainpc.sh
```

**Network Server:**
```bash
# Start services
./infra/compose/scripts/up-network.sh

# Stop services
./infra/compose/scripts/down-network.sh

# Test services
./infra/compose/scripts/smoke-network.sh
```

**Monolith:**
```bash
# Start all services
./infra/compose/scripts/up-monolith.sh
```

### Using Docker Compose Directly

```bash
cd infra/compose/base

# Main PC
docker compose -f net.yml -f compute.yml -f gateway.yml -f ui.yml \
    --profile gateway --profile compute --profile ui up -d

# Network Server
docker compose -f net.yml -f storage.yml -f observability.yml \
    --profile storage --profile observability up -d
```

## Contract

The contract file (`infra/contract/contract.env`) defines:
- Host addresses (mainpc, network)
- Port assignments
- Derived URLs for cross-host communication

## Secrets

Secrets are stored per-host in:
- `infra/contract/secrets.mainpc.env`
- `infra/contract/secrets.network.env`
- `infra/contract/secrets.monolith.env`

These files should be:
- Added to `.gitignore`
- Encrypted with Ansible Vault or similar
- Loaded by scripts automatically

## Environment Variables

Services reference URLs via environment variables from the contract:
- `GATEWAY_BASE_URL` - LiteLLM endpoint
- `OLLAMA_BASE_URL` - Ollama endpoint
- `LANGFUSE_BASE_URL` - Langfuse endpoint
- `DATABASE_URL` - Postgres connection string
- `REDIS_URL` - Redis connection string
- `CLICKHOUSE_URL` - ClickHouse connection string

## Migration from Existing Structure

The existing Ansible-based deployment continues to work. This new structure provides:
1. **Flexibility**: Easy to switch between monolith and distributed
2. **Clarity**: Clear role separation
3. **Portability**: Can run without Ansible for local development
4. **Scalability**: Easy to add new roles or split services

## Integration with Ansible

Ansible roles can be updated to:
1. Generate compose files from templates using the base files
2. Use the contract env file for consistent addressing
3. Call the scripts or use compose directly


