---
title: §E 1A "freeze half" BUILT — migrations 006–009 + extended hosted assertions (PR 
tags: [p2p-hub, section-E, freeze-settle, migrations, match-formation, impl-params, pglite-verification]
created: 2026-06-01
source: next-impl §E 1A freeze half (Oracle thread #4)
project: github.com/kxlahsimx09/p2p-hub
---

# §E 1A "freeze half" BUILT — migrations 006–009 + extended hosted assertions (PR 

§E 1A "freeze half" BUILT — migrations 006–009 + extended hosted assertions (PR #15, off origin/main, not merged).

Context: §E (Match-Formation & Reserve/Release Lifecycle Substrate, 1A slice) ratified to main via Oracle thread #4 (2026-06-01). §E12 was the hand-off spec. §D had shipped the settle half (001–005). next-impl authored the freeze half per P-004 (current design doc on origin/main, §E2–§E12).

WHAT SHIPPED (4 migrations, order matters):
- 006 providers expand: provider_status enum + status/serves_deposit/serves_payout/mdr_rate (§E2 ACTIVE+serves gate).
- 007 pool_items + pool_side/pool_status enums + FIFO partial indexes + submit_pool_item/withdraw_pool_item (§E3, B2.2 guard).
- 008 match_status ADD VALUE 'ACCEPTED' in its OWN migration step / own tx (ahead of any migration USING the literal — §E4 same-tx caution), then matches columns. Note: the column adds do NOT reference the literal, so they are safe alongside the ADD VALUE in the same file; only the RPCs that USE 'ACCEPTED' (009) need a separate tx.
- 009 the four RPCs: propose_match (§E5 FIFO 1:1 combined reserve M+F_p / F_d, both-must-reserve-or-rollback, POOLED→MATCHED single-shot B2.1, 3 change_logs, Q-D2 fail-emit + poison-cap→EXPIRED), accept_match (§E6 dual-leg idempotent, both→ACCEPTED + fee_charge×2), advance_to_verifying (§E7 1A-COLLAPSE SEAM), release_match (§E8 PROPOSED pre-charge release_reserve+fee_refund, re-pool/EXPIRED). All 5 dormant provider_wallet_operation values now have producers.

IMPL-PARAMS PINNED (§E11 delegated):
- accept_window = INTERVAL '15 minutes'
- failed_formation_count poison cap = 5
- rounding = round(M*mdr_rate,2) via Postgres numeric round = half-up (round-half-away-from-zero; verified round(0.005,2)=0.01), applied via the IDENTICAL expression hub+provider.

§E8 SEAM LEFT IN PLACE (per spec): post-ACCEPTED charged-fee balance-credit refund (balance+=F, §C7 CQ1) + EXPIRED-from-VERIFYING are NOT implemented — deferred to the transfer-window/§C8 verification pass, consumer = ratified §F verification_oracle_error fail-safe. fee_refund not overloaded.

DEVIATIONS / DECISIONS FLAGGED:
- release_match signature pinned as (p_match_id, p_reason text) with p_reason ∈ {'decline','expire'} driving both match terminal (CANCELLED/EXPIRED) and pool disposition (re-pool POOLED / EXPIRED). §E8 left the disposition selector underspecified.
- propose_match returns uuid OR NULL for the two non-exceptional no-form outcomes (no FIFO counterparty; reserve refusal). Hard errors (race, deposit-fee-reserve rollback) RAISE.
- Refusal bookkeeping (failed_formation_count++ + MatchStakeInsufficient emit) commits because the failed payout reserve made 0 row changes (nothing to roll back); the deposit-fee-reserve failure AFTER a successful payout reserve RAISEs to roll back the whole tx (§E5 step 6).

TEST STATUS — execution-verified via PGlite (WASM Postgres), NOT hosted. No Supabase CLI / Docker / hosted creds in the build env; did NOT claim a hosted PASS. All 9 migrations apply in order; full E2E + every E1–E9 scenario exercised against the real RPC bodies in isolated DBs = 21/21 execution checks PASS. tests/hosted-assertions.ts (now A1–A12 + E1–E9) typechecks clean vs repo tsconfig. One real bug caught+fixed in verification: propose_match SELECT was missing need_by, breaking the matches INSERT (LEAST(dep.need_by,...)). PGlite caveats: no pgcrypto ext (gen_random_uuid is PG13 core, unaffected); single-connection so live SKIP LOCKED races can't run — E9 asserts lock-order statically + callability (as §D A5 does). To run hosted gate: bun run db:start && db:reset && test:assert, or SUPABASE_URL/SERVICE_ROLE_KEY env + test:assert; expect 21 assertions.

REUSABLE PATTERN: PGlite is a viable execution-level verification substrate for raw-SQL Supabase migrations when no local stack/creds exist — neutralize only `CREATE EXTENSION pgcrypto` + the service_role/authenticated GRANT/REVOKE lines, and run each behavior in a fresh PGlite() to mirror clean() isolation (shared amounts otherwise cross-talk via FIFO).

---
*Added via Oracle Learn*
