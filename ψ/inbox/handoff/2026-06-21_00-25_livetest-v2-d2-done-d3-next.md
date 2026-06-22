---
from: next-live-tester (session 2026-06-22)
to: [next-live-tester]
date: 2026-06-22T (GMT+7)
topic: v2 LIVE journey — D2 (deposit create-validation + idempotency) BUILT + GREEN 9/9, PR #719 open; D3 is next (paused for owner review)
status: D2 committed on agents/25-live-test-v2 → PR #719 to main (awaiting owner review/merge). Owner asked to PAUSE before D3.
tags: [#repo:mb-next-payment-gateway, #live-tester, #live-test-journey-v2, #d2, #d3, #handoff]
---

# Handoff → next-live-tester: D2 done, D3 next

## Done this session
- **D2 · Create rejected at input validation (+ idempotency)** — FAST card, **GREEN 9/9 on staging 2026-06-22**.
  - `poc/integration/src/live/journey-d2.ts` + `run-live-d2.sh` (+ evidence under `evidence/live/d2/`).
  - Run: `cd poc/integration && ./run-live-d2.sh` (FAST ~10s; holds the staging lock; no portal/bot/money).
  - **PR #719** → main (commit `b4b1eec` on `agents/25-live-test-v2`). Owner paused before D3.

## Key authoring patterns learned (reuse for D3+)
- **FAST cards skip D1's `provision()`** (it spawns browser/portal/bot/readiness). Use only: manifest
  `assertCoreCastReady` (lite) → `reset_runtime_state` → zero the cast banks' `daily_deposit_count`/`deposit_count`
  (reset_runtime_state does NOT clear them) → run. `LiveCapture` still used for evidence frames (browser
  renders API beats only; no UI driven). `finishImpl` is safe (no minted creds/procs/teardowns).
- **No GW4 fallback for reject legs:** `createDepositWire`/`depositCreateIdem` fall back to the GW4 lever when
  no deposit_id returns — that re-sends and would MASK a real reject. D2's `rawDeposit()` posts to
  `${CF_WORKER_URL}/deposits-create` with `signedClientHeaders` and returns the real {status,body}. For the
  missing-Idempotency-Key leg, delete the header (CF worker only forwards it when present).
- **Reject codes are EF-verified, not doc-trusted.** Source of truth: `supabase/functions/deposits-create/index.ts`
  (validation order: callback_url FIRST → missing amount/method/request_id (`error:"missing_fields"`, NO code) →
  invalid method → MISSING_REQUIRED_FIELD (names `customer_bank_account_number|_name|_bank_code`) → AMOUNT_OUT_OF_RANGE
  (floor<1) → METADATA_TOO_LARGE (>2KB or >20 keys)) and `supabase/functions/_shared/idempotency.ts`
  (IDEMPOTENCY_KEY_REQUIRED / replay cached / 409 IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_BODY).
- Idempotency replay/conflict via the proven `depositCreateIdem(client, body, key)` (no fallback on 409).
- ts_deposits is `client_id`-scoped; `reset_runtime_state` zeroes it so row-count asserts start at 0.

## NEXT: D3 · Create rejected at bank-routing & gates (designed in doc §6 D3)
- **Heavier:** 6 gates on the ENFORCEMENT cast (`CLIENT_ENFORCE` → `POOL_ENFORCE` → `BANK_ENFORCE`, all in
  the manifest), each = a violating create (exact code, ZERO rows) + a compliant one (201, one row):
  1. amount band [5000,9000] → 4999/9001 = `AMOUNT_OUT_OF_RANGE`; 7000 = 201
  2. daily cap=2 → #3 = 503 `NO_BANK_AVAILABLE`; then **back-date the bank's `*_reset_date` to yesterday (BKK)**
     → next = 201 (lazy clock-free reset). **No admin API for that field → declared DB write (§1.2).**
  3. per-bank maintenance window covering now → 503 `NO_BANK_AVAILABLE`; moved past now → 201
  4. KTB source-exclusion (`bankCode=KTB`, only KTB dests) → 503 `NO_BANK_AVAILABLE_AFTER_EXCLUSION`
  5. per-client `enable_deposit=false` → 403 `DEPOSIT_DISABLED_FOR_CLIENT`; re-enabled → 201
  6. global `deposit_maintenance=on` → 503 `DEPOSIT_MAINTENANCE`; cleared → 201
- **set → test → RESTORE** every flipped setting in teardown. Flip via the admin config API where one exists;
  declared DB only for the cap lazy-reset date. **VERIFY each code/HTTP against the EF + create_deposit RPC + the
  relevant migrations BEFORE hardcoding** (codes above are from the doc, not yet EF-confirmed — esp. the 503s
  and `DEPOSIT_DISABLED_FOR_CLIENT`/`DEPOSIT_MAINTENANCE` exact strings). Mirror D2's FAST scaffold.

## Open flags (unchanged, not blocking)
- Prod gap: `create_deposit` picks MDR profile by first created_at, not merchant-bound (RED-first card candidate).
- `reset_runtime_state` doesn't clear `bank_account.daily_deposit_count` (harness zeroes per-card; possible gateway handoff).
