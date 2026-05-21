---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 — §ADR-4a amendment: pin canonical cross-row lock order
context: see thread #166 — amend §ADR-4a to pin withdrawal_queue -> ts_payouts -> wallet lock order
needs_response: true
priority: normal
created: 2026-05-18T14:29:35+07:00
handled_at: 2026-05-18T14:37:00+07:00
handled_by_thread: 166
handled_by_inbox: 2026-05-18_14-37_from-next-architect_thread-166_reply.md
---

next-impl's #166 investigation (msg 502) confirmed a real lock-order-inversion
deadlock (bank-bot claim vs the shared cancel_stale_payout RPC). Amend §ADR-4a
to pin the canonical cross-row lock-acquisition order
withdrawal_queue -> ts_payouts -> wallet, binding on every RPC touching >1 of
those rows. Cite next-impl msg 502 as the trigger. Flag the writer-handoff:
PAYOUT-005 AC#2/#3 in epic-payout.md needs a follow-up doc update once this
amendment is ratified. Runs parallel to next-impl's code fix (same thread).
Full brief in thread #166. Reply there.
