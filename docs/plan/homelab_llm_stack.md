7. LLM Stack (vLLM, Ollama, etc.)
You mentioned vLLM / Ollama — here’s how they fit.

Collections
Code
community.docker
Patterns
Run Ollama inside Docker

Run vLLM inside Docker with GPU passthrough (if you ever add a GPU node)

Expose them via Traefik

Use K3s to orchestrate them later

Starter roles
There are no official roles, but these are good:

Code
github.com/jmorganca/ollama
github.com/vllm-project/vllm
You can wrap them in your own roles.