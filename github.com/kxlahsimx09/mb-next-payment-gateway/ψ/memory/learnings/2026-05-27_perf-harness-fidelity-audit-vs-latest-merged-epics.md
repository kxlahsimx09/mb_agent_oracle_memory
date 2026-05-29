---
title: Perf-harness fidelity audit vs latest merged epics (thread #254, review-only, 20
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-harness, perf, gap-analysis, thread-254, wallet-ledger, mdr-fanout, callback-delivery, statement-matching, rate-limit, auth-rbac, rls, idempotency, admin-audit, audit-trail-http-log-reframe, finalize-deposit, handoff]
created: 2026-05-27
source: thread #254 review; poc/integration/src/load/driver.ts + finalize_deposit.sql + seed.sql @2d07877; dpay prod volumes 2026-04-27..05-27; epics on origin/main
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Perf-harness fidelity audit vs latest merged epics (thread #254, review-only, 20

Perf-harness fidelity audit vs latest merged epics (thread #254, review-only, 2026-05-27) — ADD/SKIP map.

CONTEXT: poc/integration load harness was built against an early system slice; epics grew (source-flows/auth-rbac/callback-delivery/admin-audit/fleet-control/monitoring/client-api/wallet-ledger/topup). Audit = which additions are perf/substrate-relevant. Grounded vs origin/main 2d07877 + dpay prod volumes + harness source.

KEY STRUCTURAL FINDING: the harness has TWO layers. (A) Sustained throughput load (driver.ts G-L1 + §D run-freetier-feasibility.sh) fires ONLY /deposits-create + /payouts-create, unique idem-key, hosted EFs --no-verify-jwt (auth/RBAC/RLS bypassed), callbacks→mock-merchant — and the created deposits NEVER finalize (no statement stream pushed) so the write-amplifying money path is absent from every throughput/§D number to date. (B) Small correctness/contention probes (G-L2 dup-egress, G-L4 finalize-race/deadlock, G-L6 multibank/fair-router, G-L9 cost-ledger) DO drive finalize/MDR/coalescing but at tiny scale (40-200 deposits) for correctness, not at prod write-volume. Net: create front-door driven hard; money path never driven at volume.

AUDIT_TRAIL REFRAME (load-bearing SKIP): prod's largest write flow audit_trail ~184,445/day is the raw HTTP REQUEST LOG (epic-admin-audit L129/136, verbatim), which the next system routes to Axiom (external, MONITOR-001) NOT Postgres. Next-system canonical audit_log = successor to activity_logs (~1,507 rows LIFETIME = sparse). So next-system DB write-pressure is dominated by deposit-finalize fan-out + callback attempt-log, NOT by any audit/request log. ADMIN-002's only trigger is audit_log→4-field business-row cache (NOT a trigger on money tables) — so deposit/payout load is NOT silently missing 184k/day audit writes.

RANKED ADDs (perf/substrate-relevant):
1. Drive deposits to FINALIZE under load (statement-intake submit_statements_batch [per-account pg_advisory_xact_lock, ~45.5k stmts/day] → match_deposits_cascade → finalize_deposit). finalize_deposit.sql = ~9 row-writes/finalize: ts_deposits + client-wallet UPDATE + wallets_change_logs + N×(partner-wallet UPDATE + mdr_shared) + transactions + callback_queue, under wallet.id ASC FOR UPDATE; 2 shared partner wallets = hot rows on every finalize; MDR=54% of prod change-logs. Requires feeding a matched-statement stream (real change to open-loop create-only model).
2. Callback delivery at volume (CALLBACK-005): callback_attempts append ~6 rows/delivered callback + denorm parent UPDATE at ~44.7k/day; §ADR-9 coalescing "deployed but never run under concurrent dispatchers" at load. Real outbound HTTP+DNS = SKIP (merchant-side latency, not our substrate).
3. DB-backed per-client rate-limit counter (CLIENT-002, §ADR-7 Postgres counter no cache): per-request UPDATE on per-(client,scope,window) row = row-lock hotspot on busiest client. New write-contention surface, fully bypassed by --no-verify-jwt.
4. Per-request auth read-cost (AUTH-003 RLS per-query + AUTH-006 api_key→client lookup + DB-fresh RBAC permission read per write). NOT fixed overhead — scales with RPS. Sharp point: §D ceiling is CPU/burst-credit-bound NOT conn-bound, so per-request SELECTs directly erode the measured dep/s ceiling → every §D/Micro feasibility number (auth OFF) overstates real headroom.
5. Idempotency DB dedup-table (CLIENT-001) — verify hosted EF persists §ADR-11 DB dedup table (lookup+insert/create, (client,key) unique) vs in-memory gateway map; if in-memory the per-create dedup contention is missing.

SKIPs (perf-neutral, with reason): admin-audit (sparse audit_log ≠ HTTP log; trigger is audit_log→cache); monitoring (external Axiom/Sentry/Keep sinks, log fields, session var, config-as-code — zero PG money-path writes); fleet-control (own tables fleet_command_log ~2 rows/command, operator cadence, 30s poll=read); source-flows settlement/pullout/DT (93/5/8 per day — correctness-critical wallet-freeze shapes but perf-negligible; pullout+DT touch no wallet); topup (~8/day, mirrors deposit MDR shape trivially); auth login-path AUTH-001/002/005/007 (per-login/admin-money-out, not RPS-scaling); callback signing/payload CALLBACK-002/004 (HMAC=CPU, payload=doc-only).

---
*Added via Oracle Learn*
