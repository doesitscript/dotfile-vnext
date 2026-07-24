# Sources And Precedence

For single-host apply-and-receipt work in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. The scoped playbook and role in repo
3. Preview/check/apply output
4. Direct post-apply verification output
5. The receipt template

If the receipt and the direct verification disagree, trust the direct
verification and fix the receipt.
