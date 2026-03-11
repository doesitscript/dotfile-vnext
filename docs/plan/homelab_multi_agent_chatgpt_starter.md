Small pro tip for your multi-agent system

For the system you’re building, this combo is extremely stable:

planner      → gemini-3.1-pro-preview
researcher   → gemini-2.0-flash
fast tasks   → gemini-3.1-flash-lite-preview

That setup keeps research loops cheap but planning smart.

If you want, I can also show you a really slick Cursor trick:
you can create custom model aliases like

@planner
@researcher
@fast

and map them to Gemini models so your agent prompts stay clean. It makes multi-agent workflows much easier to manage.

------------
or your setup, I’d enable these:

gpt-4.1

gpt-4.1-mini

gpt-4o-mini

o3 only if you specifically want a heavier reasoning model and are okay with extra cost / usage-based billing in Cursor. Cursor staff noted o3 requires usage-based billing, while o4-mini was added separately and treated differently in their pricing model at the time.

My practical recommendation:

gpt-4.1 → main “smart default” for tougher coding/planning

gpt-4.1-mini → cheap everyday chat, refactors, research loops

gpt-4o-mini → fast lightweight tasks if it shows up for you

skip o3 for now unless you know you need it

--------------
