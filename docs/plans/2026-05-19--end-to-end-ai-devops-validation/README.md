# End-to-End AI DevOps Validation Plan

## Summary

This plan outlines the implementation for an end-to-end AI DevOps validation pipeline. The core objective is to ensure the reliable deployment and operation of AI/LLM components by integrating robust testing and observability at each stage. This includes setting up JupyterLab for development and validation, LiteLLM as an OpenAI-compatible proxy, and Langfuse for trace observation. Ansible will be used for infrastructure provisioning, configuration, and orchestration of validation routines.

## Implementation Plan

The implementation will proceed in four main phases:

### Phase 1: Infrastructure Setup

**Goal:** Automate the deployment and initial configuration of core AI/LLM infrastructure components using Ansible.

*   **JupyterLab:** Deploy and configure JupyterLab instances, ensuring the necessary Python environment and packages are installed. This will be the primary environment for notebook-based development and validation.
*   **LiteLLM Proxy:** Deploy LiteLLM as an OpenAI-compatible proxy. This will abstract various LLM providers and route requests, enabling consistent interaction patterns for validation.
*   **Langfuse:** Deploy the Langfuse tracing service for observing and analyzing LLM interactions.
*   **Databases:** Deploy supporting databases like Postgres (for Langfuse) and ClickHouse (for analytical data).
*   **Object Storage:** Deploy MinIO for object storage needs (e.g., model artifacts, datasets).
*   **Version Pinning:** Ensure all installed packages and services use explicit version pinning as per project standards.

### Phase 2: Notebook Environment Setup

**Goal:** Prepare JupyterLab environments for effective AI DevOps validation.

*   **Dependency Management:** Ensure `pip install -r requirements.txt` is automated within the JupyterLab environment to manage Python dependencies, including `langfuse`, `openai`, `testbook`, `nbtest`, etc.
*   **Environment Variables:** Securely inject necessary environment variables (e.g., `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `OPENAI_API_KEY`) into the JupyterLab environment, potentially using Ansible vault for sensitive information.
*   **Test Frameworks:** Install and configure notebook validation frameworks like `testbook`, `nbtest`, and `nbcelltests` within the JupyterLab environment.

### Phase 3: Validation Playbook Development

**Goal:** Create Ansible playbooks to perform automated validation checks across the AI DevOps stack.

*   **Health Checks:** Develop tasks to verify the health and accessibility of all deployed services (JupyterLab, LiteLLM, Langfuse, databases, MinIO).
*   **API Validation:** Implement tasks to test API endpoints, ensuring correct responses, status codes, and OpenAI compatibility for LiteLLM.
*   **Langfuse Trace Verification:** Create tasks to programmatically query Langfuse and verify that traces are being generated correctly, contain expected data, and reflect proper context propagation.
*   **Notebook Execution & Output Validation:** Develop mechanisms to execute validation notebooks, capture their outputs, and assert against expected results (potentially integrating with `testbook` or `nbtest` CLI tools).
*   **Idempotence Testing:** Ensure all Ansible deployment and configuration playbooks are fully idempotent.

### Phase 4: Observability Integration

**Goal:** Validate that observability data (traces, metrics, logs) is correctly collected, processed, and available for analysis.

*   **Instrumentation Testing:** Implement tests to verify that expected spans are produced, attributes are correct, and errors set proper span statuses.
*   **Context Propagation:** Validate that trace context propagates correctly across service boundaries (notebook, LiteLLM, model, Langfuse).
*   **Monitoring Setup:** Ensure appropriate monitoring and alerting are configured based on the collected observability data.

## Apply / Verify / Undo / Change Class

*   **Apply:** The plan will be applied by executing a master Ansible playbook (e.g., `playbooks/deploy_ai_devops_validation.yml`) which orchestrates the deployment and configuration of all components and validation routines.
*   **Verify:** Verification will involve running dedicated Ansible validation playbooks that perform health checks, API tests, and Langfuse trace assertions. Successful execution of these playbooks, showing `ok` status and no failures, will confirm the system's operational state. Specific notebook output assertions and observability data checks will further validate functionality.
*   **Undo:** Undoing the changes will involve executing a corresponding Ansible playbook (e.g., `playbooks/teardown_ai_devops_validation.yml`) that ensures all deployed services, configurations, and associated data are cleanly removed, returning the environment to its prior state. Each role will support `state: absent`.
*   **Change Class:** This implementation falls under **idempotent configuration**. The Ansible playbooks are designed to be run multiple times without causing unintended side effects, ensuring the desired state is consistently maintained.

## Dependencies

*   **Ansible Core:** Version 2.15+
*   **Python:** Version 3.10+
*   **Docker/Podman:** For containerized deployments of LiteLLM, Langfuse, and databases.
*   **`community.general` Ansible Collection:** For `npm` module and other utilities.
*   **`ansible.builtin` Ansible Collection:** For core modules.
*   **Langfuse Python SDK:** For trace instrumentation and verification.
*   **OpenAI Python SDK:** For interacting with LLM APIs via LiteLLM.
*   **`testbook`, `nbtest`, `nbcelltests` Python libraries:** For notebook validation.

## Ansible Maturity Observations

**llm**
  Observation: Deployment and configuration of LiteLLM will require a dedicated Ansible role.
  Improvement: Create a `litellm` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**vllm**
  Observation: Deployment and configuration of vLLM will require a dedicated Ansible role.
  Improvement: Create a `vllm` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**lf**
  Observation: Deployment and configuration of Langfuse will require a dedicated Ansible role.
  Improvement: Create a `langfuse` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**pg**
  Observation: Deployment and configuration of Postgres will require a dedicated Ansible role.
  Improvement: Create a `postgres` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**ch**
  Observation: Deployment and configuration of ClickHouse will require a dedicated Ansible role.
  Improvement: Create a `clickhouse` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**min**
  Observation: Deployment and configuration of MinIO will require a dedicated Ansible role.
  Improvement: Create a `minio` role following `snake_case` conventions, including `meta/argument_specs.yml` for its public interface, and ensuring all modules use FQCNs.
  Effort: low-medium
  When: now
  Tool/pattern: Dedicated Ansible role, `snake_case`, `meta/argument_specs.yml`, FQCNs

**Variables**
  Observation: The plan specifies loading runtime variables through `.env`/vault-backed paths, but doesn't detail specific Ansible patterns for this.
  Improvement: Implement vault variable naming with `vault_<role_name>_<field>` prefixes and ensure loading via `ansible.builtin.include_vars` with `name: vault_vars` for secure and scoped access. For `.env` files, use Ansible to template or create them with correct permissions.
  Effort: low
  When: next PR
  Tool/pattern: `vault_<role>_<field>` naming, `ansible.builtin.include_vars`, secure `.env` handling

**Naming**
  Observation: The diagram uses concise codes for components (e.g., `llm`, `vlm`, `lf`).
  Improvement: Ensure these compact names are consistently used as slugs for Ansible role names and NetBox objects, adhering to the `lowercase-kebab` convention for consistency and machine readability.
  Effort: minor
  When: now
  Tool/pattern: Consistent naming schema for roles/slugs (`lowercase-kebab`)

## Architecture/Structure Diagram

```mermaid
graph TD
 subgraph dotfile_vnext [dotfile-vnext Repository]
 subgraph inventory [Inventory Layer]
 all_vars[inventory/group_vars/all.yaml<br/>(version_contracts, global_vars)]
 host_vars[inventory/host_vars/<host>/<br/>(host_specific_vars)]
 vault_vars[vault.yml<br/>(vault_role_field)]
 end
 
 subgraph roles [Ansible Roles]
 jupyter_role[roles/jupyter_lab<br/>(deploy, config)]
 litellm_role[roles/litellm<br/>(deploy, config)]
 langfuse_role[roles/langfuse<br/>(deploy, config)]
 postgres_role[roles/postgres<br/>(deploy, config)]
 clickhouse_role[roles/clickhouse<br/>(deploy, config)]
 minio_role[roles/minio<br/>(deploy, config)]
 validation_role[roles/validation<br/>(notebook_tests, api_checks)]
 common_node_role[roles/common/node<br/>(node_npm_executable)]
 end
 
 subgraph playbooks [Ansible Playbooks]
 deploy_infra[playbooks/deploy_ai_devops_infra.yml<br/>(tags: jupyter, litellm, langfuse, pg, ch, min)]
 validate_stack[playbooks/validate_ai_devops_stack.yml<br/>(tags: validate)]
 teardown_infra[playbooks/teardown_ai_devops_infra.yml<br/>(tags: teardown)]
 end
 
 subgraph docs [Documentation]
 research_file[docs/intake/jupyter-devops-implementation-plans/research/05-end-research.md]
 plan_file[docs/plans/2026-05-19--end-to-end-ai-devops-validation/README.md]
 end
 end
 
 subgraph external [External Resources]
 jupyter_service[JupyterLab Service]
 litellm_proxy[LiteLLM Proxy<br/>(OpenAI-compatible API)]
 langfuse_service[Langfuse Service]
 model_providers[Model Providers<br/>(e.g., OpenAI, Anthropic)]
 postgres_db[Postgres Database]
 clickhouse_db[ClickHouse Database]
 minio_storage[MinIO Object Storage]
 end
 
 subgraph developer_workflow [Developer Workflow]
 notebook_dev[Jupyter Notebook Development]
 python_sdk[Python SDKs<br/>(langfuse, openai)]
 end
 
 %% Data/Control Flow
 deploy_infra --> jupyter_role
 deploy_infra --> litellm_role
 deploy_infra --> langfuse_role
 deploy_infra --> postgres_role
 deploy_infra --> clickhouse_role
 deploy_infra --> minio_role
 
 litellm_proxy -- "forwards requests" --> model_providers
 
 notebook_dev -- "uses" --> python_sdk
 python_sdk -- "calls" --> litellm_proxy
 python_sdk -- "sends traces" --> langfuse_service
 
 validate_stack -- "checks" --> jupyter_service
 validate_stack -- "checks" --> litellm_proxy
 validate_stack -- "checks" --> langfuse_service
 validate_stack -- "executes notebook tests" --> notebook_dev
 
 common_node_role -- "provides" --> jupyter_role
 all_vars -- "provides variables" --> roles
 host_vars -- "provides variables" --> roles
 vault_vars -- "provides secrets" --> roles
 
 research_file -- "informs" --> plan_file
 plan_file -- "guides" --> roles
 plan_file -- "guides" --> playbooks
 
 style jupyter_service fill:#2a2a2a,color:#fff
 style litellm_proxy fill:#2a2a2a,color:#fff
 style langfuse_service fill:#2a2a2a,color:#fff
 style model_providers fill:#1e3a5f,color:#fff
 style postgres_db fill:#2a2a2a,color:#fff
 style clickhouse_db fill:#2a2a2a,color:#fff
 style minio_storage fill:#2a2a2a,color:#fff
 style notebook_dev fill:#4a3f2e,color:#fff
 style python_sdk fill:#4a3f2e,color:#fff
 style deploy_infra fill:#2d4a2d,color:#fff
 style validate_stack fill:#2d4a2d,color:#fff
 style teardown_infra fill:#2d4a2d,color:#fff
 style plan_file fill:#5a4a1a,color:#fff
 style research_file fill:#5a4a1a,color:#fff
```

## Diagram Inventory

### Diagrams Included
- **Architecture/Structure Diagram**: Shows repository organization, naming schemes, and integration points

### Additional Diagrams Available On Request
- **Deployment Flow**: Sequential deployment steps across environments
- **State Transition Diagram**: Object lifecycle and state changes
- **Integration Sequence**: Detailed API/service interaction timeline
- **Network Topology**: Host/cluster/network relationships (when infrastructure is in scope)
