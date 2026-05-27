---
title: Supabase compute tier facts + surgical baseline-clean technique (mb-next loadtes
tags: [brew-ops, repo:mb-next-payment-gateway, fleet, supabase, loadtest, compute-tier, micro, reset-runtime-state, gotcha]
created: 2026-05-27
source: thread #216 msg 1188 — Micro comparative re-run prep (brew-ops, project swqosfqrpmrhnebhksgd, 2026-05-27)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Supabase compute tier facts + surgical baseline-clean technique (mb-next loadtes

Supabase compute tier facts + surgical baseline-clean technique (mb-next loadtest, thread #216, 2026-05-27 Micro comparative run).

MICRO COMPUTE CLASS: Micro is SHARED-BURSTABLE CPU, not dedicated — confirmed via Mgmt-API `GET /v1/projects/{ref}/billing/addons` → `selected_addons[].variant.meta`: `ci_micro` = `cpu_dedicated: false`, `cpu_cores: 2`, `memory_gb: 1`, `connections_direct: 60`, `connections_pooler: 200`, ~$0.01344/hr (~$10/mo). KEY: Micro keeps the SAME connection caps as free/nano (60 direct / 200 pooler) — so `max_connections` does NOT change free→Micro (both 60); the upgrade is RAM (0.5→1 GB) + CPU baseline/burst only. Live RAM proxy: shared_buffers ≈ 25% of RAM (free/nano ≈128MB → Micro 256MB), effective_cache_size ≈768MB on Micro. Implication for load tests: free AND Micro are both shared-burstable → both have a CPU burst-credit budget that depletes under sustained load → the "sustained-tail-blowout / 503-shed after burst-credit depletion" failure mode persists on Micro (ceiling rises with more RAM+baseline, doesn't disappear). The burst-credit ceiling only DISAPPEARS at Medium+ (cpu_dedicated: true, max_connections ~120). To verify a compute upgrade took effect, use the addons endpoint (`selected_addons` compute_instance variant) — `max_connections` alone can't distinguish free vs Micro.

SURGICAL BASELINE-CLEAN that PRESERVES a bank_statements backfill (never call reset_runtime_state, which `DELETE FROM bank_statements WHERE true` wipes the whole table): mirror reset_runtime_state's EXACT proven statement sequence — disable the guard triggers (tr_wallets_change_logs_no_update/no_delete, tr_callback_attempts_*, tr_slip_verify_attempts_*), DELETE callback_attempts→callback_queue→slip_verify_attempts→transactions→mdr_shared→withdrawal_queue→(bank_statements SELECTIVE)→ts_deposits→ts_payouts→idempotency_keys→wallets_change_logs→mock_merchant_events→mock_bank_feed→test_run, reset wallets (frozen=0, client=50000, others=0), deposit_count=0, daily_deposit_count=0 + reset_date=today(BKK), re-enable triggers — all in ONE transaction (ON_ERROR_STOP → safe rollback). The ONLY change vs reset_runtime_state: replace `DELETE FROM bank_statements WHERE true` with `DELETE FROM bank_statements WHERE <NOT backfill-marker>` (e.g. raw_text NOT LIKE 'g-l7-backfill-%') so the 50k working set survives. The `postgres` role owns the tables → ALTER TABLE DISABLE/ENABLE TRIGGER works directly (no superuser needed). Also: per-bank daily deposit cap = bank_account.maximum_number_of_deposits (was 999/bank → 13×999=12,987/day, exhausts in ~7min @30 dep/s); raise ×10 for longer runs; keep the same bank count to preserve LRU topology for apples-to-apples comparison.

---
*Added via Oracle Learn*
