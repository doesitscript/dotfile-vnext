---
title: Host clarification — Mac work laptop vs Mac controller
captured_at: "2026-09-16"
---

# Host clarification

Operator correction: the incident host is the **Mac work laptop**, not the
**Mac controller laptop**.

| Host | Role in this incident |
| --- | --- |
| **Mac work laptop** | Where Continue/chat ran, where the folder search happened, where the UI error was seen. Client config drift (if any) applies **here**. |
| **Mac controller** | Ansible/Codex control plane (this lab’s `dotfile-vnext` operator machine). **Not** the failing client surface for this report. |

Do not treat controller `~/.continue/config.yaml`, Cursor rules, or controller
session context as evidence for this failure unless explicitly compared as a
separate baseline.

Gateway evidence (LiteLLM Request Inspector / pod logs on `hom-lab-ctl-k3s-02`)
remains useful because the work laptop was talking to the shared lab gateway —
but **client-side drift checks must run on the work laptop**, or against the
work-laptop export packet / day-2 apply path, not on the controller by default.
