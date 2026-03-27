Overview:
Track the first durable product-direction issue for `network_plus` so the
current local AI gateway and observability stack becomes an app-ready baseline
instead of staying as repo scaffolding plus local notes.

Why this issue lives here:
- `network_plus` owns the actual product stack shape, local runtime topology,
  and app-facing baseline
- the main issue should live where the compose files, LiteLLM config, and local
  stack decisions are made

Current state:
- the repo already defines a split Docker Compose topology for networking,
  storage, core services, and client services
- the current stack centers on LiteLLM, Langfuse, and Open WebUI
- `litellm.config.yaml` already models `reasoning` and `coding` roles for
  upstream model routing
- `README.txt` and helper scripts are enough to bootstrap the stack, but not
  enough to hold the first durable product direction
- `ascii.diagram.md` exists but is currently empty, so architecture capture is
  still a gap

Cross-repo issue map:
- [ ] https://github.com/doesitscript/dotfile-vnext/issues/9 — supporting
  framework/process coordination in `doesitscript/dotfile-vnext`

Primary execution plan:
- define the first tracked app-ready baseline for the local AI gateway stack
- clarify which current stack elements are part of the immediate product slice
  versus deferred scaffolding
- capture the most important architecture/documentation gaps that would block
  future implementation pickup
- coordinate with the supporting `dotfile-vnext` issue so cross-repo planning
  and supporting work stay linked

Definition of done:
- the main `network_plus` direction is tracked in a durable GitHub issue
- the supporting `dotfile-vnext` issue is linked from this issue
- the immediate baseline and next execution slice are explicit enough for future
  pickup
- the key repo references for the stack are named here

Pick-up references:
- `README.txt`
- `litellm.config.yaml`
- `docker-compose.net.yml`
- `docker-compose.core.yml`
- `docker-compose.client.yml`
- `ascii.diagram.md`
