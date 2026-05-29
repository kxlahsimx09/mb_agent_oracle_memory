---
title: Perf-harness 5-ADD production-fidelity BUILD PASS complete (thread #254, 2026-05
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-harness, perf, thread-254, money-path-feeder, callback-coalescing, rate-limit, rbac, rls, idempotency, auth-on, medium-run-readiness, ef-vs-gateway-boundary, poc-ready, handoff]
created: 2026-05-27
source: PRs #268/#269/#270/#271 on github.com/kxlahsimx09/mb-next-payment-gateway; local-verify on loadtest_add1/cbvol/add3/add4 @54322; thread #254 build pass 2026-05-27
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Perf-harness 5-ADD production-fidelity BUILD PASS complete (thread #254, 2026-05

Perf-harness 5-ADD production-fidelity BUILD PASS complete (thread #254, 2026-05-27) — implement + local-verify only, no hosted run.

Follow-on to the #254 gap-analysis (msg 1200). User ratified all 5 ADDs; orchestrator GO (msg 1202). Delivered 4 PRs off origin/main, each verified on a dedicated local Postgres DB:

- PR #268 ADD-1: src/load/money-path-feeder.ts — decoupled poller reads live pending deposits (created by driver.ts) → pushes matching `in` statements via the bot HTTP endpoint (submit_statements_batch per-account pg_advisory_xact_lock + count-dedup) → eager match_deposits_cascade → finalize_deposit (client+partner wallet UPDATEs, wallets_change_logs, mdr_shared fan-out, transactions ledger, callback_queue enqueue, wallet.id ASC FOR UPDATE). Also closes payout lane (claim→mark success/review/failed per 84/6/10→settle). Wired into run-load.ts behind LOAD_CLOSE_LOOP=1 + post-driver drain. Verify: 134/150 paid, 268 mdr_shared (2/dep), 226 change-logs, 134 ledger, 177 callbacks delivered+attempt-logged, 49 payouts settled.
- PR #269 ADD-2: src/rpc/callback/coalescing_claim.sql brings MAIN public substrate to migration-019 coalescing shape (dispatching status + claim_batch_for_dispatch FOR UPDATE SKIP LOCKED + sweep_stuck_dispatching; mark_delivered accepts pending|dispatching = backward-compat). src/load/callback-volume.ts: K concurrent dispatchers on the real substrate exercise callback_attempts append + denorm UPDATE (G-L2's isolated schema has neither). Verify: coalescing 1000 egress=1000 delivered dup_egress=0 (SLO-8) 40P01/40001=0; naive control 7459/1000 dup=6459.
- PR #270 ADD-3+ADD-5: rate_limit_counters + rate_limit_hit() (2 upsert-increments/request, per-client day-row hotspot) + rate-limit.ts middleware (gated RATE_LIMIT_ENABLED default off, fail-open, caps default-unlimited so contention not shedding). ADD-5 VERIFIED idempotency already DB-backed (idempotency.ts → acquire_idempotency_slot + complete_idempotency_record on idempotency_keys). Verify: 144 creates → 5 per-client counter rows/scope; idempotency_keys=144 all completed=1/create.
- PR #271 ADD-4: rbac_rpcs.sql (client.role, permissions catalogue, check_permission() DB-fresh, RLS policies on ts_deposits/ts_payouts/wallet under non-superuser app_authenticated keyed to current_setting('app.tenant')). rbac.ts per-write DB-fresh check (gated AUTH_RBAC_ENABLED default off, fail-closed). clientAuth resolves role in existing API-key round-trip. Verify: 120 creates all 201 w/ RBAC on; live e2e readonly→403 client_api→201; RLS tenant=A→18 none→0 owner→90.

ADD-1 feeder design = decoupled poller + HTTP push + per-account batched (production-faithful); reads ts_deposits only to learn amount+bank (acknowledged harness coupling). Matcher Step-1 keys on amount alone → collisions park a small fraction at review (faithful; measured not gamed). NOT split (self-contained).

KEY MEDIUM-RUN READINESS FLAG (durable): the §D/Medium runner points GATEWAY_URL at the raw EFs (/functions/v1), which BYPASS the poc Bun gateway. ADD-1 feeder (HTTP push) + ADD-2 coalescing (SQL via migration chain) are Medium-ready. BUT ADD-3 rate-limit / ADD-4 RBAC+JWT / ADD-5 idempotency are per-request MIDDLEWARE IN THE BUN GATEWAY — so for the Medium run to measure auth/rate-limit CPU cost, EITHER (a) brew-ops drops --no-verify-jwt + the EFs carry the checks (supabase/functions = next-dev's lane), OR (b) the Medium run routes through a hosted poc Bun gateway in front of the EFs. This decision gates whether the "production-faithful ceiling" includes per-request auth cost. Boundary: --no-verify-jwt deploy = brew-ops/fleet-infra; EF-side auth = next-dev; neither in poc/integration.

All ADDs gated default-OFF (LOAD_CLOSE_LOOP / RATE_LIMIT_ENABLED / AUTH_RBAC_ENABLED) to preserve the open-loop create-only path + existing E2E for §D comparability; the Medium run sets them on. cwd resets between Bash tool calls in this harness — always cd explicitly. Local verify used dedicated DBs loadtest_add1/cbvol/add3/add4 to avoid clobbering shared :54322.

---
*Added via Oracle Learn*
