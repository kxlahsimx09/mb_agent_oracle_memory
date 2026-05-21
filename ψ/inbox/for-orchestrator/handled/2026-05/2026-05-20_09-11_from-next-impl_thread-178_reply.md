---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 178
parent_thread: 178
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: G-8 d6 follow-up done — PR #192, sequential cascade-guard idempotency test, hosted-verified 171/171
context: full report on thread #178 msg 637; this envelope is the routing-back receipt
needs_response: false
priority: normal
created: 2026-05-20T09:11:00+07:00
handled_at: 2026-05-20T09:13:00+07:00
handled_by_thread: 178
---

G-8 d6 follow-up complete. Full result posted as thread #178 msg 637 (parent_session/parent_thread stamped — routes back to your session).

## Headline

- **PR #192** (fork, no merge, branched from main HEAD `a24175c`):
  https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/192
- Replaced the flaky `deposit_d6_concurrent_cascade_race` race-sim probe with a savepoint-isolated `test_cascade_race_guard_idempotency()` RPC + a thin probe wrapper that asserts two sequential checks.
- Hosted-verified `spdazjbmyagekwxixfct` `SPEED=60x FIXTURE_SIZE=tiny` → **171/171 PASS** (−1 race-sim, +2 sequential → net +1 vs the 170 baseline you quoted).

## Two notes you'll want to see on thread #178 msg 637

1. The cascade's `ALREADY_FINALIZED` catch branch is **structurally unreachable sequentially** (Step 1 count(*) reads latest committed state; once the first call commits the deposit to paid, the second call sees count=0 and never invokes `finalize_deposit`). The sequential test verifies the PROPERTY (no double-finalize/wallet/callback) — the catch code path is still exercised concurrently by the existing finalize-race probe against `finalize_deposit` directly, plus the pgTAP test `poc/4b/tests/03_race-guard-status-pending-only.spec.sql`.
2. Side observation, NOT a defect by your spec but worth flagging: cascade's Step 2b path clobbers `match_status='matched'/1` → `unmatched'/2b` on a same-statement re-entry. Benign (finalize/wallet/callback stay no-op as you specified), but cascade isn't fully no-op for double-call on the same stmt. Production never does that, so it's a latent re-entry quirk not a live bug. A one-line `AND match_status='pending'` guard on the Step 2b link-UPDATE would close it. Out of scope here; flag for a future round if you want.

Also caught a `20260520000005` version collision with G-14 via `migration list --linked` BEFORE `db push`; renumbered to `…006` (memory: `feedback_migration_version_collision.md`).

— next-impl
