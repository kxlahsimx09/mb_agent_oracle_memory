# next-investigator — PAYOUT slice-5 (FINAL: admin correction toolkit) Step-2 FALSIFICATION findings

**Campaign:** payb5i · **Branch:** `campaign/payb5i` (wt-c-payb5i) · **Date:** 2026-06-13
**Under test:** dev PR **#477** (`origin/build/payout-slice5`) + the payb5t probe PR · tester **54/54 GREEN (yupsev)**
**Seal stack (independent):** qnccph (`qnccphgykzdydebmdwdf`, `stack_role=test`) via investigator.env session pooler
**Method:** ONE `BEGIN…ROLLBACK` (`/tmp/falsify_payb5i.sql`), own fixtures, **independent re-derivation** of every money value (never trusted from the RPC return / dev / tester), every PASS attacked, zero-footprint.

---

## VERDICT — ✅ GREEN (slice-5 falsification PASS)

I re-derived every PAYOUT-012 `correction` / PAYOUT-013 `reverse_settle` / `mdr_clawback_fanout` behaviour **from the deployed substrate ground truth on qnccph** — real `pg_get_functiondef` bodies of all three RPCs + `mark_success`, real table constraints, the deployed EF source — never the dev/tester code or findings. I drove the **real deployed RPCs** with my own fixtures + my own recomputed expectations and attacked every PASS.

- **161/161** independent re-derivations reconcile with qnccph ground truth **+ 1 deliberate teeth-sentinel correctly RED** (proves the harness is non-vacuous), **0 unexpected failures**, all inside one `BEGIN…ROLLBACK`.
- The tester's **54/54 (yupsev) is corroborated by independent re-derivation on a different stack (qnccph) — NOT inherited.**
- **The clawback-conservation money rule is fully pinned (no money guess)** — confirmed from ground truth, recomputed to the satang from raw `wallets_change_logs` rows (not the harness sum) under three independent fixtures incl. odd-amount rounding and a per-partner shortfall.
- **Cross-boundary lock HELD** — `mark_success` / forward MDR fan-out / `match_payout_statement` are byte-unchanged (md5); no re-derivation required touching them. No STOP. slice-1/bbot seal intact.

Per-scenario reconciliation (all PASS, 0 FAIL): C1 review-correction 17 · C2 failed-correction 12 · C4 SM3-illegal-correction 29 · C5 PV1-R 6 · C6 §8-A 6 · R1 reverse-happy+CB5 29 · R2 reverse-shortfall 14 · R3 CB3-drift 2 · R4 SM3-reverse-illegal 31 · R5 rounding-attack 7 · R6 bare-success 5 · §8-C dedup-collision 3 · **TEETH 0/1 (deliberate RED).**

---

## Ground truth captured on qnccph (the inputs I trusted — the DB, not the docs)

- **HEAD migration** `20260613000010` (after `…000260`). The slice-5 migration **defines only the 3 greenfield fns + their REVOKE/GRANT** — it does **not** redefine `mark_success`/`match_payout_statement`/the fan-out.
- **3 RPCs present, SECURITY DEFINER, `proacl = {postgres, service_role}` only** (SV8-tight, no PUBLIC/anon/authenticated):
  `admin_correct_payout(uuid,uuid,text,text,text)` · `admin_reverse_settle_payout(uuid,uuid,text,text)` · `mdr_clawback_fanout(text,uuid,text)`. Signatures match SPEC §6.7 exactly.
- **Sealed-fn md5 (cross-boundary lock record):** `mark_success` = `55561e5aaccb2aa42582a47a5e65a3ff`; `match_payout_statement` = `966267eed668e235146ae9ca7def6d32`. Last defs: `mark_success` `…0110`, `match_payout_statement` `…0520…0007` — both **before** the prior seal HEAD `…000260`; slice-5's `…000010` is the only newer migration and touches neither ⇒ deployed bodies are byte-identical to the slice-4 seal **by construction**.
- **mdr_owner residual wallet present:** `33333333-…-0000000001ff` (owner_id `55555555-…-00ff`), baseline `0.00/0.00`.
- **`callback_queue` has `UNIQUE (dedup_key)`** + `dedup_key NOT NULL` + BEFORE-INSERT `_callback_queue_autofill` (fills `dedup_key := source_type:source_id:event` only when NULL/empty; resolves merchant_id; does **not** autofill `event_id`). **This is the structural basis of §8-C.**
- **`ts_payouts_failure_code_check`** = `{bank_rejected, validation_failed, kyc_blocked, admin_rejected, bank_timeout, claim_timeout, system_error, admin_cancelled, auto_cancelled}` — **no reverse code** (basis of §8-D).
- **wallet CHECKs:** `wallet_balance_gte_frozen (balance≥frozen)` + `wallet_frozen_nonneg (frozen≥0)` (the AM5 floor).

---

## What reconciled (the GOAL spine)

### PAYOUT-012 `correction` — BOTH source branches, DIFFERENT wallet paths (re-derived from the locked status)
- **review-source (C1, settle-from-freeze):** freeze held → `PERFORM mark_success` settles `balance −=gross AND frozen −=gross`. Verified client `50000→49795.96`, `frozen 204.04→0`; client wcl = **exactly one `payout_settle`, ZERO `payout_freeze`**; fan-out `mdr_distribute×2 (+2.00,+1.00)` + `mdr_residual (+1.05)`; **exactly one** `payout.success` callback w/ static `dedup_key=payout:<id>:payout.success`; audit `action_type=correction`, `actor_type=admin`, `metadata.source_state=review`; denorm `last_admin_action_{type=correction,reason}`; AM5 held.
- **failed-source (C2, re-debit):** freeze released → re-establish (`frozen+=gross`, one `payout_freeze`) **then** `mark_success` settles → **net** `balance −=gross`, **`frozen` UNCHANGED (0)**. Verified client `50000→49795.96`, `frozen 0→0`; client wcl = **one `payout_freeze` THEN one `payout_settle`**; audit `source_state=failed`. The PRE-freeze ordering keeps `frozen≥0` throughout (AM5).
- **Success leg inherited VERBATIM, NOT reimplemented** — confirmed by reading the deployed body (`PERFORM mark_success(v_queue_id,v_btxn)` in both branches) **and** by the fan-out/residual/single-callback reconciling against `mark_success`'s own output.
- **PV1-R inherited (C5):** over-allocated profile (Σ shares 2.00 > fee 1.00, residual −1.00) ⇒ RAISE `P0001 mdr_over_allocated …(residual=-1.00)` ⇒ whole correction rolls back, payout **stays `review`**, **no** settle/fan-out/callback/audit, client wallet unchanged.
- **SM3 illegal-source benign no-op (C4):** `pending/processing/success/cancelled` ⇒ `not_correctable` + status echo, **zero** money/callback/audit, status unchanged (incl. the already-`success` CT2 auto-reconcile-race cell). Random id ⇒ `not_found`.

### PAYOUT-013 `reverse_settle` — the money-load-bearing one (attacked hardest)
- **Happy (R1, all coverable):** `status success→failed`, `failure_code` COLUMN **NULL**, `failure_message='reverse_settle: …'`, queue→failed. Client **re-credited `+gross` (back to 50000), `frozen` UNCHANGED**, one `payout_reverse_settle`. Per-partner **full** `mdr_clawback` (A −2.00→0, B −1.00→0), residual unwound (owner back to pre), **exactly one clawback row per partner + one residual row** (no silent drop / no extra). One corrective `payout.failed` callback w/ **own `event_id` + explicit `dedup_key=payout:<id>:payout.failed:<audit_id>`**, `payload.failureCode='admin_reverse_settle'`; the **prior `payout.success` callback left untouched** (last-wins). Audit `reverse_settle/admin` + denorm.
- **CB5 reverse-conservation EXACT — recomputed BY ME from raw `wallets_change_logs`, not the harness sum:** `Σ mdr_clawback(partners) + Σ mdr_unwind_shortfall + residual_unwound = payout_fee`. R1: `3.00 + 0 + 1.05 = 4.05 = fee` (RPC return == my wcl reconstruction, Δ0 satang). R5 odd-amount (333.33/fee 7.77 → shares 3.33/1.67, residual 2.77): `5.00 + 0 + 2.77 = 7.77 = fee`. **The rounding leftover is absorbed by the residual by construction; the clawback reverses the RECORDED amounts, so no re-rounding can break it.**
- **Per-partner shortfall — never forced negative (R2):** drained victim A to `1.00` (< share 2.00) → A **UNTOUCHED (stays 1.00, ≥0)**, one `mdr_unwind_shortfall` recording the **FULL** 2.00, **zero** clawback on A; coverable B fully clawed; `shortfalls[]` lists A@2.00; **txn COMMITS** (PW3, `status=failed`); **CB5 still holds with shortfall:** `1.00 + 2.00 + 1.05 = 4.05 = fee`. AM5 held on every wallet.
- **CB3 reconstruct-from-recorded-amounts, NOT current profile (R3 attack):** after the forward settle I **drifted** partner A's profile % to `99.0`; the reverse clawed the **recorded `2.00`**, NOT `round(199.99×99/100)=197.99` — proving the clawback reconstructs from the change-log, immune to profile drift.
- **SM3 reverse legal source = `{success}` ONLY (R4):** `review/failed/pending/processing/cancelled` ⇒ `not_success` + echo, zero money/callback/audit. (This also makes a double-reverse a benign no-op — no double clawback.) Random id ⇒ `not_found`.
- **§6 bare-success caveat (R6):** hand-set `success` with no forward fan-out ⇒ `clawed=0/shortfall=0/residual=0` (nothing was distributed) — valid but **not** the conservation probe; client still `+gross` re-credited (PW1 is unconditional). Confirms the conservation witness REQUIRES a real prior settle.

### Cross-boundary lock — HELD (re-confirmed independently)
`mark_success` + the forward MDR fan-out (inline in `mark_success`) + `match_payout_statement` are **NOT modified** — proven two ways: (a) the slice-5 migration `…000010` body defines only the 3 greenfield fns + their grants; (b) md5 of the deployed bodies is the slice-4-sealed state, since no migration after `…000260` redefines them. The correction success leg `PERFORM mark_success` and reverse_settle reconstructs from its change-log rows. **No re-derivation required changing any sealed fn → no STOP, no slice-1/bbot seal re-opened.**

---

## §6 architect notes — assessed from MY ground truth (all REAL, all correctly NON-BLOCKING)

1. **§8-A (correction failed-path client insufficiency) — REAL, fail-closed (C6 confirmed live).** Client balance 100 < gross 204.04 ⇒ the re-freeze RAISEs `23514 wallet_balance_gte_frozen` ⇒ whole correction rolls back ⇒ 500, payout **stays `failed`**, wallet intact, **never forced negative**. The build's fail-closed default is AM5-safe and correctly implemented. Genuinely a *policy* question (fail-closed vs client-leg audit-shortfall) for next-architect — **not a defect.**
2. **§8-B (multi-generation reconstruction) — netting confirmed + ONE precision to surface.** The deployed `mdr_clawback_fanout` nets `net_share := Σ mdr_distribute − Σ mdr_clawback **− Σ mdr_unwind_shortfall**`. **NOTE:** SPEC §4.4 text states only `… − Σ(mdr_clawback)` — the deployed code *also* subtracts `mdr_unwind_shortfall`. This is **identical single-generation (0 prior rows) — proven** — and only diverges across re-correction generations (§8-B, out of Phase-1 scope). Surfaced to next-architect as a §8-B refinement; not reachable in the supported single-generation flow (see §8-C interaction below). **Not a defect for this slice.**
3. **§8-C (repeat-success dedup collision) — REAL risk, fails SAFE, and is *self-defending* (exercised live).** Confirmed structurally (`UNIQUE(dedup_key)` + static `payout:<id>:payout.success` autofill) **and** exercised: `forward → reverse → re-correct` ⇒ the 2nd `mark_success` callback INSERT hits `23505 callback_queue_dedup_key_key` ⇒ whole re-correction **rolls back, payout stays `failed`, NO money moved** (client balance byte-identical to post-reverse). **Key interaction I add to the dev/tester note:** this collision *blocks* the `success→reverse→correct→success` cycle entirely — so the §8-B multi-generation accumulation is **unreachable through the supported RPCs**. It is a fail-safe backstop, not a money hole. The single-generation invariant therefore holds **by construction** in the live flows. Correctly flagged non-blocking; the architect decision is whether to *enable* repeat-success (would need a `mark_success` touch → seal-gated).
4. **§8-D (reverse failure_code taxonomy) — REAL latent asymmetry (R1 confirmed).** The COLUMN is `NULL` (CHECK has no reverse code), the callback payload carries `failureCode='admin_reverse_settle'` — same pattern as `bank_maintenance`. Taxonomy-add is a shared-constraint change, architect-routed, out of slice. **Not a defect.**

**Conclusion on the four notes:** all four are accurately characterised by dev/tester, none blocks the dominant single-correction / single-reverse path, and §8-C additionally guarantees the multi-generation edges (§8-B) are unreachable.

---

## Method notes / scope

- **Virtual clock — N/A for slice-5 (verified by-read of all 3 RPC bodies).** Unlike slices 3/4 (sweeps), `correction`/`reverse_settle`/`mdr_clawback_fanout` have **no time-window or `app_now()`-gated branch** — `now()` is used only for `completed_at`/`failed_at` timestamps, never for a decision. No clock injection was load-bearing; none was needed.
- **NOT step-up — confirmed by-read.** Both EFs (`admin-payout-correct`, `admin-payout-reverse-settle`) import only `adminAuth, requirePermission, isAuthError` + `rpc, json` — **no step-up module**; chain = JWT-verify→aal2→IP-allowlist→RBAC `payout:approve`. The money logic was exercised via **direct service-role RPC** (no JWT) per SPEC §6; the live EF gate (401/403/405 + no-step-up-challenge, real gotrue aal2) is the tester's yupsev lane — corroborated by-read, not minted here (minting commits non-transactional gotrue rows = footprint).
- **Audit metadata** — reverse_settle writes the 4 clawback totals into `audit_log.metadata` (confirmed by-read; the canonical row + `last_admin_action_*` denorm reconcile in R1).

## Zero-footprint

After the run (post-`ROLLBACK`): `ts_payouts=0`, `withdrawal_queue=0`, `wallets_change_logs=0`, `callback_queue=0`, `audit_log=447` (baseline unchanged), my `payb5i-*` clients `0`, `mdr_owner` balance `0.00` (baseline). `pg_net` dispatch trigger rolled back transactionally. **Nothing committed to qnccph.** The 3 real banks `77…` were read-only references; shared merchant `1111…001` + `mdr_owner` wallet were read/asserted, not mutated past rollback.

**OUT OF SCOPE (untouched):** fixing / merging / marking; the EPIC-SEAL (slice-level only — the payout epic-seal is a separate next dispatch after all slices land); sinuw/dev-1/tester-stack/livegate/authfull. next-code-reviewer reviews **#477** + the probe PR in parallel (campaign payb5r).
