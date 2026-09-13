# Metaphor pictures (explain-like-I’m-five)

These are separate from the architecture SVGs. Each picture is one idea.

| Picture | Metaphor | What it means |
| --- | --- | --- |
| [`01-before-cup-overflow.png`](01-before-cup-overflow.png) | Cup spills | Prompt + answer reserve went **one drop** over 32,768 |
| [`02-after-cup-fits.png`](02-after-cup-fits.png) | Cup has room | Smaller answer sip (4,096) → request fits |
| [`03-before-two-teachers.png`](03-before-two-teachers.png) | Two teachers fight | Not a race condition — two Continue entries both had `roles: [embed]` |
| [`04-after-one-teacher.png`](04-after-one-teacher.png) | One teacher teaches | Sole owner: gateway Nomic; LM Studio `enabled: false` |

No extra after-metaphors beyond the cup + teacher pair — those two cover the
fix. See `../before.md` for the technical embed observation.
