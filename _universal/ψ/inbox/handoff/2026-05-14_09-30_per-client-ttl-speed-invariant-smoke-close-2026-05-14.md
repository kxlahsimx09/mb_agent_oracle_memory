# next-impl session close 2026-05-13 → 2026-05-14

## Outcome

Two PRs merged. Smoke now **SPEED-invariant** (1x / 10x / 60x produce identical 63/63 PASS); per-client TTL drift closed (DEPOSIT-001 AC #1 spec compliance); new admin-web views surface client status + wallet ledger.

## Same-arc closure

### PRs merged (2)

| # | Title | Merge |
|---|---|---|
| 100 | poc-implement: smoke quality — V1 minute-anchor + cron kicker + #current QR/PromptPay parity | 2026-05-13 ~10:09 UTC |
| 101 | poc-implement: per-client TTL + cluster/race coverage + admin-web client+wallet views | 2026-05-14 |

### Substrate impact

| Substrate | Change |
|---|---|
| Cascade Step 2b | Identity REQUIRED (was identity-optional per spec; 99.9985% production behavior anyway) |
| Cascade Step 1 / FA1 | Temporal-safety guard — refuse auto-finalize when `v_dep.created_at > v_stmt.created_at + 10s` |
| `client` table | NEW column `expired_deposit_seconds INT NOT NULL` |
| `create_deposit` RPC | Reads from client config; rejects body `p_expires_in_seconds` (ERRCODE 22023) |
| `apply_test_speed_to_client_ttl(p_speed)` | NEW helper RPC — orchestrator pre-scales TTLs by SPEED |
| `deposits-create` EF | Returns HTTP 400 on body `expires_in_seconds` |
| QR PromptPay seed | Mobile → taxId 100% match #current |
| QR encoded amount | `final_amount` → `amount` (base) match #current |
| `ts_deposits.promptpay_id` | Now persisted 100% on QR rows (was NULL pre-fix) |
| Tiny fixture | 18 deposits = 4 QRH + 1 EXP + 3 A3LATE + 1 V1TWIN + 1 SLIPV1 + 1 SLIPV2 + 1 SLIPH + 2 CLUSTER-FA1 + 2 CLUSTER-FA2 + 1 RACE-TEMPORAL + 1 RACE-CROSSBANK |
| admin-web routes | NEW /clients (TTL tier badges + wallet balance) + /wallet-logs (wallet_change_logs live tail) |

### Migrations applied (hosted)

- 20260513000020 — QR/PromptPay taxId parity (seed + create_deposit fallback)
- 20260513000021 — qr_type=taxId 100% assertion + qr_payload tag-54=amount assertion
- 20260513000022 — Cascade Step 2b identity-required
- 20260513000023 — Cluster FA1/FA2 seed breakdown for assertions
- 20260513000024 — Cascade Step 1 temporal-safety guard (10s wall threshold)
- 20260513000025 — Race-temporal + crossbank seed breakdown
- 20260513000026 — `client.expired_deposit_seconds` column + 5-tier seed + apply_test_speed_to_client_ttl helper
- 20260513000027 — `create_deposit` reads from client config; rejects body override

## Smoke verification matrix (SPEED-invariant)

| SPEED | FIXTURE_DURATION_MIN | Wall-clock | Result | Notes |
|---|---|---|---|---|
| 60x | 60 (default) | ~1m18s | 63/63 PASS | fast iteration default |
| 10x | 60 (default) | ~6m | 63/63 PASS | moderate |
| 1x | 2 | ~4m34s | 63/63 PASS | debug-fast (packed events) |
| 1x | 10 | ~13 wall-min (recommended) | (unverified) | production-density |
| 1x | 60 | ~63 wall-min | (unverified) | true production replay |

Identical totals across SPEEDs: deposits_paid=8 / expired=8 / rejected=2, bank_statements_matched=7 / review=2 / unmatched_with_xref=3, callbacks_delivered=23.

## Durable learnings filed (this session)

| File | Topic |
|---|---|
| `2026-05-14_speed-invariant-smoke-design-auto-scale-wall.md` | Auto-scale QUIESCE + BOT_AUTO_EXIT + fixture offsets by SPEED |
| `2026-05-14_transfer-before-deposit-policy-cascade-must-s.md` | RACE policy + temporal-safety guard + production audit 99.9985% identity |
| `2026-05-14_per-client-ttl-config-deposit-001-ac-1-drift.md` | Drift fix + 5-tier client seeding + apply_test_speed_to_client_ttl |
| `2026-05-14_v1-slip-fraud-minute-boundary-anchor-cross-la.md` | Hash composition must share temporal anchor; not `new Date()` on both sides |
| `2026-05-13_epic-depositmd-vs-hosted-smoke-coverage-gap-an.md` (earlier in session) | Full gap analysis: 8 DEPOSIT stories vs 63 assertions — P0-P3 pickup roadmap |

## Pickup signal for next session

From the **gap analysis learning**, P0/P1 items remaining:

### P0 critical drift not yet closed

1. **Idempotency error paths** — header-missing 4xx, replay-safe response, REUSED_WITH_DIFFERENT_BODY 409 (DEPOSIT-001 AC #2-4)
2. **Duplicate stmt dedup** — bot-retry produces 2x rows currently? DEPOSIT-002 AC #2 not explicitly tested
3. **ALREADY_FINALIZED race** — concurrent `finalize_deposit` for same deposit (DEPOSIT-002 AC #6)
4. **Client wallet missing → rollback** — chaos test, no phantom paid (DEPOSIT-002 AC #7)

### P1 high (well-scoped against single AC)

5. NO_BANK_AVAILABLE + EXCLUSION + AMOUNT_OUT_OF_RANGE error contracts (DEPOSIT-001)
6. V1+V2 force-approve override path (DEPOSIT-007)
7. 4-actor matrix slip upload (customer / client / sub-client / admin) + tenant-scope 403 (DEPOSIT-004)
8. Thunder verdict diversity (forged / system_error / timeout)
9. `deposit.expired` callback delivery + WC10 X-Maxpay-Event-Id header

### P2 medium (new endpoints / multi-bank)

10. Multi-bank routing — fair-rotation + per-bank daily cap + midnight BKK reset
11. **DEPOSIT-008** admin verify-slip-now endpoint (entirely missing in PoC)
12. **DEPOSIT-012** manual resend-callback endpoint (entirely missing)
13. v_deposits.effective_status read-time invariant
14. Race-case admin flip-back (DEPOSIT-007 C6)

## User collaboration signal

- Probes via specific surface questions (e.g. "Fixture TTL มีไว้ทำอะไรนะ" / "1800 มาจากไหน") → drives drift discovery
- Trusts production-data audit (dpay MCP) over implementation inference
- Direct execution style ("เอาเลย", "kill เลย", "merged แล้ว restart ให้หน่อย")
- Catches packaging issues quickly ("PR ใหม่ละล่ะ" when commits drifted past a merged PR)
- Spotted FIXTURE_DURATION_MIN=2 as "too packed" without prompting — has strong intuition for production-realism

## Retrospective

### What went well
- Production-data-first investigation pattern: 4 dpay audits surfaced the 1800-TTL not-from-production, the 99.9985% identity-required vs spec's identity-optional, the 100% qr_type=taxId, and the per-client TTL 5-15 min distribution.
- Subprocess kicker pattern (sweep_unmatched_statements every 2s wall) cleanly absorbs cron/SPEED mismatch.
- Multi-tier client seeding replaces per-deposit TTL override — cleaner semantics.
- Migration-by-amendment kept Step 2b / per-client TTL / temporal-safety as independent ratifications, each with audit-grounded rationale.

### What went sideways
- I introduced `matched_at` column references that don't exist; sweep silently swallowed → all deposits routed to Step 2b instead of Step 1. Caught quickly via user "ไม่ต้องรัน 5 รอบหรอก รอบแรก พัง" — should have stopped immediately, not chained 5 retries.
- Hardcoded `FIXTURE_DURATION_MIN: "60"` subprocess env override silently ignored user's env. Generic anti-pattern: subprocess env should be `...process.env` first.
- Reused PR #100 branch for commits after it merged → had to spin a new PR #101. Branch lifecycle hygiene: stop pushing to merged branches.

### Patterns to repeat
- "Question the magic number" pattern: 1800 was just author intuition, not data-grounded. User's question forced a production audit that turned up the median (10 min) and the proper design (per-client config).
- SPEED-invariance via auto-tune wall-clock budgets — derive from longest fixture TTL + SPEED, never hardcode.
- Defense-in-depth on race scenarios: temporal-guard (same-bank) + scope-filter (cross-bank). Test both with separate fixtures.

### Patterns to avoid
- Cross-language hash composition with independent `new Date()` calls on each side. Always anchor one side as source-of-truth.
- Catching `EXCEPTION WHEN OTHERS` in sweep helpers without surfacing the error context. Made `matched_at` column bug invisible until manual DB inspection.

— next-impl session close 2026-05-14 09:30 GMT+7 (PR #100 + #101 merged; hosted smoke SPEED-invariant verified 1x/10x/60x).
