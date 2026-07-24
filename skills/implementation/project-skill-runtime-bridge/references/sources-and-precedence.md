# Sources And Precedence

For the runtime bridge, prefer:

1. `skills/catalog.yaml`
2. Source skill directories under `skills/`
3. `.cursor/skills/catalog.yml`
4. Existing `.cursor/skills/*` filesystem state

The catalog defines what is managed. Existing runtime copies do not outrank the
source library.
