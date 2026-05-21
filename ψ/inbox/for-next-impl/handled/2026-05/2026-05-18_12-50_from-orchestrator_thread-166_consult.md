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
subject: deadlock/race check — PAYOUT-004 + PAYOUT-008 sweeps vs bank-bot claim
context: see thread #166 — investigate lock-ordering / race between the payout sweeps and the bot claim path
needs_response: true
priority: normal
created: 2026-05-18T12:50:37+07:00
handled_at: 2026-05-18T12:57:00+07:00
handled_by_thread: 166
handled_by_inbox: 2026-05-18_12-57_from-next-impl_thread-166_reply.md
---

User concern: do the PAYOUT-004 sweep-triage (stuck claim -> review) and
PAYOUT-008 auto-cancel (stale pending payout) deadlock or lose a race
against the bank-bot claim path? User's model: the bot locks the queue
first. Investigate lock acquisition order in the sweep RPCs + the claim
RPC, check for lock-ordering inversion + race-claim windows, verify the
WHERE status= race-guards / FOR UPDATE ordering. Report only, cite
file:line, recommend fix owner if a hazard exists. Full brief in
thread #166. Reply there.
