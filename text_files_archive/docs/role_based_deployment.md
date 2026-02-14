# Role-Based Deployment Guide

This guide explains the new role-based deployment structure that enables flexible configurations from monolith to distributed deployments.

## Overview

The role-based structure separates services into logical roles and uses Docker Compose profiles to enable different deployment targets without changing service definitions.

## Architecture

### Roles

1. **Gateway** - Single stable OpenAI-compatible endpoint (litellm)
2. **UI** - Human interaction layer (openwebui)
3. **Compute** - GPU-bound model execution (ollama)
4. **Observability** - Traces, sessions, analytics (langfuse)
5. **Storage** - Persistence and durability (postgres, redis, clickhouse, minio)
6. **Network** - Connectivity contract (Docker networks)

### Deployment Targets

#### Monolith (Single Machine)
All services on one host:
- Gateway + UI + Compute + Observability + Storage

#### Split (Current Setup)
- **Main PC (server-225)**: Gateway + Compute + UI (optional)
- **Network Server**: Observability + Storage

#### Scaled (Future)
- Multiple gateway instances
- Dedicated UI host
- Compute nodes (GPU pool)
- Storage/observability HA

## Directory Structure

```
infra/
├── compose/
│   ├── base/              # Base compose files by role
│   │   ├── net.yml
│   │   ├── storage.yml
│   │   ├── observability.yml
│   │   ├── compute.yml
│   │   ├── gateway.yml
│   │   └── ui.yml
│   ├── targets/           # Target documentation
│   └── scripts/           # Deployment scripts
└── contract/
    ├── contract.env       # Non-secret addresses/ports
    └── secrets.*.env      # Per-host secrets (gitignored)
```

## Quick Start

### 1. Setup Contract

Edit `infra/contract/contract.env` to match your network:
```bash
MAINPC_HOST=server-225  # or IP: 192.168.50.158
NETWORK_HOST=network-server  # or IP: 192.168.50.38
```

### 2. Setup Secrets

Create per-host secret files:
```bash
# infra/contract/secrets.mainpc.env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# infra/contract/secrets.network.env
POSTGRES_PASSWORD=...
LANGFUSE_PUBLIC_KEY=pk-...
LANGFUSE_SECRET_KEY=sk-...
```

### 3. Deploy

**Main PC:**
```bash
cd infra/compose/scripts
./up-mainpc.sh
```

**Network Server:**
```bash
cd infra/compose/scripts
./up-network.sh
```

**Monolith (all on one host):**
```bash
cd infra/compose/scripts
./up-monolith.sh
```

## Using with Ansible

The new structure can be integrated with existing Ansible roles:

### Option 1: Use Scripts from Ansible

```yaml
- name: Deploy Main PC services
  shell: |
    cd {{ stacks_root }}/infra/compose/scripts
    ./up-mainpc.sh
```

### Option 2: Generate Compose from Templates

Ansible roles can generate compose files from the base templates, maintaining the role structure while using Ansible for configuration management.

### Option 3: Hybrid Approach

- Use Ansible for initial setup and configuration
- Use compose scripts for day-to-day operations
- Use Ansible for updates and changes

## Migration Path

### Phase 1: Parallel Structure
- New structure exists alongside existing Ansible roles
- Both can coexist
- Test new structure in development

### Phase 2: Gradual Migration
- Update Ansible roles to use new compose files
- Migrate one stack at a time
- Keep existing functionality working

### Phase 3: Full Adoption
- All deployments use role-based structure
- Ansible focuses on configuration, not compose generation
- Compose files become source of truth

## Benefits

1. **Flexibility**: Easy to switch between monolith and distributed
2. **Clarity**: Clear role separation
3. **Portability**: Can run without Ansible for local development
4. **Scalability**: Easy to add new roles or split services
5. **Stability**: Contract ensures URLs don't change when services move

## Examples

### Adding a New Service

1. Add service to appropriate role file in `base/`
2. Add profile to service
3. Update target files if needed
4. Update scripts to include new profile

### Splitting Services

1. Update target files to change which profiles are enabled
2. Update contract.env if addresses change
3. Services automatically adapt via environment variables

### Testing Locally

```bash
# Test monolith locally
cd infra/compose/scripts
./up-monolith.sh
./smoke-mainpc.sh  # Tests all services
```

## Troubleshooting

### Services Can't Connect

1. Check contract.env has correct hostnames/IPs
2. Verify hosts file entries (if using hostnames)
3. Check firewall rules
4. Verify services are using environment variables from contract

### Profile Not Enabled

Make sure scripts enable the correct profiles:
```bash
docker compose -f base/*.yml --profile gateway --profile compute up -d
```

### Secrets Not Loading

1. Check secrets file exists: `secrets.<host>.env`
2. Verify file is readable
3. Check script is loading secrets correctly

## Next Steps

1. Test monolith deployment locally
2. Test split deployment (mainpc + network)
3. Integrate with Ansible roles
4. Add monitoring and health checks
5. Document service-specific configurations


