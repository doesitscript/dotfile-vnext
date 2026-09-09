# Jan.AI local RAG on the work Mac

Work-laptop operator entry. Design authority is this packet. Sync into the
sibling `work-laptop-ai-tools` checkout before using it on the laptop.

Ansible role `jan_ide` writes this config when the packet playbook runs.
`jan_ide_state: present` on the work laptop. Apply with `--tags jan`.

Library research: HRL `implementation-guides/jan/local-rag-work-mac.md`
and `generated/context7/jan/local-rag-mac/`.

## Target

- Machine: work laptop (MacBook Pro 14-inch, November 2023, Apple M3 Pro).
- App: Jan desktop.
- Model: a local Qwen around 3B–4B, GGUF, already under `~/models`. Size
  band only. Exact file is `pending_research`. Do not download it inside Jan.
- Corpus: the homelab-reference-library checkout on this Mac.

## Paths

| What | Path | Source |
| --- | --- | --- |
| Jan data | `~/Library/Application Support/Jan/data` | Jan macOS docs |
| Owned weights | `~/models` | `helpers/work-mac-local-models/share-paths.sh` (`WORK_LAPTOP_LOCAL_MODELS`) |
| Share copy source | `WORK_LAPTOP_PUBLIC_FOLDER` | same file; mount not recorded |
| HRL checkout | `~/Documents/develop/homelab-reference-library` | `jan_ide_rag_corpus_path` |

Do not use `~/develop/homelab-reference-library` on this machine. Do not
point Jan at the HVH public share.

## Model

1. Weights arrive by `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`: public share
   `models/huggingface`, then copy to `~/models/huggingface`.
2. In Jan, Llama.cpp local import of that GGUF. Vendor docs say this links
   the file and does not duplicate it. Deleting the Jan entry must not be
   assumed to delete the file under `~/models`.
3. Confirm the Jan model entry's path is under `~/models/huggingface`, not
   under `~/Library/Application Support/Jan/data/llamacpp/models`.

## RAG on the library checkout

The corpus path Ansible writes is
`~/Documents/develop/homelab-reference-library`. That is the document source
for the managed assistant, project record, and filesystem MCP server.

The corpus is the HRL project, not a second copy of the docs invented for Jan.

Documented Jan RAG surfaces (Context7, 2026-09-09):

- A Project can take uploaded Markdown (and other office/PDF files). Those
  files are chunked and shared with conversations in that project.
- Assistant `assistant.json` can carry a `retrieval` tool. The documented
  example is disabled (`enabled: false`) with `top_k`, `chunk_size`, and
  `chunk_overlap`.

Context7 did not show a setting that watches the git checkout in place. A
Project upload copies documents into Jan. Until a live attach path is
verified, index a bounded set of HRL documents (for example
`implementation-guides/` and `q-and-a/`), not `vendor-work/` and not
generated mirrors.

Do not enable retrieval until the installed Jan build shows the same tool.

## Not in this entry

- Installing Jan. The role writes config only.
- Pinning a Qwen repo id or quantization.
- Continue, Ollama, or LM Studio config. Those stay on the local-model
  arrival scripts and still import from `~/models` so the weight is shared.
