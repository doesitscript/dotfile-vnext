# Deployment Contract

This directory contains the deployment contract - stable addresses, ports, and URLs that services use to communicate.

## Files

### `contract.env`
Non-secret contract file defining:
- Host addresses (mainpc, network, dev)
- Port assignments
- Derived URLs for cross-host communication

This file can be committed to git as it contains no secrets.

### `secrets.*.env`
Per-host secret files (not committed):
- `secrets.mainpc.env` - Secrets for Main PC (API keys, passwords)
- `secrets.network.env` - Secrets for Network Server (database passwords, etc.)
- `secrets.monolith.env` - Secrets for monolith deployment

## Usage

Scripts automatically load:
1. `contract.env` (always)
2. `secrets.<host>.env` (if available)

## Example Secrets File

```bash
# secrets.mainpc.env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
WEBUI_SECRET_KEY=...
```

```bash
# secrets.network.env
POSTGRES_USER=langfuse
POSTGRES_PASSWORD=...
POSTGRES_DB=langfuse
NEXTAUTH_SECRET=...
SALT=...
LANGFUSE_PUBLIC_KEY=pk-...
LANGFUSE_SECRET_KEY=sk-...
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=...
MINIO_ACCESS_KEY=...
MINIO_SECRET_KEY=...
```

## Addressing Strategy

The contract uses hostnames by default:
- `mainpc` → server-225
- `network` → network-server
- `dev` → dev-3090

**To use hostnames:**
1. Add entries to `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
   ```
   192.168.50.158 mainpc server-225
   192.168.50.38 network network-server
   192.168.50.191 dev dev-3090
   ```

**To use IPs:**
Update `contract.env` to use IP addresses directly:
```bash
MAINPC_HOST=192.168.50.158
NETWORK_HOST=192.168.50.38
```

## Contract Stability

The contract is designed to be stable:
- URLs don't change when services move between hosts
- Port assignments are consistent
- Service names are stable

This allows you to:
- Start with monolith (all on one host)
- Split to distributed (mainpc + network)
- Scale later (multiple gateways, dedicated UI host)

Without changing application code or configuration.


