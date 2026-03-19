Here’s the clean version.

The pattern many teams converge on is not “lots of random agents.” It is a small set of distinct roles around one workflow: a planner to decide approach, a researcher/retriever to gather missing context, an executor or implementer to do the work, a critic/evaluator to judge output quality, and a memory/trace layer to preserve what happened for later debugging and improvement. That pattern lines up with how the OpenAI Agents SDK is framed—agents can use tools, handoffs, and guardrails—and with the cookbook you linked, which focuses on tracing internal steps and evaluating them with Langfuse. ([OpenAI Developers][1])

A practical diagram looks like this:

```text
User request
   ↓
Planner
   ↓
Researcher / Retriever
   ↓
Executor / Implementer
   ↓
Critic / Evaluator
   ↓
Final answer

Alongside every step:
Memory / Trace / Dataset / Scores
```

Why this shape works: each role has one job. That reduces prompt bloat, makes failures easier to localize, and gives you cleaner traces. The OpenAI Agents SDK’s built-in tracing is designed to capture exactly these kinds of internal events—LLM generations, tool calls, handoffs, guardrails, and custom events—so you can debug the workflow step by step instead of treating the whole run like one opaque blob. ([OpenAI GitHub][2])

Planner means “figure out how to attack the task.” It should not do deep research or write the final artifact unless the task is trivial. Its job is to decompose, choose tools, decide whether more context is needed, and route work. In the Agents SDK model, this is where handoffs and orchestration naturally live. ([OpenAI GitHub][3])

Researcher means “get smart before acting.” This is the role you were intuitively asking for earlier. Instead of trusting one agent to both think and fetch, you can force a distinct retrieval phase: read docs, inspect files, hit APIs, gather examples, return evidence. That aligns with your desire to have one part of the system make sure the other part actually read the material. Langfuse’s trace model is useful here because you can see whether retrieval actually happened, what was fetched, and whether the downstream answer used it. ([OpenAI Developers][1])

Executor or implementer means “produce the thing.” In your world that might mean writing Ansible, generating YAML, editing a config, producing a plan, or drafting a Notion-ready artifact. This agent should be narrow and obedient. It gets context from the planner and researcher, then turns that into output. The value of separating it is that you can swap models here without redesigning the rest of the system. ([OpenAI GitHub][3])

Critic or evaluator means “grade the work.” This is the center of the cookbook page. The example shows tracing an agent run in Langfuse, then attaching evaluation signals such as user feedback and model-based judging so you can assess quality after the fact. That means your system can ask: Was it correct? complete? safe? useful? fast enough? cheap enough? ([OpenAI Developers][1])

Memory is the part people confuse. There are really two kinds. Short-term working memory is the state passed between agents in one run. Long-term memory is traces, datasets, metadata, prior outputs, and feedback saved across runs. In the OpenAI Agents SDK docs, tracing is enabled by default and is meant to capture runs for visualization, debugging, and monitoring. Langfuse extends that into a proper eval and experiment layer with datasets and live or offline evaluators. ([OpenAI GitHub][4])

So the “5-agent architecture” is not really five autonomous personalities. It is closer to five system responsibilities:

```text
1. Decide
2. Learn
3. Do
4. Judge
5. Remember
```

That is why the cookbook feels so different from old software development. In older apps, success often meant “request returned 200.” In agent systems, you need to know what the system decided, what it looked at, what it produced, and whether that output was actually good. The SDK and Langfuse are both built around that more granular view. ([OpenAI GitHub][2])

For your stack, the mapped version would be:

```text
User
  ↓
Planner agent
  ↓
Research agent
  ↓
Implementer agent
  ↓
Critic / judge
  ↓
Response

Parallel systems:
- LiteLLM for routing models
- Langfuse for traces, scores, experiments
- Your knowledge sources / MCP / Notion / docs as retrieval inputs
```

LiteLLM’s role in that picture is model routing and gateway behavior; Langfuse’s role is traces, evals, prompt and metrics support. They are complementary, not competing. ([langfuse.com][5])

The strongest practical lesson is this: do not start by building five complicated agents. Start by enforcing five phases, even if some phases are initially handled by the same model. For example, phase 1 plan, phase 2 retrieve, phase 3 execute, phase 4 judge, phase 5 store trace. Once the boundaries are visible, you can split them into separate agents only where the separation is actually buying you something. That is also consistent with the cookbook’s emphasis on tracing and evaluation first, because you cannot improve what you cannot observe. ([OpenAI Developers][1])

For your homelab and governance-heavy setup, I’d put it even more bluntly:

Planner decides scope.
Researcher proves grounding.
Implementer writes the artifact.
Critic checks against contract.
Memory keeps the audit trail.

That is the version that will fit your Notion/Langfuse/MCP style best.

I can turn this into a concrete starter template next: one for “planner + researcher + implementer + critic” with Langfuse trace points and LiteLLM routing notes.

[1]: https://developers.openai.com/cookbook/examples/agents_sdk/evaluate_agents/?utm_source=chatgpt.com "Evaluating Agents with Langfuse"
[2]: https://openai.github.io/openai-agents-python/tracing/?utm_source=chatgpt.com "Tracing - OpenAI Agents SDK"
[3]: https://openai.github.io/openai-agents-python/agents/?utm_source=chatgpt.com "OpenAI Agents SDK"
[4]: https://openai.github.io/openai-agents-python/config/?utm_source=chatgpt.com "Configuration - OpenAI Agents SDK"
[5]: https://langfuse.com/?utm_source=chatgpt.com "Langfuse"
