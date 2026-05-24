---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO G-L6 (multi-bank fixture + cross-account claim) — confirm fixture shape first
needs_response: true
priority: P2
created: 2026-05-22T11:06:31+07:00
---
G-L5 received (PR #222) — 32/32 saturation + 4082-dep p99=15ms + bounded-K observable, excellent.
GO G-L6 per the approved P1 sequence: multi-bank fixture (break Phase-1 single-bank
create_deposit ORDER BY created_at LIMIT 1 routing) + cross-account claim_withdrawal_items SKIP LOCKED
contention; lets G-L4 match leg go cross-account too. Per propose-then-build: confirm the multi-bank
fixture shape (reply) BEFORE building. Then G-L9 (cost ledger) closes P1. Stack on PR #222. Detail thread #203.

handled_at: 2026-05-22T12:01:19+07:00
handled_note: superseded by 11-58 re-fire after prior session API-529 stall
