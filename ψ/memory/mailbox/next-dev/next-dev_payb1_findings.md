# next-dev — PAYOUT core-lifecycle slice-1 (campaign payb1) — findings

**Role/slot:** next-dev, stack slot **dev-1** (`.secrets/slots/dev-1.env`, ref `qvmjywljrgqzyxshexhx`).
**Branch:** `origin/build/payout-slice1` (off `origin/main`; `campaign/payb1 == origin/main`, 0 ahead).
**SPEC (contract):** `docs/spec/payout-core-lifecycle-slice.md` — broadcast via reply + `SPEC-BROADCAST.md`.
**Scope built:** PAYOUT-001 (create), PAYOUT-002 (claim→success+PW2), PAYOUT-003 (failed), SM1–SM3.
**Out of slice (not built):** PAYOUT-004/005/007/008/009/010/012/013; fair-router/BOT dispatch internals; success-confirmation audit (PAYOUT-009).

---

## ROUND 2 — next-architect payb1 rulings applied (gating, before cross-stack deploy)

Rulings: `next-architect_payb1_findings.md` (Q1/Q2/Q3/Q4/C1). My §5 round-1 notes 1–2 are now RULED + ENFORCED; note 3 (F2 triple) ruled `client_id`-suffices Phase-1; note 4 (`final_amount`) ruled display-only — no change. Applied to **PR #437** + SPEC v2 + a separate parity **PR #441**.

**PR #437 (gating edits — committed `8169193`, re-verified on dev-1):**
1. **Q2 fail-close** — `mark_success` now `RAISE mdr_over_allocated` + rolls back the whole settle when `Σ partner shares > payout_fee` (`residual < 0`). Inert on valid configs. (migration 110)
2. **Q1 tiebreaker** — `create_payout` MDR-profile select `ORDER BY created_at, id LIMIT 1` (global-singleton model; inert on single-profile). (migration 100)
3. **Q2 fixture** — seed MDR profiles' `payout_fee_percent` bumped (1.50/1.30/1.20) so seed partners (Σ 1.00%) are payout-valid (`residual ≥ 0`). **DEPOSIT-INERT** (`deposit_fee_percent` untouched). (migration 100 seed §4)

**SPEC v2 (CONTRACT change — RE-BROADCAST via `SPEC-BROADCAST.md` + orchestrator reply):**
- **C1** — §1 SM1 narrowed to **`ts_payouts.status` ONLY**; `withdrawal_queue` keeps a `claimed` work-state → §3.1 claim observable binds to `withdrawal_queue.status='claimed'` + `ts_payouts.status='processing'`.
- **Q2** — §3.2 conservation unchanged (`payout_fee = Σ credited + residual`) + explicit **`residual ≥ 0` invariant** + over-config fail-close clause.

**dev-1 re-verification (smoke ALL-PASS):** added an over-config fail-close scenario → `mark_success` RAISEs `mdr_over_allocated` + rolls back (stays `processing`). All prior scenarios re-pass with the seeded payout fee (tier-small 1.50% → fee 15.00, partners 6/4, residual 5.00, conservation 10+5=15).

**Parity PR #441 (DO NOT MERGE — deposit-lane mirror, `20260612000070`):** `finalize_deposit` residual<0 fail-close + `create_deposit` tiebreaker; **`pg_get_functiondef` byte-exact** bodies + 2 minimal injections; dev-1-verified non-regressive (deposit VALID path unchanged: client +982, partners 10.00, residual 8.00, conservation 10+8=18; over-config RAISEs + rolls back).

**⚠️ COLLISION SURFACED (not resolved unilaterally):** `admin_approve_paid`'s matching `residual<0` guard is **OMITTED** from #441 — **PR #438** (secres, `20260612000060`) is actively rewriting `admin_approve_paid`'s residual routing (adds the `v_residual` pool + `mdr_owner` routing + missing-owner fail-close, but **not** the over-allocation `residual<0` guard). A `CREATE OR REPLACE admin_approve_paid` in #441 would clobber #438. **Recommendation routed to orchestrator:** fold the 3-line `residual<0` guard into **#438** (natural home, right after its partner loop before `IF v_residual > 0`), or fast-follow once #438 merges.

---

## 1. Substrate census — ratified AC → verdict

> Substrate predates the ratified text (RPCs landed 2026-05-10..16). `stands` = already compliant, untouched. `drifts` = present but diverges → rebuilt. `missing` = absent → built.

### PAYOUT-001 (create)

| AC / contract item | verdict | delta built |
|---|---|---|
| 200 + freeze (`frozen += amount+fee`) + `withdrawal_queue` row + `pending` | **drifts** | response was `201` + `{payout_id,wq_id,request_id,final_amount,mode}`; rebuilt → **200** carrying request_id/amount/payout_fee/final_amount/dest number+code/status (PAYOUT-001 AC fields) |
| raw `callback_url` → `CALLBACK_URL_NOT_ALLOWED` (400) | **missing** | EF rejects any `callback_url` before state write |
| preconfigured PAYOUT endpoint resolved + snapshot | **missing** | `create_payout` resolves `client_callback_endpoints(flow='payout')`; `ts_payouts.callback_url` = RESOLVED url; `callback_endpoint_key`/`_version` snapshot cols added |
| no config → `CALLBACK_ENDPOINT_NOT_CONFIGURED` (409); bad key → `INVALID_CALLBACK_ENDPOINT_KEY` (400) | **missing** | RPC raises both (mirror `create_deposit`); EF `db.ts` already wired the wire-codes (409/400) |
| `IDEMPOTENCY_KEY_REQUIRED` (400) + replay-same + reuse-diff (409) + concurrent (409) | **stands** | `withIdempotency` wrapper (unchanged) |
| `PAYOUT_DISABLED` / `UNSUPPORTED_DEST_BANK` / `AMOUNT_OUT_OF_RANGE` (400) | **stands** | `create_payout` G9 checks (20260518000004) |
| `INSUFFICIENT_FUNDS` (4xx) + concurrent spend-guard | **drifts** | RPC raised it (402) but EF body had no `code`; added `insufficient_funds→INSUFFICIENT_FUNDS` to WIRE_CODES |
| `metadata` bound → `METADATA_TOO_LARGE` (400) | **missing** | EF bound (impl-pinned 30 keys / 8192 bytes); `metadata` jsonb col added |
| `client_reference_id` echo / `ref_code` | **missing** | `ref_code` col added + snapshot |
| create-time actor triple (§ADR-13 F2) | **missing — NOT built** (see §4 note 3) | `ts_payouts` has no `created_by_*` cols; weakly satisfied via `client_id` + asserted `sub` |

### PAYOUT-002 (claim → success)

| AC / contract item | verdict | delta built |
|---|---|---|
| claim `pending → processing`, bind bank, server-derived pool/method, one-batch-per-bank | **stands** | `claim_withdrawal_items` (20260520000002) |
| dead-session pre-claim health check | **stands (bot-side)** | bot seam; gateway never claims a dead session (no gateway code) |
| settle 4-step (status→success, wallet settle, callback, queue unlock) | **stands** | `mark_success` settle + callback (20260513000005) |
| **partner-MDR fan-out + PW2 residual** | **missing** | `mark_success` had **NO** fan-out at all; built the RM template (per-partner credit/`mdr_skip`, residual→`mdr_owner`, fail-closed; ledger balances `payout_fee = Σ credited + residual`) |
| atomic rollback (no success-with-frozen / no-callback / unbalanced) | **stands + hardened** | single txn; residual fail-closed RAISE rolls the whole settle back |
| success callback body (`SUCCESS`,`completedAt`,`fee`,`clientReferenceId?`) | **drifts** | added `clientReferenceId` (from `ref_code`) when set |
| duplicate success → benign no-op (no 2nd settle/callback/debit) | **drifts** | was queue-idempotency only; added SM3 positive `ts_payouts.status ∈ {processing,review}` assertion |

### PAYOUT-003 (failed)

| AC / contract item | verdict | delta built |
|---|---|---|
| `processing → failed` release (`frozen -= amount+fee`, balance untouched), callback, queue close | **stands** | `mark_failed` (20260513000005) |
| balance never touched on failed | **stands** | release-only |
| failed callback body (`FAILED`, mandatory `failureCode`, `fee`, `failureMessage?`, `clientReferenceId?`) | **drifts** | added `clientReferenceId` when set |
| pre-claim never `failed` (→ `cancelled`) | **stands** | claim required; cancel path out of slice |
| duplicate failed → benign no-op | **drifts** | was queue-idempotency only; added SM3 guard |

### SM1 / SM2 / SM2-SPLIT / SM3

| Item | verdict | delta built |
|---|---|---|
| SM1 state set (6 values; `rejected` retired; `review` non-terminal/callback-silent) | **stands** | CHECK (20260518000002) |
| SM2 per-RPC legal source-state assertions | **drifts** | `mark_success`/`mark_failed` had only queue-idempotency early-returns (no positive source-state assert) → built explicit lock-first asserts |
| **SM2-SPLIT** (`mark_failed` = `processing` ONLY; `review→failed` = no-op; late bot `success` from `review` = ACCEPTED) | **missing** | `mark_failed` would flip a `review` row to `failed` → built `processing`-only guard; `mark_success` accepts `review` |
| SM3 uniform CAS lock-first (`SELECT … FOR UPDATE` ts_payouts → assert → else benign no-op) | **drifts** | built into both RPCs (canonical lock order queue→ts_payouts→wallet) |
| `mark_rejected` orphan (wrote `status='rejected'` — illegal under final CHECK) | **drifts** | dropped (uncalled; EF routes `rejected`→`mark_failed`) |

---

## 2. Delta built (files)

**Migrations (3) — commit `06e94a6`:**
- `supabase/migrations/20260612000100_payout001_callback_endpoint_meta.sql` — ts_payouts snapshot cols (`callback_endpoint_key`,`callback_endpoint_version`,`mdr_profile_id`,`ref_code`,`metadata`); `create_payout` rebuilt (callback-endpoint resolve+snapshot, mdr_profile snapshot, richer RETURNS); payout-endpoint seed for all clients.
- `supabase/migrations/20260612000110_payout002_mark_success_pw2_fanout.sql` — `mark_success`: SM3 `{processing,review}` guard + PW2 partner-MDR fan-out + residual; `clientReferenceId` callback.
- `supabase/migrations/20260612000120_payout003_mark_failed_sm_guard.sql` — `mark_failed`: SM3 `processing`-only guard; `clientReferenceId` callback; `DROP mark_rejected`.

**Edge Functions (2) — commit `06e94a6`:**
- `supabase/functions/payouts-create/index.ts` — `CALLBACK_URL_NOT_ALLOWED`, `METADATA_TOO_LARGE`, `callback_endpoint_key`/`client_reference_id`/`metadata` pass-through, server-resolved callback (no raw url to RPC), **200** AC response.
- `supabase/functions/_shared/db.ts` — `insufficient_funds → INSUFFICIENT_FUNDS` wire code (also imported by `bot-queue-mark`).

`bot-queue-mark` EF unchanged (routes `success`/`failed`/`rejected`→`mark_*`; redeployed only to pick up the shared `db.ts`).

---

## 3. dev-1 deploy + verification (DONE)

- **Migrations:** `supabase db push` → all 9 pending applied (6 intervening main migs + my 3). `mark_rejected` drop NOTICE (idempotent).
- **EFs:** `supabase functions deploy payouts-create bot-queue-mark` → bundled clean (= build clean); reachable (HTTP 401 assertion-gate, not 404).
- **EFs:** unchanged in round 2 (gating round touched RPCs + SPEC + seed only); the round-1 `payouts-create`/`bot-queue-mark` deploys stand.
- **RPC smoke (non-destructive, BEGIN/ROLLBACK) — re-run after the gating edits, ALL PASSED** (values reflect the seeded payout fee: tier-small 1.50% → fee 15.00) —
  1. create→pending+fee 15+final 985+freeze(+1015)+endpoint/profile/ref snapshot;
  2. claim pending→processing (queue→claimed);
  3. success settle(−1015)+partners 6.00/4.00+residual 5.00+**PW2 conservation 10+5=15**+1 callback;
  4. duplicate-success benign no-op;
  5. **Q2 over-config fail-close** — `mark_success` on an over-allocated profile RAISEs `mdr_over_allocated` + rolls back (stays `processing`);
  6. **SM2-SPLIT** `mark_failed` on review = no-op; late success from review = ACCEPTED; `mark_failed` on terminal success = no-op;
  7. failed: status=failed, balance untouched, freeze released, 1 callback;
  8. create rejections: invalid_callback_endpoint_key / callback_endpoint_not_configured / unsupported_dest_bank / payout_disabled / amount_out_of_range / insufficient_funds.
  - Smoke script: `/tmp/payout_smoke.sql` (re-runnable against any slot's pooler URL).
  - **Deposit non-regression smoke (parity PR #441):** deposit VALID path unchanged (client +982, partners 10.00, residual 8.00, conservation 10+8=18 — INERT); over-config RAISEs `mdr_over_allocated` + rolls back.

---

## 4. Cross-stack deploy handoff (brew-ops / owner)

> `next-dev` holds only dev-1; the tester + investigator stacks are brew-ops/owner. Apply to **tester** + **investigator** so the stack-readiness gate passes before probes run.

**Migration set (apply in order, via `supabase db push` over the IPv4 session pooler):**
- the 3 slice migrations: `20260612000100`, `20260612000110`, `20260612000120` (now at commit `8169193` — 100/110 carry the Q1 tiebreaker + Q2 fail-close + payout-valid seed bump).
- **plus** any of these main migrations the target stack is behind on (dev-1 was behind on all 6): `20260611000300`, `20260612000010`, `20260612000020`, `20260612000030`, `20260612000040`, `20260612000050`. (These are already on `main` — pushing the branch applies them in order.)
- **NOTE:** the parity migration `20260612000070` lives on PR **#441** (DO NOT MERGE), NOT on this branch — do not bundle it into the #437 cross-stack deploy.

**Edge Functions to deploy** (needs `SUPABASE_ACCESS_TOKEN`):
- **`payouts-create`** (changed — required).
- **`bot-queue-mark`** (unchanged behavior; redeploy to pick up `_shared/db.ts` — optional, the changed WIRE_CODE is inert for it).

**Fixture prerequisites** (SPEC §5): per-client wallet (balance ≥ gross), `enable_payout`, band, an MDR profile (`payout_fee_percent` + partners w/ wallets), an `is_owner`/`mdr_owner` residual wallet, an active **payout** `client_callback_endpoints` row, a registry bank, and a **routed** `withdrawal_queue` item (routing is out of slice → seed it). The slice migration seeds a `default` payout endpoint for all clients.

---

## 5. Contract / ADR notes ROUTED to parent (for next-architect — NOT resolved unilaterally)

> **Status: notes 1 & 2 RULED (next-architect payb1) + ENFORCED in Round 2** (Q1 tiebreaker, Q2 fail-close + payout-valid seed). Note 3 RULED `client_id`-suffices-Phase-1; note 4 RULED display-only/no-change. Original text preserved below for the record.

1. **`create_payout` global-profile selection is non-deterministic.** — **RULED Q1:** global-singleton model (no per-client); fix = deterministic `created_at, id` tiebreaker (DONE, both lanes); per-client/tiered = Phase-2 story. It picks `mdr_profile ORDER BY created_at LIMIT 1` with **no tiebreaker**; the 3 seed profiles (`tier-small/medium/large`) share an identical `created_at`, so the chosen profile — and thus the **fee + the partner set the PW2 fan-out distributes to** — is non-deterministic per call. This is **pre-existing** (not my delta) but PW2 makes it money-load-bearing. **Q for architect:** should the payout fee/MDR profile be **per-client** (a `client.mdr_profile_id`) rather than a global oldest-row? (The deposit lane snapshots `mdr_profile_id` similarly — same question both lanes.)

2. **Partner-percentage-vs-fee over-distribution (shared deposit+payout).** — **RULED Q2:** PW2 template is CORRECT (re-affirmed); shares are gross-percentages constrained so `Σ partner-pct ≤ fee_pct`; an over-allocated profile is **INVALID config**, not an equation re-open. Enforcement DONE = fail-closed `residual<0` RAISE (`mark_success` + `finalize_deposit`; `admin_approve_paid` surfaced→#438) + the payout-valid seed fixture; config-write validation is a named follow-up. Original note: The RM/PW2 template computes `share = round(amount × partner.percentage / 100, 2)` and `residual = fee − Σ shares`. The seed profile partners (0.6%+0.4% = 1.0%) **exceed** the payout fee percent (0.3%), so `Σ shares (10.00) > fee (3.00)` → `residual < 0` → no residual credit → **partners are credited MORE than the fee debited from the client** (conservation `fee = Σ shares + residual` breaks). PW2's ratified equation only holds when `Σ partner-pct ≤ fee_percent`. I **faithfully mirrored the ratified deposit template** (did not change the share base). **Q for architect:** is partner % meant to apply to the **fee pool** (carved-from-fee, ratified prose) rather than the gross `amount`, or is an over-config a guarded error? This affects **both** `finalize_deposit` and `mark_success`. (My dev-1 smoke bumped the fee so `Σ shares ≤ fee` to demonstrate the residual leg cleanly.)

3. **§ADR-13 F2 actor triple not built.** `ts_payouts` has no `created_by_id/username/type` columns and the gateway assertion carries only `sub` (no username) — PAYOUT-001's "create-time actor triple populated, type `client`" AC is **not** structurally satisfiable today; weakly met via `client_id`. Flagged as a gap; needs the column-add + an EF-supplied username (or an architect ruling that `client_id` suffices for Phase-1).

4. **`final_amount` semantic.** `create_payout` stores `final_amount = amount − fee` while freezing `amount + fee`; PAYOUT-001 prose says "`amount` = what the destination will receive". Preserved existing/production-parity (`final_amount = amount − fee`); flagging in case the destination-pays-`amount` reading is intended.

---

## 6. DONE-WHEN status

**Round 1 (build):**
- [x] SPEC committed+pushed early + broadcast (reply + `SPEC-BROADCAST.md`).
- [x] Substrate census table (§1).
- [x] Delta built + deployed to dev-1 + verified (migrations push clean, EF bundle clean, RPC smoke all-pass).
- [x] ONE PR open vs main — **#437** (not merged; reviewer-gate + owner rules stand).
- [x] Findings file (this).
- [x] Final summary reply (to parent).

**Round 2 (next-architect rulings — gating before cross-stack deploy):**
- [x] Q2 fail-close `residual<0` RAISE in `mark_success` (PR #437, migration 110).
- [x] Q1 `created_at, id` tiebreaker in `create_payout` (PR #437, migration 100).
- [x] Q2 payout-valid seed fixture (`payout_fee_percent` bump; deposit-inert) (PR #437, migration 100).
- [x] SPEC v2 edits (C1 + Q2) committed+pushed; `SPEC-BROADCAST.md` updated; **re-broadcast reply to orchestrator**.
- [x] dev-1 redeployed + smoke re-run green (incl. over-config fail-close).
- [x] Parity PR **#441** open (DO NOT MERGE): `finalize_deposit` guard + `create_deposit` tiebreaker; dev-1 non-regression verified.
- [x] `admin_approve_paid` collision with PR #438 **surfaced** (not resolved unilaterally) — recommend folding the guard into #438.
- [x] Findings updated (this) + final reply to orchestrator.
