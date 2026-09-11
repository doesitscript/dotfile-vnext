# Experimental bounded parallel preflight

Use this optional stage before the serial Implementer/Evaluator loop when the
parent has four independent read-only questions. It improves elapsed time; it
does not create parallel implementation authority.

`run-parallel-preflight.ts` allows at most four allowlisted inspection/test
commands, gives each a finite timeout, and writes separate logs/receipts plus a
single `manifest.json`. The Implementer synthesizes relevant evidence into one
owned change and one review-ready handoff. The Evaluator reviews that handoff
serially. Worker exit failures are evidence to assess, not a license to guess or
skip target/authority gates.

Suggested lanes: infrastructure evidence, Ansible contract, research mapping,
and fast tests. No lane may edit repository files, send peer messages, release a
worker slot, create infrastructure, or run a live Apply.

For the current storage pass, split verified-route/SSH control-master evidence,
storage-report ownership mapping, and the Alloy/vLLM owner lookup. Those facts
can arrive together in the manifest. The Implementer alone decides which owner
to edit after reconciling them; the Evaluator still reviews the resulting single
handoff.
