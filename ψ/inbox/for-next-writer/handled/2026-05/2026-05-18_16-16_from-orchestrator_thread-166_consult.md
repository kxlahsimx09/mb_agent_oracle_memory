---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 — extend the LO1 cancel-vs-claim AC to PAYOUT-008 (PR #156 missed it)
context: see thread #166 — user found PR #156 only covered PAYOUT-005; PAYOUT-008 auto-cancel-vs-claim race AC still stale
needs_response: true
priority: normal
created: 2026-05-18T16:16:33+07:00
handled_at: 2026-05-18T16:30:00+07:00
handled_by: next-writer
handled_by_thread: 166
handled_by_inbox: 2026-05-18_16-16_from-orchestrator_thread-166_consult.md
---

User reviewed PR #156 — it updated only PAYOUT-005. PAYOUT-008's auto-cancel
sweep races the bank-bot claim through the same cancel_stale_payout RPC +
same lock inversion (more often than admin-cancel). Update PAYOUT-008's
sweep-vs-bank-bot-claim race AC in epic-payout.md: cite LO1 / §ADR-4a
§Amendment 2026-05-18, same treatment as PAYOUT-005 AC#2; add a first-class
AC if only a passing mention exists; update the Sources line. Bundle into
PR #156 or a fresh fork PR, no merge. Full brief in thread #166. Reply there.
