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
subject: SCOPE CORRECTION #166 — PAYOUT-005 + PAYOUT-008 (not 004) vs bank-bot claim
context: see thread #166 — correction: investigate PAYOUT-005 admin-cancel + PAYOUT-008 auto-cancel, not PAYOUT-004
needs_response: true
priority: normal
created: 2026-05-18T12:51:43+07:00
handled_at: 2026-05-18T12:57:00+07:00
handled_by_thread: 166
handled_by_inbox: 2026-05-18_12-57_from-next-impl_thread-166_reply.md
---

CORRECTION to thread #166: the user clarified the concern is PAYOUT-005 +
PAYOUT-008, NOT PAYOUT-004. Investigate: PAYOUT-005 (admin manual-cancel
of a pending payout) + PAYOUT-008 (auto-cancel sweep of a stale pending
payout) — siblings sharing the same atomic cancel + WHERE status='pending'
race-guard — do they deadlock / lose a race vs the bank-bot claim of the
same pending payout? Note PAYOUT-005 is just-authored (PR #150 unmerged,
likely no impl yet) — analyse vs spec, flag spec-vs-code. Rest of the
brief unchanged. Full correction in thread #166. Reply there.
