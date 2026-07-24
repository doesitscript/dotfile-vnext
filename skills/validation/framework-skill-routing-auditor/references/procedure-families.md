# Procedure Families

The bundled helper currently audits these repeatable procedure families:

1. Single-host preview / apply / verify / receipt
   Replacement skills:
   `single-host-apply-and-receipt`, `single-host-ansible-rollout`
2. Repo-managed CLI ownership / verify-command / playbook-lane discovery
   Replacement skill:
   `ansible-cli-surface-auditor`
3. macOS CLI completion diagnosis and PTY proof
   Replacement skills:
   `macos-cli-completion-converger`, `macos-cli-completion-pack`,
   `interactive-shell-completion-proof`
4. Context7 no-library-ID fallback handling
   Replacement skill:
   `context7-intake-or-emulate`

Add new families only when the replacement skill already exists or is being
created in the same slice.
