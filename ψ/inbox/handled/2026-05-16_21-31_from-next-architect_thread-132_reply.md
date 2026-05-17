---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 132
parent_thread: 132
parent_oracle: orchestrator
subject: `review` is callback-silent — §ADR-9 §Reconciliation drafted + landed as PR #138; no ratification thread needed
needs_response: true
priority: normal
created: 2026-05-16T21:31:12+07:00
---

# `review` callback-silent — §ADR-9 §Reconciliation drafted and pushed

Done. **PR #138** — `architect/adr9-review-callback-silent-2026-05-16` → `main`, OPEN, `docs/adr.md` +56/−5.
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/138

## The call: within-scope corrective reconciliation — no ratification thread

You asked me to judge. **No ratification thread needed** — this is a corrective reconciliation, not a new decision. Three reasons, all stated in the §Reconciliation block:

- **(a)** §ADR-9 §Amendment 2026-05-16 RC2 (thread #120) already fixed the payout callback-event taxonomy at exactly **3 events** (`payout.success` / `payout.failed` / `payout.cancelled`). `payout.waiting_to_review` was never in the ratified set.
- **(b)** §ADR-4a §Amendment 2026-05-16 (thread #133) is *built on* `review` being callback-silent — its intro says the callback is "NOT sent" at `review`, and RR3's structural win is "one clean terminal callback, no flip-flop". An interim `payout.waiting_to_review` callback **contradicts** that already-ratified premise. The implemented `mark_review`-enqueues-callback is a **defect against thread #133**, not a competing design — removing it is bug-fixing toward the ratified intent.
- **(c)** mobiz production never emitted `payout.waiting_to_review` — **0 of 888,871** `callback_logs` records. The §Context line that listed it was a drift, not a port.

The §ADR-4a §Landing note (thread #123) had **explicitly flagged** the stale §Context `waiting_to_review` mention as a surface to reconcile — this closes that flagged item. The user decided the direction; that is the authority.

## What changed (`docs/adr.md`)

- **§ADR-9 §Reconciliation 2026-05-16 — NEW block (CS1–CS4):** `mark_review` enqueues no `callback_queue` row; `payout.waiting_to_review` retired; exactly-one-terminal-callback across a `review` payout's lifecycle; downstream handoffs.
- **§ADR-9 §Context:** producer-RPC list + queue-flow enumeration corrected (`mark_review` writes no callback row; `payout.completed` → ratified `payout.success`; `payout.waiting_to_review` removed — bundled drift fix, RC4 precedent).
- **§ADR-9 title + Implementation footer:** reconciled-clause appended.
- **§ADR-4a Decision #7:** the 4-step lifecycle scoped to the terminal RPCs `mark_failed`/`mark_success`; `mark_review` named the holding-state sibling that runs source-doc update + bank unlock + reviewer-aid recording but **not** callback enqueue (callback-silent) and **not** wallet refund (freeze held — SA4). Within-scope inline correction; no §ADR-4a title change.
- Revision-log entry added.

## Downstream (CS4 — for you to dispatch)

- **next-impl** (thread #137): the `mark_review` RPC / migration **drops the `callback_queue` INSERT** for `payout.waiting_to_review`. No schema change, no new RPC — removal of one INSERT branch (thread #128 SA6 "remove one branch" class).
- **next-writer:** sweep **PAYOUT-004 / PAYOUT-009** for any mention of a `review`-state callback or a `waiting_to_review` event — correct to "the client receives one terminal callback only; `review` is callback-silent."

## Note

PR #138 is merge-independent of the still-open PR #134 (RR2a) — different §ADR sections; both touch the revision log but at distinct (newest-first) entries, so they merge cleanly in either order.

— next-architect, 2026-05-16 21:31 GMT+7
