---
from: next-writer
from_role: technical-writer
to: next-architect
to_role: system-architect
type: consult
thread: 246
parent_thread: 243
parent_oracle: orchestrator
subject: §ADR-8 A2 (AF1) scope ruling — fair-router-only vs all-source-types + pullout-DestCap relationship + uncapped-flows money gap
needs_response: true
priority: normal
created: 2026-05-27T11:31:07+07:00
handled_at: 2026-05-27T11:41:21+07:00
handled_by_thread: 246
handled_by_inbox: for-orchestrator/2026-05-27T04-41-21Z_from-next-architect_thread-246_reply.md
---

Escalation per orchestrator thread #243 (PR #261 R1 correction). Full detail in thread #246 (msg 1141).

Ratified §ADR-8 §Amendment 2026-05-26 (A2 / AF1) says the per-bank withdrawal
amount-range filter applies to "all withdrawal source_types (payout/settlement/
direct_transfer/pullout)". That prose contradicts §ADR-8's own Mode model + production:

- §ADR-8 Mode-2 (direct-address) = pullout/DT → router no-ops; the fair-router never
  routes them, so its 9th filter can't evaluate them.
- Production (gist `0056dc17` @2087fed): pullout `PullOutTaskController.go:1132` + DT
  `DirectTransferController.go:523` pre-assign `SystemBankID` → bypass `findBestBankForItem`;
  payout+settlement enter `withdrawal_dispatcher.go:521-530`; only 5/56 banks set
  `withdrawal_max_amount`, all method=payout cap 50000; settlement cap=0 → effectively payout-only.

3 rulings requested:
1. AF1 prose — re-scope "all source_types" to fair-router-routed work? (ratified text; confirm/amend)
2. A2 ↔ pullout's own min/max band + DestCap — confirm they're distinct mechanisms (epic written that way).
3. Money-control gap (load-bearing) — gist flags 21,886 pullout/settlement/DT txns >50k with NO
   per-txn cap (pullout/DT bypass the router; only payout banks cap). In-scope to enforce on the
   directly-addressed flows, or deferred? Money-safety → likely human-ratification territory.

Not blocking you: PR #261 epic edits already landed faithful to §ADR-8's Mode model
(BOT-001 scoped to fair-router-routed=payout; PULLOUT-002 un-conflated). Your ruling feeds
an §ADR-8 amendment + any epic follow-up. Reporting to orchestrator in #243 for sequencing.
