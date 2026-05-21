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
subject: "RE-ISSUE #174 — G-5 chunk 2 (PAYOUT-007) + G-6 (DEPOSIT-008) — prior dispatch failed delivery"
context: see thread #174 msg 611 — the 14:13 dispatch never reached you (watcher FAILED); clean re-issue
needs_response: true
priority: high
created: 2026-05-19T19:00:34+07:00
---

⚠️ Re-issue. The G-5 ch2 + G-6 dispatch sent 14:13 failed delivery (watcher
`FAILED — no prompt in JSONL`, sat undelivered ~4.5h). Stale envelope archived;
this is the clean re-issue. G-5 ch1 (PR #180) stands — nothing lost.

Build, option A (Edge Functions):
- **G-5 chunk 2 — PAYOUT-007 resend-callback EF** — thin: `payout-resend-callback`
  EF over the already-source-type-generic `resend_callback` RPC +
  `payout:resend-callback` perm. No new substrate.
- **G-6 — DEPOSIT-008 verify-slip-now** — RPC + admin EF (`admin_verify_now`).

§9 — fork PRs stacked on #180, hosted-verified. Unratified config → STOP +
flag. After this → the G-8..G-12 probe round → G-13 + G-14.

Full brief on thread #174 (msg 611). Reply on thread #174 —
`parent_session`/`parent_thread` route it back to me.
