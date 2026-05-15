---
title: D-track methodology — "tested-by-absence" surfaces both code-path gaps AND laten
tags: [poc-implement, testing-methodology, load-bearing, negative-path-realism, tested-by-absence, invariant-proof, D-track, architectural-coverage, session-2026-05-12-to-13]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# D-track methodology — "tested-by-absence" surfaces both code-path gaps AND laten

D-track methodology — "tested-by-absence" surfaces both code-path gaps AND latent test-infrastructure bugs

Closes the testing pattern surfaced + executed during 2026-05-12 → 2026-05-13 session arc (7 PRs: #52 baseline / #62 A3 / #65 D1 / #67 recovery / #68 A1 / #70 D5 / #73 D4 / #78 D3 / #79 admin-web). User-initiated "load-bearing realism > feature breadth" pattern. Two-tier discovery:

# Tier 1 — Invariants in code that have no test exercise

Pattern: code/constraint/trigger exists per ADR but no scenario activates it. Test infrastructure silent on whether the invariant fires.

Examples surfaced (all closed today):
- `uq_bank_statements_dedup_in` unique index + `ON CONFLICT DO NOTHING` — never fired because client-side `pushedStatement: Set` dedup'd first (D1 PR #65 → 35/35, replay loop forced server constraint to fire)
- `_block_mutation_append_only` triggers on 3 forensic tables × 2 ops = 6 triggers — never fired because no RPC mutates these tables (D5 PR #70 → 47/47, dedicated `test_append_only_blocks` RPC with savepoint-rollback safety)
- `RAISE EXCEPTION 'insufficient_funds'` in create_payout — never fired because fixture amounts < 50k wallet (D4 PR #73 → 49/49, PAY-D4INSUFF-* seed with amount=99999.99)
- `mark_retry` + `mark_dead_letter` dispatcher state machine — never exercised because mock-merchant was hard-coded `always_200` (A1 PR #68 → 36/36, MERCHANT_BEHAVIOR=mostly_500 chaos)
- `match_deposits_cascade` Step 2a/2b identity score (full=2, last_4=1) + min-delta tie-break — extracted but never used for discrimination because cascade returned LIMIT 1 by amount only (A3 PR #62 → 32/32, rewrite + `_a3_overlap_score` helper)
- `sweep_unmatched_statements` RPC authored but never cron-scheduled (A3 fix migration — wired to pg_cron)
- `bank_statements.statement_date_bkk`-derived cursor per §ADR-4b D2 amendment B1 — only "spec exists, impl was inverted" (D3 PR #78 → 53/53, full cursor model + new EF `bot-bank-statements-last`)

# Tier 2 — Test infrastructure bugs surfaced by Tier-1 tests

Pattern: when a test forces fresh-data + cross-run conditions, latent bugs in test infrastructure surface. D3 (cursor model) was the first test to require fresh deposit_id per run + bank_id determinism + complete reset. Other tests (A1/D4/D5) work fine on stale data so they masked these.

4 latent bugs surfaced in D3 iteration loops:
1. `reset_runtime_state` referenced `wallet.available_balance` column that doesn't exist (D3 run #1: full RPC failure → cross-run pollution silently)
2. `UPDATE bank_account SET deposit_count = 0;` without WHERE clause — Supabase safety policy ERRCODE P0001 → reset RPC failed mid-transaction (D3 run #2)
3. `idempotency_keys` table NOT cleared in reset → loader POST returned cached deposit_id from prior runs → ts_deposits empty → cascade had no candidates to match → all stmts unmatched. CRITICAL — this would have affected ANY cross-run test that depended on fresh deposit_id (D3 run #4 — confused me ~3h until I traced it)
4. `create_deposit ORDER BY ba.created_at LIMIT 1` non-deterministic because all 3 bank_accounts share identical created_at (seeded same INSERT statement) — Postgres random pick → ~half deposits routed to KTB but mock_bank_feed pre-assigned to SCB → dest_bank mismatch (D3 run #5, fix: add `ba.id` tie-break)

# Operational discipline

- Each invariant test = 1 PR with consistent shape: migration adds metric to `run_hosted_assertions` RPC + orchestrator adds N assertions + evidence captures. Easy to add new tests by following pattern.
- D-track items can be discovered by reading ADRs/spec docs and grepping for "should fire" vs assertion presence. Asymmetric: ADR specifies invariant + code implements + test absent.
- Iteration loops (D3 took 6 runs) are NORMAL when surfacing latent infrastructure bugs. Don't quit on first failure — each fix migration reveals next bug.

# Production-readiness signal

Before session: substrate 85% / scenarios 50% / bot model parity 30% / scale 5%.
After session: substrate 95% / scenarios 75% / bot model parity 95% / scale 5%.

Bot model parity jumped +65% from D3 cursor refactor (source-derived cursor per §ADR-4b B1 I-derived/I-no-retry/I-dedup). Substrate matured by closing test-infrastructure bugs. Scenarios doubled via 4 explicit invariant tests (D1/D4/D5/A1) + A3 cascade fix.

# Pattern is repeatable

Any system with spec-defined invariants + no positive test coverage will benefit from this approach. Cost ~1-3h per invariant proven. Returns include:
- Confidence in spec-implementation match
- Surface latent infrastructure bugs
- Regression coverage gained per PR

# Companion vault entries

- Pause/resume clock-skew architectural limitation (separate learning, this session)
- D3 cascade migration sequence (06 wallet col / 07 UPDATE-no-WHERE / 08 idempotency / 09 deterministic bank) — preserved as PR #78 migration history

---
*Added via Oracle Learn*
