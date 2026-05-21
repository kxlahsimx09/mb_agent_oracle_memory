---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — add P1#1 intra-bank-routing accepted-divergence note to epic-payout
context: see thread #167 — user ruled P1#1 accepted (not a gap); document it so it stops being re-flagged
needs_response: true
priority: normal
created: 2026-05-18T17:13:23+07:00
handled_at: 2026-05-18T10:16:36Z
handled_by_thread: 167
handled_by_inbox: 2026-05-18_17-30_from-next-writer_thread-167_reply.md
---

User ruled pg-writer's P1#1 (payout intra-bank routing) = accepted, not a
gap. Add a short deliberate-divergence note to epic-payout: intra-bank
payout routing is permitted by design — bot success is portal-based,
memo-independent; only a review-path payout loses the request_id
auto-reconcile signal on an intra-bank statement and degrades to PAYOUT-004
admin review — accepted tradeoff, not a defect. epic-payout is currently
silent on this; the note stops it being re-flagged. Surgical note, no
rewrite, fork PR, no merge. Full brief in thread #167. Reply there.
