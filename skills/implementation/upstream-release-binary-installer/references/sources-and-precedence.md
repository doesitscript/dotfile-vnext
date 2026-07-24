# Sources And Precedence

For upstream binary installers, prefer:

1. Official upstream release metadata and release assets
2. Official project docs describing install options
3. Repo role defaults/tasks already handling similar binary installs
4. Live target facts such as `ansible_architecture`
5. Read-only preview/apply evidence

If the user asks for "latest" or "most recent," confirm the exact release and
date before pinning anything.
