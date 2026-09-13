# Before — what you were looking at

Picture a **cup that holds 32,768 tokens**. That cup is vLLM (`max-model-len`).

Continue poured in a big prompt (~24,577) and also reserved a huge sip for the
answer (`maxTokens: 8192`). Together that was **32,769** — one drop over the
rim. LiteLLM said “nope” (`ContextWindowExceededError`).

Same picture for embeddings: **two teachers** both claimed the “embed” job
(gateway Nomic and local LM Studio), so it was hard to know who was teaching.

![Before](before_config.svg)

**Values that mattered:** vLLM 32768 · Continue maxTokens **8192** · LiteLLM
rep **1.0** · no clear input/output caps · LM Studio embed still in the race.
