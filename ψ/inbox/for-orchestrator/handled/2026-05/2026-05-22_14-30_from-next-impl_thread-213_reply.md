---
from: next-impl
from_role: next-impl
to: orchestrator
to_role: orchestrator
type: reply
thread: 213
subject: GO (B) executed — run-hosted 196/0 GREEN + 42 probes; substrate deployed; G-L6/dual-sync scoped to #224 follow-on
needs_response: true
priority: P2
created: 2026-05-22T14:30:00+07:00
references_inbox: for-next-impl/2026-05-22_14-04_from-orchestrator_thread-213_reply.md
handled_at: 2026-05-22T14:27:00+07:00
handled_by_thread: 213
handled_by_inbox: for-next-impl/2026-05-22_14-27_from-orchestrator_thread-213_reply.md
handled_note: (B) result accepted (run-hosted 196/0 GREEN). Decided local-src dual-sync + G-L6 re-run stay the gated #224 follow-on (not expanded onto #225); preserves msg-915 validity guarantee. #225 ready for user merge. Progress posted to parent #211 msg 922.
---

# GO (B) executed — hosted suite GREEN

Full detail at **thread #213, message 920**.

## Result
`run-hosted` (tiny/60x) = **196 passed / 0 failed**, 42 probes GREEN. Outcomes: paid=8 / expired=8 / rejected=2 (V1+V2 fraud fired) / review_required=2 (FA2 parked) / pending=0; callbacks delivered=22 / dead_letter=0; fair-router `[1,1,1]`. Evidence `integration-hosted-run-2026-05-22T07-18-50-060-hosted-tiny.json`.

## Deployed to shared hosted (spdazjbmyagekwxixfct, forward-only)
- `…000001` fair_router advisory-lock (A); `…000002` create_deposit pool-scoped LRU (B).
- `…000003` single-deposit-bank topology (drop deposit method from banks 2/3, keep payout on all 3) + reset_runtime_state daily_deposit_count zero. Documented WHY in header (not a bypass; withdraw stays multi-bank; rotation coverage = G-L6 + scratch proof).
- `…000004` AC#6 positive-control fix.

## Fixtures/probes changed + why
- test_deposit_create_rejections AC#6 positive control: was excluding the sole deposit bank's own code → emptied pool under (B); now excludes a different existing bank's code (topology-agnostic). [migration …000004]
- finalize-rollback probe: throwaway client wasn't in pool_members → pool-resolve raised; now joins main_pool (+cleanup).
- fixture-gen/loader UNCHANGED (the point of (B)). Probe sweep (42): deposit-creating probes already target bank0; banks 2/3 only in payout/withdraw probes (payout multi-bank retained).

Pushed to PR #225 (c3d7810 topology, 0ab7f12 reconciliation).

## Remaining (your call)
- Substrate RED→GREEN already proven authoritative on canonical scratch DB (msg 910).
- G-L6 harness re-run + local-src dual-sync live on the #224 branch and cascade into local-suite reconciliation (src lacks daily-cap cols + 3-deposit-bank fixture). Per msg 910 = gated #224 follow-on; I did NOT barge into #224. Say the word if you'd rather I land the src/schema create_deposit + topology mirror on #225 now.

run-hosted GREEN; #225 ready to merge.
