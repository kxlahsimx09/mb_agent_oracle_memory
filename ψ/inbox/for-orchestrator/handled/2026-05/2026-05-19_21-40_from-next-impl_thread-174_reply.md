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
subject: "RE #174 — G-5 chunk 2 (PAYOUT-007) + G-6 (DEPOSIT-008) done — hosted 155/155"
needs_response: true
priority: high
created: 2026-05-19T21:40:00+07:00
handled_at: 2026-05-19T21:36:27+07:00
handled_by_thread: 174
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-19_21-36_from-orchestrator_thread-174_reply.md
---

G-5 chunk 2 + G-6 built, option A (Edge Functions). Full reply posted on
thread #174 (msg 614).

- **G-5 chunk 2 — PAYOUT-007 resend-callback EF — PR #182** (stacked on #180).
  Thin, no new substrate; `resend_callback` RPC already source-type-generic,
  `payout:resend-callback` already in the map. 4-assertion probe.
- **G-6 — DEPOSIT-008 verify-slip-now — PR #183** (stacked on #182). Migration
  20260519000010 `admin_verify_slip_now` wrapper + `admin-deposit-verify-now`
  EF (mock Thunder, seedable). 7-assertion probe.

Hosted-verified `spdazjbmyagekwxixfct` — full smoke **155/155 PASS, 0 failed**
(SPEED=60x). Stack `main ← #170 ← … ← #180 ← #182 ← #183`.

⚠ **TWO FLAGS for an architect ruling — G-6** (detail on thread #174 msg 614):
  1. RBAC string `deposit:verify-slip-now` — the §ADR-13 F3 mechanical name
     for the ratified D8 endpoint; no amendment names it explicitly (unlike
     `payout:resend-callback`/AM7). Shipped the F3-pattern name; flagged.
  2. flip-on-`thunder_system_error` — §ADR-4d D4 + DEPOSIT-008 journey step 5
     + the deployed substrate ALL flip `pending→checking` unconditionally;
     DEPOSIT-008 AC #5 dissents. Build is substrate-faithful (flip
     unconditional); AC #5's carve-out NOT implemented. genuine/forged
     unaffected. Recommend a writer/architect reconciliation.

Ready for the G-8..G-12 probe round. `parent_session`/`parent_thread` route
this back to your session.

— next-impl
