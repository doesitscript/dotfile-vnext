They're actually solving **very different problems**, even though they can be combined in one system.

**Lab diagrams (promoted):** separate plan packets —
[ComfyUI](../../plans/2026-08-06--comfyui-lab-setup-diagrams-implemented/) and
[Automatic1111](../../plans/2026-08-06--automatic1111-lab-setup-diagrams-implemented/).
This folder’s [README.md](README.md) is a redirect.

Here's the simplest way to think about it:

* **ComfyUI** orchestrates **AI media generation** (images, video, audio).
* **LangGraph** orchestrates **AI reasoning and decision-making** (LLMs, agents, workflows).

One controls pixels; the other controls logic.

---

## ComfyUI

ComfyUI is a **node-based media processing engine**.

Every node performs an operation on images, latent representations, video, or models.

For example:

```text
Load Image
      │
      ▼
Load FLUX
      │
      ▼
Prompt
      │
      ▼
Sampler
      │
      ▼
VAE Decode
      │
      ▼
Upscale
      │
      ▼
Save
```

The workflow is mostly deterministic: each node transforms data and passes it to the next.

Typical node types include:

* Load model
* Load image
* Prompt encoding
* Sampling
* Face restoration
* Upscaling
* Video generation
* Save output

---

## LangGraph

LangGraph is a **graph framework for LLM-driven applications**.

Each node is typically an AI agent or a function that makes decisions.

Example:

```text
User Request
      │
      ▼
Planner
      │
      ├──────────────┐
      ▼              ▼
Research        Write Code
      │              │
      └──────┬───────┘
             ▼
         Reviewer
             │
             ▼
         Final Answer
```

Nodes can:

* Call LLMs
* Use tools
* Access databases
* Decide which node to execute next
* Loop until a task is complete

It's much more dynamic than ComfyUI.

---

# Think of it like a movie studio

Imagine you're making a film.

### LangGraph is the producer.

It decides:

* What project to make
* Which people are involved
* What happens next
* Whether another revision is needed

### ComfyUI is the camera department.

It:

* Shoots scenes
* Applies lighting
* Handles visual effects
* Produces the final frames

---

## Example collaboration

Suppose you ask:

> "Create five editorial portraits with different lighting styles."

A LangGraph workflow might do this:

```text
Receive Request
      │
      ▼
Interpret Intent
      │
      ▼
Generate Prompt Variations
      │
      ▼
Call ComfyUI API
      │
      ▼
Receive Images
      │
      ▼
Evaluate Results
      │
      ▼
If needed, revise prompts and repeat
      │
      ▼
Return Best Images
```

Inside ComfyUI, one of those calls might execute:

```text
Portrait
      │
      ▼
Identity Module
      │
      ▼
FLUX
      │
      ▼
Upscaler
      │
      ▼
Save Image
```

LangGraph never generates pixels directly—it tells ComfyUI *when* and *how* to do it.

---

## Which is more powerful?

It depends on what you mean.

### ComfyUI excels at:

* Image generation
* Image editing
* Video generation
* Upscaling
* Inpainting/outpainting
* ControlNet workflows
* Chaining visual models

### LangGraph excels at:

* Multi-step reasoning
* Agent coordination
* Tool use
* Long-running workflows
* Memory
* Planning
* Automation

---

## If I were designing a local AI studio

I'd use both.

```text
                User
                  │
                  ▼
            LangGraph
                  │
      ┌───────────┼───────────┐
      ▼           ▼           ▼
  Planner     Asset Manager   QA
      │
      ▼
   LiteLLM Router
      │
      ├──────────────┐
      ▼              ▼
 Image Model     Video Model
      │              │
      └──────┬───────┘
             ▼
          ComfyUI
             │
             ▼
     Images / Videos
```

In this architecture:

* **LangGraph** decides what should happen next and manages the overall workflow.
* **LiteLLM** provides a consistent interface to whichever language models you choose to use.
* **ComfyUI** performs the actual image and video generation.

This separation keeps each tool focused on what it does best and makes the overall system easier to maintain and extend.
