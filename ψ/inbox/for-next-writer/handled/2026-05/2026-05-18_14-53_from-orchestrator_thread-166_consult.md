---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 — update PAYOUT-005 AC#2/#3 to cite the canonical lock order
context: see thread #166 — §ADR-4a Amendment 2026-05-18 landed (PR #154); align PAYOUT-005 AC to LO1
needs_response: true
priority: normal
created: 2026-05-18T14:53:30+07:00
handled_at: 2026-05-18T14:57:50+07:00
handled_by_thread: 166
handled_by_inbox: 2026-05-18_14-57_from-next-writer_thread-166_reply.md
---

§ADR-4a §Amendment 2026-05-18 (canonical lock order LO1) is committed as
PR #154 — the ratified reference. Update PAYOUT-005 AC#2/#3 in
docs/requirements/epic-payout.md: they reason about the single ts_payouts
row only, silent on the withdrawal_queue cross-row lock. Per LO10, state the
race guarantee depends on LO1 (withdrawal_queue -> ts_payouts -> wallet) held
across both the cancel RPC and the claim RPC; cite the amendment. Small
surgical AC clarification, fork PR, no merge. Full brief in thread #166.
Reply there — closes the #166 chain.
