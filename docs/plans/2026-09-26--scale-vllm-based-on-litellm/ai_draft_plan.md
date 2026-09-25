Yes — and I think the thing you're looking for is **much simpler than KEDA** if your only requirement is:

> "If this vLLM model hasn't received a request for X minutes, shut it down; when I request it again, bring it back."

The simplest pattern is a **small idle-timeout controller/proxy** in front of vLLM.

### What I'd do in your K3s setup

Keep **LiteLLM running continuously**:

```text
OpenAI API
     │
     ▼
  LiteLLM
     │
     ▼
  vLLM 32B
     │
     ▼
    GPU
```

Then have a tiny controller watch **requests to that particular LiteLLM model**.

For example:

```text
Request arrives
      │
      ▼
LiteLLM → vLLM
      │
      └── reset "last used" timer
                  │
                  ▼
            30 minutes idle?
                  │
                 YES
                  │
                  ▼
        kubectl scale vllm --replicas=0
```

When the next request arrives:

```text
OpenAI request
      ↓
LiteLLM
      ↓
vLLM isn't running
      ↓
scale vLLM → 1
      ↓
wait for Ready
      ↓
send request
```

### But there's one important issue

If you literally scale vLLM to **0**, something has to notice the next request **before** trying to send it to vLLM.

That's why I wouldn't make the mechanism "watch vLLM traffic." Once vLLM is at zero, there is no vLLM process receiving traffic to watch.

Instead, watch the traffic **at LiteLLM**.

And that's particularly convenient for you because **all your agents are already going through LiteLLM**.

You can therefore make the logic specific to your large model:

```text
Agent
  │
  ├── small model → normal path
  │
  └── 32B model → LiteLLM
                       │
                       ├── running → forward
                       │
                       └── asleep → wake vLLM
```

You don't have to make your agents aware that the GPU model is sleeping.

### One thing I'd check before building anything

There may already be a **very lightweight existing Kubernetes component that does exactly this**, and I'd rather use that than have you maintain a custom controller.

Given that you're using **K3s + LiteLLM + vLLM**, I can specifically look for the simplest existing solution that supports:

* OpenAI/LiteLLM traffic as the trigger
* vLLM Deployment scaling `0 → 1`
* waiting for vLLM readiness
* forwarding the original request
* scaling back to `0` after an idle period
* minimal additional components

That's the part I'd research rather than automatically reaching for KEDA.
