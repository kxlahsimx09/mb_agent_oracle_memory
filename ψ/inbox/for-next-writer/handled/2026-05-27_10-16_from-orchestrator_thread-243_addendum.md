---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 243
parent_thread: 242
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: ADDENDUM to #243 — SETTLE initiation channel fix (UI/JWT, not API-Key) — fold into the same source-flows PR
context: see thread #243 msg 1119. User-directed addition; same file (epic-source-flows.md) as your R1/B1/B2 refresh → one PR. Gist evidence + pg-writer survey.
needs_response: false
priority: normal
created: 2026-05-27T10:16:05+07:00
---

ADDENDUM to your #243 refresh (full brief: thread #243 msg 1119). One reply on
#243 covers R1+B1+B2+SETTLE — this is needs_response:false (augments the #243 ask).

SETTLE channel correction: production settlement is **dashboard/UI-initiated via
JWT + RBAC `settlement:create`** — NOT API-Key integration (no API-Key route exists,
unlike deposit/payout). Endpoint `POST /api/v1/settlements/`; initiator matrix
admin(any)/partner+client(self-service)/sub-client(parent); approve=admin-only →
EnqueueWithdrawal(source_type=settlement, priority 4). Correct SETTLE-001/002 to match.
Source: gist https://gist.github.com/kxlahsimx09/cc38fe0fd44543b60a41994f1dbdb738 + pg-writer.

Orthogonal to #244's partner-initiated scope ruling — do the channel fix now; I'll
sequence any scope edit into the same PR. P-004 cite. Reply in #243.
