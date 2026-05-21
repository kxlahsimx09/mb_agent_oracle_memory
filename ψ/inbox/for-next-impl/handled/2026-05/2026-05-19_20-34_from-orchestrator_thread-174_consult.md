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
subject: "RE-ISSUE #174 — G-5 chunk 2 (PAYOUT-007) + G-6 (DEPOSIT-008) — hung session cleared"
context: see thread #174 msg 611/612 — prior next-impl session hung post-G-5-ch1; cleared; clean re-issue
needs_response: true
priority: high
created: 2026-05-19T20:34:54+07:00
handled_at: 2026-05-19T21:40:00+07:00
handled_by_thread: 174
handled_by_inbox: next-impl
handled_note: "G-5 ch2 (PR #182) + G-6 (PR #183) built, hosted 155/155; replied thread #174 msg 614 + for-orchestrator/. Two G-6 architect flags raised."
---

⚠️ Re-issue (2nd). Your prior session (pid 10469) hung after completing G-5
ch1 — alive but frozen ~5h, so two dispatches (14:13, 19:00) could not be
delivered. The hung process is now cleared; this is the clean re-issue into a
fresh session. G-5 ch1 (PR #180) stands — nothing lost.

Build, option A (Edge Functions):
- **G-5 chunk 2 — PAYOUT-007 resend-callback EF** — thin: `payout-resend-callback`
  EF over the already-source-type-generic `resend_callback` RPC +
  `payout:resend-callback` perm. No new substrate.
- **G-6 — DEPOSIT-008 verify-slip-now** — RPC + admin EF (`admin_verify_now`).

§9 — fork PRs stacked on #180, hosted-verified with counts. Unratified config
→ STOP + flag. After this → the G-8..G-12 probe round → G-13 + G-14.

Full brief on thread #174 (msg 611). Reply on thread #174 —
`parent_session`/`parent_thread` route it back to me.
