Yes — your instinct is sound, with one important distinction:

An `AGENTS.md` inside `dotfile-vnext/` is a very good way to make **instructions and tool-selection policy local to that subtree**. If your agent respects hierarchical `AGENTS.md` files, then the file in `dotfile-vnext/` can govern work in that folder and its descendants without polluting the repository-wide instructions.

For the skills themselves, though, whether they can physically live inside `dotfile-vnext/` and only be discovered there depends on the agent/runtime you are using. `AGENTS.md` scoping and **skill discovery/loading** are two separate mechanisms.

The architecture I’d aim for is:

```text
repo/
├── AGENTS.md
├── skills/
│   ├── broadly-useful-skill-a/
│   └── broadly-useful-skill-b/
│
└── dotfile-vnext/
    ├── AGENTS.md
    ├── skills/
    │   ├── dotfile-specific-skill-a/
    │   ├── dotfile-specific-skill-b/
    │   └── dotfile-specific-skill-c/
    │
    ├── module-a/
    └── module-b/
```

Then the root `AGENTS.md` stays concerned with repository-wide behavior, while `dotfile-vnext/AGENTS.md` says something like:

```markdown
## dotfile-vnext local capabilities

The skills under `./skills/` are specific to work in `dotfile-vnext`
and its descendants.

Prefer these local skills when the current task falls within their
declared responsibilities.

Do not use these skills for work outside this subtree unless explicitly
requested.
```

That is exactly the kind of decomposition I would want if your global skill catalog is getting large enough that descriptions are being truncated to stay under a context-budget target.

There are really **three different benefits** here.

First, you reduce conceptual clutter. A skill such as:

```text
dotfile-vnext-state-migration
```

has no business competing for agent attention while you're editing Terraform, LiteLLM, or an unrelated part of the repository.

Second, you make skill routing easier. Inside `dotfile-vnext`, the agent can reason from a much smaller candidate set:

```text
global skills
     +
dotfile-vnext skills
```

instead of:

```text
one enormous global skill registry
```

Third, it gives you a natural ownership boundary. If you eventually delete `dotfile-vnext`, its specialized operating knowledge can disappear with it instead of leaving orphaned global skills behind.

The one thing I would verify before moving anything is **how your particular agent discovers skills**. If it only scans something like:

```text
~/.codex/skills/
```

or a single repository-level:

```text
.skills/
```

then merely creating:

```text
dotfile-vnext/skills/
```

will not automatically make those skills discoverable.

In that case, I would still keep the **skill source files physically local** to `dotfile-vnext`, but use a small registration/index mechanism at the global level rather than duplicating the full skill definitions.

For example:

```text
.codex/
└── skills/
    └── dotfile-vnext/
        └── references → ../../dotfile-vnext/skills/
```

or a tiny global entry whose only purpose is effectively:

```text
When working under dotfile-vnext/, consult:
dotfile-vnext/skills/
```

The exact mechanism depends on your agent implementation.

So I would separate the design into:

```text
INSTRUCTION SCOPE
AGENTS.md hierarchy

DISCOVERY SCOPE
Where the runtime looks for skills

IMPLEMENTATION SCOPE
Where the actual skill files live
```

Those don't have to be the same directory.

And I think your token-pressure observation is actually a sign that you **should** start doing this. If your agent is already saying, in effect, "I have so many skills that I'm compressing their descriptions to fit a 2% context budget," you've reached the point where capability locality becomes worthwhile.

I would not try to solve that by making every skill description shorter. That's treating the symptom.

The better progression is:

```text
Few skills
    ↓
Global catalog is fine

More skills
    ↓
Domain-grouped skills

Many specialized skills
    ↓
Hierarchical / locality-based skills
    ↓
Only expose relevant capability sets
```

`dotfile-vnext` sounds like a very clean candidate for that third stage.

One caution: don't make the local skills **too microscopic**. If you end up with 25 tiny skills that each handle one command, you've recreated the same discovery problem one level lower. I'd prefer perhaps 3–7 cohesive capabilities local to the subtree, each with a clear responsibility.

So yes: **put the domain-specific knowledge next to the domain**. Use `dotfile-vnext/AGENTS.md` to scope behavior there, and, if your runtime supports local skill discovery, put the actual skills there too. If it doesn't, keep their source local and expose only a lightweight registration mechanism globally.

Given what you're seeing with skill-description trimming, I think this is not merely organizational cleanup; it is probably the correct next step in your agent architecture.
