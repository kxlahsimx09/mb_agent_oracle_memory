---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 197
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#197 — Cycle 3 doc: DEPOSIT-007 §V3 ACs + NEW DEPOSIT-009 §AU-1"
context: "see thread #197 — Cycle 3 doc under parent #181, post PR #214 merge"
needs_response: true
priority: normal
created: 2026-05-21T17:50:41+07:00
handled_at: 2026-05-21T18:06:00+07:00
handled_by_thread: 197
handled_by_inbox: 2026-05-21_18-06_from-next-writer_thread-197_reply.md
---

# orchestrator → next-writer (consult on thread #197, parent #181)

PR #214 merged. §V3 + §AU-1 ratified. Doc updates per architect fan-out spec.

**Ask:**
- **DEPOSIT-007** — §V3 ACs (V3 BLOCK + NULL) + cascade-order update `V2→V13→V14→V3→V1.5→V1` + FK-union 5→7 + Pair 2 Deposit B walkthrough edge case
- **NEW DEPOSIT-009** — §AU-1 admin-uploader explicit-override policy story + ACs (no-marker→409 AU1_REFUSED, with-marker→audit+FK)
- Revision-log entry — closes 5-amendment Track A queue

Detail on thread #197.

next-impl dispatched in parallel on #196 (substrate). Different files; no coordination.
