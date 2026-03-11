# Two Azure OpenAI guides — model tasks and what’s interesting

Short summary of **two guides** about Azure OpenAI: what they do with models, what tasks they show, and what stands out. (Useful for README or “what can I do with a deployment?” context.)

---

## Guide 1: Microsoft Learn — Create an Azure OpenAI Resource and Deploy a Model (+ Natural Language to SQL)

**Source:** [Create an Azure OpenAI Resource and Deploy a Model](https://learn.microsoft.com/en-us/microsoft-cloud/dev/tutorials/openai-acs-msgraph/02-openai-create-resource) and [Natural Language to SQL](https://learn.microsoft.com/en-us/microsoft-cloud/dev/tutorials/openai-acs-msgraph/03-openai-nl-sql) (same tutorial series).

### What they do with the model

1. **Create resource and deploy gpt-4o**  
   Create an Azure OpenAI resource (Standard S0), then in Azure OpenAI Studio deploy **gpt-4o** with a **Tokens per Minute** rate limit (e.g. 100K) so the app doesn’t hit limits.

2. **Chat playground — simple GenAI tasks**  
   In **Playgrounds → Chat** they use the deployment for:
   - **Summarization:** “Summarize what Generative AI is and how it can be used.”
   - **Short factual answer:** “Provide a short history about the capital of France.”

3. **App integration**  
   They wire the deployment into a full stack: **.env** with `OPENAI_API_KEY` and `OPENAI_ENDPOINT`, then start PostgreSQL, a TypeScript API server, and a web client. The **model name** in .env matches the deployment name (e.g. `gpt-4o`).

4. **Natural language → SQL (main model task)**  
   The follow-up exercise uses **the same gpt-4o deployment** to:
   - Turn **natural language** into **SQL** for a PostgreSQL DB (e.g. “Get the total revenue for all orders. Group by company and include the city” or “Get the total revenue for Adventure Works Cycles. Include the contact information as well.”).
   - Return a **JSON object** with `sql` and `paramValues` so the server can run **parameterized queries** (to avoid SQL injection).
   - The server calls a `getSQLFromNLP(userPrompt)` that builds a **system prompt** with the DB schema, rules (“convert strings to parameterized values”), and few-shot examples, then calls the Azure OpenAI chat API. Results are queried from PostgreSQL and shown in the browser.

### Interesting bits

- They explicitly say: *“Just because you can doesn’t mean you should”* — and stress **when** natural-language-to-SQL is appropriate, plus **prompt rules and database security** (e.g. a `isProhibitedQuery()` check on generated SQL).
- **One deployment (gpt-4o)** is used for both “chat-style” answers and structured output (JSON with SQL + params).
- End-to-end flow: portal → deploy model → playground → then same model in an API route that drives a real DB and UI.

---

## Guide 2: Microsoft Learn — Embeddings and document search

**Source:** [Tutorial: Explore Azure OpenAI embeddings and document search](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/tutorials/embeddings).

### What they do with the model

1. **Deploy an embeddings model**  
   Use a **text-embedding** model (e.g. **text-embedding-ada-002** v2, or text-embedding-3-small/large) in a supported region.

2. **Embed a document set**  
   - Download **BillSum** (US Congress bills) as a CSV; keep columns like `text`, `summary`, `title`.
   - Normalize text, then **token-count** with `tiktoken` and drop rows over the model’s limit (e.g. 8,192 tokens) so every document is embeddable.
   - Call the **embeddings API** once per document (or in batches; max 2,048 inputs per call) and store the vectors in a column (e.g. `ada_v2`).

3. **Search with cosine similarity**  
   - User asks in plain language, e.g. **“Can I get information on cable company tax revenue?”**
   - **Embed the query** with the same model.
   - Compute **cosine similarity** between the query vector and each document vector; rank and take top‑k (e.g. top 4).
   - Show the best-matching bill(s); in the guide the top hit is “Taxpayer’s Right to View Act of 1993” with similarity ~0.76.

### Interesting bits

- **No chat model** — only embeddings. The “task” is **semantic search over a knowledge base**, not generation.
- They point out you can store embeddings in **Azure Cosmos DB**, **Azure SQL**, **PostgreSQL (pgvector)**, **Azure AI Search**, etc., for real vector search at scale.
- Uses **Jupyter + pandas + scipy/sklearn** for similarity; good template for “embed a corpus once, then search with ad-hoc queries.”
- Clear pattern: **normalize → token-check → embed → similarity → rank**.

---

## Summary table

| Guide        | Model(s) used              | Tasks with the model |
|-------------|----------------------------|------------------------|
| **Learn: Create + NL to SQL** | gpt-4o (one deployment)     | Chat (summarize, short answer); **natural language → SQL** (JSON with parameterized SQL); drive PostgreSQL and a web UI. |
| **Learn: Embeddings**        | text-embedding-ada-002 (or -3-small/large) | Embed bills; embed user query; **cosine similarity**; return top‑k docs (semantic search). |

Both guides are from Microsoft Learn; one is older (portal + Studio, gpt-4o, NL→SQL), one is current (Foundry-era embeddings tutorial). Either way they show concrete **tasks** you can do with a deployed model: chat + structured output (SQL) in the first, embeddings + search in the second.
