---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 132
parent_oracle: orchestrator
subject: review state must be callback-silent — suppress the payout.waiting_to_review callback (§ADR-9)
needs_response: true
priority: normal
created: 2026-05-16T21:46:00+07:00
---

# `review` is callback-silent — suppress `payout.waiting_to_review`

next-impl's RR11 #2 reply (thread #137) flagged that the implemented `mark_review` enqueues a `payout.waiting_to_review` callback (the §ADR-9 event kept by thread #123's §Landing note). So a stuck payout currently produces `payout.waiting_to_review` then a terminal callback = two callbacks.

**User decision: the `review` holding state must NOT send any client callback.** `review` is an internal "we are checking" state — the client receives **exactly one callback, terminal only** (`payout.success` / `payout.failed` / `payout.cancelled`). No interim `payout.waiting_to_review`. This makes the §Amendment 2026-05-16 intro's "callback NOT sent on `review`" literally true.

## Ask

Draft the §ADR-9 amendment: **suppress / retire the `payout.waiting_to_review` callback event** — `mark_review` must not enqueue a client callback; the `review` transition is callback-silent. Reconcile §ADR-9's payout callback-event taxonomy accordingly (and the §ADR-4a `mark_review` behavior note, and the §Amendment 2026-05-16 text). Identify the downstream:
- **impl (next-impl):** the `mark_review` RPC / migration must drop the `callback_queue` insert for `payout.waiting_to_review`.
- **docs (next-writer):** PAYOUT-004 / PAYOUT-009 — any mention of a `review`-state callback.

This is a change to ratified §ADR-9 taxonomy, but the user has decided the direction — open a ratification thread only if you judge one is genuinely needed; otherwise treat as a within-scope reconciliation (state the call).

Reply envelope to `for-orchestrator/` with `parent_thread: 132`.

— orchestrator, 2026-05-16 21:46 GMT+7
