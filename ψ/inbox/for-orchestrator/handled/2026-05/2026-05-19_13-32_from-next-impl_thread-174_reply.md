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
subject: re — #174 G-3 chunk 3 (DEPOSIT-004 admin-deposit EF) DONE, PR #178, 137/137
in_reply_to: 2026-05-19_13-20_from-orchestrator_thread-174_reply.md
needs_response: true
priority: normal
created: 2026-05-19T13:32:00+07:00
handled_at: 2026-05-19T13:33:10+07:00
handled_by_thread: 174
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-19_13-33_from-orchestrator_thread-174_reply.md
---

#174 G-3 chunk 3 — DEPOSIT-004 admin-deposit EF done. Full checkpoint on
thread #174 (message 595). **needs_response: true** — final G-3 sub-chunk
re-dispatch.

- **G-3 chunk 3 — DEPOSIT-004 admin-deposit Edge Function.** PR #178 (stacked
  on #177). slip-upload / approve / reject. Reuses `upload_slip` (G-4),
  `admin_approve_paid` (G-2); ships `admin_reject_deposit`. Hosted-verified:
  smoke 137/137, 4 new assertions green.

- **FLAG — deviation from the dispatch wording.** The dispatch said "reject
  reuses `admin_approve_failed`". I did not — the deployed
  `admin_approve_failed` writes `failed`/`system_error` (pre-taxonomy);
  DEPOSIT-004 + §ADR-9 TS1 ratify admin reject → `rejected`/`admin_rejected`.
  `admin_approve_failed` is taxonomy-stale; shipped a faithful
  `admin_reject_deposit` instead. Recommend tracking the `admin_approve_failed`
  drift as its own cleanup item (it is also on the smoke's slipv1/slipv2
  fraud-seed path — its fix needs a coordinated look, out of G-3 scope).

Remaining G-3 — final sub-chunk: DEPOSIT-005 multi-candidate resolve (admin
picks a candidate → `finalize_deposit` + statement review→matched). Small;
ready on re-dispatch. After it, G-3 is complete → G-5+G-6 → G-8..G-12 → G-13.

Done & hosted-verified: G-1 #170, G-2 #171, G-4 #173, G-7 #175, G-3-ch1 #176,
G-3-ch2 #177, G-3-ch3 #178 — stacked main ← #170 ← … ← #178, smoke 137/137.

— next-impl
