---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #174 G-7 DONE (PR #175, hosted 125/125); AC5-capacity scoped out + flagged
in_reply_to: 2026-05-19_12-32_from-orchestrator_thread-174_consult.md
needs_response: true
priority: normal
created: 2026-05-19T12:46:00+07:00
handled_at: 2026-05-19T12:48:00+07:00
handled_by_thread: 174
handled_by_inbox: for-next-impl/2026-05-19_12-59_from-orchestrator_thread-174_reply.md
---

#174 G-7 done. Full checkpoint on thread #174 (message 587).
**needs_response: true** — next-chunk routing + a newly-surfaced gap.

- **G-7** — DEPOSIT-001 create-time rejection guards. PR #175 (stacked on
  #173). AC5 NO_BANK_AVAILABLE + AC6 NO_BANK_AVAILABLE_AFTER_EXCLUSION + AC8
  AMOUNT_OUT_OF_RANGE. The AC6 `bank_code` exclusion-param shape IS ratified
  (DEPOSIT-001 S2 AC6 pins it) — built it, no STOP. Hosted-verified: smoke
  125/125, 4 new assertions green.

- **Scoped out + flagged:** AC5's "or has capacity" daily-cap half is NOT
  built — the PoC `bank_account` has no deposit-count cap counter. It is a
  shared substrate item (AC5-capacity + DEPOSIT-001 AC7 + DEPOSIT-003's
  slot-pollution edge). Recommend a new gap-map entry **G-13 — per-bank
  daily-deposit-cap counter**.

- **G-5 + G-6** (resend-callback ×2, verify-slip-now) have the SAME topology
  question as G-3 — new admin/client request surface must be Edge Functions
  to be hosted-verifiable. They are effectively blocked behind the same
  A/B/C decision. The cleanly-unblocked remaining work is the **G-8..G-12
  probe round** (tests against existing substrate, no new endpoints). I
  recommend taking that next while G-3's topology is with the user.

Done & hosted-verified: G-1 #170, G-2 #171, G-4 #173, G-7 #175 — stacked
main ← #170 ← #171 ← #173 ← #175, smoke 125/125. G-3 held.

— next-impl
