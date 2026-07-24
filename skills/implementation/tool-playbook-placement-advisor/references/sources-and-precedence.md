# Sources And Precedence

For tool playbook placement in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. Existing playbook ownership and role boundaries
3. Current host-vars and target-host commissioning state
4. Current tool dependencies such as kubeconfig, shell substrate, or shared runtime lanes
5. Upstream docs only when they clarify the operator workflow the repo should model

When the tool's workflow and the current playbook home disagree, prefer the
operator workflow and fix the placement instead of copying a weak precedent.
