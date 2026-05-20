# Research: LiteLLM Gateway

**Research Date:** 2026-05-19  
**Purpose:** Documentation research for deploying LiteLLM as unified OpenAI-compatible gateway on K3s with Ansible automation

---

## Executive Summary

LiteLLM is an open-source proxy that provides a unified OpenAI-compatible API gateway for routing requests across multiple LLM providers. Key capabilities include:

- **OpenAI API Compatibility:** 100% OpenAI-compatible endpoints
- **Multi-Provider Support:** Route to Azure OpenAI, AWS Bedrock, GCP Vertex AI, Anthropic, Groq, vLLM, and 100+ providers
- **Intelligent Routing:** Load balancing, fallback chains, rate limit tracking, health checks
- **Production-Ready:** Kubernetes/Helm deployment, database backend for key management, Redis for distributed state
- **Observability:** Native Langfuse integration for tracing and monitoring

---

## Official Documentation Sources

### Primary Documentation
- **Official Docs:** https://docs.litellm.ai/
- **Proxy Deployment:** https://docs.litellm.ai/docs/proxy/deploy
- **Docker Quick Start:** https://docs.litellm.ai/docs/proxy/docker_quick_start
- **Configuration Reference:** https://docs.litellm.ai/docs/proxy/configs
- **Routing & Load Balancing:** https://docs.litellm.ai/docs/routing

### GitHub Repository
- **Main Repo:** https://github.com/BerriAI/litellm
- **Helm Chart:** https://github.com/BerriAI/litellm/tree/main/deploy/charts/litellm-helm
- **Docker Images:** https://github.com/orgs/BerriAI/packages

### Community Resources
- **2026 Production Guide:** [Run Free LLMs at Scale: LiteLLM Gateway](https://stevescargall.com/blog/2026/04/run-free-llms-at-scale-litellm-gateway-with-groq-nvidia-nim-openrouter-and-local-vllm/)

---

## Kubernetes/K3s Deployment

### Official Kubernetes Support

LiteLLM provides official Kubernetes deployment through multiple methods:

#### 1. Helm Chart (Recommended)
- **Chart Location:** `ghcr.io/berriai/litellm-helm`
- **Requirements:** Kubernetes 1.21+, Helm 3.8.0+
- **Community-maintained** but officially supported

**Installation:**
```bash
# Pull chart
helm pull oci://docker.litellm.ai/berriai/litellm-helm

# Unzip
tar -zxvf litellm-helm-0.1.2.tgz

# Install
helm install lite-helm ./litellm-helm

# Expose service
kubectl port-forward $POD_NAME 8080:4000
```

**Key Features:**
- Configurable replica counts
- Master key management via Kubernetes Secrets
- ConfigMap integration for environment variables
- Persistent volume support for config files

#### 2. Raw Kubernetes Manifests

**Example Deployment:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: litellm-config-file
data:
  config.yaml: |
    model_list:
      - model_name: gpt-4o
        litellm_params:
          model: azure/gpt-4o-deployment
          api_base: https://my-endpoint.openai.azure.com/
          api_key: os.environ/AZURE_API_KEY
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: litellm-secrets
data:
  AZURE_API_KEY: <base64-encoded-key>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litellm-deployment
spec:
  selector:
    matchLabels:
      app: litellm
  template:
    metadata:
      labels:
        app: litellm
    spec:
      containers:
      - name: litellm
        image: docker.litellm.ai/berriai/litellm:main-stable
        args:
          - "--config"
          - "/app/proxy_server_config.yaml"
        ports:
        - containerPort: 4000
        volumeMounts:
        - name: config-volume
          mountPath: /app/proxy_server_config.yaml
          subPath: config.yaml
        envFrom:
        - secretRef:
            name: litellm-secrets
      volumes:
      - name: config-volume
        configMap:
          name: litellm-config-file
```

**Best Practices:**
- Use SHA digests or specific versions instead of `:main-stable` for production
- Mount config as read-only
- Use Secrets for all API keys
- Set resource limits and requests

### Production Kubernetes Configuration

**Minimum Specifications (per pod):**
- **CPU:** 4 vCPU
- **Memory:** 8 GB RAM

**Worker Configuration:**
Match Uvicorn workers to pod CPU count:
```bash
--num_workers $(nproc)
```

**Optional Worker Recycling:**
```bash
--max_requests_before_restart 10000
```
Use Gunicorn for more stable recycling.

**Database Connection Pooling:**
Calculate total connections carefully:
```
MAX_DB_CONNECTIONS / (instances × workers)
```

### Multi-Pod Deployments

**Shared Health Check State:**
For multi-pod deployments, coordinate health checks via Redis to avoid duplicate checks:

```yaml
router_settings:
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
  redis_password: <password>
```

**Redis Performance:**
Use individual `host`, `port`, `password` parameters rather than `redis_url` (reportedly 80 RPS faster).

---

## Configuration Management

### Config.yaml Structure

```yaml
# ── MODEL LIST ────────────────────────────────────────
model_list:
  - model_name: gpt-4o                    # Client-facing name
    litellm_params:
      model: azure/my-deployment          # <provider>/<model>
      api_base: os.environ/AZURE_API_BASE
      api_key: os.environ/AZURE_API_KEY
      api_version: "2025-01-01-preview"
      rpm: 60                              # Rate limit: requests/min
      tpm: 100000                          # Rate limit: tokens/min

# ── ROUTER SETTINGS ───────────────────────────────────
router_settings:
  routing_strategy: "simple-shuffle"      # Recommended default
  num_retries: 2
  retry_after: 5
  allowed_fails: 3
  cooldown_time: 86400                     # 24 hours
  
  # Fallback chains
  fallbacks:
    - {"azure/gpt-4o": ["groq/llama-3.1-8b", "openai/gpt-4o"]}

  # Redis for distributed state
  redis_host: redis.default.svc.cluster.local
  redis_port: 6379
  redis_password: os.environ/REDIS_PASSWORD

# ── GENERAL SETTINGS ──────────────────────────────────
general_settings:
  master_key: sk-1234                      # Admin key
  database_url: postgresql://...           # Postgres for key mgmt
  store_model_in_db: false
  
  # Background health checks
  background_health_checks: true
  health_check_interval: 300               # 5 minutes
  enable_health_check_routing: true

# ── LITELLM SETTINGS ──────────────────────────────────
litellm_settings:
  drop_params: true                        # Drop unsupported params
  set_verbose: false
  request_timeout: 120
  callbacks: ["langfuse_otel"]             # Observability
```

### Configuration from Remote Sources

**S3/GCS Bucket:**
```bash
export LITELLM_CONFIG_BUCKET_TYPE="gcs"
export LITELLM_CONFIG_BUCKET_NAME="litellm-proxy"
export LITELLM_CONFIG_BUCKET_OBJECT_KEY="proxy_config.yaml"
```

**Kubernetes ConfigMap:**
Mount as volume (see Kubernetes section above)

### Environment Variables

**Priority:** Environment variables override config.yaml values

**Common Variables:**
```bash
LITELLM_MASTER_KEY=sk-1234
DATABASE_URL=postgresql://...
AZURE_API_KEY=...
OPENAI_API_KEY=...
GROQ_API_KEY=...
REDIS_HOST=redis.default.svc.cluster.local
REDIS_PORT=6379
REDIS_PASSWORD=...
```

---

## Model Routing & Load Balancing

### Routing Strategies

**Available Strategies:**
1. **simple-shuffle** (recommended) — Randomly distributes requests weighted by rpm/tpm
2. **least-busy** — Routes to deployment with fewest active requests
3. **usage-based-routing** — Routes based on lowest RPM/TPM usage
4. **latency-based-routing** — Routes to fastest responding deployment
5. **cost-based-routing** — Routes to lowest cost deployment

**Configuration:**
```yaml
router_settings:
  routing_strategy: "simple-shuffle"
```

### Model Resolution

**How it works:**
1. Client sends request with `model: "gpt-4o"`
2. LiteLLM looks up `model_name: gpt-4o` in config
3. Extracts `litellm_params.model: azure/my-deployment`
4. Routes to Azure with deployment name `my-deployment`

**Model Parameter Format:**
```
model: <provider>/<model-identifier>
       ─────────  ─────────────────
           │             │
           │             └──▶ Model name sent to provider API
           └────────────────▶ Provider routing target
```

### Fallback Chains

**Configuration:**
```yaml
router_settings:
  fallbacks:
    # Primary fails → try these in order
    - {"azure/gpt-4o": ["groq/llama-3.1-8b", "openai/gpt-4o", "anthropic/claude"]}
    
    # Context window fallback
  context_window_fallbacks:
    - {"groq/llama-3.1-8b": ["groq/llama-3.3-70b", "nvidia/llama-3.3-70b"]}
```

**Behavior:**
- Retries same model `num_retries` times
- Falls back to next in chain after exhaustion
- Triggers cooldown after `allowed_fails` consecutive failures

### Rate Limit Management

**Rate Limit Awareness:**
```yaml
model_list:
  - model_name: groq/llama-3.3-70b
    litellm_params:
      model: groq/llama-3.3-70b-versatile
      rpm: 28        # Buffer under 30 RPM limit
      tpm: 11000     # Buffer under 12K TPM limit
```

**What LiteLLM does:**
- Tracks rpm/tpm in-memory
- Pre-emptively avoids scheduling requests that would exceed limits
- Puts model in cooldown after `allowed_fails` consecutive 429s
- Cooldown duration: `cooldown_time` seconds (typically 86400 = 24 hours)

**What LiteLLM does NOT do:**
- Read `x-ratelimit-remaining` headers proactively
- Distinguish between per-minute and daily limits automatically

---

## Provider Integration

### Supported Providers (100+)

**Major Providers:**
- Azure OpenAI
- OpenAI
- AWS Bedrock
- GCP Vertex AI
- Anthropic
- Groq
- Mistral AI
- Cohere
- Together AI
- Hugging Face

**OpenAI-Compatible:**
- vLLM
- Ollama
- LocalAI
- Text Generation Inference (TGI)

### Provider-Specific Configuration

#### vLLM Integration
```yaml
model_list:
  - model_name: "local/qwen"
    litellm_params:
      model: "hosted_vllm/Qwen/Qwen2.5-72B-Instruct"
      api_base: "http://vllm-service:8000/v1"
      api_key: "none"
```

**Supported vLLM Endpoints:**
- `/chat/completions`
- `/embeddings`
- `/completions`
- `/rerank`
- `/audio/transcriptions`

#### Azure OpenAI
```yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: azure/my-deployment
      api_base: os.environ/AZURE_API_BASE
      api_key: os.environ/AZURE_API_KEY
      api_version: "2025-01-01-preview"
```

#### AWS Bedrock
```yaml
model_list:
  - model_name: claude-3
    litellm_params:
      model: bedrock/anthropic.claude-3-sonnet-20240229-v1:0
      aws_region_name: us-east-1
      aws_access_key_id: os.environ/AWS_ACCESS_KEY_ID
      aws_secret_access_key: os.environ/AWS_SECRET_ACCESS_KEY
```

---

## Langfuse Integration

### Overview
LiteLLM integrates with Langfuse for comprehensive observability, tracing, and prompt management.

### Integration Methods

**1. SDK Integration (2 lines of code):**
```python
import litellm

litellm.success_callback = ["langfuse"]
litellm.failure_callback = ["langfuse"]
```

**Environment Variables:**
```bash
LANGFUSE_PUBLIC_KEY=pk-lf-...
LANGFUSE_SECRET_KEY=sk-lf-...
LANGFUSE_HOST=https://cloud.langfuse.com  # or self-hosted
```

**2. Proxy Integration (Recommended):**
```yaml
litellm_settings:
  callbacks: ["langfuse_otel"]  # Use OTEL for Langfuse v3
```

### Advanced Features

**Custom Metadata:**
```python
litellm.completion(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello"}],
    metadata={
        "generation_name": "my-generation",
        "trace_id": "custom-trace-id",
        "user_id": "user-123",
        "tags": ["production", "critical"]
    }
)
```

**Message Redaction:**
For privacy/compliance, redact sensitive content before logging.

**Multi-Region Support:**
- US: `https://cloud.langfuse.com`
- EU: `https://cloud.langfuse.eu`
- Japan: `https://cloud.langfuse.jp`
- HIPAA: Available
- Self-hosted: Configurable

### Observability Capabilities

**What Langfuse Provides:**
- Request/response tracing
- Token usage tracking
- Latency metrics
- Error tracking
- Prompt versioning
- User session tracking
- Cost tracking per model/user/key

---

## Secrets Management

### Kubernetes Secrets Approach

**Best Practices (2026):**
1. Use `stringData` with `kubernetes.core.k8s` module for automatic base64 encoding
2. Integrate Ansible Vault for encrypting variables at rest
3. Group secrets logically by service type

**Ansible Pattern:**
```yaml
- name: Create LiteLLM secrets
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Secret
      metadata:
        name: litellm-secrets
        namespace: default
      type: Opaque
      stringData:
        AZURE_API_KEY: "{{ vault_azure_api_key }}"
        OPENAI_API_KEY: "{{ vault_openai_api_key }}"
        GROQ_API_KEY: "{{ vault_groq_api_key }}"
        DATABASE_URL: "{{ vault_database_url }}"
        LITELLM_MASTER_KEY: "{{ vault_litellm_master_key }}"
```

**Vault File Organization:**
```yaml
# vault.yml (encrypted with ansible-vault)
vault_azure_api_key: "..."
vault_openai_api_key: "..."
vault_groq_api_key: "..."
vault_database_url: "postgresql://..."
vault_litellm_master_key: "sk-..."
```

### Environment Variable Pattern

**In config.yaml:**
```yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      api_key: "os.environ/AZURE_API_KEY"  # Reference env var
```

**In Kubernetes Secret:**
```yaml
stringData:
  AZURE_API_KEY: "actual-key-value"
```

---

## Ansible Automation Patterns

### Role Structure

**Recommended Layout:**
```
roles/litellm_gateway/
├── defaults/main.yml        # Default variables
├── tasks/
│   ├── main.yml            # Entry point
│   ├── namespace.yml       # Create namespace
│   ├── secrets.yml         # Manage secrets
│   ├── configmap.yml       # Deploy config
│   ├── deployment.yml      # Deploy LiteLLM
│   ├── service.yml         # Expose service
│   └── verify.yml          # Health checks
├── templates/
│   ├── config.yaml.j2      # LiteLLM config template
│   ├── deployment.yaml.j2  # K8s deployment
│   ├── service.yaml.j2     # K8s service
│   └── secret.yaml.j2      # K8s secret
├── files/
│   └── helm-values.yaml    # Helm chart values
└── meta/
    └── main.yml            # Dependencies
```

### Example Task: Deploy ConfigMap

```yaml
- name: Create LiteLLM config from template
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: litellm-config
        namespace: "{{ litellm_namespace }}"
      data:
        config.yaml: |
          {{ lookup('template', 'config.yaml.j2') | indent(10) }}
```

### Example Task: Deploy with Helm

```yaml
- name: Install LiteLLM via Helm
  kubernetes.core.helm:
    name: litellm
    chart_ref: oci://docker.litellm.ai/berriai/litellm-helm
    release_namespace: "{{ litellm_namespace }}"
    create_namespace: true
    values:
      replicaCount: 3
      image:
        repository: docker.litellm.ai/berriai/litellm
        tag: "main-v1.83.0"
      resources:
        limits:
          cpu: 4000m
          memory: 8Gi
        requests:
          cpu: 2000m
          memory: 4Gi
      env:
        - name: LITELLM_MASTER_KEY
          valueFrom:
            secretKeyRef:
              name: litellm-secrets
              key: LITELLM_MASTER_KEY
```

### Verification Playbook

```yaml
- name: Verify LiteLLM deployment
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Wait for deployment to be ready
      kubernetes.core.k8s_info:
        kind: Deployment
        name: litellm-deployment
        namespace: default
      register: deployment
      until: deployment.resources[0].status.availableReplicas == 3
      retries: 30
      delay: 10

    - name: Test health endpoint
      uri:
        url: "http://litellm-service.default.svc.cluster.local:4000/health"
        method: GET
        headers:
          Authorization: "Bearer {{ litellm_master_key }}"
        status_code: 200
      register: health_check

    - name: Display healthy endpoints
      debug:
        msg: "Healthy: {{ health_check.json.healthy_count }}, Unhealthy: {{ health_check.json.unhealthy_count }}"
```

---

## Architecture Patterns

### Single-Cluster Deployment

**Simple Pattern:**
```
┌────────────────────────────────────────┐
│          K3s Cluster                   │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  LiteLLM Pod (3 replicas)        │ │
│  │                                  │ │
│  │  ┌──────────┐  ┌──────────┐     │ │
│  │  │ Replica  │  │ Replica  │     │ │
│  │  │    1     │  │    2     │  ...│ │
│  │  └──────────┘  └──────────┘     │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  Redis (state coordination)      │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  PostgreSQL (key management)     │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘
           │
           ▼
    External Providers:
    Azure OpenAI, AWS Bedrock,
    Groq, vLLM, etc.
```

### Multi-Provider Routing

**Intelligent Routing Pattern:**
```
Client Request
      │
      ▼
┌─────────────────┐
│  LiteLLM Proxy  │
│  Port 4000      │
└────┬────────────┘
     │
     ├──▶ Primary: Local vLLM (unlimited, fast)
     │
     ├──▶ Fallback 1: Groq (LPU-accelerated, 14K RPD)
     │
     ├──▶ Fallback 2: Azure OpenAI (enterprise)
     │
     └──▶ Fallback 3: OpenRouter (free models)
```

**Rate Limit Strategy:**
- Declare `rpm`/`tpm` per model
- Set `allowed_fails: 3` with `cooldown_time: 86400`
- Order fallbacks by daily durability (high RPD first)
- Enable background health checks

---

## Production Recommendations

### Resource Requirements

**Per Pod:**
- CPU: 4 vCPU (minimum)
- Memory: 8 GB RAM (minimum)
- Workers: Match CPU count (`--num_workers $(nproc)`)

**Scaling:**
- Start with 3 replicas for HA
- Scale horizontally based on RPS
- Use Redis for shared state across pods

### Database Requirements

**PostgreSQL:**
- Required for virtual key management
- Track spend per user/team/key
- Connection pooling: `MAX_DB_CONNECTIONS / (instances × workers)`

**High-Traffic Deployments (1000+ RPS):**
```yaml
general_settings:
  use_redis_transaction_buffer: true

litellm_settings:
  cache: true
  cache_params:
    type: redis
    host: redis.default.svc.cluster.local
```

### Security Best Practices

1. **Master Key:** Always set `LITELLM_MASTER_KEY` (must start with `sk-`)
2. **Secrets:** Use Kubernetes Secrets + Ansible Vault
3. **Network:** Use NetworkPolicies to restrict pod communication
4. **TLS:** Enable SSL for external endpoints
5. **RBAC:** Limit service account permissions

### Monitoring & Observability

**Health Checks:**
```yaml
general_settings:
  background_health_checks: true
  health_check_interval: 300
  enable_health_check_routing: true
```

**Endpoints:**
- `/health` - Full health check with per-model status
- `/health/liveliness` - Lightweight liveness check

**Langfuse Integration:**
```yaml
litellm_settings:
  callbacks: ["langfuse_otel"]
```

---

## API Reference

### Core Endpoints

**Chat Completions:**
```bash
POST /v1/chat/completions
Authorization: Bearer <master-key>
Content-Type: application/json

{
  "model": "gpt-4o",
  "messages": [{"role": "user", "content": "Hello"}]
}
```

**List Models:**
```bash
GET /v1/models
Authorization: Bearer <master-key>
```

**Health Check:**
```bash
GET /health
Authorization: Bearer <master-key>
```

### Key Management

**Generate Key:**
```bash
POST /key/generate
Authorization: Bearer <master-key>
Content-Type: application/json

{
  "rpm_limit": 60,
  "tpm_limit": 100000,
  "models": ["gpt-4o", "claude-3"],
  "duration": "30d"
}
```

**Response:**
```json
{
  "key": "sk-..."
}
```

---

## Troubleshooting

### Common Issues

**1. Config Mount Error:**
```
Error: IsADirectoryError: [Errno 21] Is a directory: '/app/config.yaml'
```
**Fix:** Delete the directory, create the file, restart:
```bash
docker compose down
sudo rm -rf config.yaml
# Create config.yaml file
docker compose up -d
```

**2. SSL Verification Error:**
```yaml
litellm_settings:
  ssl_verify: false
```

**3. Connection to vLLM Fails:**
- Verify vLLM started with `--host 0.0.0.0`
- Check IP address in config
- Confirm port 8000 is accessible

**4. OpenRouter 401 Errors:**
- With $0 balance, all requests route through Venice (rate-limited)
- Add minimum $5 credit to unlock additional providers
- Free models remain zero-cost

**5. Database Permission Issues:**
```sql
CREATE DATABASE litellm;
GRANT ALL PRIVILEGES ON DATABASE litellm TO your_username;
```

---

## Next Steps

### Implementation Checklist

- [ ] Choose deployment method (Helm vs raw manifests)
- [ ] Set up PostgreSQL database for key management
- [ ] Create Ansible role structure
- [ ] Define model routing configuration
- [ ] Configure Kubernetes secrets
- [ ] Deploy Redis for multi-pod coordination
- [ ] Set up Langfuse for observability
- [ ] Configure rate limits and fallback chains
- [ ] Test health checks and failover
- [ ] Document operator runbook

### Key Decisions Required

1. **Deployment Method:**
   - Helm chart (recommended, easier updates)
   - Raw manifests (more control)

2. **Database:**
   - Managed PostgreSQL (Supabase, Neon)
   - Self-hosted PostgreSQL in cluster

3. **Model Providers:**
   - Primary: vLLM local?
   - Fallbacks: Azure, Groq, OpenRouter?

4. **Observability:**
   - Langfuse Cloud vs self-hosted
   - Additional metrics exporters?

5. **Secret Management:**
   - Sealed Secrets
   - External Secrets Operator
   - Manual Ansible Vault

---

## Sources Checked

1. **LiteLLM Official Docs:**
   - https://docs.litellm.ai/docs/proxy/deploy
   - https://docs.litellm.ai/docs/proxy/docker_quick_start
   - https://docs.litellm.ai/docs/routing
   - https://docs.litellm.ai/docs/proxy/configs

2. **Kubernetes Deployment:**
   - https://github.com/BerriAI/litellm/blob/main/deploy/charts/litellm-helm/README.md

3. **Provider Integration:**
   - https://docs.litellm.ai/docs/providers/vllm
   - https://docs.litellm.ai/docs/providers/openai
   - https://docs.litellm.ai/docs/routing-load-balancing

4. **Langfuse Integration:**
   - https://docs.litellm.ai/docs/observability/langfuse_integration
   - https://langfuse.com/docs/integrations/litellm
   - https://docs.litellm.ai/docs/proxy/logging

5. **Ansible K8s Automation:**
   - https://oneuptime.com/blog/post/2026-02-21-ansible-kubernetes-secrets/view
   - https://oneuptime.com/blog/post/2026-02-21-how-to-use-ansible-to-configure-api-gateways-kong/view
   - https://oneuptime.com/blog/post/2026-02-21-how-to-store-api-keys-in-ansible-vault/view

6. **Production Deployment Guide (2026):**
   - https://stevescargall.com/blog/2026/04/run-free-llms-at-scale-litellm-gateway-with-groq-nvidia-nim-openrouter-and-local-vllm/

---

**Document Version:** 1.0  
**Last Updated:** 2026-05-19  
**Next Review:** Before implementation phase
