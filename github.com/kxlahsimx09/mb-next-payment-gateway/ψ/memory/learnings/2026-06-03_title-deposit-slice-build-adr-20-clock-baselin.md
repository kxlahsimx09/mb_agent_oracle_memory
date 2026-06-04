---
title: title: DEPOSIT slice BUILD — §ADR-20 clock baseline + AC-3 residual-MDR (PR #310
tags: [next-dev, deposit, adr-20, virtual-clock, residual-mdr, wallet-ledger, build, deposit-001, deposit-002, gotcha]
created: 2026-06-03
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: DEPOSIT slice BUILD — §ADR-20 clock baseline + AC-3 residual-MDR (PR #310

title: DEPOSIT slice BUILD — §ADR-20 clock baseline + AC-3 residual-MDR (PR #310, branch next-dev/deposit-slice-adr20)

next-dev built the DEPOSIT vertical slice (DEPOSIT-001 + DEPOSIT-002) on the mb-next substrate (dev-1 qvmjywljrgqzyxshexhx). Step-0 SPEC-FIRST published at docs/spec/deposit-slice.md (the test-facing contract; next-tester builds probes off it in parallel, never off code).

KEY FINDING: the repo already had ~79 migrations with most of DEPOSIT-001/002 promoted (create_deposit, 3-step match_deposits_cascade, finalize_deposit, callback_queue fan-out, idempotency middleware, QR/PromptPay). The two GENUINE build gaps were:
(1) the ENTIRE §ADR-20 clock abstraction was MISSING — no app_now/sys_clock anywhere. Added baseline migration 20260603000001: sys_clock singleton, app_now() (STABLE, T2), clock_set/clock_advance/clock_reset (T5 frozen-step), reset_for_test() (E3) — control/reset RPCs hard-guarded to non-prod via app_settings.stack_role. Then retrofitted the deposit money path (migration 20260603000002): create_deposit (expires_at + Bangkok-day → app_now(), signature unchanged), finalize_deposit/sweep_expired_deposits/expire_deposit → COALESCE(p_now, app_now()) with p_now added (DROP 2-arg + recreate 3-arg; cascade's 2-arg call resolves via DEFAULT NULL).
(2) the live finalize_deposit (20260515000001) was AC-3 NON-COMPLIANT: it credited only active partners, wrote NO wallets_change_logs row per partner, and had NO residual routing. Implemented §ADR-10 D4 + §Amendment 2026-05-31 (RM2→R1): exactly one wallets_change_logs row per profile partner (mdr_distribute active / mdr_skip inactive-or-missing — not a silent drop), un-routable share → mdr_owner residual wallet (= the "is_owner" wallet in this substrate), ledger balanced gross = client-net + Σ credited + residual, unroutable residual RAISEs → rolls back whole finalize (G-1 all-or-nothing).

SUBSTRATE GOTCHAS for future deposit builders: real table names diverge from AC prose — wallet (singular), wallets_change_logs (plural), residual wallet = owner_type='mdr_owner'. Deployed create endpoint = POST /functions/v1/deposits-create returning 201 (not /deposits 200); body uses customer_bank_* + per-deposit callback_url (the §ADR-9 preconfigured-endpoint-key flow is NOT in this slice). idempotency table = idempotency_keys; canonical reset = reset_runtime_state().

DELIBERATE SCOPE: cascade's expires_at > now() candidate PRE-filter left wall-clock (redundant pre-screen; authoritative gate = finalize_deposit app_now() guard + sweep flipping status — that is what enforces G-4 late-statement-after-expiry under the virtual clock). X-App-Now edge-stamp not threaded (RPCs read app_now() directly = DB-as-clock single instant). AC-1 amount-floor (separate DEPOSIT-001 edge AC) not in scope.

tags: [next-dev, repo:mb-next-payment-gateway, next, deposit, wallet-ledger, edge-function, migration, build, poc-promoted, decision, gotcha, deposit-001, deposit-002, adr-20, adr-10, virtual-clock, residual-mdr]
source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/310 commit 6834ad0 — supabase/migrations/20260603000001_adr20_clock_baseline.sql + 20260603000002_adr20_deposit_path_clock_and_residual.sql + supabase/functions/deposits-create/index.ts + docs/spec/deposit-slice.md
project: github.com/kxlahsimx09/mb-next-payment-gateway

---
*Added via Oracle Learn*
