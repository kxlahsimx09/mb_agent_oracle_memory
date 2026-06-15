# brew-ops — PAYOUT slice-1 cross-stack deploy + GW4 provisioning + readiness verification (campaign payb1ops)

**Role/actor:** brew-ops, the **all-slots** deploy actor (next-dev holds only dev-1; tester + investigator
slots are brew-ops/owner — role isolation).
**Date:** 2026-06-12.  **cwd:** `mb-next-payment-gateway.wt-c-payb1ops` (branch `campaign/payb1ops`).
**Source:** PR **#437** branch `origin/build/payout-slice1` @ **`8169193`** — 3 slice migrations
(`20260612000100/110/120`) + EFs `payouts-create` + `bot-queue-mark` (picks up `_shared/db.ts`).
Fetched + checked out to an **isolated detached worktree** `/tmp/payb1-src` @ 8169193 (the dev's
`wt-c-payb1` was never touched — file reads + deploy from the isolated copy only).
**Targets:** tester stack `tester.env` = **yupsev** `yupsevcrubgprsbujbpu`; investigator/seal stack
`investigator.env` = **qnccph** `qnccphgykzdydebmdwdf`. (All `ap-southeast-1`.)

**BOTTOM LINE:** ✅ **BOTH stacks deployed + the tester stack is PROBE-READY.** 29/31 readiness checks
GREEN on each stack. The **2 REDs are PROBE-BINDING drift (next-tester _spec-payout.ts), NOT substrate**
— the substrate for both is present and correct (corrected filters are GREEN). The GW4 payout keypair
authenticates end-to-end on both stacks. **next-tester payb1t: stack is ready — see §5 for the two
one-line probe rebindings to apply before the run.**

---

## 1. Migrations (`supabase db push` over the IPv4 session pooler, `--workdir /tmp/payb1-src`)

### Tester (yupsev) — was FURTHER behind than briefed
- **Drift diagnosed (read-only `migration list` first):** last-applied = **`20260607000002`**, **23 pending**
  (not the ~6+3 the brief estimated — yupsev had been stale since 06-07, per the reg28 slot-map note).
- **Out-of-order wrinkle:** `20260607000001_deposit010_client_cancel` sorts *before* the already-applied
  `20260607000002_deposit012_…` (yupsev got 000002 without 000001). Plain `db push` correctly **refused**
  and asked for `--include-all`. This is **not a SQL/drift failure and not "forcing"** — it is the
  documented flag for an out-of-order file, and DEPOSIT-010 is **not** a prereq of the already-applied
  DEPOSIT-012 (000002 applied fine without it), so applying it now is correct. Confirmed with
  `--dry-run --include-all` (full ordered plan = the 23, ending in the 3 slice migs).
- **Applied:** `db push --include-all` → **all 23 in version order, exit 0**, ending at
  `20260612000120`. Now fully current.
- **Benign NOTICEs (idempotent guards, all `IF [NOT] EXISTS`, NOT failures):**
  `cancelled_at … already exists, skipping` (pre-existing column drift, absorbed — the "Drizzle-style
  index-exists drift" the brief flagged, handled gracefully); several `policy/trigger … does not exist,
  skipping`; `function mark_rejected(uuid,text,text) does not exist, skipping` (the dev's orphan-DROP).

### Investigator (qnccph) — exactly as briefed
- Confirmed at `20260612000050`; **3 slice migs pending** → plain `db push` (in order, no `--include-all`)
  → **exit 0**. (`mark_rejected … does not exist` NOTICE = benign DROP-IF-EXISTS on a fn qnccph never had.)

## 2. Edge Functions (`supabase functions deploy`, `SUPABASE_ACCESS_TOKEN` from each slot)
- **`payouts-create` + `bot-queue-mark` deployed to BOTH** yupsev + qnccph (with their `_shared` deps:
  `idempotency.ts`, `db.ts`, `gateway-assertion.ts`, `auth.ts`, `bot-auth.ts`).
- "Docker is not running" warning is **non-fatal** — CLI 2.104.0 bundled server-side via the Management
  API. Both EFs answer from their auth layer (**401, not 404**) on both stacks → GW4 gate live:
  `payouts-create` → `401 missing_assertion`; `bot-queue-mark` → `401 bot_key_missing`.
- Both `[functions.*]` blocks are `verify_jwt = false` (each owns its own GW4/bot-tier auth).

## 3. GW4 payout keypair (brew-ops-managed signing key, §ADR-2)
- **GW4 model (verified in `_shared/gateway-assertion.ts`):** `GW4_VERIFY_KEYS` is a flat
  `{ "<kid>": { kty:"OKP", crv:"Ed25519", x:"…" } }` map; alg pinned `EdDSA`; verifier accepts
  `scope ∈ {deposit,payout}` and `payouts-create` then hard-guards `scope === "payout"` (else 401
  `wrong_scope`). The keypair itself is scope-agnostic; "scope=payout" = the harness mints scope=payout.
- **Minted ONE Ed25519 keypair**, **kid = `payout-test-1`**, `pub.x = EuILnDclyBqQ1MZNJPzZ9QRpcZ-qoo6SzF5Bbv004sE`.
- **Merged (NOT clobbered) into `GW4_VERIFY_KEYS` on BOTH stacks** — EF secret values aren't readable,
  so each stack's existing public JWK was **re-derived from its slot private key** and verified
  **byte-exact against the deployed digest** before merge:
  | stack | existing kid | pre-merge digest (reconstructed == deployed) | post-merge digest (set == computed) | now contains |
  |---|---|---|---|---|
  | tester (yupsev) | `deposit-test-1` | `25897a21…` ✓ | `67d47cfc…` ✓ | `{deposit-test-1, payout-test-1}` |
  | investigator (qnccph) | `seal-test-1` | `2e534acc…` ✓ | `6b93e826…` ✓ | `{seal-test-1, payout-test-1}` |
  (Exact digest match both before and after = no hidden kids, byte-exact set, existing signers preserved.)
- **`tester.env` updated:** `GATEWAY_ASSERTION_SIGNING_KEY` (base64 PKCS8) + `GATEWAY_ASSERTION_KID =
  payout-test-1`, scope=payout. The prior `deposit-test-1` keypair is **preserved as a commented backup**
  (still registered in GW4_VERIFY_KEYS — restore the 2 lines to sign scope=deposit again). Mode `600`.
  Private key never echoed/committed; investigator.env's signer unchanged (still `seal-test-1`).
- **End-to-end proof (both stacks, NON-mutating):**
  `scope=payout` → **400 `IDEMPOTENCY_KEY_REQUIRED`** (signature verifies + scope accepted, no state);
  `scope=deposit` → **401 `wrong_scope`**; missing assertion → **401 `missing_assertion`**.

---

## 4. TESTER stack-readiness checklist (tester findings §2) — per-item GREEN/RED

| # | Item | Verdict | Evidence |
|---|---|---|---|
| R1 | tables not-404: ts_payouts, withdrawal_queue, wallet, wallets_change_logs, client_callback_endpoints, mdr_profile, mdr_profile_partners (+ client, bank_account) | **GREEN** | all 9 → REST 200 (service-role) + `to_regclass` non-null |
| R2 | EF payouts-create deployed (GW4 gate live = 401 not 404) | **GREEN** | `401 missing_assertion` |
| R2 | EF bot-queue-mark deployed (respond, not 404) | **GREEN** | `401 bot_key_missing` |
| R3 | RPC claim_withdrawal_items(p_bank_account_id) | **GREEN** | resolves (200), sig exact |
| R3 | RPC mark_success(p_queue_id,p_bank_transaction_id) | **GREEN** | resolves, sig exact |
| R3 | RPC mark_failed(p_queue_id,p_error_message,p_failure_code) | **GREEN** | resolves, sig exact |
| R3 | RPC upsert_client_callback_endpoint(…) | **GREEN** | resolves (no PGRST202); left no junk row |
| R4 | RPC app_now / clock_set / clock_advance / clock_reset | **GREEN** | resolve (200/200/200/204) |
| R4 | RPC reset_for_test | **GREEN** | resolves; **ran clean** (empirical, below) |
| R5 | ≥1 bank_account (registry) | **GREEN** | 3 rows (scb/ktb/kbank) |
| R5 | enable_payout client + funded wallet + band | **GREEN** | 5 clients `enable_payout=true`, band 1.00–1,000,000.00; client wallets balance=50000, frozen=0 |
| R5 | mdr_profile with payout_fee_percent (slice bump) | **GREEN** | 3 profiles = **1.50 / 1.30 / 1.20** (the slice-100 bump) |
| R5 | ≥1 mdr_profile_partners row with a partner wallet | **GREEN (substrate)** | 6 partner rows (2/profile); 2 `owner_type='partner'` wallets matching `partner_id`. **NB: gate's `select=wallet_id` false-REDs — see §5** |
| R5 | is_owner mdr_owner residual wallet | **GREEN (substrate)** | 1 `owner_type='mdr_owner'` wallet. **NB: gate's `is_owner=eq.true` false-REDs — see §5** |
| R5 | active payout client_callback_endpoints (flow=payout, key=default) | **GREEN** | 5 rows flow=payout key=default is_active (slice-100 seed) |
| — | GW4 payout-test-1 keypair signs+verifies (scope=payout) | **GREEN** | 400 IDEM_REQUIRED (no state) |

**Empirical reset-safety (the probe runner's `reset+clock → gate → lanes` preamble):** `reset_for_test()`
→ `reset_runtime_state()` DELETEs only *transactional* tables (ts_payouts, withdrawal_queue,
callback_queue, wallets_change_logs, …) and resets balances (client→50000, partner/mdr_owner→0). It does
**NOT** touch `client_callback_endpoints`, `mdr_profile`, `mdr_profile_partners`, or wallet rows.
**Verified by running it:** post-reset the payout endpoints (5), MDR fees (1.50/1.30/1.20), partner
wallets (2), residual wallet (1), partner rows (6), enable_payout clients (5), client wallet (50000) ALL
**survive**; ts_payouts → 0 (clean slate). So the slice-seeded payout config is **reset-durable** — the
probe's reset preamble will not erase it (a real risk had reset reseeded an old fee/endpoint set).

---

## 5. The 2 RED items — PROBE-BINDING drift, NOT a substrate blocker (BLOCKER surfaced + routed to next-tester)

Both REDs are SPEC-vs-impl **column-name** drift in the tester probe's `_spec-payout.ts` / `readiness.ts`
bindings. The deployed substrate has the fixtures; the gate's *filter column names* don't match the
deployed schema, so two `readiness.ts` REST filters return a PostgREST `42703 column does not exist` →
the gate would **false-RED**. Confirmed against the dev's deployed `mark_success` (migration 110):

1. **`mdr_profile_partners`** — probe binds `mppWalletId = "wallet_id"`; the deployed table has **no
   `wallet_id`** (cols: `mdr_profile_id, partner_id, percentage`). The impl resolves the partner wallet
   via `mdr_profile_partners.partner_id → wallet(owner_type='partner', owner_id=partner_id)`.
   - Gate line: `restSelect(mdr_profile_partners, "select=wallet_id&mdr_profile_id=eq.…")` → **42703 → []** → false-RED.
   - **Fix (next-tester):** the readiness partner check should `select=partner_id` (corrected filter = **GREEN, 1 row**).
   - Also `mppIsActive = "is_active"` is **absent** on the table — partner active-ness is the **partner
     WALLET's `is_active`** (mark_success reads `w.is_active` off the joined partner wallet). This
     **matches the tester's own [SPEC-PENDING] note** ("probe deactivates the partner *wallet*") → the PW2
     `mdr_skip` money-lane probe is already correct; only the readiness binding needs the rename.

2. **`wallet.is_owner`** — probe binds `walletIsOwner = "is_owner"`; the deployed `wallet` has **no
   `is_owner`** (cols: `id, owner_type, owner_id, balance, is_active, created_at, frozen`). The impl
   identifies the residual wallet by **`owner_type='mdr_owner'` ALONE** (mark_success L64/L76:
   `… FROM wallet WHERE owner_type='mdr_owner'`; "is_owner" appears only in prose comments).
   - Gate line: `restSelect(wallet, "select=id&owner_type=eq.mdr_owner&is_owner=eq.true")` → **42703 → []** → false-RED.
   - **Fix (next-tester):** drop the `is_owner=eq.true` predicate; `owner_type=eq.mdr_owner` alone
     (corrected filter = **GREEN, 1 row**).

> These are **probe-code reconciliations (next-tester owns `_spec-payout.ts`/`readiness.ts`)**, not deploy
> blockers — I deployed the dev's exact #437 handoff set; the substrate matches the dev's RPC contract.
> Surfaced here (per "a failed item is a BLOCKER to surface with detail, never silently skipped") because
> they are load-bearing for the run: left unrebound, the Lane-0 gate false-REDs and the money lanes
> report BLOCKED-ON-DEPLOY against a substrate that is actually ready.

**Also (known, flagged — not new):** `ts_payouts` has **no actor-triple columns** (`created_by_id/
username/type` absent) — matches dev §4 note 3; the probe already degrades to `client_id` + asserted
`sub`. `wallets_change_logs` has all four `balance_before/after, frozen_before/after` columns (GREEN).

## 6. Investigator (qnccph) deploy-confirmation
Same trimmed verifier (URL/SVC=qnccph; signed with the `payout-test-1` private key): tables present, EFs
deployed (401 gate live), slice RPCs resolve, **`payout-test-1` verifies on qnccph too** (scope=payout→400
IDEM, scope=deposit→401 wrong_scope) → confirms the payout pubkey is live in qnccph's `GW4_VERIFY_KEYS`.
enable_payout client + payout endpoint + residual wallet present (qnccph also got the slice-100 seed).
**Identical 2 column-binding REDs** (same impl, same drift — consistent across stacks).

## 7. Out-of-scope honored
- **dev-1 untouched** (read the dev's *findings*, deployed from an isolated `/tmp/payb1-src` checkout — never the dev's `wt-c-payb1` worktree, never dev-1.env).
- **sinuw/staging untouched; no PR merged; livegate / #433 / #438 untouched; no production code modified** — deployed **exactly** the #437 handoff set (3 migs + 2 EFs).
- **Parity migration `20260612000070` (PR #441, DO-NOT-MERGE) was NOT bundled** — it is not on `build/payout-slice1`, and `db push` from the branch never saw it.
- `SUPABASE_ACCESS_TOKEN` (owner-held) was already present in both slots; DB pushes used only the slot DB password over the IPv4 session pooler.

## DONE-WHEN
- [x] Tester fully current (23 migs, incl. 3 slice) — exit 0.
- [x] Investigator: 3 slice migs — exit 0.
- [x] EFs `payouts-create` + `bot-queue-mark` deployed to both stacks (401 gate live, not 404).
- [x] GW4 `payout-test-1` keypair minted, merged into `GW4_VERIFY_KEYS` on both stacks (digest-verified, existing kids preserved), written into `tester.env` (scope=payout, mode 600), proven end-to-end on both.
- [x] Readiness checklist verified per-item (above), incl. empirical reset-safety.
- [x] Findings written (this file).
- [x] Stack-ready signal to next-tester (payb1t) — sent; **2 probe rebindings in §5 to apply first**.

---

## 8. FOLLOW-UP DEPLOY — parity migration `20260612000070` (#441, merge `68b12559`) — 2026-06-12

Owner merged **#441** (deposit-lane parity: `finalize_deposit` residual<0 `mdr_over_allocated` RAISE +
`create_deposit` `ORDER BY created_at, id` tiebreaker — byte-exact mirror, reviewer-verified) + **#440**
(docs-only ADR, no deploy). Task: apply the single migration `20260612000070` to **both** stacks.

- **Source:** fresh isolated checkout of `origin/main` @ **`68b1255`** → `/tmp/payb1-main` (removed after).
  Confirmed main's slice migs `100/110/120` are **byte-identical** to my earlier-deployed `8169193`
  (`git diff` empty) → no slice-lane drift; the test/probe commits (#439) carry no migrations.
- **Out-of-order note (same benign class as §1):** `000070` sorts *before* the already-applied
  `000100/110/120`, so plain `db push` refused → used `--include-all`. `--dry-run --include-all` on BOTH
  stacks confirmed the plan was **exactly `[20260612000070]`** (nothing else re-pushed — the slice migs are
  matched by version in remote history and skipped). `000070` only CREATE-OR-REPLACEs the two deposit RPCs;
  no dependency on the payout slice → applying it after `000120` is correct.
- **Applied:** `db push --include-all` → **both stacks, clean ("Finished", no errors)**.
- **Verification (psql `prosrc` + `schema_migrations`) — ALL TRUE on BOTH yupsev + qnccph:**
  | check | tester | investigator |
  |---|---|---|
  | `000070` in migration history (list shows `…070 | …070` applied) | ✅ | ✅ |
  | `finalize_deposit` body contains `mdr_over_allocated` | ✅ | ✅ |
  | `finalize_deposit` has residual `< 0` fail-close RAISE | ✅ | ✅ |
  | `create_deposit` body contains `ORDER BY created_at, id` | ✅ | ✅ |
- **Scope honored:** sinuw/staging + dev-1 untouched; only `000070` applied; no EF deploy (RPC-only
  migration); no other migration pushed.

**FOLLOW-UP RESULT: ✅ DONE on both stacks.**
