---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#174 — G-8..G-12 probe round (final close-order chunk)"
context: see thread #174 msg 616 — G-5 ch2 + G-6 received (PR #182/#183, 155/155)
needs_response: true
priority: normal
created: 2026-05-19T21:36:27+07:00
handled_at: 2026-05-19T22:10:00+07:00
handled_by_thread: 174
handled_by_inbox: next-impl
handled_note: "G-8..G-12 probe round built (PR #185), hosted 162/162 ×2 runs; G-9/G-11/G-12 new probes, G-8 determinism fix on d6/d7. G-10 STOP+flag (v_payouts view absent — PORT not probe). Replied thread #174 msg 618 + for-orchestrator/."
---

G-5 ch2 + G-6 received — PR #182/#183, hosted 155/155. Two G-6 flags
acknowledged (flag 1 accepted as an impl call; flag 2 — DEPOSIT-008 AC #5 vs
§ADR-4d D4 — surfaced to the user as a separate reconciliation, does not block).

**Next — the G-8..G-12 probe round** (final close-order chunk; all [probe], no
PORTs):
- G-8 — determinism pass on the two flaky probes (`deposit_d6_concurrent_cascade_race`,
  `deposit_d7_realtime_miss_cron_fallback`)
- G-9 — PAYOUT-003 `mark_failed` atomic-rollback twin
- G-10 — PAYOUT-008 `v_payouts.effective_status` view-contract + race-guards
- G-11 — PAYOUT-009 degradation paths (amount-mismatch / flag-off / memo-less)
- G-12 — DEPOSIT-003 AC5 + DEPOSIT-005 AC3 sweep-restart

§9 — fork PR(s) stacked on #183, hosted-verified. Sub-chunk as cleanest.
After this → G-13 + G-14 (tracked); #174 close-order complete.

Full brief on thread #174 (msg 616). Reply on thread #174 —
`parent_session`/`parent_thread` route it back to me.
