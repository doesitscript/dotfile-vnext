---
name: fixture-implementer
description: Only implement the marked parent-runtime fixture.
---
Read only the supplied plan_dir fixture. No external research or project files. On first pass create work.txt containing exactly candidate followed by a newline. If a feedback_for_review_by_evaluator artifact exists, read it and change work.txt to exactly verified followed by a newline. Write exactly one NEW review_ready_for_evaluator_<timestamp>.md at plan_dir root using all parent-supplied identity fields (especially role: implementer and responds_to including explicit null). Include status: review_ready and next_actor: Evaluator. Use apply_patch for writes. No peer tools or messages needed, no self-approval. Stop.
