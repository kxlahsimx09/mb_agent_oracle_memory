# next-tester — nextfixa campaign findings

**Goal:** harden DEPOSIT test/CI robustness on the three recurring flakiness sources, with
**zero product-logic change**, so a re-run still reproduces the sealed **50/50** (baseline =
50/50 green at `6bd9538`). Test-harness-only. No product code / migrations / Edge Functions
touched. No verify assertion's pass/fail meaning changed. **Not merged** (owner reviews per
AGENTS §9).

Two PRs into `main`:

| PR | Branch | Scope | Files |
|----|--------|-------|-------|
| **#317** | `tester/nextfixa-ac5-deterministic-callback` | **A1** (AC-5 callback determinism) | `tests/integration/probes/{deposit-002-ac5-success-callback,_flow}.ts` + evidence |
| **#318** | `tester/nextfixa-load-dupegress-clock` | **A2** (dup_egress ground truth) + **A3** (SPEED-clock) | `poc/integration/src/load/{hosted-lifecycle-probe,concurrent-dispatch,callback-volume}.ts`, `poc/integration/src/probes/statement-dedup.ts` |

---

## A1 — AC-5 callback determinism (highest value) — PR #317

**Problem.** The AC-5 verify probe's delivered / non-delivered legs depended on the **external
`httpbin.org`** endpoint (slice seed: `callback_endpoint_key 'default'`→`/status/200`,
`'fail'`→`/status/500`). httpbin is globally flaky (was **503 at seal time**) — a future verify
run could go **red purely on reachability, not on logic**.

**Fix.** The probe now **seeds its own two endpoints** for `CLIENT_B` before create
(`upsert_client_callback_endpoint`, CU2/CU3, idempotent) at **deterministic, tester-controlled**
targets on **this** project's gateway:

- `KEY_OK` (`default`) → `${SUPABASE_URL}/functions/v1/mock-merchant` — the run-hosted
  mock-merchant EF (deterministic **2xx**; verified 10/10 → 200 on the tester stack).
- `KEY_FAIL` (`fail`) → `${SUPABASE_URL}/functions/v1/mock-merchant-ac5-deterministic-404` —
  a non-existent function name on the same project gateway → stable **404** (a deterministic
  non-2xx; CU3-valid public-https/:443).

Both targets live on the tester's **own** Supabase project, so reachability is identical to the
rest of the run with **zero external flakiness**. Overridable via env:
`CALLBACK_STUB_OK_URL` / `CALLBACK_STUB_FAIL_URL` / `MOCK_MERCHANT_URL` /
`CALLBACK_ENDPOINT_KEY_OK` / `CALLBACK_ENDPOINT_KEY_FAIL`.

**Files touched**
- `tests/integration/probes/_flow.ts` — new `setClientCallbackEndpointKey()` (keyed CU2 upsert helper).
- `tests/integration/probes/deposit-002-ac5-success-callback.ts` — resolve deterministic stub
  URLs from the tester stack; seed the two endpoints at the top of the run; finally-note updated
  (endpoints are idempotently re-seeded each run; no other probe asserts `CLIENT_B`'s url).

**Assertions UNCHANGED in meaning** — verbatim:
- `deposit_002_ac5_success_callback_delivered_on_2xx`: exactly 1 `deposit.paid` row →
  `status='delivered'` + `delivered_at` set + `last_response_code ∈ 200..299` + `attempt_count≥1`
  + **dup-egress (delivered rows) == 1** read off `callback_queue`.
- `deposit_002_ac5_not_delivered_without_2xx`: 1 row, `attempt_count≥1`, `status != 'delivered'`,
  `delivered_at NULL`, recorded `last_response_code` non-2xx; exactly 1 row (no dup-egress row).

Only the callback **target** changed (httpbin → tester-controlled), plus the probe now **seeds**
the endpoints it reads. The ground-truth reads and pass/fail predicates are byte-identical.

**Proof (tester stack, committed sha `657cde0`)**
- Slice **12/12** green; GAP **38/38** green → **50/50 unchanged**.
- AC-5 positive: `status=delivered last_code=200 delivered_at=… attempt_count=1 delivered_rows=1`.
- AC-5 negative: `status=pending delivered_at=null last_code=404 attempt_count=2` (single row).
- `evidence.endpoints`: `ok_url=…/mock-merchant`, `fail_url=…/mock-merchant-ac5-deterministic-404`.
- Files: `evidence/integration-deposit-slice-1780500146718-657cde05.json`,
  `evidence/integration-deposit-gap-1780500180650-657cde05.json`.

---

## A2 — dup_egress false-positive source — PR #318

**Problem.** Three load harnesses computed `dup_egress` from **in-flight counters / merchant-log
parse** instead of the `callback_queue` / `callback_attempts` ground-truth tables — the artifact
that reported `dup_egress=4` when the truth was `0`. Re-expressed each to read off the
ground-truth **table**, never the counters. (These harnesses were already quarantined; this makes
them read truth when un-quarantined. The naive-vs-coalescing contrast and the crash-clause bound
are preserved.)

**Files touched**
- `poc/integration/src/load/hosted-lifecycle-probe.ts` (~L114) — was
  `dup_egress: Math.max(0, attempts - delivered)` (counter proxy). Now a `callback_queue` SQL read:
  duplicate **delivered** rows per deposit = `SUM(GREATEST(0, delivered_count − 1))` grouped by
  `cq.source_id` for the run's deposits — AC-5-parity ("delivered_rows == 1 → dup-egress 0").
  `egress_attempts` / `delivered` kept as diagnostics.
- `poc/integration/src/load/concurrent-dispatch.ts` (~L144) — was `received − unique(merchant-log)`.
  The dedup **baseline** is now the `callback_queue` `delivered` row count (the TABLE), not the
  log's `unique`: `dup_egress = max(0, received − delivered)`. `received` (wire egress) stays as
  the thing we count duplicates of; the log's `unique` is retained as a `wire_log_unique`
  diagnostic only. Applied in both `runMode` and `runCrashMode`. This preserves the demonstrations
  (naive → dup>0; crash → dup ≈ stuck_claims, bounded ≤ stuck) while anchoring the SLO baseline on
  ground truth (fixes the stale/duplicate-log-line false positive).
- `poc/integration/src/load/callback-volume.ts` (~L164) — was `counters.egress − delivered`
  (in-process counter). Now `attemptRows − delivered`, where `attemptRows` is the per-leg
  **`callback_attempts`** (append-only egress ledger) row delta — the DB ground truth. coalescing ⇒
  1 attempt/event ⇒ 0; naive control ⇒ 2 attempts vs 1 delivered ⇒ dup>0 (preserved). Header +
  evidence `note` updated.

**SLO meaning preserved.** `slo.ts checkDupEgress` is unchanged: steady ⇒ must be 0; crash ⇒
≤ stuck_claims. The new ground-truth values satisfy the same gates with the same intent.

---

## A3 — SPEED-clock flakiness — PR #318

**Problem.** `poc/integration/src/probes/statement-dedup.ts` was SPEED-clock-coupled: `new Date()`
for `transaction_date_bkk` + a `SPEED=60x` ~15s wall window for the deposit TTL = a race-via-
wall-clock (FLAKY — the probe could outrun the deposit's expiry).

**Fix.** Re-expressed under the **§ADR-20 frozen-step virtual clock** (the determinism style
`cascade-race` adopted). A single instant `T0 = real-now + 5min` is **pinned** via
`clock_set(T0)` before any create/match (so every `app_now()` read returns `T0`, `speed=0`),
`transaction_date_bkk` uses the frozen `T0` instead of `new Date()`, and `clock_reset()` restores
real mode on both return paths. With the clock frozen, the deposit's `expires_at` is anchored at
`app_now()==T0 + TTL` and the cascade temporal checks read `app_now()==T0` — **deterministic
regardless of wall-clock elapsed or any SPEED multiplier**. (Probes run sequentially in
`runAllProbes`, so the global `sys_clock` pin cannot leak to siblings; `reset_for_test()` also
resets `sys_clock` to real, healing any exception-path leak.)

**File touched**
- `poc/integration/src/probes/statement-dedup.ts` — add module `T0`; `clock_set`/`clock_reset`
  bracket; both `transaction_date_bkk` now `T0`. Probe **logic and assertions unchanged**
  (`deposit_002_ac2_bot_retry_dedup` → 1 row + 1 credit + paid; `adr4b_b2_ambiguous_pair_preserved`
  → 2 rows kept, retry adds 0).

---

## Run status / caveats

- **A1 re-run executed** against the tester stack → 50/50 green (proof above). All four edited poc
  files transpile clean (`bun build`).
- **A2/A3** are code-only re-expressions of **quarantined** poc load/hosted harnesses; they are
  not part of the sealed 50/50 and were **not re-run** here (a poc-hosted/perf run needs the full
  load substrate). The changes are mechanical ground-truth-source swaps + a frozen-clock bracket,
  verified by reading + transpile.

## Out of scope (bounced to orchestrator)
- No product code / migrations / Edge Functions touched (test-harness-only).
- No verify assertion's pass/fail meaning changed.
- Functional gaps (`v_residual` over-credit guard, ADR-19 per-client MDR mapping, the negative/race
  suite) are a **separate later pass** — not this one.
- next-writer's SPEC rev-9 doc PR (on `docs/spec`) is independent — no overlap.
