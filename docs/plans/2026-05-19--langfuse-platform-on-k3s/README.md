# Plan: Langfuse Platform on K3s

**Date:** May 19, 2026
**Status:** Draft

## Executive Summary

This plan outlines the implementation of Langfuse on a K3s cluster using Ansible for automation. Langfuse is an open-source LLM observability platform that leverages a Helm chart for Kubernetes deployments. The deployment will include Langfuse web and worker, PostgreSQL, ClickHouse, Redis/Valkey, and MinIO/S3. Ansible will manage the Helm chart deployment and Kubernetes secrets. In the broader lab direction, this packet should be understood as the observability substrate for multiple agents, IDE flows, and model lanes rather than a single-app deployment.

## Apply / Verify / Undo / Change Class

*   **Apply:** The Ansible playbook will deploy the Langfuse Helm chart, create necessary Kubernetes secrets, and configure the K3s cluster components.
*   **Verify:** Post-deployment Ansible tasks will check pod readiness, service availability, and expose the Langfuse UI via port-forwarding for manual verification. `kubectl` commands will be used to inspect all deployed resources.
*   **Undo:** The Ansible playbook will support `release_state: absent` for the Helm chart to uninstall Langfuse. Kubernetes secrets and namespaces will also be removed.
*   **Change Class:** Idempotent configuration. The Ansible playbook is designed to be run multiple times without causing unintended side effects, ensuring the desired state is maintained. Version updates will be managed by updating the Helm chart version in the Ansible role.

## Architecture/Structure Diagram

```mermaid
graph TB
 subgraph dotfile_vnext [dotfile-vnext Repository]
 subgraph inventory [Inventory Layer]
 k3s_control_plane[inventory/inventory.yaml<br/>group: k3s_control_plane]
 end
 
 subgraph roles [Role Layer]
 langfuse_platform[roles/langfuse_platform/]
 defaults[langfuse_platform/defaults/main.yml]
 tasks[langfuse_platform/tasks/<br/>main.yml, prerequisites.yml, secrets.yml, helm_deploy.yml, verify.yml]
 templates[langfuse_platform/templates/<br/>values.yaml.j2]
 vault[vault/langfuse_secrets.yml]
 end
 
 subgraph playbooks [Playbook Layer]
 deploy_langfuse[playbooks/deploy_langfuse.yaml]
 end
 end
 
 subgraph k3s_cluster [K3s Cluster]
 k3s_nodes[K3s Nodes]
 langfuse_ns[Namespace: langfuse]
 
 subgraph langfuse_components [Langfuse Helm Release]
 langfuse_web[Langfuse Web (Pod)]
 langfuse_worker[Langfuse Worker (Pod)]
 postgres[PostgreSQL (Pod, PVC)]
 clickhouse[ClickHouse (Pod, PVC)]
 redis[Redis/Valkey (Pod)]
 minio[MinIO/S3 (Pod, PVC)]
 end
 
 subgraph k8s_services [Kubernetes Services]
 k8s_secrets[langfuse-app-secrets (Secret)]
 k8s_db_secrets[langfuse-db-secrets (Secret)]
 k8s_storage_secrets[langfuse-storage-secrets (Secret)]
 ingress[Ingress (Traefik)]
 end
 
 langfuse_ns --> langfuse_web
 langfuse_ns --> langfuse_worker
 langfuse_ns --> postgres
 langfuse_ns --> clickhouse
 langfuse_ns --> redis
 langfuse_ns --> minio
 
 langfuse_ns --> k8s_secrets
 langfuse_ns --> k8s_db_secrets
 langfuse_ns --> k8s_storage_secrets
 langfuse_ns --> ingress
 
 k3s_nodes -- "hosts" --> k3s_control_plane
 
 deploy_langfuse -- "uses" --> langfuse_platform
 deploy_langfuse -- "targets" --> k3s_control_plane
 
 langfuse_platform -- "defines defaults" --> defaults
 langfuse_platform -- "implements logic" --> tasks
 langfuse_platform -- "uses templates" --> templates
 langfuse_platform -- "manages secrets" --> vault
 
 templates --> "provides values" --> langfuse_components
 tasks --> "creates" --> k8s_secrets
 tasks --> "creates" --> k8s_db_secrets
 tasks --> "creates" --> k8s_storage_secrets
 tasks --> "deploys" --> langfuse_components
 
 k3s_control_plane -- "orchestrates" --> k3s_nodes
 
 style k3s_control_plane fill:#2a2a2a
 style langfuse_platform fill:#1e3a5f
 style deploy_langfuse fill:#2a2a2a
 style k3s_nodes fill:#2a2a2a
 style langfuse_ns fill:#1e3a5f
 style k8s_secrets fill:#4a3f2e
 style k8s_db_secrets fill:#4a3f2e
 style k8s_storage_secrets fill:#4a3f2e
 style ingress fill:#5a4a1a
 style langfuse_web fill:#2d4a2d
 style langfuse_worker fill:#2d4a2d
 style postgres fill:#2d4a2d
 style clickhouse fill:#2d4a2d
 style redis fill:#2d4a2d
 style minio fill:#2d4a2d
```

## Naming Standards

### NetBox Conventions
*   `langfuse` namespace will be used for all Kubernetes resources.
*   Default Kubernetes `Service`, `Deployment`, `Pod` names will be adopted from the Helm chart.
*   VMs (k3s nodes) and other infrastructure components will follow existing NetBox naming conventions.

### Ansible Conventions
*   **Role Name:** `langfuse_platform` (snake_case, capability-focused).
*   **Variables:** `langfuse_platform_` prefix for role-specific variables (e.g., `langfuse_platform_chart_version`).
*   **Vault Variables:** `vault_langfuse_<field>` prefix (e.g., `vault_langfuse_salt`).
*   **Task Names:** Descriptive and imperative (e.g., "Add Langfuse Helm repository").
*   **Tags:** `langfuse` (general), `prerequisites`, `secrets`, `deploy`, `verify` for specific task sets.

## Variable Sources

*   **Version Contracts:** Helm chart version for Langfuse and its dependencies will be defined in `defaults/main.yml` within the `langfuse_platform` role, potentially linked to a version contract in `inventory/group_vars/all.yaml` for consistency across the project.
*   **Defaults:** `roles/langfuse_platform/defaults/main.yml` will hold default values for Helm chart parameters.
*   **Vault:** Sensitive information (API keys, database passwords) will be stored in `vault/langfuse_secrets.yml` and managed by Ansible Vault.
*   **Kubernetes Secrets:** Ansible will create Kubernetes `Secret` objects using values from `vault/langfuse_secrets.yml`, which will then be referenced by the Helm chart via `secretKeyRef`.

## Tag Hierarchies

*   **`langfuse`**: General tag for all tasks related to Langfuse deployment.
*   **`prerequisites`**: Tasks for setting up the environment (namespace, storage checks).
*   **`secrets`**: Tasks for creating Kubernetes secrets.
*   **`deploy`**: Tasks for deploying the Helm chart.
*   **`verify`**: Tasks for post-deployment health checks and verification.

This structure allows for granular execution and targeted operations (e.g., `ansible-playbook -t deploy`).

## File Organization

*   **`roles/langfuse_platform/`**:
    *   `defaults/main.yml`: Default Helm values and role variables.
    *   `tasks/main.yml`: Entry point, includes other task files.
    *   `tasks/prerequisites.yml`: Namespace creation, storage class validation.
    *   `tasks/secrets.yml`: Creation of Kubernetes `Secret` resources.
    *   `tasks/helm_deploy.yml`: Helm chart deployment using `kubernetes.core.helm`.
    *   `tasks/verify.yml`: Post-deployment checks (pod status, service health).
    *   `templates/values.yaml.j2`: Jinja2 template for Helm `values.yaml` file.
    *   `README.md`: Role documentation.
*   **`playbooks/deploy_langfuse.yaml`**: Main playbook to orchestrate the `langfuse_platform` role.
*   **`vault/langfuse_secrets.yml`**: Encrypted file containing sensitive credentials for Langfuse.

## Dependencies

*   **Ansible Collections:** `kubernetes.core` (installed via `ansible-galaxy collection install kubernetes.core`).
*   **Helm:** Helm v3.x or newer must be installed on the Ansible control node.
*   **Python Libraries:** `kubernetes` Python library (>= 24.2.0) must be installed in the Ansible environment.
*   **K3s Cluster:** A running K3s cluster with the `local-path` storage provisioner enabled (default in K3s).
*   **OpenSSL:** Required for generating secrets.

## Open Questions for Implementation

*   **Ingress Controller:** Confirm preferred ingress (Traefik vs Nginx-ingress) configuration for K3s.
*   **TLS Certificate Management:** Strategy for TLS certificates (cert-manager, manual, Let's Encrypt).
*   **Monitoring/Observability:** Integration with existing monitoring solutions (Prometheus, Grafana).
*   **Backup Strategy:** Defined backup and restore procedures for PostgreSQL, ClickHouse, and S3 data.
*   **Multi-Environment Configuration:** How to manage `values.yaml` overrides for different environments (dev/staging/prod).

## Next Implementation Steps

1.  Create `roles/langfuse_platform/` role structure.
2.  Define vault variables in `vault/langfuse_secrets.yml` using `ansible-vault create`.
3.  Create Helm `values.yaml.j2` template within the role.
4.  Implement `prerequisites.yml` tasks (namespace, storage class verification).
5.  Implement `secrets.yml` tasks to create Kubernetes secrets from vault variables.
6.  Implement `helm_deploy.yml` tasks using `kubernetes.core.helm` module.
7.  Add `verify.yml` tasks for post-deployment health checks.
8.  Create playbook `playbooks/deploy_langfuse.yaml` to include the role.
9.  Test the deployment on a K3s cluster.
10. Document the operational runbook for Langfuse management.

## Diagram Inventory

### Diagrams Included
- **Architecture/Structure Diagram**: Shows repository organization, naming schemes, and integration points

### Additional Diagrams Available On Request
- **Deployment Flow**: Sequential deployment steps across environments
- **State Transition Diagram**: Object lifecycle and state changes
- **Integration Sequence**: Detailed API/service interaction timeline
- **Network Topology**: Host/cluster/network relationships (when infrastructure is in scope)
