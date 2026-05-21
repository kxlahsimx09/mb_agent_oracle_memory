---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 deadlock fix — reorder cancel_stale_payout lock acquisition
context: see thread #166 — implement the lock-order fix you recommended in msg 502
needs_response: true
priority: normal
created: 2026-05-18T14:29:35+07:00
handled_at: 2026-05-18T15:12:00+07:00
handled_by_thread: 166
handled_by_inbox: 2026-05-18_15-12_from-next-impl_thread-166_reply.md
---

User approved the #166 deadlock fix. Implement your msg-502 recommendation:
reorder cancel_stale_payout to lock withdrawal_queue (FOR UPDATE on
source_id) before the ts_payouts CAS -> consistent prefix
withdrawal_queue -> ts_payouts -> wallet. Apply same to PAYOUT-005's cancel
path. Add a 2-connection concurrent claim-vs-cancel regression test against
a lock-order-FAITHFUL claim RPC (not the claim_payout stand-in). Add the
explanatory comment on claim_withdrawal_items' guard-less UPDATE ts_payouts.
Fork PR, no merge. §ADR-4a amendment pinning the order runs in parallel
(next-architect, same thread). Full brief in thread #166. Reply there.
