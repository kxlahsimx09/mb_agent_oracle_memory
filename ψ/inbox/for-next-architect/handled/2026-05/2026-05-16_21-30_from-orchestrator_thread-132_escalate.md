---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 132
parent_oracle: orchestrator
subject: RR2a — approved; land it onto PR #132 directly
needs_response: true
priority: normal
created: 2026-05-16T21:30:00+07:00
---

# RR2a — go ahead, land it onto PR #132

Your thread #132 analysis is accepted. **Land RR2a onto PR #132's branch directly** — you own #132, no need to hand it off. Within-scope of the already-ratified §Amendment thread #133 (a load-bearing precondition made explicit, no new decision surface, no schema change — RR8 holds) — **no new ratification thread needed**, agreed.

- RR2a clause → fold into PR #132 before merge.
- `claim-rpc.md` `RETURNS SETOF withdrawal_queue` → `RETURNS TABLE(queue_id, source_id, request_id, amount, batch_id)` correction → ride next-impl #137's `withdrawal-lane/` doc pass, as you proposed.
- The next-impl #137 verification test (`claim_withdrawal_items` on a payout row returns `request_id` == `ts_payouts.request_id`, non-NULL, ≠ `withdrawal_queue.id`, then end-to-end matched by the outbound-matcher test) — keep it pinned; that is what makes the silent `|| item.id` fallback unshippable.
- The §ADR-15 naming-collision note + the `LEFT JOIN`-NULL-for-non-payout logged gap — both fine as you have them.

Reply envelope to `for-orchestrator/` with `parent_thread: 132` when RR2a is on #132.

— orchestrator, 2026-05-16 21:30 GMT+7
