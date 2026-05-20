# Kubernetes Naming Conventions

## Source

- Official Kubernetes Naming: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/
- Workload Naming: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

## Hard Requirements (MUST)

Kubernetes enforces strict naming constraints based on DNS standards. Every object name must follow one of these specifications:

### DNS Subdomain Names (Most Common)

Most resource types require DNS subdomain names per [RFC 1123](https://tools.ietf.org/html/rfc1123).

**Rules:**
- **Maximum length**: 253 characters
- **Valid characters**: lowercase alphanumeric, `-` (hyphen), `.` (dot)
- **Start with**: alphanumeric character
- **End with**: alphanumeric character
- **No**: uppercase, underscores, spaces, special characters

**Applies to:** Namespaces, Services, ConfigMaps, Secrets, PersistentVolumeClaims, most resources

**Examples:**
- ✅ `my-app`, `web-frontend`, `api.service`, `db-01`
- ❌ `My-App`, `web_frontend`, `-api`, `db-01-`

### RFC 1123 Label Names

Some resource types require RFC 1123 label names (stricter than subdomain).

**Rules:**
- **Maximum length**: 63 characters
- **Valid characters**: lowercase alphanumeric, `-` (hyphen) only
- **Start with**: alphabetic character (NOT numeric)
- **End with**: alphanumeric character
- **No**: dots, underscores, uppercase

**Applies to:** Pod names, ReplicaSet names, StatefulSet names, some label values

**Note:** When `RelaxedServiceNameValidation` feature gate is enabled, Service names can start with digits.

**Examples:**
- ✅ `nginx-pod`, `api-deployment`, `worker-01`
- ❌ `nginx_pod`, `API-deployment`, `1-worker` (starts with number), `worker-`

### RFC 1035 Label Names

Legacy resources may require RFC 1035 label names (even stricter).

**Rules:**
- **Maximum length**: 63 characters
- **Valid characters**: lowercase alphanumeric, `-` (hyphen)
- **Start with**: alphabetic character (stricter than RFC 1123)
- **End with**: alphanumeric character

**Applies to:** Older Kubernetes resources, specific validation contexts

### Path Segment Names

Some resources require names safe for URL path segments.

**Rules:**
- **Cannot be**: `.` or `..`
- **Cannot contain**: `/` or `%`

## Recommendations (SHOULD)

### Naming Patterns for Workloads

**Deployment naming:**
```
<app-name>-<component>
```

Examples:
- `myapp-frontend`
- `myapp-backend`
- `myapp-worker`

**Service naming:**
```
<app-name>-<component>-service
```

Examples:
- `myapp-frontend-service`
- `myapp-api-service`

**ConfigMap/Secret naming:**
```
<app-name>-<component>-<type>
```

Examples:
- `myapp-frontend-config`
- `myapp-backend-secret`
- `myapp-db-credentials`

### Label Conventions

Kubernetes uses labels for selection and grouping. Common label patterns:

**Standard labels:**
```yaml
metadata:
  labels:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp-prod
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/component: frontend
    app.kubernetes.io/part-of: myapp-suite
    app.kubernetes.io/managed-by: helm
```

**Custom labels:**
- Use lowercase
- Use hyphens for multi-word values
- Prefix with domain when appropriate: `myorg.com/team: platform`

### Namespace Naming

**Patterns:**
- By environment: `dev`, `staging`, `prod`
- By team: `platform-team`, `data-team`
- By application: `myapp-prod`, `myapp-dev`

**Reserved namespaces:**
- `default` — default namespace for resources without explicit namespace
- `kube-system` — Kubernetes system resources
- `kube-public` — readable by all users
- `kube-node-lease` — node heartbeat objects

### StatefulSet Naming

StatefulSets create pods with predictable names:

```
<statefulset-name>-<ordinal>
```

Example:
- StatefulSet: `web`
- Pods: `web-0`, `web-1`, `web-2`

**Design implication:** StatefulSet names should be short since pod names include ordinal suffix.

### PersistentVolumeClaim Naming

```
<volume-purpose>-<consumer>-<ordinal>
```

Examples:
- `data-mysql-0`
- `config-nginx-1`
- `cache-redis-master`

## Common Patterns

### Multi-Tier Application

```
myapp-frontend       # Deployment
myapp-backend        # Deployment
myapp-database       # StatefulSet
myapp-cache          # Deployment
myapp-frontend-svc   # Service
myapp-backend-svc    # Service
myapp-db-svc         # Service
myapp-config         # ConfigMap
myapp-secrets        # Secret
```

### Microservices

```
<service-name>-<environment>
```

Examples:
- `user-service-prod`
- `auth-service-staging`
- `payment-service-dev`

### Ingress Resources

```
<app-name>-ingress
```

Examples:
- `myapp-ingress`
- `api-gateway-ingress`
- `frontend-ingress`

## Constraints

| Constraint | Value | Applies To |
|---|---|---|
| Maximum name length | 253 characters | DNS subdomain names |
| Maximum label length | 63 characters | RFC 1123/1035 labels |
| Valid characters | `[a-z0-9.-]` | DNS subdomain |
| Valid characters | `[a-z0-9-]` | RFC 1123/1035 labels |
| Must start with | `[a-z]` | RFC 1123/1035 labels (strict) |
| Must start with | `[a-z0-9]` | DNS subdomain names |
| Must end with | `[a-z0-9]` | All formats |
| Case | Lowercase only | All Kubernetes names |

## Rationale

### Why DNS Compliance

- Kubernetes services create DNS records
- Pod names become DNS entries
- Cross-cluster communication relies on DNS
- Ingress controllers generate DNS names from resource names

### Why Length Limits

- DNS label length limit: 63 characters (RFC 1035)
- DNS FQDN limit: 253 characters
- StatefulSets append ordinals to names
- Labels and selectors use these names

### Why Lowercase Only

- DNS is case-insensitive
- Avoids ambiguity and collisions
- Simplifies tooling and automation
- Universal convention across cloud-native ecosystem

### Why Hyphens Over Underscores

- DNS allows hyphens, not underscores
- Consistency with other cloud-native tools
- Better readability in UIs and logs

## Anti-Patterns to Avoid

- ❌ Using uppercase letters: `MyApp` → Use `myapp`
- ❌ Using underscores: `my_app` → Use `my-app`
- ❌ Starting with hyphen: `-myapp` → Use `myapp`
- ❌ Ending with hyphen: `myapp-` → Use `myapp`
- ❌ Very long names: `my-very-long-application-name-with-many-words` (hard to read, hits limits)
- ❌ Numbers-only names: `123` → Use `app-123`
- ❌ Starting with number for pod names: `1-worker` → Use `worker-1`
- ❌ Special characters: `my@app`, `my.app!` → Use `my-app`
- ❌ Spaces: `my app` → Use `my-app`

## Generated Names

Kubernetes can auto-generate names when `generateName` is used instead of `name`:

```yaml
metadata:
  generateName: myapp-
```

- Server appends a random suffix
- Useful for Jobs, Pods created by controllers
- Example result: `myapp-xk9sd`

## UIDs vs Names

- **Names**: Human-readable, unique within namespace and resource type
- **UIDs**: System-generated, globally unique, never reused
  - Format: UUID (e.g., `d7f8c2a4-3e5f-11e9-b210-d663bd873d93`)
  - Distinguish between historical occurrences of similar entities

## Integration with Other Systems

### DNS Records Created by Kubernetes

**Service DNS:**
```
<service-name>.<namespace>.svc.cluster.local
```

Example: `myapp-frontend.production.svc.cluster.local`

**Pod DNS (when hostname set):**
```
<pod-hostname>.<subdomain>.<namespace>.svc.cluster.local
```

**Implication:** Service and pod names become DNS entries. Name length and character constraints ensure DNS compatibility.

### Label Selectors

Names often become label values:

```yaml
spec:
  selector:
    matchLabels:
      app: myapp-frontend  # Name used as label value
```

## References

- Kubernetes Object Names: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/
- Kubernetes Labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
- Recommended Labels: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
- RFC 1123: https://tools.ietf.org/html/rfc1123
- RFC 1035: https://tools.ietf.org/html/rfc1035
