# Sources And Precedence

For framework change receipts in `dotfile-vnext`, prefer:

1. Direct diff and changed-file content
2. Framework routing audit output
3. Project `skills/catalog.yaml`
4. Supporting runtime mirrors only when a route target must be confirmed

If the receipt helper and direct file inspection disagree, trust the direct file
content and fix the receipt interpretation.
