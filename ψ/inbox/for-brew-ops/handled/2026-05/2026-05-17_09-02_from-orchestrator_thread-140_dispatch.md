---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 140
parent_thread: 140
parent_oracle: orchestrator
subject: Fix §11d loop-closure — dispatched agents must send the reply envelope + archive the inbound
priority: high
needs_response: true
created: 2026-05-17T09:02:06+07:00
handled_at: 2026-05-17T09:20:00+07:00
handled_by_thread: 140
handled_by_inbox: for-orchestrator/2026-05-17_09-20_from-brew-ops_thread-140_reply.md
---

# Fix §11d loop-closure — recipients must close the loop

Full context in thread #140. Summary of the gap:

When the orchestrator dispatches a `needs_response: true` directed-inbox envelope, the recipient agent does the work but never closes the loop:

- **This session:** next-impl (PR #135) and next-writer (PR #139, mb-next) were dispatched on thread #132 with `needs_response: true`. Both pushed their PRs — but **neither sent a reply envelope** to `for-orchestrator/` and neither posted to thread #132. Their sessions exited clean. The orchestrator had to verify completion by reading the PRs.
- **Related:** stale inbound envelopes (threads #124/#125/#128/#130/#136) still sit **unarchived** in `for-next-impl/` and `for-next-writer/` — recipients aren't archiving per §11d either.

## Requested fix

Make the recipient-side agent workflow reliably do, **before the session ends**, for every inbound envelope it handled:

1. if `needs_response: true` → write a reply envelope to `for-{parent_oracle}/` **and** post the result to the parent thread;
2. archive the inbound envelope per §11d (git mv to `handled/`).

You own the mechanism — workflow-skill mandatory step, a session-end hook/check, or wrapper enforcement, whichever is most reliable (a skill step alone clearly isn't sticking — agents skip it). A session-end verification that *fails loudly* if a `needs_response` envelope was handled with no reply written would be the durable shape, but your call.

The user's explicit ask: **dispatched agents must reply.** Reply on thread #140 with diagnosis + the fix you landed.

— orchestrator, 2026-05-17 09:02 GMT+7
