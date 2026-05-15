---
title: 
tags: [epic-deposit, integration-test, smoke-coverage, requirement-drift, pickup-roadmap]
created: 2026-05-13
source: next-impl gap-analysis 2026-05-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 


# epic-deposit.md vs hosted-smoke coverage gap analysis (2026-05-13)

Map of `docs/requirements/epic-deposit.md` (DEPOSIT-001..012, 8 stories) against the integration-smoke (`poc/integration/src/run-hosted.ts`, 63/63 assertions PASS as of PR #100 commit `e5dc287`). Captures three classes: **drift** (smoke contradicts spec), **partial coverage** (story covered but acceptance criteria missing), **entirely untested**.

Full report kept verbatim at: https://gist.github.com/kxlahsimx09/f8f0c41112ddce46ddb6af67f60001af (file `next-impl_20260513-161801_poc__2026-05-13_2008.md`)

## Covered ✓
- DEPOSIT-001 QR happy path (taxId 100%, base amount, customer_bank_* §CB1-CB3)
- DEPOSIT-002 Step 1/2a/2b cascade + identity-required + wallets_change_log atomic boundary
- DEPOSIT-003 DEP-EXP-* + A3LATE-* Step 2b post-expiry cross-ref
- DEPOSIT-004 SLIPH slip flow (upload → Thunder mock → admin approve → finalize)
- DEPOSIT-005 CLUSTER-FA1 (§FA1 degenerate-FIFO all paid) + CLUSTER-FA2 (last4 collision review parking)
- DEPOSIT-007 V1 (real SHA256 via V1TWIN pair) + V2 (receiver-mismatch) fraud + failure_code
- §ADR-9 wire contract — Stripe-style X-Maxpay-Signature 18/18 verified
- Transfer-before-deposit policy — RACE-TEMPORAL (cascade temporal-safety guard) + RACE-CROSSBANK (scope-filter natural)

## Drift ⚠️ (smoke ≠ spec — bug surface)
1. **DEPOSIT-001 AC #1 `expires_at` server-derived violated**. Spec: "server-derived per client config; request body cannot override." Smoke: `fixture-loader.ts:143` sends `expires_in_seconds`; `deposits-create/index.ts:46` accepts caller override. Fix: derive from `client.expired_deposit_time` per-client config; reject body override.
2. **Multi-bank routing**. Spec needs fair-rotation + per-bank daily cap + KTB intra-bank exclusion + NO_BANK_AVAILABLE_AFTER_EXCLUSION 503. Smoke: `create_deposit` RPC uses `ORDER BY ba.created_at, ba.id LIMIT 1` deterministic single-bank — no rotation tested at all.
3. **Idempotency error paths untested**. Smoke sends `Idempotency-Key` header but doesn't exercise: header-missing 4xx, replay-with-same-body returns stored response, REUSED_WITH_DIFFERENT_BODY 409.

## Entirely untested 🔴 (P0)
- **DEPOSIT-008** Admin verify-slip-now on-demand endpoint. `slip_verify_attempts` append-only history; 3-verdict (genuine/forged/thunder_system_error); sync 202 per ATC1. No endpoint exists in PoC.
- **DEPOSIT-012** Manual resend-callback. 202 fire-and-forget; race-guard CALLBACK_ALREADY_IN_FLIGHT; append-not-destructive (new callback_queue row, NOT counter reset); WC10 X-Maxpay-Event-Id header. No endpoint exists in PoC.

## Partial coverage 🟡 (P1)
- DEPOSIT-001: IDEMPOTENCY error paths · NO_BANK_AVAILABLE · NO_BANK_AVAILABLE_AFTER_EXCLUSION · AMOUNT_OUT_OF_RANGE · concurrent daily-cap · midnight BKK reset
- DEPOSIT-002: duplicate-stmt dedup · ALREADY_FINALIZED concurrent race · client-wallet-missing rollback · 5-second SLA · SCB/KTB per-bank parsers · callback_attempts increment+gating
- DEPOSIT-003: v_deposits.effective_status read-time invariant · finalize vs expire race-guard · `deposit.expired` callback delivery · sweep restart durability
- DEPOSIT-004: actor matrix (only `customer` auto-stub tested; missing client + sub-client + admin uploads) · tenant-scope 403 · Thunder verdict diversity (forged + system_error) · 3-timer independence · slip_verify_attempts append-only
- DEPOSIT-005: sweep filter excludes `review` (not explicitly verified) · admin resolution endpoint (admin-API future) · pending_review enum-not-adopted assertion
- DEPOSIT-007: force-approve override (literal + JWT user_type) · NATID mask comparator · V2 PARTIAL_DATA fail-closed · V1 day-bound window · admin queue fraud_preview Layer 1 · race-case admin flip-back

## Deliberate-divergence-from-current not verified
- `failed` vs `rejected` semantic split — smoke covers `rejected` via fraud, but `failed`=`system_error` path (chaos: wallet missing → finalize abort → status=failed) untested
- NO_BANK_AVAILABLE_AFTER_EXCLUSION vs current's silent fallback
- Append-not-destructive resend (DEPOSIT-012) vs current's counter reset

## Out-of-PoC per spec (not gaps)
- Admin UI (multi-candidate resolution, dead-letter queue UI) — §Scope boundary
- Per-tenant retry interval config — Phase-2 trigger-driven
- callback_attempts retention — data-governance ADR future
- bilingual TH/EN error messages
- name_score algorithm

## Pickup priority (next session)
**P0 critical:**
1. Server-derived `expires_at` from client config (DEPOSIT-001 AC #1)
2. Idempotency error paths
3. Duplicate stmt dedup (DEPOSIT-002 AC #2)
4. ALREADY_FINALIZED race (DEPOSIT-002 AC #6)

**P1 high (well-defined, doable in PoC):**
5. NO_BANK_AVAILABLE + EXCLUSION + AMOUNT_OUT_OF_RANGE error contracts
6. Force-approve override (DEPOSIT-007)
7. 4-actor matrix slip upload + tenant-scope
8. Thunder verdict diversity
9. `deposit.expired` callback delivery + WC10 Event-Id header

**P2 medium (need DB/fixture restructure):**
10. Multi-bank routing (fair-rotation + daily cap + midnight reset)
11. DEPOSIT-008 admin verify-slip-now endpoint
12. DEPOSIT-012 manual resend-callback endpoint
13. v_deposits effective_status read-time invariant
14. Race-case admin flip-back (DEPOSIT-007 C6)

**P3 deferred per spec** (admin UI, etc.)

## Context for pickup
PR #100 baseline: 63/63 PASS hosted smoke at SPEED=60x FIXTURE_SIZE=tiny. Migrations 020-025 applied. Cascade temporal-safety guard at 10s wall threshold. Tiny fixture covers: 4 QRH + 2 RACE (1 temporal + 1 crossbank) + 1 EXP + 1 SLIPH + 1 SLIPV1 + 1 V1TWIN + 1 SLIPV2 + 3 A3LATE + 2 CLUSTER-FA1 + 2 CLUSTER-FA2 = 18 deposits.

Next session can pick any P0/P1 item independently — each is well-scoped against a single AC in epic-deposit.md.


---
*Added via Oracle Learn*
