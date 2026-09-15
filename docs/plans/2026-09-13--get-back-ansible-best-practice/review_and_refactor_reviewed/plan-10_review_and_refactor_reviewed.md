Your suspicion is correct. hvh01 is evidence that the refactor stopped halfway.
The actual manifest.yml does not contain the gateway variable shown in your snippet. It contains the same underlying anti-pattern in its lane identities and metadata:
- Duplicate 1.5B entries: code-fast and code-autocomplete-1.5b
- Host embedded in lane ID: nomic-embed-text-hvh01
- Deployment state embedded in lane ID: qwen3-coder-30b-a3b-primary
- Gateway variables still combine provider, host, runtime, role, and model size:
  k3s_litellm_gateway_ollama_hvh01_fim_1_5b_*
Other findings:
- Continue and Cline independently duplicate model catalogs instead of rendering from ai_cli_commissioned_models.
- gpt-oss-20b still has 8192 output tokens in SSOT, Continue, and Cline despite the requested 4096.
- Embedding ownership is not enforced as an explicit invariant.
- LiteLLM chart/image versions remain mutable.
- A plaintext fallback gateway secret remains in role defaults.
- Runtime identity and physical placement are mixed in metadata strings.
I documented the full audit and recommended migration sequence in:
[plan-07_antipattern_audit.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/plan-07_antipattern_audit.md)
I did not perform the structural registry migration yet. That requires changing the route builder and client catalog generation, followed by rendered-config comparison and live acceptance tests. The previous commit only performed terminology cleanup; the next proper pass should implement the structured model/deployment registry described in the audit.

## Implementation receipt — 2026-09-14

The requested corrective pass has now implemented the first structural model and
deployment normalization:

- LiteLLM local backends are represented under
  `k3s_litellm_gateway_local_backends` with logical IDs (`primary`, `desktop_7b`,
  `desktop_14b`, `fim_1_5b`, `nomic`, `desktop_gpt_oss`, and
  `desktop_ministral`). Host placement is a value in the backend record, not
  part of the variable key.
- LiteLLM route generation and the request-inspector tokenizer now consume that
  registry.
- The duplicate Qwen 1.5B catalog row was removed; `code-fast` is retained only
  as an explicit alias on the canonical `code-autocomplete-1.5b` row.
- Host/lifecycle suffixes were removed from the active Nomic and Qwen3 catalog
  lane identities.
- Continue and Cline now translate the shared
  `ai_cli_commissioned_models` SSOT into their own schemas at render time.
- `gpt-oss-20b` chat output is now 4096 in the SSOT, Continue, and Cline. The
  1.5B FIM exception remains 256.
- The LiteLLM master-key fallback was removed; deployment now fails closed when
  the vault key is absent.

Evidence:

- gateway convergence: `ok=33 changed=0 failed=0`;
- lane contract validation: `ok=4 changed=0 failed=0`;
- Continue/Cline convergence on commissioned `mac-dev`: first run passed;
  targeted second Cline run completed `changed=0`;
- production-profile `ansible-lint`: zero failures and warnings;
- deployment playbook syntax check: passed;
- seven live TDD model tests: all passed (five chat, one FIM, one embedding).

The LiteLLM chart and image are now pinned to the currently deployed `1.100.1`
release. The old client-role default lists remain as standalone-role fallback
data, but commissioned renders are SSOT-driven and validated; deleting those
fallbacks is a separate compatibility change for standalone role consumers.

Final verification after the naming normalization:

- second LiteLLM gateway converge: `ok=33 changed=0 unreachable=0 failed=0`;
- live lane contract validator: all seven canonical lane IDs passed;
- live model-lane suite: all seven passed — five chat responses, one FIM
  completion, and one 768-dimension embedding response;
- production-profile `ansible-lint`: `0 failure(s), 0 warning(s)`;
- deployment playbook syntax check and `git diff --check`: passed;
- active route metadata now uses logical runtime fields and separate
  `placement_host` values; endpoint hosts remain only in backend registry data.
