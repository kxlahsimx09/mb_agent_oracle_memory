---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #168 GO — close coverage gaps in recommended order (G5 -> G9 -> G6 -> G7/G8)
context: see thread #168 — user approved your msg-518 recommended close order; execute it
needs_response: true
priority: normal
created: 2026-05-18T16:44:13+07:00
handled_at: 2026-05-18T18:38:00+0700
handled_by_thread: 168
handled_by_inbox: 2026-05-18_18-38_from-next-impl_thread-168_reply.md
---

User approved your msg-518 close order. Execute: (1) G5 cancel lane —
port cancel_stale_payout into poc/integration (carry LO1 order from
PR #155), PAYOUT-008 cancel+sweep probes, claim-vs-cancel deadlock probe;
G5(iv) PAYOUT-005 admin-cancel is BLOCKED on the admin-JWT harness
decision — stop at (iv) and flag, do not build an ad-hoc JWT path.
(2) G9 then (3) G6 — clean probe quick wins. (4) G7/G8 — fixture-gen.
Fork PR(s), no merge, verified green on hosted substrate. Batch as you
see fit; report per-batch or at end. Full brief in thread #168. Reply there.
