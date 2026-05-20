# Research: Langfuse Platform on K3s

**Date:** May 19, 2026  
**Status:** Research Complete  
**Target Deployment:** Langfuse on K3s with Helm and Ansible

---

## Executive Summary

Langfuse provides a community-maintained Helm chart (`langfuse/langfuse-k8s`) for Kubernetes deployment, compatible with K3s. The chart deploys:
- Langfuse web and worker containers
- PostgreSQL (OLTP transactional data)
- ClickHouse (OLAP observability data)
- Redis/Valkey (cache and queue)
- MinIO/S3 (raw events and multi-modal attachments)

**Current Version:** Chart v1.5.29 (May 4, 2026), App v3.162.0  
**Repository:** https://github.com/langfuse/langfuse-k8s  
**Stars:** 231, 95 releases, 50 contributors

---

## 1. Official Langfuse Documentation

### 1.1 Self-Hosting Overview

**Source:** https://langfuse.com/self-hosting

Langfuse architecture consists of:

```mermaid
flowchart TB
    User["UI, API, SDKs"]
    subgraph vpc["VPC"]
        Web["Web Server<br/>(langfuse/langfuse)"]
        Worker["Async Worker<br/>(langfuse/worker)"]
        Postgres["Postgres - OLTP<br/>(Transactional Data)"]
        Cache["Redis/Valkey<br/>(Cache, Queue)"]
        Clickhouse["Clickhouse - OLAP<br/>(Observability Data)"]
        S3["S3 / Blob Storage<br/>(Raw events, multi-modal)"]
    end
    LLM["LLM API/Gateway<br/>(optional)"]

    User --> Web
    Web --> S3
    Web --> Postgres
    Web --> Cache
    Web --> Clickhouse
    Web -.->|"optional for playground"| LLM

    Cache --> Worker
    Worker --> Clickhouse
    Worker --> Postgres
    Worker --> S3
    Worker -.->|"optional for evals"| LLM
```

**Key Requirements:**
- All infrastructure components must run with timezone set to **UTC** (non-UTC causes incorrect queries)
- Internet access is optional (can deploy in VPC or on-premises)
- Optimized for production with queued ingestion, caching, OLAP offloading

### 1.2 Kubernetes (Helm) Deployment Guide

**Source:** https://langfuse.com/self-hosting/deployment/kubernetes-helm

**Installation Steps:**

```bash
# Add Helm repository
helm repo add langfuse https://langfuse.github.io/langfuse-k8s
helm repo update

# Create namespace
kubectl create namespace langfuse

# Install chart
helm install langfuse langfuse/langfuse -n langfuse
```

**Deployment Timeline:**
- Initial deployment: up to 5 minutes
- Web and worker containers restart during database provisioning
- Monitor: `kubectl get pods -n langfuse`

**Upgrade Process:**

```bash
helm repo update
helm upgrade langfuse langfuse/langfuse -n langfuse
```

**Cleanup:**

```bash
helm uninstall langfuse -n langfuse
kubectl delete namespace langfuse
```

---

## 2. Helm Chart Configuration

### 2.1 Chart Dependencies (from README)

**Source:** https://github.com/langfuse/langfuse-k8s/blob/main/charts/langfuse/README.md

```yaml
requirements:
  - oci://registry-1.docker.io/bitnamicharts/clickhouse:8.0.5
  - oci://registry-1.docker.io/bitnamicharts/common:2.30.0
  - oci://registry-1.docker.io/bitnamicharts/postgresql:16.4.9
  - oci://registry-1.docker.io/bitnamicharts/redis:2.2.4  # (valkey)
  - oci://registry-1.docker.io/bitnamicharts/s3:14.10.5  # (minio)
```

**Important Note:** As of August 28, 2025, Bitnami restructured its registry. Chart now uses `bitnamilegacy/*` images by default to prevent deployment failures.

### 2.2 Required Configuration Values

**Minimal required values.yaml configuration:**

```yaml
langfuse:
  # Required secrets
  salt:
    value: ""  # Generate: openssl rand -base64 32
  
  nextauth:
    secret:
      value: ""  # NextAuth JWT encryption
    url: "http://localhost:3000"  # Set to production URL
  
  encryptionKey:
    value: ""  # Generate: openssl rand -hex 32 (256-bit)

# Database authentication
postgresql:
  auth:
    username: langfuse
    password: ""  # Required

clickhouse:
  auth:
    username: default
    password: ""  # Required

redis:
  auth:
    username: default
    password: ""  # Required (set to null for passwordless)

# MinIO/S3 configuration
s3:
  auth:
    rootUser: "minio"
    rootPassword: ""  # Required
```

### 2.3 Secret Management Patterns

**Two approaches supported:**

1. **Direct value assignment:**
   ```yaml
   langfuse:
     salt:
       value: "your-secret-value"
   ```

2. **Existing Kubernetes Secret reference:**
   ```yaml
   langfuse:
     salt:
       secretKeyRef:
         name: "langfuse-secrets"
         key: "salt"
   ```

**Available secret fields:**
- `langfuse.salt` - API key hashing
- `langfuse.nextauth.secret` - JWT encryption
- `langfuse.encryptionKey` - Sensitive data encryption (256-bit hex)
- `langfuse.licenseKey` - EE license
- `postgresql.auth.password` / `existingSecret`
- `clickhouse.auth.password` / `existingSecret`
- `redis.auth.password` / `existingSecret`
- `s3.auth.rootPassword` / `existingSecret`

### 2.4 External Data Store Configuration

**All data stores can be replaced with external instances:**

```yaml
# Use external PostgreSQL
postgresql:
  deploy: false
  host: "external-postgres.example.com"
  port: 5432
  directUrl: ""  # Connection string for migrations
  shadowDatabaseUrl: ""  # Required if user lacks CREATE DATABASE

# Use external ClickHouse
clickhouse:
  deploy: false
  host: "external-clickhouse.example.com"
  httpPort: 8123
  nativePort: 9000
  migration:
    autoMigrate: true
    ssl: false

# Use external Redis
redis:
  deploy: false
  host: "external-redis.example.com"
  port: 6379

# Use external S3
s3:
  deploy: false
  endpoint: "https://s3.amazonaws.com"
  bucket: "langfuse-storage"
  region: "us-east-1"
```

### 2.5 Production Resource Recommendations

**From chart documentation:**

```yaml
clickhouse:
  replicaCount: 3
  resourcesPreset: "2xlarge"
  # Recommended: 2 CPU, 8Gi memory per replica
  zookeeper:
    # Recommended: 2 CPU, 4Gi memory

redis:
  architecture: standalone
  # Recommended: 1 CPU, 1.5Gi memory

langfuse:
  web:
    replicas: 1  # Scale via HPA/KEDA
  worker:
    replicas: 1  # Scale via HPA/KEDA
```

### 2.6 Scaling Options

**Horizontal Pod Autoscaler (HPA):**

```yaml
langfuse:
  web:
    hpa:
      enabled: true
      minReplicas: 1
      maxReplicas: 5
      targetCPUUtilizationPercentage: 50
```

**KEDA (Kubernetes Event-Driven Autoscaling):**

```yaml
langfuse:
  web:
    keda:
      enabled: true
      minReplicas: 1
      maxReplicas: 5
      triggerType: "cpu"  # or "memory"
      value: "50"
```

**Note:** Cannot enable both HPA and KEDA simultaneously.

### 2.7 Ingress Configuration

```yaml
langfuse:
  ingress:
    enabled: true
    className: "nginx"  # Or traefik for K3s
    hosts:
      - host: "langfuse.example.com"
        paths:
          - path: /
            pathType: ImplementationSpecific
    tls:
      enabled: true
      secretName: "langfuse-tls"
```

---

## 3. K3s-Specific Considerations

### 3.1 K3s Persistent Storage

**Source:** https://docs.k3s.io/add-ons/storage

**Default K3s Storage:**
- K3s includes Rancher Local Path Provisioner by default
- Namespace: `local-path-storage`
- Storage class: `local-path`
- Default path: `/opt/local-path-provisioner`
- Access mode: `ReadWriteOnce`
- Latest version: v0.0.35 (March 10, 2026)

**Helm Installation (if needed):**

```bash
helm repo add local-path-provisioner https://rancher.github.io/local-path-provisioner/
helm install local-path-provisioner local-path-provisioner/local-path-provisioner \
  --namespace local-path-storage \
  --create-namespace
```

**Configuration via ConfigMap:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-path-config
  namespace: local-path-storage
data:
  config.json: |
    {
      "nodePathMap": [
        {
          "node": "DEFAULT_PATH_FOR_NON_LISTED_NODES",
          "paths": ["/opt/local-path-provisioner"]
        }
      ]
    }
```

**Use Cases:**
- ✅ Development, testing
- ✅ Single-replica databases
- ✅ Local caches
- ✅ CI/CD workloads
- ❌ Production data requiring replication
- ❌ Distributed storage requirements

**K3s Traefik Ingress:**
- K3s ships with Traefik as default ingress controller
- Set `langfuse.ingress.className: "traefik"` in values

### 3.2 MinIO on K3s

**Source:** https://github.com/minio/minio/blob/master/helm/minio/README.md

**MinIO Helm Installation:**

```bash
helm repo add minio https://charts.min.io/
helm install minio minio/minio \
  --namespace minio \
  --create-namespace \
  --set rootUser=rootuser \
  --set rootPassword=rootpass123 \
  --set persistence.storageClass=local-path
```

**Key Configuration:**

```yaml
persistence:
  enabled: true
  storageClass: "local-path"
  size: 10Gi

mode: standalone  # or distributed for HA

resources:
  requests:
    memory: 512Mi
    cpu: 250m
```

**Important Notes:**
- MinIO recommends using `direct-csi` for production
- For K3s testing, `local-path` storage class works
- Set `--set persistence.enabled=false` for ephemeral testing
- Requires Kubernetes v1.19 or later

**Production Recommendation:**
Use MinIO Kubernetes Operator and Tenant Helm Chart for production deployments.

---

## 4. Ansible Automation for Helm Deployment

### 4.1 kubernetes.core Collection

**Source:** https://docs.ansible.com/ansible/latest/collections/kubernetes/core/

**Installation:**

```bash
ansible-galaxy collection install kubernetes.core
```

**Requirements:**
- Ansible 2.16.0 or newer
- Helm v3.x or newer
- Python kubernetes library (>= 24.2.0)

### 4.2 kubernetes.core.helm Module

**Source:** https://docs.ansible.com/ansible/latest/collections/kubernetes/core/helm_module.html

**Basic Langfuse Deployment Example:**

```yaml
---
- name: Deploy Langfuse on K3s
  hosts: k3s_control_plane
  gather_facts: false
  collections:
    - kubernetes.core
  tasks:
    - name: Add Langfuse Helm repository
      kubernetes.core.helm_repository:
        name: langfuse
        repo_url: https://langfuse.github.io/langfuse-k8s
        state: present

    - name: Create langfuse namespace
      kubernetes.core.k8s:
        name: langfuse
        api_version: v1
        kind: Namespace
        state: present

    - name: Deploy Langfuse Helm chart
      kubernetes.core.helm:
        name: langfuse
        chart_ref: langfuse/langfuse
        release_namespace: langfuse
        create_namespace: true
        chart_version: "1.5.29"
        release_state: present
        values:
          langfuse:
            salt:
              value: "{{ vault_langfuse_salt }}"
            nextauth:
              secret:
                value: "{{ vault_langfuse_nextauth_secret }}"
              url: "https://langfuse.example.com"
            encryptionKey:
              value: "{{ vault_langfuse_encryption_key }}"
          postgresql:
            auth:
              username: langfuse
              password: "{{ vault_langfuse_postgres_password }}"
          clickhouse:
            auth:
              password: "{{ vault_langfuse_clickhouse_password }}"
          redis:
            auth:
              password: "{{ vault_langfuse_redis_password }}"
          s3:
            auth:
              rootUser: minio
              rootPassword: "{{ vault_langfuse_minio_password }}"
```

### 4.3 Ansible Vault Secret Management

**Source:** https://oneuptime.com/blog/post/2026-02-21-ansible-kubernetes-secrets/

**Pattern 1: Ansible Vault + Direct Values**

1. Create encrypted vault file:
   ```bash
   ansible-vault create vault/langfuse_secrets.yml
   ```

2. Store secrets in vault:
   ```yaml
   vault_langfuse_salt: "generated-salt-value"
   vault_langfuse_nextauth_secret: "generated-secret"
   vault_langfuse_encryption_key: "64-char-hex-string"
   vault_langfuse_postgres_password: "secure-password"
   vault_langfuse_clickhouse_password: "secure-password"
   vault_langfuse_redis_password: "secure-password"
   vault_langfuse_minio_password: "secure-password"
   ```

3. Reference in playbook via Jinja templating (see above)

4. Run with vault password:
   ```bash
   ansible-playbook deploy_langfuse.yaml --ask-vault-pass
   ```

**Pattern 2: Kubernetes Secret + Secret References**

1. Create Kubernetes Secret:
   ```yaml
   - name: Create Langfuse secrets in Kubernetes
     kubernetes.core.k8s:
       state: present
       definition:
         apiVersion: v1
         kind: Secret
         metadata:
           name: langfuse-secrets
           namespace: langfuse
         type: Opaque
         stringData:  # Use stringData for automatic base64 encoding
           salt: "{{ vault_langfuse_salt }}"
           nextauth-secret: "{{ vault_langfuse_nextauth_secret }}"
           encryption-key: "{{ vault_langfuse_encryption_key }}"
   ```

2. Reference in Helm values:
   ```yaml
   values:
     langfuse:
       salt:
         secretKeyRef:
           name: langfuse-secrets
           key: salt
       nextauth:
         secret:
           secretKeyRef:
             name: langfuse-secrets
             key: nextauth-secret
   ```

**Best Practice:** Use Ansible Vault to encrypt the vault file in version control, and only decrypt during deployment.

### 4.4 kubernetes.core.k8s Module for Secrets

**Module Capabilities:**
- Create/update/delete Kubernetes objects
- Supports inline definitions or source files
- Accepts Jinja templates
- Works with vault-encrypted files
- CRUD operations via Kubernetes Python client

**Creating Opaque Secrets (recommended approach):**

```yaml
- name: Create database secrets
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Secret
      metadata:
        name: langfuse-db-secrets
        namespace: langfuse
      type: Opaque
      stringData:  # Preferred over data - auto base64 encoding
        postgres-password: "{{ vault_langfuse_postgres_password }}"
        clickhouse-password: "{{ vault_langfuse_clickhouse_password }}"
        redis-password: "{{ vault_langfuse_redis_password }}"
```

**Note:** Use `stringData` instead of `data` to avoid manual base64 encoding - Kubernetes handles it automatically.

### 4.5 Complete Ansible Role Structure Example

```
roles/langfuse_platform/
├── defaults/
│   └── main.yml           # Default values
├── tasks/
│   ├── main.yml          # Entry point
│   ├── prerequisites.yml # Namespace, storage checks
│   ├── secrets.yml       # Create K8s secrets
│   ├── helm_deploy.yml   # Helm chart deployment
│   └── verify.yml        # Post-deployment checks
├── templates/
│   └── values.yaml.j2    # Helm values template
├── vars/
│   └── main.yml          # Non-secret variables
└── README.md
```

**Example tasks/main.yml:**

```yaml
---
- name: Include prerequisites
  ansible.builtin.include_tasks: prerequisites.yml
  tags: [prerequisites, langfuse]

- name: Include secrets configuration
  ansible.builtin.include_tasks: secrets.yml
  tags: [secrets, langfuse]

- name: Include Helm deployment
  ansible.builtin.include_tasks: helm_deploy.yml
  tags: [deploy, langfuse]

- name: Include verification tasks
  ansible.builtin.include_tasks: verify.yml
  tags: [verify, langfuse]
```

---

## 5. Dependency Setup Guides

### 5.1 PostgreSQL on K3s

**Default Bitnami PostgreSQL (from Langfuse chart):**

```yaml
postgresql:
  deploy: true
  image:
    repository: bitnamilegacy/postgresql
  architecture: standalone
  primary:
    service:
      ports:
        postgresql: 5432
```

**External PostgreSQL Configuration:**

```yaml
postgresql:
  deploy: false
  host: "postgres.example.com"
  port: 5432
  auth:
    database: "postgres_langfuse"
    username: "langfuse"
    password: "{{ vault_postgres_password }}"
  migration:
    autoMigrate: true
```

**Important:**
- If user is `postgres`, use `postgresPassword` instead of `password`
- For cloud databases without CREATE DATABASE permission, configure `shadowDatabaseUrl`

### 5.2 ClickHouse on K3s

**Default Bitnami ClickHouse (from Langfuse chart):**

```yaml
clickhouse:
  deploy: true
  image:
    repository: bitnamilegacy/clickhouse
  replicaCount: 3  # HA setup
  shards: 1
  clusterEnabled: true
  resourcesPreset: "2xlarge"
  zookeeper:
    image:
      repository: bitnamilegacy/zookeeper
```

**External ClickHouse Configuration:**

```yaml
clickhouse:
  deploy: false
  host: "clickhouse.example.com"
  httpPort: 8123
  nativePort: 9000
  database: "default"
  auth:
    username: "default"
    password: "{{ vault_clickhouse_password }}"
  migration:
    autoMigrate: true
    ssl: false
    url: ""  # TCP protocol migration URL
```

**Production Sizing:**
- ClickHouse: 2 CPU, 8Gi memory per replica
- ZooKeeper: 2 CPU, 4Gi memory

### 5.3 Redis/Valkey on K3s

**Default Bitnami Valkey (from Langfuse chart):**

```yaml
redis:
  deploy: true
  image:
    repository: bitnamilegacy/valkey
  architecture: standalone
  auth:
    username: default
    password: "{{ vault_redis_password }}"
  primary:
    extraFlags:
      - "--maxmemory-policy noeviction"  # Required!
```

**Important:** `--maxmemory-policy noeviction` is mandatory for Langfuse.

**External Redis Configuration:**

```yaml
redis:
  deploy: false
  host: "redis.example.com"
  port: 6379
  auth:
    database: 0
    username: "default"
    password: "{{ vault_redis_password }}"  # null for passwordless
```

**Redis Cluster Mode:**

```yaml
redis:
  deploy: false
  cluster:
    enabled: true
    nodes:
      - "redis-1:6379"
      - "redis-2:6379"
      - "redis-3:6379"
```

**Redis Sentinel Mode:**

```yaml
redis:
  deploy: false
  sentinel:
    enabled: true
    masterName: "mymaster"
    nodes: "sentinel-1:26379,sentinel-2:26379,sentinel-3:26379"
    username: ""  # optional
    password: ""  # optional
```

**TLS Support:**

```yaml
redis:
  tls:
    enabled: true
    caPath: "/path/to/ca.crt"
    certPath: "/path/to/client.crt"
    keyPath: "/path/to/client.key"
```

**Production Sizing:**
- Redis Primary: 1 CPU, 1.5Gi memory

### 5.4 MinIO/S3 Storage on K3s

**Default Bitnami MinIO (from Langfuse chart):**

```yaml
s3:
  deploy: true
  image:
    repository: bitnamilegacy/minio
  defaultBuckets: "langfuse"
  auth:
    rootUser: "minio"
    rootPassword: "{{ vault_minio_password }}"
  forcePathStyle: true  # Required for MinIO
```

**Storage Upload Types:**

Langfuse configures S3 for three upload types:

1. **Media Upload:** User-uploaded multi-modal content
2. **Batch Export:** Large data exports
3. **Event Upload:** Raw event storage

**Per-upload-type configuration:**

```yaml
s3:
  # Global defaults
  endpoint: "http://minio.minio.svc.cluster.local:9000"
  bucket: "langfuse"
  region: "auto"
  accessKeyId:
    value: "minio"
  secretAccessKey:
    value: "{{ vault_minio_password }}"
  
  # Media uploads
  mediaUpload:
    enabled: true
    bucket: "langfuse-media"
    maxContentLength: 1000000000  # 1GB
    downloadUrlExpirySeconds: 3600
  
  # Batch exports
  batchExport:
    enabled: true
    bucket: "langfuse-exports"
    prefix: "exports/"
  
  # Event uploads
  eventUpload:
    bucket: "langfuse-events"
    prefix: "events/"
```

**External S3 Configuration:**

```yaml
s3:
  deploy: false
  endpoint: "https://s3.amazonaws.com"
  bucket: "my-langfuse-bucket"
  region: "us-east-1"
  forcePathStyle: false
  accessKeyId:
    value: "AWS_ACCESS_KEY"
  secretAccessKey:
    value: "{{ vault_aws_secret_key }}"
```

**GCS (Google Cloud Storage) Support:**

```yaml
s3:
  gcs:
    credentials:
      value: "{{ vault_gcs_service_account_json }}"
      # Or use secretKeyRef
```

**Concurrency Controls:**

```yaml
s3:
  concurrency:
    reads: 50
    writes: 50
```

---

## 6. Storage and Secrets Patterns

### 6.1 Persistent Volume Claims

**Langfuse dependencies auto-create PVCs:**

- PostgreSQL: `data-langfuse-postgresql-0`
- ClickHouse: `data-langfuse-clickhouse-shard0-X` (per replica)
- MinIO: `export-langfuse-s3-0`

**K3s Local Path Provisioner handles these automatically with `local-path` storage class.**

**Custom Storage Class Configuration:**

```yaml
postgresql:
  primary:
    persistence:
      storageClass: "local-path"
      size: 20Gi

clickhouse:
  persistence:
    storageClass: "local-path"
    size: 100Gi

s3:
  persistence:
    storageClass: "local-path"
    size: 50Gi
```

### 6.2 Secret Generation and Rotation

**Required Secret Generation Commands:**

```bash
# Langfuse salt (base64, 32 bytes)
openssl rand -base64 32

# Langfuse encryption key (hex, 256-bit / 64 characters)
openssl rand -hex 32

# NextAuth secret
openssl rand -base64 32

# Database passwords
openssl rand -base64 24
```

**Ansible Task for Secret Generation:**

```yaml
- name: Generate Langfuse secrets
  ansible.builtin.set_fact:
    generated_salt: "{{ lookup('password', '/dev/null chars=ascii_letters,digits length=44') | b64encode }}"
    generated_encryption_key: "{{ lookup('password', '/dev/null chars=hexdigits length=64') | lower }}"
    generated_nextauth_secret: "{{ lookup('password', '/dev/null chars=ascii_letters,digits length=44') | b64encode }}"
```

### 6.3 Existing Secret References

**Using pre-created Kubernetes Secrets:**

```yaml
langfuse:
  salt:
    secretKeyRef:
      name: langfuse-app-secrets
      key: salt
  nextauth:
    secret:
      secretKeyRef:
        name: langfuse-app-secrets
        key: nextauth-secret
  encryptionKey:
    secretKeyRef:
      name: langfuse-app-secrets
      key: encryption-key

postgresql:
  auth:
    existingSecret: langfuse-db-secrets
    secretKeys:
      userPasswordKey: postgres-password

clickhouse:
  auth:
    existingSecret: langfuse-db-secrets
    existingSecretKey: clickhouse-password

redis:
  auth:
    existingSecret: langfuse-db-secrets
    existingSecretPasswordKey: redis-password

s3:
  auth:
    existingSecret: langfuse-storage-secrets
    rootUserSecretKey: minio-root-user
    rootPasswordSecretKey: minio-root-password
```

---

## 7. Additional Configuration

### 7.1 Feature Flags

```yaml
langfuse:
  features:
    telemetryEnabled: true
    signUpDisabled: false
    experimentalFeaturesEnabled: false
```

### 7.2 Logging Configuration

```yaml
langfuse:
  logging:
    level: info  # trace, debug, info, warn, error, fatal
    format: json  # text or json
```

### 7.3 SMTP Configuration (Optional)

```yaml
langfuse:
  smtp:
    connectionUrl: "smtp://user:pass@smtp.example.com:587"
    fromAddress: "noreply@example.com"
```

### 7.4 Organization Creators (EE Feature)

```yaml
langfuse:
  allowedOrganizationCreators:
    - "user@example.com"
```

### 7.5 Health and Readiness Probes

**Web Container:**

```yaml
langfuse:
  web:
    livenessProbe:
      path: "/api/public/health"
      initialDelaySeconds: 20
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    readinessProbe:
      path: "/api/public/ready"
      initialDelaySeconds: 20
      periodSeconds: 10
      timeoutSeconds: 5
      successThreshold: 1
```

---

## 8. Deployment Verification

### 8.1 Post-Deployment Checks

**Ansible verification tasks:**

```yaml
- name: Wait for Langfuse pods to be ready
  kubernetes.core.k8s_info:
    kind: Pod
    namespace: langfuse
    label_selectors:
      - app.kubernetes.io/name=langfuse
  register: langfuse_pods
  until: langfuse_pods.resources | selectattr('status.phase', 'equalto', 'Running') | list | length > 0
  retries: 30
  delay: 10

- name: Check Langfuse web service
  kubernetes.core.k8s_info:
    kind: Service
    name: langfuse-web
    namespace: langfuse
  register: langfuse_web_service

- name: Display service info
  ansible.builtin.debug:
    msg: "Langfuse web service available at {{ langfuse_web_service.resources[0].spec.clusterIP }}:3000"
```

### 8.2 Port Forwarding for Testing

```bash
kubectl port-forward svc/langfuse-web -n langfuse 3000:3000
```

Access UI at: http://localhost:3000

### 8.3 Component Status Checks

```bash
# Check all pods
kubectl get pods -n langfuse

# Check services
kubectl get services -n langfuse

# Check PVCs
kubectl get pvc -n langfuse

# View logs
kubectl logs -n langfuse deployment/langfuse-web
kubectl logs -n langfuse deployment/langfuse-worker
```

---

## 9. Langfuse MCP Server Documentation Access

**Source:** Langfuse skill (`/Users/joshc/.cursor/skills-cursor/langfuse/SKILL.md`)

The Langfuse MCP server provides three methods for documentation access:

### 9.1 Documentation Index (llms.txt)

```bash
curl -s https://langfuse.com/llms.txt
```

Returns structured list of all documentation pages with titles and URLs.

### 9.2 Fetch Individual Pages as Markdown

```bash
curl -s "https://langfuse.com/docs/observability/overview.md"
# Or with header:
curl -s "https://langfuse.com/docs/observability/overview" -H "Accept: text/markdown"
```

### 9.3 Search Documentation

```bash
curl -s "https://langfuse.com/api/search-docs?query=How+do+I+trace+LangGraph+agents"
```

Returns JSON with matching documents from docs, GitHub issues, and discussions.

**Recommended Workflow:**
1. Start with llms.txt to find relevant pages
2. Fetch specific pages when identified
3. Fall back to search for unclear topics or context

---

## 10. Summary and Next Steps

### 10.1 What We Know

✅ **Official Helm Chart:** Community-maintained, actively developed (v1.5.29 as of May 2026)  
✅ **K3s Compatibility:** Works with default local-path-provisioner  
✅ **Ansible Automation:** kubernetes.core collection supports Helm and K8s secrets  
✅ **Secret Management:** Two patterns available (vault + direct values, or vault + K8s secrets)  
✅ **External Data Stores:** All dependencies can be replaced with external services  
✅ **Production Patterns:** HPA/KEDA scaling, resource recommendations documented  
✅ **Documentation Access:** Multiple methods via Langfuse MCP server and web docs

### 10.2 Recommended Ansible Implementation Pattern

1. **Role Structure:** `roles/langfuse_platform/` with separate task files
2. **Secret Management:** Ansible Vault → Kubernetes Secrets → Helm secretKeyRef
3. **Helm Deployment:** kubernetes.core.helm with templated values.yaml
4. **Dependencies:** Use bundled Bitnami charts for initial deployment, migrate to external later
5. **Storage:** K3s local-path-provisioner for dev/test, plan migration path for prod
6. **Verification:** Include post-deployment health checks and service readiness

### 10.3 Open Questions for Implementation

- Preferred ingress configuration (Traefik vs nginx-ingress on K3s)?
- TLS certificate management strategy (cert-manager, manual, let's encrypt)?
- Monitoring and observability integration (Prometheus, Grafana)?
- Backup strategy for PostgreSQL, ClickHouse, and S3 data?
- Multi-environment configuration (dev/staging/prod values)?

### 10.4 Next Implementation Steps

1. Create `roles/langfuse_platform/` role structure
2. Define vault variables in `vault/langfuse_secrets.yml`
3. Create Helm values template at `templates/values.yaml.j2`
4. Implement prerequisite tasks (namespace, storage class verification)
5. Implement secret creation tasks
6. Implement Helm deployment tasks
7. Add verification and health check tasks
8. Create playbook `playbooks/deploy_langfuse.yaml`
9. Test on K3s cluster
10. Document operational runbook

---

## Sources Checked

- Langfuse self-hosting overview: https://langfuse.com/self-hosting
- Langfuse Kubernetes Helm guide: https://langfuse.com/self-hosting/deployment/kubernetes-helm
- Langfuse Helm chart repository: https://github.com/langfuse/langfuse-k8s
- Langfuse Helm chart README: https://github.com/langfuse/langfuse-k8s/blob/main/charts/langfuse/README.md
- Langfuse Helm values.yaml: https://github.com/langfuse/langfuse-k8s/blob/main/charts/langfuse/values.yaml
- Ansible kubernetes.core collection: https://docs.ansible.com/ansible/latest/collections/kubernetes/core/
- Ansible kubernetes.core.helm module: https://docs.ansible.com/ansible/latest/collections/kubernetes/core/helm_module.html
- Ansible Kubernetes secrets management: https://oneuptime.com/blog/post/2026-02-21-ansible-kubernetes-secrets/
- K3s storage documentation: https://docs.k3s.io/add-ons/storage
- Rancher local-path-provisioner: https://github.com/rancher/local-path-provisioner/
- MinIO Helm chart: https://github.com/minio/minio/blob/master/helm/minio/README.md
- Langfuse MCP skill: `/Users/joshc/.cursor/skills-cursor/langfuse/SKILL.md`

---

**Research completed:** May 19, 2026  
**Ready for implementation planning**
