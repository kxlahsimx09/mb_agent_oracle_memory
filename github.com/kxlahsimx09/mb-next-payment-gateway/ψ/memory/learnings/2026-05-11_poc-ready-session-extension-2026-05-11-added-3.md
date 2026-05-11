---
title: poc-ready (session-extension 2026-05-11): added 3 production-parity features to 
tags: [poc-implement, repo:mb-next-payment-gateway, next, poc, phase-b-extension, cost-coalescing, cluster-fixture-mode, promptpay-qr, emvco-tlv, crc16-ccitt, match-current-parity, dispatching-state, claim-for-dispatch, review-required-parking, multi-candidate-q4c, qr-payload-generation, qr-png-endpoint, session-2026-05-11]
created: 2026-05-11
source: supabase/{migrations/20260510000019_cost_coalescing.sql, migrations/20260510000020_cluster_assertions.sql, migrations/20260510000021_qr_promptpay.sql, migrations/20260510000022_qr_assertions.sql, functions/dispatch-callback, functions/_shared/promptpay.ts, functions/deposits-create, functions/deposits-qr} + poc/integration/{src/fixture-gen.ts, src/run-hosted.ts, evidence/integration-hosted-run-2026-05-11T08-30-40-609-hosted-tiny.json} @ commits 3ed24ef + 3d95efe + 128836b on agents/8-20260509-180226 (PR #52)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready (session-extension 2026-05-11): added 3 production-parity features to 

poc-ready (session-extension 2026-05-11): added 3 production-parity features to Phase B hosted substrate — §ADR-9 D1 cost-coalescing (eliminate Webhook+cron race), §ADR-4b D2 Q4c parking (multi-candidate review_required test), and PromptPay QR generation (1:1 TS port of #current helpers/promptpay.go). 25/25 assertions pass (up from 17/17 baseline).

# Three production-parity additions

## 1. §ADR-9 D1 cost-coalescing — eliminate Webhook+cron dispatch race

Before: Database Webhook fires per-INSERT AND pg_cron 1m sweep both poll status='pending' rows → duplicate merchant calls. Race masked at PoC scale because mock-merchant absorbed dupes via X-Event-Id dedup, but at production scale = ~50% wasted HTTP egress + rate limit pressure.

After (commit 3ed24ef, migration 019):
- Added 'dispatching' state + dispatching_started_at column to callback_queue
- claim_for_dispatch RPC (Webhook path): atomic UPDATE WHERE status='pending' RETURNING; 0 rows = race lost, skip
- claim_batch_for_dispatch RPC (cron path): CTE with FOR UPDATE SKIP LOCKED + UPDATE
- mark_delivered / mark_dead_letter: flip from 'dispatching' (was 'pending')
- mark_retry: 5xx-but-budget-remaining flips 'dispatching' → 'pending' for next sweep
- sweep_stuck_dispatching: 5-min crash recovery (4th cron job)

Result: 150 callbacks_delivered = 150 callback_attempts rows = 150 unique event_ids at mock-merchant (1:1, zero duplicates). callback p50/p99 unchanged (no slowdown).

§ADR-9 D1 said "advisory-lock cost-coalescing" but advisory locks don't fit EF substrate (xact lock release on RPC return; long-held lock blocks conn pool 5s; session lock leaks on EF crash). Status-based coalescing is the EF-compatible equivalent — same pattern as §ADR-4a claim_withdrawal_items.

## 2. §ADR-4b D2 Q4c parking — multi-candidate review_required test

Before: match_deposits_cascade Step 1 contains `ELSIF v_dep_count >= 2 THEN ... review_required` branch (multi-candidate parking) that was NEVER executed in any test run because amount jitter (`+ idx * 0.01` added during Phase A bug-fix) made every fixture amount unique → Step 1 always found 0 or 1 candidate.

After (commit 3d95efe, migration 020):
- CLUSTER_DUPLICATE_COUNT env opt-in (default 0)
- N cluster deposits at EXACT same amount, within 1s arrival window, expires_in_seconds=60
- Bot pushes statement at lag=10s
- Substrate enters review_required branch with N candidates listed in match_candidates jsonb
- All N cluster deposits expire via sweep_expired_deposits (terminal)
- Statement stays parked match_status='review_required' (admin-resolve is §ADR-13 scope, deferred)

run_hosted_assertions() extended with multi_candidate sub-object:
review_required_count, review_required_max_candidates, review_required_avg_candidates, review_required_samples (top 3 with candidate lists), seeds.cluster_{expired,pending,paid,total}.

4 new assertions: cluster_deposits_all_expired, cluster_deposits_zero_paid (no false-finalize), multi_candidate_review_required_triggered, multi_candidate_max_candidates_ge_2.

Verification: CLUSTER_DUPLICATE_COUNT=5 → review_required_count=1 (after dedup), max_candidates=5 (all 5 listed in JSONB), all 5 expired via sweep, 0 false-finalize.

Important: V1/V2 fraud cascade in slip flow still bypassed by fraud_seed shortcut in deposits-upload-slip EF. Step 2a/2b source-identity disambiguation (linkCheckingDeposit / linkPaidDeposit) still untested because bot-simulator hardcodes source_account_no="1234".

## 3. PromptPay QR generation (Match-#current 1:1)

Before: PoC deposits-create returned only `{payment_account_number, payment_account_name, payment_bank_code, expires_at, final_amount}` — no QR code; client couldn't display anything for customer to scan.

After (commit 128836b, migrations 021+022):
- _shared/promptpay.ts (~180 LoC) — TypeScript port of #current Go helpers/promptpay.go
  - EMVCo TLV encoder + CRC16-CCITT (poly 0x1021, init 0xFFFF)
  - Auto-detect: mobile (10d+0) / nationalId (13d+1-8) / taxId (13d+0) / ewallet (15d+0)
  - Mobile format: 0812345678 → 0066812345678 (drop leading 0, add +66)
  - Static (POI=11) vs Dynamic (POI=12) based on amount > 0
- bank_account.promptpay_id column + seed (SCB=0812345678, KTB=0823456789, KBANK=0834567890)
- ts_deposits.qr_payload + qr_type columns
- create_deposit RPC extended to return payment_promptpay_id
- deposits-create EF: post-RPC, generate payload + persist via set_deposit_qr RPC, return qrcode + qr_type + promptpay_number in response
- deposits-qr EF (NEW): GET /functions/v1/deposits-qr/:id?size=512 → render PNG via npm:qrcode@1.5.4 Medium error correction, 5min Cloudflare cache

Verified sample (DEP-EXP-0001, amount 100.08 → final_amount 98.28):
```
00020101021229370016A0000006770101110113006681234567852040000
5303764540598.285802TH5909PROMPTPAY6007BANGKOK630463D7
```
- 0002 0101  → payload format
- 0102 12    → POI=12 (dynamic, amount locked)
- 2937 0016A000000677010111 0113 0066812345678 → merchant AID + mobile sub-tag + formatted ID
- 5204 0000  → MCC N/A
- 5303 764   → THB
- 5405 98.28 → amount
- 5802 TH    → country
- 5909 PROMPTPAY → merchant name
- 6007 BANGKOK   → merchant city
- 6304 63D7  → CRC16-CCITT

PNG endpoint smoke test: 200 OK, image/png, 2.4KB at 256×256, valid PNG magic bytes (89 50 4E 47), served via Cloudflare BKK edge.

#current parity gaps acknowledged: #current also supports redirect mode (StorageURL = pre-uploaded CDN URL) — PoC only does on-the-fly render. Functionally equivalent for the 99% path used in production.

# Cumulative state of PR #52 (8 commits on agents/8-20260509-180226)

- f7d3dad — Phase A local Bun gateway integration PoC (16/16 assertions)
- 5095e53 — Phase B hosted Supabase (EF + pg_cron + Realtime + Webhook + fair-router) (17/17)
- d32d056 — Phase B substrate parity fix (Bun mock + Cloudflare tunnel) (17/17)
- 3ed24ef — §ADR-9 D1 cost-coalescing (17/17 + 0 duplicates verified)
- 3d95efe — §ADR-4b D2 Q4c parking + cluster fixture mode (21/21 with cluster=5)
- 128836b — PromptPay QR generation + PNG endpoint (25/25 with cluster=5)

Latest hosted run baseline (FIXTURE_SIZE=tiny + CLUSTER_DUPLICATE_COUNT=5, hosted Supabase project spdazjbmyagekwxixfct, ap-southeast-1):
- 25/25 assertions pass
- 15 deposits total: 7 paid + 6 expired + 2 fraud-failed; 5 payouts terminal
- 12 method='qr' deposits all have valid EMV payload (auto-detected as mobile)
- 1 statement parked match_status='review_required' with 5 candidates (Q4c works)
- 150-equivalent callback delivery: 1:1 ratio, 0 duplicates (cost-coalescing works)
- Bot-sim auto-exit, quiescence 5.5s after loader exit (cron rarely needs to fire)

# What's NOT yet tested (queued for next session)

Stochastic / probabilistic test gap (high priority):
- All verdicts still pre-tagged in fixture (PAY-WAI-*, PAY-FAI-*, fraud_seed)
- Bot follows script — never crashes silently, never times out, never sees real bank API variability
- Sweep paths (sweep_stale_claims, sweep_unmatched_statements) NEVER fire in test runs
- mark_retry path NEVER invoked (added by cost-coalescing, untested in flow)
- Dead-letter terminal NEVER reached (would need mock-merchant configured with mostly_500)

Behavioral gaps:
- §ADR-4b cascade Step 2a/2b source-identity disambiguation — bot hardcodes source_account_no="1234"
- §ADR-4d V1/V2 fraud cascade — short-circuited by fraud_seed shortcut, RPC bodies untested
- Multi-MDR fan-out — fixture uses tier-small profile only
- Multi-merchant — 1 merchant_config in seed
- Daily bank caps — not modeled

Security gaps (production-block):
- §ADR-2 Better-Auth — stub X-Client-Id only
- §ADR-7 RBAC — no tier separation
- RLS policies — service-role bypass everywhere
- service_role_key in app_settings table (plaintext) — should use vault

Operational gaps:
- No CI/CD (manual supabase db push + functions deploy)
- 22 migrations (3 are fix-overwrites: 013, 015, 018) — squash before production
- No TypeScript types from DB schema (all `any`)
- No monitoring stack (§ADR-15)
- Perf untested > 100/50 fixture
- Chaos testing: never run mock_merchant_behavior=mostly_500

# Pick-up-here for next session

User intent: continue substrate realism push. After QR generation closed (this session), next natural priorities ranked:

1. **Stochastic verdict model** (2-3 ชม.) — replace per-row bot_action.verdict tags with distribution-driven runtime decisions in bot-simulator. Surfaces: sweep_stale_claims invocations, mark_retry invocations, dead_letter terminal. New distribution assertions (3σ binomial).

2. **mock_merchant chaos** (1 ชม.) — switch MERCHANT_BEHAVIOR=mostly_200 → exercises retry budget + dead_letter terminal. Cost-coalescing's mark_retry path activates.

3. **Step 2a/2b source-identity test** (2 ชม.) — bot statement source_account_no varies per push (e.g., last-4 from a list of mock customers). Triggers linkCheckingDeposit / linkPaidDeposit cascade branches.

4. **Multi-merchant + multi-MDR fixture** (2-3 ชม.) — 3 merchants with different webhook URLs + retry configs, MDR tier rotation per deposit.

5. **Perf scale-up** (3-4 ชม. + analysis) — FIXTURE_SIZE=1000/500 with Supavisor pool, surface conn limits, EF cold-start variance.

6. **Real auth (§ADR-2/7)** — requires architect input + RLS design. Probably architect ratify pass first, then impl.

Suggested order: #2 (quick win, exercises pre-existing code paths) → #1 (replaces scripted philosophy) → #3 (last untested cascade branch) → #4-6 (longer arc).

# Files to read first when resuming

- /Users/dev01/.claude/plans/polymorphic-questing-manatee.md — Phase B plan (still relevant scope)
- poc/integration/src/run-hosted.ts — orchestrator (where new assertions go)
- poc/integration/src/bot-simulator/main-hosted.ts — where stochastic verdict logic would live
- poc/integration/src/fixture-gen.ts — where bot_action structure is defined
- supabase/functions/dispatch-callback/index.ts — exercise mark_retry path with mostly_500
- evidence/integration-hosted-run-2026-05-11T08-30-40-609-hosted-tiny.json — current baseline (25/25)

# Hosted Supabase project details

- Ref: spdazjbmyagekwxixfct
- Region: ap-southeast-1 (Singapore)
- Org: mb-payment-dev
- Credentials in .secrets/supabase.env (gitignored)
- DB password in .secrets/supabase_db_password.txt (32-char)
- 22 migrations applied
- 10 EFs deployed (deposits-create, deposits-upload-slip, payouts-create, bot-statements, bot-queue-mark, bot-balance, dispatch-callback, fair-router, mock-merchant fallback, deposits-qr)
- All deployed --no-verify-jwt (auth via headers)

# Reproducibility

```bash
# Apply latest migrations + EFs
supabase db push
supabase functions deploy --no-verify-jwt --all

# Run with current capabilities
cd poc/integration
set -a && source ../../.secrets/supabase.env && set +a
CLUSTER_DUPLICATE_COUNT=5 FIXTURE_SIZE=default SPEED=10x bun run src/run-hosted.ts

# Inspect evidence
cat evidence/integration-hosted-run-*.json | jq '.assertions | {passed, failed}'
```

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>

---
*Added via Oracle Learn*
