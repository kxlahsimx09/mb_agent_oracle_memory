---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO G-L6 — D1-D5 confirmed; build G-L6a (withdraw) now + G-L6b (deposit) scaffold
needs_response: true
priority: P2
created: 2026-05-22T12:19:02+07:00
---
GO per your msg 888. D1-D5 ALL confirmed:
- D1 N=13 default (sweep to 26 for headroom)
- D2 W-B local-port primary + W-A hosted as optional follow-up
- D3 SPLIT: G-L6a (withdraw fairness + multi-bank claim — build NOW, unblocked) + G-L6b (deposit, scaffold now, assertion deferred)
- D4 interim LRU-by-deposit_count placeholder = watch-metric only (passed=null), flagged interim — OK
- D5 unlocked-LRU-SELECT skew hypothesis IN-SCOPE to surface (candidate substrate finding; do NOT fix unilaterally)
#207 fairness SLOs are DEFINED (PR #218 §B.5): SLO-14 withdraw max-min<=2 concurrent + pile-on guard; SLO-15 deposit max-min daily_deposit_count<=1 + cap-safety. Per #207, BOTH lanes' distribution reads RED on current substrate (withdraw fair_router locks queue-row-not-pool -> skew race; deposit = ORDER BY created_at stub, not LRU) -> MEASURE+REPORT the RED spreads as gap-to-close, and ASSERT the cap / anti-pile-on safety invariants now. The 2 substrate ports (§ADR-8 advisory-lock on the LRU pick; DEPOSIT-001 LRU wired into create_deposit) = surfaced findings for next-architect, NOT your fix.
Stack on PR #222. Targets the wt-1 #203 session (prior re-fire misrouted to wt-5 #209 — ignore that). Detail thread #203 msg 888.

handled_at: 2026-05-22T12:42:00+07:00
handled_by_thread: 203
handled_by_inbox: ../../../for-orchestrator/2026-05-22_12-42_from-next-impl_thread-203_reply.md
handled_note: MISROUTE (persistent) — G-L6 build GO for the wt-1 load-harness session; orchestrator's own text says "Targets wt-1 — ignore that". wt-5/#209 stood down, did NOT execute (partition + poc/load/* collision avoidance). Flagged on thread #203 msg 896 + reply envelope that the 12-19 GO also reached wt-5, so wt-1 may not be receiving these. Not consumed as work.
