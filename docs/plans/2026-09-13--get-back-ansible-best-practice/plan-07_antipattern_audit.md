# Anti-pattern audit: model, runtime, gateway, and client ownership

Date: 2026-09-14

## Executive finding

The `hvh01` text in a variable name is a real signal, but it is not itself a
problem because the host exists. The problem is that deployment placement,
runtime implementation, model identity, client role, and gateway wiring are
encoded together in one variable key.

For example:

```yaml
k3s_litellm_gateway_ollama_hvh01_fim_1_5b_model: qwen2.5-coder:1.5b-base-q8_0
```

This key carries four different dimensions:

```text
gateway namespace + provider/runtime + physical host + client behavior + model size
```

The plans called for those dimensions to be separate. The prior migration only
renamed scalar variables, so it improved terminology but did not complete the
normalization. That is why the anti-pattern is still visible.

## Naming analysis

The local Ansible naming standard requires capability-focused role variables and
stable compact identifiers, while model lane aliases are intended to be
client-facing slugs rather than inventory or GPU taxonomy. `HOM-LAB-HVH-01` is
valid as an inventory/storage host identity, but it should be a value in host or
deployment metadata, not part of a model variable name.

Recommended separation:

```yaml
ai_model_lanes:
  qwen2.5-coder-1.5b-base-q8_0:
    capability: code_completion
    variant: base
    client_roles: [autocomplete]
    deployments:
      - id: qwen25_coder_15b_fim
        runtime: ollama
        host: HOM-LAB-HVH-01
        api_base: http://ollama-hvh01.hom.lab:11434/v1
        provider: openai
        served_model: qwen2.5-coder:1.5b-base-q8_0
```

The exact schema can be refined during implementation, but the important rule
is that adding a deployment on another host must add data, not require a new
variable family.

## Findings

### P1 — gateway backend variables still encode placement and role

Active examples include `ollama_hvh01_fim_1_5b`, `ollama_hvh01_nomic`,
`ollama_desktop_7b`, and `ollama_desktop_14b`. These are safer than the retired
client-oriented names, but they are still one-off scalar triplets (`api_base`,
`model`, `provider`) and cannot represent multiple deployments without adding
more variable names.

The same issue appears in `backend_runtime` metadata such as
`ollama-autocomplete-1.5b-hvh-01`. Runtime identity and placement should be
separate fields.

### P1 — the model catalog contains duplicate or mixed-purpose lane identities

`code-fast` and `code-autocomplete-1.5b` describe the same Qwen 1.5B base
deployment. `nomic-embed-text-hvh01` combines the model name and host. Other
rows combine a model with lifecycle or deployment state, such as
`qwen3-coder-30b-a3b-primary` and `qwen3.6-35b-a3b-generalist`.

The catalog needs separate fields for `model_id`, `capability`, `deployment`,
`status`, and `client_roles`. A lane should not multiply merely because a
second client alias or host placement exists.

### P1 — client catalogs are duplicated instead of rendered from the SSOT

`ai_cli_commissioned_models` is described as the shared commissioned model
contract, but `roles/continue_ide/defaults/main.yml` and
`roles/cline_ide/defaults/main.yml` each contain their own model rows. This
creates drift risk: names, context windows, max output, and roles can diverge
without a schema failure.

The work-laptop export is expected to contain rendered copies. The role
defaults are not expected to independently repeat the same catalog.

### P1 — token policy is still inconsistent

The shared commissioned SSOT sets `gpt-oss-20b` to `max_output: 8192`, while
Continue and Cline also expose 8192 for that lane. The requested commissioned
chat policy was 4096. The 1.5B FIM lane is correctly special-cased at 256, but
that exception should be represented as a capability/client-role policy, not
used to justify duplicated model definitions.

### P2 — embedding ownership is not represented as an explicit invariant

The active route correctly points Nomic to HVH-01 Ollama, but the catalog has a
host-suffixed lane and the client model lists still include embedding entries.
The architecture should declare one gateway-owned embed route and have clients
reference that route, with local client embeddings explicitly disabled. This
should be validated rather than inferred from an empty or omitted field.

### P2 — mutable infrastructure inputs weaken reproducibility

The LiteLLM defaults use a mutable chart/image policy (`latest`/`main-latest`),
which conflicts with the plans’ deterministic and idempotent deployment goal.
Those should be pinned in the deployment contract after confirming the current
working versions.

### P2 — plaintext fallback secret remains in role defaults

The vault path is working, but the role still contains a non-secret-looking
fallback value for the gateway master key. The fallback is an operational
secret and should be removed or made an explicit fail-closed development-only
override. Vault resolution should be required for commissioned deployment.

## Corrective implementation sequence

1. Introduce a structured model/deployment registry in the authoritative
   inventory layer.
2. Keep plain client model IDs as compatibility aliases.
3. Render LiteLLM routes by looping over deployment records; remove scalar
   per-placement gateway variables only after rendered-config comparison.
4. Render Continue and Cline model catalogs from the shared registry, retaining
   only client-specific schema and sparse overrides in each role.
5. Move embedding ownership into an explicit gateway invariant and assert that
   local client embedding is disabled.
6. Set chat `max_output`/`maxTokens` to 4096 everywhere, retaining 256 only for
   the FIM autocomplete contract.
7. Pin mutable chart/image versions and remove the secret fallback under a
   separate vault-gated change.
8. Validate source YAML, Ansible lint, rendered Helm values, second-run
   idempotence, live gateway routes, and client round trips before deleting
   compatibility variables.

## Scope boundary

This audit intentionally does not rename the live model IDs or immediately
replace the gateway route builder. That would be a structural migration, not a
safe naming-only edit. The next implementation pass should use a rendered
configuration diff and the existing seven-lane TDD smoke suite as its acceptance
gate.

## Documentation Provenance

- Source plans: `docs/plans/2026-09-13--get-back-ansible-best-practice/plan-01-vNow.md`,
  `plan-02-design_for_future_profile_concept.md`, and
  `plan-03-multiple_file_sections.md`.
- Naming authority: `docs/reference/naming-standards/ansible.yml`.
- Implementation surfaces reviewed: `inventory/group_vars/all/ai_cli_apps.yml`,
  `inventory/group_vars/model_catalog/manifest.yml`,
  `roles/k3s_litellm_gateway/defaults/main.yml`,
  `roles/k3s_litellm_gateway/tasks/build_helm_values.yml`,
  `roles/continue_ide/defaults/main.yml`, and `roles/cline_ide/defaults/main.yml`.
