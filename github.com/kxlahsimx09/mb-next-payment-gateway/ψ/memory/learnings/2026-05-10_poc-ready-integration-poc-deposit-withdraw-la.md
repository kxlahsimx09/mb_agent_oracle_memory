---
title: poc-ready: integration PoC — deposit + withdraw lanes E2E, both Phase A (local B
tags: [poc-implement, repo:mb-next-payment-gateway, next, poc, poc-ready, integration, deposit-lane, withdraw-lane, phase-a-local-bun, phase-b-hosted-supabase, edge-functions, pg_cron, realtime, database-webhook, pg_net, fair-router, lru-rotation, mode-1-pool-broadcast, mode-2-direct-address, callback-dispatcher, idempotency, slip-fraud-v1-v2, expire-sweep, stale-claim-sweep, race-guard, wallet-ledger-balance, append-only-trigger, matcher-cascade, production-substrate, session-2026-05-10]
created: 2026-05-10
source: poc/integration/{src,tests,evidence,seed.sql} + supabase/{migrations,functions} @ commits f7d3dad (Phase A) + 5095e53 (Phase B); hosted project ref spdazjbmyagekwxixfct (Singapore, free tier)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: integration PoC — deposit + withdraw lanes E2E, both Phase A (local B

poc-ready: integration PoC — deposit + withdraw lanes E2E, both Phase A (local Bun gateway, single process collapsed) and Phase B (hosted Supabase: EF + pg_cron + Realtime + Database Webhook + §ADR-8 fair-router) green.

# Scope

First HTTP-layer PoC for mb-next-payment-gateway. Consolidates substrates from §ADR-{4a, 4b, 4c, 4d, 9, 10, 11} + §ADR-8 (Phase B addition). Same data lanes, same RPCs, same fixture distributions tested on two substrates back-to-back to compare local-baseline vs production-grade timings.

**Phase A (local)**: Bun + Hono gateway port 3010 collapsing 4 in-process tickers + dispatcher; mock-merchant Bun :3011; bot-sim with claim polling; fixture-loader replaying timeline at SPEED multiplier; orchestrator + 16 assertions.

**Phase B (hosted)**: 9 Edge Functions in Deno 2 (deposits-create, deposits-upload-slip, payouts-create, bot-statements, bot-queue-mark, bot-balance, dispatch-callback, fair-router, mock-merchant); 3 pg_cron jobs (1m cadence each); Realtime publication on withdrawal_queue with REPLICA IDENTITY FULL; 2 Database Webhooks via pg_net (callback_queue INSERT → dispatch-callback fast-path; withdrawal_queue INSERT WHERE pool_id NOT NULL → fair-router LRU assignment); bot-sim Realtime subscriber via @supabase/supabase-js; orchestrator + 17 assertions (16 + fair-router LRU balance check).

# Results

## Phase A local (Bun gateway, 100 deposits + 50 payouts, SPEED=10x)
- 16/16 assertions pass
- 87 deposits paid (60 QR + 2 race + 25 slip-happy) + 8 expired + 5 fraud-failed (3 V1-collision + 2 V2-mismatch)
- 50 payouts terminal: 42 success + 3 waiting_to_review + 5 failed (84/6/10% per fixture distribution)
- 150 callbacks delivered, 0 dead_letter, 62 bank statements pushed → 62 matched (100%)
- Wallet ledger balanced gap=0.00 per client wallet
- Latency: deposit_create→paid p50=10.7s, payout_create→completed p50=7.9s, statement_push→match p50=5ms, callback_enqueue→delivery p50=1.6s
- Quiescence: 1.6s after loader exit (5s in-process tick handles everything)

## Phase B hosted (Supabase, same fixture)
- 17/17 assertions pass (added fair_router_lru_balanced)
- Identical totals to local: 87/8/5 deposits, 50 payouts terminal, 62 statements matched
- Mode-1 fixture split: 23 Mode 1 (pool-broadcast) + 27 Mode 2 (direct), all 23 Mode 1 rows assigned by fair-router; per-bank LRU rotation scb=8, ktb=8, kbank=7 (max-min=1)
- Latency: deposit→paid p50=11.6s (+8% vs local), payout→completed p50=8.5s (+8%), stmt→match p50=35ms (vs 5ms — EF cold-start + network), **callback delivery p50=1191ms (25% FASTER than local 1596ms** — Webhook fires instantly on INSERT vs 5s polling), callback p99=50.8s (cron 1m sweep ceiling for retries)
- 1 callback dead_letter (rare 5xx via mostly_200 verdict; 3-attempt budget exhausted)
- Quiescence: 45.8s after loader exit (cron-paced)

# Substrate boundary (per user 2026-05-10)

**Inside Supabase (production-grade, tested as-is)**:
- Postgres + ~30 RPCs + DDL (consolidated from 6 sibling PoCs, deposit_count column added for fair-router LRU)
- Edge Functions (Deno 2)
- pg_cron jobs
- Realtime publication + subscriber fan-out
- Database Webhooks via pg_net
- §ADR-8 fair-router (Mode 1 pool-broadcast support, post-INSERT trigger pattern)

**Outside Supabase (test infrastructure, can be local)**:
- fixture-gen (deterministic Poisson via mulberry32 seed)
- fixture-loader (replays at SPEED multiplier)
- bot-simulator (claim handler + statement push + verdict-from-fixture)
- mock-merchant (deployed AS an EF in Phase B for self-contained testing — hostedaes EFs cannot reach localhost)
- orchestrator + assertion harness

# Substrate features verified end-to-end

| Feature | Phase A (local) | Phase B (hosted) | Verified by |
|---|---|---|---|
| Postgres + RPCs | ✓ | ✓ | ledger gap=0.00, terminal counts match fixture |
| Edge Functions | (in-process) | ✓ Deno 2 cold-start <200ms | per-EF curl smoke + fixture-loader 100/50 run |
| pg_cron | (5s ticker) | ✓ 1m cadence | sweep_expired catches 8 DEP-EXP-* seeds; sweep_stale catches uncompleted claims |
| Realtime | (none) | ✓ INSERT + UPDATE filter | bot-sim claim_count == loader payout_count; Mode 1 UPDATE event fires after fair-router |
| Database Webhook (pg_net) | (none) | ✓ INSERT trigger → EF | callback delivery p50=1.2s vs cron-only 30s avg |
| fair-router LRU | (deferred) | ✓ §ADR-8 Tier-2 | 23 Mode 1 rows all assigned, max-min=1 across 3 banks |

# 9 bugs surfaced + fixed during PoC build

## Phase A (3)
1. **append-only INSERT order in create_payout** — UPDATEd wallets_change_logs.reference_id triggered append-only block. Fix: INSERT ts_payouts first, then INSERT wallets_change_logs with reference_id at INSERT time (not backfill).
2. **JSONB param shape** — Bun.SQL parameter `JSON.stringify(arr) + ::jsonb` produced jsonb scalar, not array → "cannot extract elements from a scalar". Fix: function param type changed to text + `::jsonb` cast inside RPC + `jsonb_typeof()` defensive check.
3. **numeric overload resolution** — Bun.SQL sent `300.01` as float8 (double precision), so `create_deposit(uuid, double precision, ...)` overload didn't exist. Fix: explicit `${amount}::numeric` cast in handler.

## Phase B (6)
4. **ALTER DATABASE postgres SET requires superuser** (Supabase hosted denies). Fix: `public.app_settings` table read by trigger functions via `SELECT value FROM app_settings WHERE key = ...`.
5. **net.http_post body parameter type** — pg_net signature is `body jsonb` not `body text`. Error: "function net.http_post(... body => text) does not exist". Fix: pass `body := jsonb_build_object(...)` directly.
6. **service_role auth in EFs** — `Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")` mismatch with header value. Fix: dropped auth check on internal EFs (dispatch-callback, fair-router); rely on URL obscurity + `--no-verify-jwt` boundary. Production: switch to custom INTERNAL_INVOKE_SECRET via `supabase secrets set`.
7. **`ORDER BY` placement in jsonb_agg** — `ORDER BY` after FROM clause errors with "must appear in GROUP BY"; correct form is `jsonb_agg(... ORDER BY col)` inside the aggregate.
8. **`DELETE requires WHERE clause`** — Supabase safety policy. Fix: `WHERE true` on every DELETE in `reset_runtime_state()`.
9. **Cloudflare Quick Tunnel API 500** (transient infra). Fix: ditched tunnel; deployed mock-merchant as 9th EF for self-contained PoC.

# §ADR-8 fair-router implementation (NEW for Phase B)

`fair_router_assign(p_queue_id uuid)` PL/pgSQL function:
- SELECT FOR UPDATE the withdrawal_queue row
- Resolve method = source_type_to_method(source_type)
- LRU pick: `SELECT bank_account.id WHERE pool_id = NEW.pool_id AND is_active = true AND bank_account_method.method = X ORDER BY deposit_count ASC, created_at ASC LIMIT 1`
- Atomic UPDATE: withdrawal_queue.required_bank_account_id = chosen + bank_account.deposit_count += 1
- Return chosen bank_account_id

Triggered by Database Webhook on INSERT withdrawal_queue WHERE pool_id IS NOT NULL AND required_bank_account_id IS NULL. The post-trigger UPDATE fires Realtime broadcast (REPLICA IDENTITY FULL) which the bot-sim subscribes to (filtered by required_bank_account_id).

LRU rotation result on 23 Mode-1 rows / 3 banks: scb=8, ktb=8, kbank=7 (perfect ±1 spread).

# What's still out of scope (post-PoC)

- §ADR-2 Better-Auth (full auth) — PoC continues stub `X-Client-Id` / `X-Bot-Secret`
- §ADR-7 API-Key full RBAC tier separation
- §ADR-13 Admin-API surface (manual reconcile, verify-slip-now, force-refund)
- §ADR-14 Fleet-Control (halt-pool, force-logout)
- §ADR-15 Monitoring/alerting wiring (Axiom + Sentry + Keep) — relies on Supabase EF logs only
- §ADR-16 Client topup B2B
- Multi-region replication / DR
- RLS policies (PoC uses service-role from EFs; production needs RLS for client tier)
- CI/CD pipeline for `supabase db push` + `functions deploy` (manual for now)
- Perf scale-up to 1000+ deposits
- Chaos / mutation testing on Phase B substrate (existing pgTAP mutation harness covers Phase A floor)
- P2P matching ADR (separate concept; see learning_2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p)

# Reproducibility

```bash
# Phase A (local Bun gateway)
cd poc/integration
bun install
supabase start
bun run src/run.ts                    # default 100/50 SPEED=1 (~9 min)
SPEED=10x FIXTURE_SIZE=tiny bun run src/run.ts   # fast smoke

# Phase B (hosted Supabase)
# prerequisites: supabase login + supabase link --project-ref <ref> + supabase secrets set BOT_SECRET=...
supabase db push
supabase functions deploy --no-verify-jwt deposits-create deposits-upload-slip payouts-create bot-statements bot-queue-mark bot-balance dispatch-callback fair-router mock-merchant
cd poc/integration
set -a && source ../../.secrets/supabase.env && set +a
SPEED=10x FIXTURE_SIZE=default bun run src/run-hosted.ts
cat evidence/integration-hosted-run-*.json | jq .latency_ms
```

# Pointers

- Plan file: ~/.claude/plans/polymorphic-questing-manatee.md
- Phase A commit: f7d3dad
- Phase B commit: 5095e53
- Local evidence: poc/integration/evidence/integration-run-2026-05-10T04-11-53-181-default.json
- Hosted evidence (tiny): poc/integration/evidence/integration-hosted-run-2026-05-10T05-48-06-756-hosted-tiny.json
- Hosted evidence (default 100/50): poc/integration/evidence/integration-hosted-run-2026-05-10T05-54-26-897-hosted-default.json
- Hosted Supabase project ref: spdazjbmyagekwxixfct (Singapore, free tier)
- Sibling PoCs (Postgres-floor pgTAP): poc/{4a, 4b, 4c, 4d, 9, 11, smoke}
- §ADR-8 fair-router learning: this PoC's `fair_router_assign()` RPC is the first runnable implementation; previously deferred as "Tier-2 not in scope" across §ADR-{4a, 4b}.

# Recommendation

Phase B substrate green. Next-impl candidates:
- (a) **Perf scale-up**: large fixture (500/250 or 1000/500) on hosted to surface EF concurrency + Postgres conn-limit (use Supavisor transaction-pool port 6543).
- (b) **Chaos**: mock-merchant EF behavior=mostly_500 → test cron retry + dead_letter terminal.
- (c) **§ADR-13 Admin-API extension**: replace cascade-stub admin verification in deposits-upload-slip with real admin EF + auth.
- (d) **CI**: GitHub Actions to `supabase db push` + `functions deploy` on merge to main, then trigger run-hosted.ts.
- (e) **next-architect handoff**: §ADR-8 now has a working implementation reference; ratify §ADR-8 amendment based on `fair_router_assign()` shape + LRU rotation evidence.

---
*Added via Oracle Learn*
