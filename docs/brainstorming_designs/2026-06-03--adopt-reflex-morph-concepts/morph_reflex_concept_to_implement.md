> ## Documentation Index
> Fetch the complete documentation index at: https://docs.morphllm.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Reflexes for Tracing

> Label every turn your agent runs — jailbreaks, loops, frustrated users — by piping traces to Morph and letting Reflexes classify them off your request path

Your agent runs thousands of turns a day. The ones worth reading — the jailbreak attempt, the loop it never broke out of, the user who gave up after three bad answers — are a handful of rows buried in logs you'll never scroll through. LLM-as-a-judge over 100% of traffic is too slow and too expensive to leave running.

The fix is two pieces you already have: [tracing](/sdk/components/tracing) ships each turn to Morph as a span, and [Reflexes](/sdk/components/reflexes) put a label on every turn in \~90ms. Wire them together and every turn gets classified automatically, async, adding nothing to your latency. This guide takes you from an uninstrumented app to labeled traces you can alert on and mine for training data.

<Card title="Open the Traces dashboard" icon="timeline" href="https://morphllm.com/dashboard/traces">
  Where labeled turns land. Browse conversations and run Reflexes by hand; to export the raw turns, pull them from `GET /v1/reflex/traces`.
</Card>

## How the pieces fit

| Piece                      | What it does                                                                                          | Where it lives                        |
| -------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------- |
| **Tracing SDK**            | One `morph_tracing()` call instruments OpenAI / Anthropic / LangChain and exports spans to Morph.     | Your app, at startup.                 |
| **`begin()` / `finish()`** | Wraps a turn so it gets a stable `event_id` — the join key labels attach to.                          | Around each turn you want classified. |
| **`evals`**                | Names which Reflexes run on which role (`user` / `assistant`). Morph classifies after the span lands. | On `begin()`, or as a default.        |
| **Read-back**              | The dashboard and `GET /v1/reflex/traces` return each turn with its `reflex_results`.                 | Dashboard + API.                      |

The rule that drives everything below: **a turn is only classified if you wrap it in `begin()`.** Auto-instrumented LLM calls outside an interaction still get traced, but they have no `event_id`, so no label can attach.

## Wire it up

<Steps>
  <Step title="Instrument your app">
    Install the SDK with the OpenTelemetry extra and initialize once at startup. After this, calls to instrumented SDKs are traced with no further changes.

    <CodeGroup>
      ```python Python theme={null}
      # pip install 'morphsdk[otel]'
      from morphsdk.tracing import morph_tracing

      morph = morph_tracing({"api_key": "sk-..."})  # or set MORPH_API_KEY
      ```

      ```typescript TypeScript theme={null}
      // npm install @morphllm/morphsdk
      import { morphTracing } from "@morphllm/morphsdk/tracing";

      const morph = morphTracing({ apiKey: process.env.MORPH_API_KEY });
      ```
    </CodeGroup>
  </Step>

  <Step title="Wrap the turns you want classified">
    Open an interaction with `begin()`, set the input, nest any tool calls, and close it with `finish()`. The `event_id` it mints is what every label links back to.

    <CodeGroup>
      ```python Python theme={null}
      turn = morph.begin({"user_id": "u1", "convo_id": "c1", "event": "chat"})
      turn.set_input(user_message)
      answer = turn.with_tool({"name": "get_weather"}, lambda: get_weather("SF"))
      turn.finish({"output": answer})
      ```

      ```typescript TypeScript theme={null}
      const turn = morph.begin({ userId: "u1", convoId: "c1", event: "chat" });
      turn.setInput(userMessage);
      const answer = await turn.withTool({ name: "get_weather" }, () => getWeather("SF"));
      await turn.finish({ output: answer });
      ```
    </CodeGroup>

    Keep `convo_id` stable across a conversation so the dashboard threads turns together, and `user_id` consistent so you can slice labels by user later.
  </Step>

  <Step title="Turn on automatic classification">
    Pass `evals` on the turn. You choose which role each Reflex reads: `user` for the incoming message, `assistant` for the agent's output. Morph classifies each role after the span lands, off your request path.

    <CodeGroup>
      ```python Python theme={null}
      turn = morph.begin({
          "user_id": "u1",
          "convo_id": "c1",
          "event": "chat",
          "evals": {
              "user": ["jailbreak", "guardrail", "user-frustrated"],
              "assistant": ["leaked-thinking"],
          },
      })
      ```

      ```typescript TypeScript theme={null}
      const turn = morph.begin({
        userId: "u1",
        convoId: "c1",
        event: "chat",
        evals: {
          user: ["jailbreak", "guardrail", "user-frustrated"],
          assistant: ["leaked-thinking"],
        },
      });
      ```
    </CodeGroup>

    Set a default for every turn by passing `evals` to `morph_tracing` / `morphTracing`; a per-`begin` value overrides it. Omit both and nothing runs.
  </Step>

  <Step title="Read the labels back">
    Open the [Traces dashboard](https://morphllm.com/dashboard/traces) to browse turns with their labels, or pull them with the API. A freshly-traced turn shows "Classifying…" for a moment, then carries its `reflex_results`.

    ```python Python theme={null}
    import requests

    res = requests.get(
        "https://api.morphllm.com/v1/reflex/traces",
        headers={"Authorization": "Bearer YOUR_API_KEY"},
        params={"convo_id": "c1", "limit": 100},
    ).json()

    # Each Reflex's firing label, as the API returns it:
    FIRING = {"jailbreak": "jailbreak", "guardrail": "true", "user-frustrated": "Frustrated"}

    for turn in res["data"]:
        fired = [r["model"] for r in turn["reflex_results"] if r["label"] == FIRING.get(r["model"])]
        if fired:
            print(turn["event_id"], turn["input_text"][:60], "→", fired)
    ```

    `GET /v1/reflex/traces` returns LLM turns that carry text, newest first, each with the labels attached whether they ran from the SDK or by hand in the dashboard. Filter to one conversation with `convo_id`, page with `limit` / `offset`. A result's `selected` names the winning class even when it's the benign one (`["Not Frustrated"]`, `["false"]`), so test the `label` against the failure class, as above — non-empty `selected` is not a hit. See the [field reference](/sdk/components/tracing#list-traced-turns).
  </Step>
</Steps>

## Which Reflex on which role

Most safety and intent classifiers read the user's message; response-quality ones read the agent's output. A sensible starting set for a chat or coding agent:

| Reflex               | Role        | Catches                                                                                     |
| -------------------- | ----------- | ------------------------------------------------------------------------------------------- |
| `jailbreak`          | `user`      | Prompt-injection and jailbreak attempts before they shape the response.                     |
| `guardrail`          | `user`      | Harassment or NSFW content in the incoming message.                                         |
| `user-frustrated`    | `user`      | The user losing patience — the signal that your agent is failing in a way tests won't show. |
| `incomplete-thought` | `user`      | Truncated or underspecified prompts, so you can tell "bad answer" from "bad question."      |
| `leaked-thinking`    | `assistant` | The agent spilling internal reasoning or system instructions into its reply.                |
| `stuck-in-a-loop`    | `assistant` | The agent repeating itself instead of trying something new.                                 |

Start with two or three that map to a failure you actually care about, watch the dashboard for a day, then add more. Custom Reflexes you've [trained](/sdk/components/reflexes/custom) drop into the same `evals` arrays by name.

## Worked example: a GLM-5.3 agent, end to end

One Morph key runs the whole thing. The agent itself runs on [GLM-5.3](/sdk/components/fast-models) (`morph-glm53-744b`) through Morph's OpenAI-compatible endpoint; the same SDK call that points the OpenAI client at Morph also gets it auto-instrumented by tracing, so every model call is a span. Wrap each turn in `begin()` with `evals` and Reflexes label it off the request path. No second provider, no judge in the loop.

<CodeGroup>
  ```python Python theme={null}
  # pip install 'morphsdk[otel]' openai
  from openai import OpenAI
  from morphsdk.tracing import morph_tracing

  # 1. Auto-instrument. Default evals apply to every begin() turn.
  morph = morph_tracing({
      "api_key": "sk-...",  # or set MORPH_API_KEY
      "evals": {
          "user": ["jailbreak", "user-frustrated"],
          "assistant": ["leaked-thinking", "stuck-in-a-loop"],
      },
  })

  # 2. The agent runs on GLM-5.3 via Morph's OpenAI-compatible API.
  #    Same key, same base URL. This client's calls are now traced.
  client = OpenAI(api_key="sk-...", base_url="https://api.morphllm.com/v1")

  def handle_message(user_id, convo_id, user_message):
      # 3. Wrap the turn so the GLM-5.3 span gets an event_id to label.
      turn = morph.begin({"user_id": user_id, "convo_id": convo_id, "event": "chat"})
      turn.set_input(user_message)

      resp = client.chat.completions.create(
          model="morph-glm53-744b",
          messages=[
              {"role": "system", "content": "You are a helpful coding assistant."},
              {"role": "user", "content": user_message},
          ],
      )
      answer = resp.choices[0].message.content

      turn.finish({"output": answer})
      return answer
  ```

  ```typescript TypeScript theme={null}
  // npm install @morphllm/morphsdk openai
  import OpenAI from "openai";
  import { morphTracing } from "@morphllm/morphsdk/tracing";

  // 1. Auto-instrument. Default evals apply to every begin() turn.
  const morph = morphTracing({
    apiKey: process.env.MORPH_API_KEY,
    evals: {
      user: ["jailbreak", "user-frustrated"],
      assistant: ["leaked-thinking", "stuck-in-a-loop"],
    },
  });

  // 2. The agent runs on GLM-5.3 via Morph's OpenAI-compatible API.
  //    Same key, same base URL. This client's calls are now traced.
  const client = new OpenAI({
    apiKey: process.env.MORPH_API_KEY,
    baseURL: "https://api.morphllm.com/v1",
  });

  async function handleMessage(userId, convoId, userMessage) {
    // 3. Wrap the turn so the GLM-5.3 span gets an event id to label.
    const turn = morph.begin({ userId, convoId, event: "chat" });
    turn.setInput(userMessage);

    const resp = await client.chat.completions.create({
      model: "morph-glm53-744b",
      messages: [
        { role: "system", content: "You are a helpful coding assistant." },
        { role: "user", content: userMessage },
      ],
    });
    const answer = resp.choices[0].message.content;

    await turn.finish({ output: answer });
    return answer;
  }
  ```
</CodeGroup>

Nothing in the request path changed: GLM-5.3 answers exactly as before, no extra round-trip, no blocking on a judge. The labels appear on the trace shortly after each turn lands.

Read them back once the turns have landed — every GLM-5.3 turn now carries its Reflex labels:

<CodeGroup>
  ```python Python theme={null}
  from morphsdk import Morph

  morph_client = Morph(api_key="sk-...")  # or set MORPH_API_KEY

  # Each Reflex's firing label, as the API returns it:
  FIRING = {
      "jailbreak": "jailbreak",
      "user-frustrated": "Frustrated",
      "leaked-thinking": "leaked",
      "stuck-in-a-loop": "looping",
  }

  page = morph_client.traces.list(convo_id="c1", limit=100)
  for turn in page.data:
      fired = [r.model for r in turn.reflex_results if r.label == FIRING.get(r.model)]
      if fired:
          print(turn.event_id, turn.input_text[:60], "→", fired)
  ```

  ```typescript TypeScript theme={null}
  import { MorphClient } from "@morphllm/morphsdk";

  const morphClient = new MorphClient({ apiKey: process.env.MORPH_API_KEY });

  // Each Reflex's firing label, as the API returns it:
  const FIRING: Record<string, string> = {
    jailbreak: "jailbreak",
    "user-frustrated": "Frustrated",
    "leaked-thinking": "leaked",
    "stuck-in-a-loop": "looping",
  };

  const page = await morphClient.traces.list({ convoId: "c1", limit: 100 });
  for (const turn of page.data) {
    const fired = turn.reflexResults.filter((r) => r.label === FIRING[r.model]).map((r) => r.model);
    if (fired.length) console.log(turn.eventId, turn.inputText.slice(0, 60), "→", fired);
  }
  ```
</CodeGroup>

## What to do with the labels

A label is only worth collecting if you act on it.

* **Alert.** Poll `GET /v1/reflex/traces` (or wire the dashboard) and page on-call when `jailbreak` or `guardrail` fires, or when `user-frustrated` crosses a rate you set for a conversation.
* **Build training sets.** Filter traces by label to pull the exact turns you want — every `stuck-in-a-loop` turn, every frustrated exchange — and feed them into evals or fine-tuning. The list endpoint returns `input_text` and `output_text` directly.
* **Track trends.** Watch a label's rate over time to know whether a prompt change actually reduced frustration or just moved it.

<Note>
  Classification rides the trace export, so it adds nothing to your latency. Under the hood, evals go through the same queue as the [async batch API](/sdk/components/reflexes/batch) and are billed at the batch rate — $0.0005/event, stepping down to $0.00025 past 1M/month. You pay only for the turns you put in `evals`, not every traced span. See [Reflex pricing](/sdk/components/reflexes#pricing).
</Note>

## Backfill traces you already have

Turning on `evals` only labels turns going forward. To classify a backlog — every conversation from last month, scanned for jailbreaks and loops — run it from the [Traces dashboard](https://morphllm.com/dashboard/traces): select conversations, pick the Reflexes, and the labels land back on each trace. Under the hood that's an [asynchronous batch](/sdk/components/reflexes/batch#classifying-traces) over the text of each turn, billed at the discounted batch rate. No code required.

## Next steps

<CardGroup cols={2}>
  <Card title="Tracing reference" icon="timeline" href="/sdk/components/tracing">
    Every config field, direct OTLP ingest, and the `/v1/reflex/traces` schema.
  </Card>

  <Card title="Reflexes overview" icon="bullseye" href="/sdk/components/reflexes">
    The nine default classifiers, response shape, and realtime `/predict`.
  </Card>

  <Card title="Train a Custom Reflex" icon="wrench" href="/sdk/components/reflexes/custom">
    When the defaults don't match your failure modes, train one in \~30s and drop it into `evals`.
  </Card>

  <Card title="Batch classification" icon="layer-group" href="/sdk/components/reflexes/batch">
    Label a backlog of up to 10,000 rows offline at the discounted rate.
  </Card>
</CardGroup>
