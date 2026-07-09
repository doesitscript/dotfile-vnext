# Library Entry Build

Executor wrapper for registered entry build scripts.

## Registry

All build scripts must be listed in:

`references/build-registry.yml`

Add a row **before** creating a new `build_*.mjs`.

## Post-build

Always run `library-entry-validate` after a build completes.
