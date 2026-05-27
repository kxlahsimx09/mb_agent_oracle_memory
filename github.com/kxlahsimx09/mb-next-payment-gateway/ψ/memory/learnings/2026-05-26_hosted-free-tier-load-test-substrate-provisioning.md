---
title: Hosted free-tier load-test substrate provisioning recipe + gotchas (mb-next-paym
tags: [brew-ops, repo:mb-next-payment-gateway, fleet, supabase, loadtest, provisioning, gotcha, reset-runtime-state, edge-functions]
created: 2026-05-26
source: thread #216 msg 1077 — free-tier substrate provision (brew-ops, project swqosfqrpmrhnebhksgd, 2026-05-26)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Hosted free-tier load-test substrate provisioning recipe + gotchas (mb-next-paym

Hosted free-tier load-test substrate provisioning recipe + gotchas (mb-next-payment-gateway, thread #216, 2026-05-26). Proven end-to-end on a user-provisioned project.

ORDERING GOTCHA (load-bearing): `reset_runtime_state()` does `DELETE FROM bank_statements WHERE true` (among other transactional tables). So a ~50k `bank_statements` G-L7 backfill MUST be the LAST data step, AFTER the final reset — otherwise reset wipes it. Corollary for the downstream runner (next-impl): its harness must NOT call reset_runtime_state after handover, or it must re-backfill — else the G-L7 working set is gone. reset does NOT delete bank_account/bank_account_method, so the 13-bank fleet seed survives reset; it resets wallets (client=50000, others=0), deposit_count=0, daily_deposit_count=0, and re-derives merchant_config.callback_url from app_settings.dispatch_callback_url (replace /dispatch-callback → /mock-merchant). Latest reset_runtime_state lives in migration 20260522000003 (merchant_config id = 11111111-1111-1111-1111-000000000001).

RECIPE (free-tier-adjusted, mirrors #216):
1. Creds may be a LEAN set (SUPABASE_URL/ANON/SERVICE_ROLE/DB_PASSWORD/BOT_SECRET/ACCESS_TOKEN). Derive PROJECT_REF from SUPABASE_URL. If the CLI default login can't see the project (new/separate org), the ACCESS_TOKEN (sbp_ PAT, 44 chars) is REQUIRED — set it as SUPABASE_ACCESS_TOKEN for link/deploy/Mgmt-API.
2. REGION + pooler host: get from Mgmt API `GET /v1/projects/{ref}/config/database/pooler` — the host prefix is project-specific (saw `aws-1-ap-northeast-2`, NOT the assumed `aws-0`). Don't guess it.
3. Migrations: `supabase db push --db-url <session pooler :5432>` (direct host db.<ref>.supabase.co is IPv6-only/unreachable from IPv4; transaction pooler :6543 breaks migrations).
4. app_settings (key/value table, migration 012 hard-codes the SHARED project spdazjbmyagekwxixfct): UPDATE dispatch_callback_url, fair_router_url, service_role_key → the new project ref + the new project's service-role key. Do this BEFORE reset_runtime_state.
5. 13-bank seed = mirror seedFleet() (poc/integration/src/load/concurrent-multibank.ts): DELETE bank_account_method + bank_account, INSERT 13 banks `77777777-7777-7777-7777-<lpad(i+1,12)>` in pool `66666666-6666-6666-6666-000000000001`, system_bank_code='scb', account_number '600'+lpad(i,7), balance 1_000_000, + deposit & payout method on each. Supersedes the single-deposit-bank topology (migration 20260522000003).
6. Deploy EFs: `supabase functions deploy --no-verify-jwt` (deploys all dirs, skips _shared). Secrets: BOT_SECRET + MERCHANT_BEHAVIOR=always_200 (via --env-file). origin/main currently has 18 deployable EFs (not 19).
7. Smoke (EF path, on-project mock): deposits-create REQUIRES header `Idempotency-Key` (exact name, no x- prefix; §ADR-11 C5) + Authorization: Bearer ANON + x-client-id: client-a-api-key; body {amount,method,request_id,callback_url,customer_bank_account_number}. Read the assigned bank + exact amount back from ts_deposits (LRU picks a fleet bank). bot-statements: header x-bot-secret: <BOT_SECRET>; matching statement needs source_account_no == deposit.customer_bank_account_number, amount == deposit.amount, system_bank_id == assigned bank, direction='in'. Callback delivers via DB webhook (eager, on callback_queue insert) + pg_cron dispatch-callback-sweep (60s backstop) → on-project mock-merchant EF inserts mock_merchant_events. Verify ts_deposits.status='paid', callback_queue.status='delivered', mock_merchant_events count.

COMPUTE-CLASS gotcha: a project in a Pro org can still run free/micro compute — verify `current_setting('max_connections')` LIVE (60=free/micro, 120=Medium); the org plan does NOT imply the per-project compute add-on (§C.7 / msg 1061). 50k bank_statements ≈ 18 MB; full DB ≈ 32 MB = 6.3% of the 500 MB free cap (ample headroom).

---
*Added via Oracle Learn*
