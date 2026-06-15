# next-tester regression re-certification — campaign `reg28`

**VERDICT: NO REGRESSION** at `origin/main` HEAD `e69bc76` (post PR #423/#424/#425/#427/#428/#429/#430/#431/#432).

- **Date:** 2026-06-12 · **Runner:** next-tester (campaign reg28) · **Stack:** qnccph (`qnccphgykzdydebmdwdf`, creds in `investigator.env` — the same stack the morning #17 cert ran on; `tester.env`→yupsev is ~15 migs stale and not a viable target).
- **Baseline:** the 2026-06-12 morning #17 cert vs main `329051c` (pgTAP 171/171 · A6 9/0/1 · substrate 65/67).
- **Bottom line:** every delta vs the morning baseline is fully attributable to **intentional, ratified substrate evolution merged since `329051c`** (SV7c/SV8/SV9 grant tightening #423/#425, CA8 catalogue #415, v_payouts_read #428, live_signoff #427) — each either adds new GREEN coverage or *tightens* security so that an unchanged/old probe's expectation went stale. No previously-passing security or correctness contract is broken. The 2 bbot BS-2 REDs are the **known by-design pair** (not new).

---

## Pre-flight — stack readiness at HEAD  ✅ GREEN

| Check | Result |
|---|---|
| Migration head | `20260612000050_adr21_l5_live_signoff` (top), **141 migrations** total |
| 5 new `20260612*` migs recorded | `000010`(SV7c) `000020`(SV8 #423) `000030`(SV9 #425) `000040`(v_payouts_read #428) `000050`(live_signoff #427) — all present |
| New substrate objects | `public.v_payouts_read` view present · `public.live_signoff` table present |
| EF ledger (`scripts/ef-deploy-list.sh --assert qnccph…`, the #424 generated list) | **source=27 / ACTIVE-deployed=27 — OK, no family excluded** |
| pgtap | available 1.3.3 (injected in-txn per the morning no-residue technique) |

Investigator's 15:10 finding (qnccph @ `20260612000050`) is confirmed. No BLOCKER — proceeded to run.

---

## Suite 1 — pgTAP  (baseline 171/171)

The suite **grew** at HEAD: the new substrate shipped new pgTAP files (`sv8`, `live_signoff`, `rbac_seed`) and expanded `sv7b`. Per-file, production tests, unpatched, run on qnccph:

| File | plan | ok | not-ok | vs baseline | Verdict |
|---|---:|---:|---:|---|---|
| `rls_tenant_isolation_test` | 35 | 35 | 0 | **unchanged file, = baseline 35** | ✅ GREEN |
| `v_deposits_rls_test` | 13 | 13 | 0 | **unchanged file, = baseline 13** | ✅ GREEN |
| `auth_phase2_a4_rls_test` | 75 | 50 | 1 | **2 stale assertions → aborts at 51** | ⚠️ see R1 (not a regression) |
| `sv7b_rls_or_no_grants_test` | 61 | 61 | 0 | grew from 48 (more SV-series tables in sweep) | ✅ GREEN (+13 new) |
| `sv8_execute_or_no_grants_test` | 121 | 121 | 0 | **NEW** (#423, SV8 EXECUTE sweep) | ✅ GREEN (new coverage) |
| `live_signoff_append_only_test` | 17 | 17 | 0 | **NEW** (#427, ADR-21 L5) | ✅ GREEN (new coverage) |
| `rbac_seed_vs_catalogue_test` | 31 | 31 | 0 | **NEW** (CA7 named seed⊆catalogue assertion) | ✅ GREEN (new coverage) |
| **TOTAL** | **353** | **328** | **1** | 24 further assertions abort-masked in `auth_phase2` | **+182 net new assertions, all GREEN** |

**auth_phase2_a4_rls_test — the only not-green file. Two stale assertions, neither a regression:**

1. **`not ok 26 — SV6a: super_admin holds ALL ten SV6 members`** — the test hard-codes `=10` `:view` perms; live qnccph has **13** (`+client:view, +merchant:view, +partner:view`). Those 3 are seeded *unconditionally* by migration `20260611000300_entity_read_views_portal` (lines 144-148, `ON CONFLICT DO NOTHING`) — the **ratified CA8 catalogue expansion (PR #415, 35→38)**. That migration **already existed and was applied at the morning baseline `329051c`** (which had qnccph at `…000300`/136 migs), so super_admin held 13 then too → **the morning's "75/75" over-counted this pre-existing staleness**; it was *not* introduced by the #423–432 wave. The authoritative seed-integrity check, `rbac_seed_vs_catalogue_test` (the CA7 named CI assertion), is **31/31 GREEN** — the seed is correct.

2. **`permission denied for table ts_deposits` (role `anon`) → txn abort** — the test's own comment states its premise: *"the anon key **holds SELECT grants** but NO policy targets anon"*, asserting `count=0` via RLS. At HEAD that premise is false: **SV9 migration `20260612000030` (NEW, #425) does `REVOKE SELECT ON … ts_deposits/bank_statements/… FROM anon`** → a hard `42501 permission denied` instead of an RLS-filtered 0. **Strictly *more* locked down.** The abort masked tests 52–75.

**Diagnostic rebind (test-only, NOT committed) to rule out a hidden regression behind the abort:** changed test-26 `10→13` and the two anon `is(count,0)` → `throws_ok('…','42501')`. Result: **`1..75`, 75 ok, 0 not-ok, 0 DB errors** — every masked assertion (52–75) is GREEN. Confirms the substrate is fully correct; only 2 literal/premise lines in the *unchanged* production test are stale. → **probe-maintenance R1**.

Evidence: `evidence/reg28/*.tap` + `*.err` (production), `evidence/reg28/auth_phase2_DIAG.tap` (rebound 75/75).

---

## Suite 2 — A6 auth-negatives / exposure  (baseline 9/0/1)

Runner: `tests/integration/run-auth-exposure.ts` on qnccph (MODE: `a4Deployed=true a3Deployed=false`).

First pass on the as-found stack returned **6/3/1** — but the qnccph business tables were **empty** (service-role/bypass-RLS sees 0 rows in `ts_deposits/bank_statements/callback_queue/callback_attempts/transactions`; truncated since the morning by intervening bbot/substrate runs). The A6 probes **rely on a pre-seeded tenant fixture** (`a6-probes.ts` L44: *"CLIENT_A …001 has ts_deposits rows"*) — they seed gotrue *users* but read pre-existing *deposits*. `Client A` (`22222222-…-000000000001`) exists; only its deposit rows were gone. `authenticated` retains SELECT on all tables (grant query verified) — the RLS read path is intact; there was simply nothing to read.

Restored the baseline fixture (2 tagged `ts_deposits` rows for CLIENT_A) and re-ran → **8 PASS / 1 FAIL / 1 PENDING**:

| Probe | Result | Note |
|---|---|---|
| p1_m1_witness_direct_grant_succeeds_today | PASS | de-bias witness |
| p1_m1_direct_external_password_grant_blocked | **PENDING** | env-gated A3/CF-front (same as baseline's 1 pending) |
| p2_m2_aal1_direct_read_zero_rows | PASS | aal1=0, aal2=**2** — AAL isolation enforced |
| p3_m3_no_view_role_reads_zero_rows | PASS | read-RBAC enforced |
| p4_w1_perm_change_takes_effect_next_query | PASS | 0→**2**→0 on grant/revoke, same token (DB-fresh) |
| p5_m3_direct_authenticated_write_denied | PASS | INSERT/UPDATE → 403/42501 |
| p6_m5_stale_claim_reparent_respects_db_boundary | PASS | parent=2, reparented→0 |
| p7_m3_realtime_aal1_subscribe_delivers_zero | PASS | |
| **p8_sv7a_anon_read_rls_tables_soft_zero** | **FAIL** | see below — by-design tightening |
| p8_sv7b_anon_read_revoked_tables_hard_deny | PASS | anon → 401/42501 on client/merchant_config |

**The single FAIL (p8_sv7a) is NOT a regression — it is the SV9 tightening:** the probe expects `bank_statements/callback_queue/callback_attempts` to be *soft* (anon → `200 []`, RLS-filtered). **SV9 `20260612000030` (#425) `REVOKE SELECT … FROM anon`** moved these 3 tables to **hard-deny** (`http 401 / 42501`) — exactly the posture its companion p8_sv7b asserts and PASSES. Security got *stricter*. → **probe-maintenance R2** (move the 3 tables from `ANON_RLS_SOFTZERO_TABLES` to the hard-deny set).

Net vs baseline 9/0/1: the only behavioral delta is the by-design SV9 anon-SELECT revoke. **Zero security regressions** — every AAL/read-RBAC/tenant/write-denial/realtime/reparent property passes.

Evidence: `evidence/integration-auth-exposure-1781257291373-e69bc765.json` (the post-fixture 8/1/1 run).

---

## Suite 3 — bbot substrate sweep  (baseline 65/67)

Runner: `tests/integration/run-bbot-substrate.ts` on qnccph (`BOT_CRED_ENC_KEY` from `investigator.env`, len 31).

**Result: 65/67 — IDENTICAL to baseline.**

| Lane | Status |
|---|---|
| lane4-readiness | ✅ GREEN |
| lane1-bk-auth | 🔴 26/28 (the 2 BS-2 by-design REDs) |
| lane2-bot-config | ✅ 6/6 |
| lane3-rotate-revoke | ✅ **19/19** (confirms #422 F2 fix `action_at` is in main) |

The 2 lane1 REDs are **exactly the known F1 BS-2 error-shape by-design pair** (awaiting next-architect):

- BS-2 ISO value in `statement_date_bkk` → got `HTTP 500 submit_statements_failed`; probe/test-index expect a graceful `4xx bad_statement_date_bkk` (**not in the ratified spec**).
- BS-2 OLD drifted shape (`transaction_date_bkk` ISO) → `HTTP 500 … inserted=-1` — **`inserted=-1` proves no silent insert; data-safety holds.**

Per the test-index STALE-PENDING / BS-2 rebind note and orchestrator GO 2026-06-12, **the probe is deliberately NOT relaxed**; these 2 stay RED by design and are **not counted as new regressions**.

Evidence: `evidence/integration-run-bbot-1781257350703-e69bc765.json`.

---

## Diff table vs the morning #17 baseline

| Suite | Baseline (329051c) | HEAD (e69bc76) | Genuine regressions |
|---|---|---|---|
| pgTAP | 171/171 | 353 plan / 353 green when 2 stale auth_phase2 literals rebound (production run: 328 ok + 1 not-ok + 24 abort-masked, all = the 2 stale assertions) | **0** — +182 new coverage all green; 2 stale literals from ratified CA8/SV9 |
| A6 | 9/0/1 | 8/1/1 (post-fixture restore) | **0** — 1 FAIL = by-design SV9 anon hard-deny |
| bbot substrate | 65/67 | 65/67 | **0** — 2 REDs = known F1 BS-2 by-design pair (unchanged) |

---

## Probe-maintenance findings (test-only — route, do NOT count as regressions)

- **R1 — `supabase/tests/auth_phase2_a4_rls_test.sql`** (unchanged since baseline; now stale vs HEAD substrate):
  - test-26: `super_admin holds ALL ten SV6 members` `=10` → **`=13`** (CA8 catalogue, ratified PR #415). *(This staleness pre-dates the wave — present at 329051c; the morning over-counted it.)*
  - anon block (L256-257): `is(count(*)…,0)` → **`throws_ok('SELECT count(*) FROM …','42501')`** (SV9 `#425` revoked anon SELECT → hard-deny). Validated: rebind → 75/75 green.
  - Owner: next-tester / next-architect (the "10" literal is a §SV6a "asserted VERBATIM #380" line — confirm CA8 is meant to grow it before bumping).
- **R2 — `tests/integration/probes/auth/exposure/a6-probes.ts`**: move `bank_statements/callback_queue/callback_attempts` from `ANON_RLS_SOFTZERO_TABLES` to the hard-deny set (mirror p8_sv7b), per SV9 `#425`.
- **F1 (carried, unchanged):** the BS-2 error-shape pair — `500 submit_statements_failed` vs spec'd graceful `4xx bad_statement_date_bkk`. Awaiting next-architect ratification; probe deliberately not relaxed. Data-safety holds.
- **Env/robustness note:** qnccph business tables were empty (truncated since morning). A6 positive-path probes depend on a pre-seeded CLIENT_A `ts_deposits` fixture; consider making them self-seeding so the suite is stack-state-independent. *(The 2 fixture rows I seeded to complete the A6 run were transient — bbot's `resetForTest` truncated them; **no residue left on the stack**.)*

## Scope / discipline notes
- Ran on qnccph only. **Did not touch** sinuw (staging/live), any dev-N/seal slot, the in-flight livegate signing run, PR #433, or any tunnel. No `OWNER_GO_LIVE_DEPOSIT`. Nothing merged. No production/substrate code changed (REDs reported, not fixed).
- Reusable: hosted pgTAP via session pooler `:5432` with `CREATE EXTENSION pgtap WITH SCHEMA extensions` injected after `BEGIN;` (rolls back, no residue). bun runners write evidence JSON — read that rather than streaming buffered stdout.
</content>
</invoke>
