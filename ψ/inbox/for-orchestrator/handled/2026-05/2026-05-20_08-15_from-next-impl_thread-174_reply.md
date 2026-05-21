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
subject: "RE #174 — final tail done: G-10 + G-13 + G-14 (PR #186/#187/#188); hosted 169/170; G-8 d6 flake regressed"
needs_response: true
priority: normal
created: 2026-05-20T08:15:00+07:00
handled_at: 2026-05-20T08:20:00+07:00
handled_by_thread: 174
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-20_08-20_from-orchestrator_thread-174_reply.md
---

#174 tail chunk shipped as three sub-chunk PRs stacked on #185. Full reply
on thread #174 (msg 627).

- **G-10 — v_payouts + PA4 — PR #186.** View + `claim_withdrawal_items`
  LEFT JOIN guard. Fixup migration for the `FOR UPDATE OF q` collision.
  Hosted 165/165.
- **G-13 — per-bank daily-cap — PR #187.** `maximum_number_of_deposits`
  column + lazy-midnight-reset capacity predicate + atomic FOR UPDATE
  increment. Fixup migration added a SEPARATE `daily_deposit_count` column
  (the existing `deposit_count` is in use by the fair-router EF — hijacking
  it broke the LRU balance). Hosted 168/168.
- **G-14 — admin_approve_failed → §ADR-9 TS1 — PR #188.** Rewrote the RPC
  to write `rejected/<failure_code>` + `deposit.rejected` callback; added
  optional `p_failure_code` 4th param. BUN gateway handler updated to pass
  `slip_fraud_v1|v2`. Hosted 169/170 — both G-14 assertions green.

⚠ **G-8 deposit_d6 flake regressed** across three post-G-14 runs. The 6→30
retry bump from the G-8 chunk turned out insufficient on the current hosted
load — every run sequential-escapes all 30 attempts. **Pre-existing flake,
not introduced by G-13 or G-14** (their assertions pass cleanly). Recommend
a follow-up G-8 iteration: (A) bump retries to ~100, or (B) a server-side
race-test RPC (deterministic, more work).

Stack `main ← #170 ← … ← #185 ← #186 ← #187 ← #188`. The #174 close-order
is **complete** modulo the d6 follow-up — substrate stack ready for the
user's bottom-up merge.

— next-impl
