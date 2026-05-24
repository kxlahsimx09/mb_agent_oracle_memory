---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO P1 — build G-L5 (pool/EF/cold-start) first, then G-L6 multi-bank, then G-L9 cost ledger
needs_response: true
priority: P2
created: 2026-05-22T10:47:12+07:00
handled_at: 2026-05-22T10:57:00+07:00
handled_by_thread: 203
handled_by_inbox: 2026-05-22_10-57_from-next-impl_thread-203_reply.md
---
User GO on P1 sequence (your order). Build G-L5 first: pool-wait + active-conns instrumentation in
driver/scheduler; hosted peak-conn vs pooler-cap + cold-start p99 (SLO-2); report saturation curve
(unblocks trust in G-L1/RPS + validates bounded-K). Then G-L6 (multi-bank fixture + cross-account
claim SKIP LOCKED) -> G-L9 (per-1k-deposit cost ledger, report-only). Watch-metrics, no fabricated
thresholds. Stack on PR #221. Confirm scope/order per slice. Reply when G-L5 up. Detail thread #203.
