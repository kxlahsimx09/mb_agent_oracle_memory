# next-tester — PAYOUT slice 5 (FINAL: admin correction toolkit) VERIFY findings — campaign payb5t

**Slice:** PAYOUT-012 `correction` (failed/review → success) + PAYOUT-013 `reverse_settle` (success → failed + per-partner MDR clawback) + the greenfield WALLET-008 `mdr_clawback_fanout`.
**SPEC (bound EXCLUSIVELY):** `git show origin/build/payout-slice5:docs/spec/payout-correction-toolkit-slice.md` (v1, 2026-06-13). De-bias: never read `supabase/` or the dev branch beyond the SPEC path. Reused merged slice-1..4 tester helpers (`_spec/_assert/_flow/_stage` payout + rc + cs + rr + `_authctx`) verbatim; added `_ct` siblings additively.
**Branch / PR:** `test/payb5-probes` off `origin/main` — ONE test-only PR, **DO NOT MERGE**.
**Stack:** tester slot `yupsevcrubgprsbujbpu` (yupsev).

## VERDICT — GREEN 54/54 on yupsev

Stack-ready signal received from the orchestrator (brew-ops GREEN both stacks, migration `20260613000010`). Push-button run:

| Lane | Status | Count |
|---|---|---|
| lane0-readiness | **GREEN** | 25/25 (+1 soft note) |
| lane1-ct-efgate | **GREEN** | 18/18 |
| lane2-correction (PAYOUT-012) | **GREEN** | 4/4 |
| lane3-reverse (PAYOUT-013) | **GREEN** | 3/3 |
| lane4-sm3 | **GREEN** | 4/4 |
| **total** | **GREEN** | **54/54, 0 RED** |

- Harness self-check (offline, network-free): **149/149** meta-assertions (+29 slice-5), each money/SM predicate GREEN-on-valid / RED-on-violated. Includes the five directive-mandated RED-on-violation gates: reverse-conservation-breaks→RED, partner-forced-negative→RED, correction-wrong-wallet-branch→RED, reverse_settle-from-non-success→RED, step-up-required→RED.
- Offline validation: bundle of the full runner graph (18 modules) clean; ephemeral `tsc --strict` type-clean across all new `_ct`/`p012`/`p013`/`ct-efgate`/`sm3-ct`/`readiness-ct`/runner files (one real type error caught + fixed pre-commit: `ct-efgate.ts` `.includes()` literal-union vs number).
- Evidence: `evidence/integration-run-payout-ct-1781338922737-2e65dce9.json` (git_sha 2e65dce9, status GREEN, 54/54).

### Money-load-bearing results (the heart of this slice)
- **Reverse-conservation (CB5, §2.3) — EXACT to the satang.** TWO independent witnesses agreed and matched the RPC return: `RPC(clawed 7.00 + shortfall 0 + residual 3.50 = fee 10.50) = true [Δ0 satang]`, `WCL-reconstruction = true`, `rpc==wcl = true`. The probe goes RED if conservation breaks by even one satang (moneyEq half-satang tolerance; self-check proves a 17.99-vs-18.00 break flips conserved=false, deltaSatang=−1).
- **Per-partner shortfall — never forced negative.** Drained victim partner: `decision=shortfall`, partner UNTOUCHED `bal 4.19→4.19`, one `mdr_unwind_shortfall` recording the FULL share, `shortfall_total=4.20>0`, whole txn COMMITTED (`status=failed`), CB5 STILL holds (RPC + WCL). Coverable partners fully clawed.
- **Correction — correct wallet branch per source (CT1.2).** failed→success: client `bal −gross, frozen UNCHANGED` (wcl +1 `payout_freeze` re-establish THEN +1 `payout_settle` → net re-debit); review→success: client `bal −gross AND frozen −gross` (wcl +0 freeze, +1 settle — settle-from-held-freeze). PW2 fan-out + residual + exactly-one `payout.success` + audit(`action_type=correction`,`source_state`) + `last_admin_action_*` denorm all present; AM5 held.
- **PV1-R inherited (§3.4 AC#3).** Over-allocated profile → RAISE `mdr_over_allocated`, whole correction rolled back, payout STAYS prior status, no settle/callback/audit. Bound to mark_success's STATED outcome — NOT requiring a mark_success change.
- **reverse_settle status flip:** `status→failed`, `failure_code` COLUMN **NULL** (§0/§8-D latent asymmetry), `failure_message` carries `reverse_settle:`; client re-credit `bal +gross, frozen UNCHANGED` (one `payout_reverse_settle`, WALLET-003 mirror); residual unwound (`mdr_clawback` note residual-unwind); one corrective `payout.failed` callback with own `event_id` + explicit `dedup_key`, payload `failureCode='admin_reverse_settle'`, prior `payout.success` left untouched (last-wins).
- **SM3 matrices:** correction illegal {pending/processing/success/cancelled} → all `not_correctable` benign no-op (incl. the success/auto-reconcile-race CT2 cell); reverse_settle illegal {pending/processing/review/failed/cancelled} → all `not_success` benign no-op.
- **EF gate + NOT-step-up (live):** both EFs — 405 (GET), 401 (no/forged/stub/aal1 bearer), 403 (aal2 lacking `payout:approve`), 400 (missing_payout_id / missing_reason). NOT-step-up: a valid super_admin aal2 bearer REACHED the handler (404 payout_not_found for a zero-uuid), **NO step-up challenge** — the path is not step-up-gated (§ADR-2 §S2). The RBAC seed (super_admin ⊇ payout:approve, dev reused the `admin-payout-reconcile` perm) was granted — no SEED-PENDING triggered.

## Probe → AC bijection

### PAYOUT-012 `correction` (SPEC §3.4) — lane2-correction
| AC | Probe | binds |
|---|---|---|
| AC#1 failed→success re-debit | `p012.correction_failed_to_success_re_debit_correct_branch` | client `bal −gross / froz UNCHANGED`, wcl +1 freeze +1 settle, PW2 inherited, 1 callback, audit+denorm, source_state=failed |
| AC#2 review→success settle-from-freeze | `p012.correction_review_to_success_settle_from_freeze_correct_branch` | client `bal −gross AND froz −gross`, wcl +0 freeze +1 settle, source_state=review |
| AC#3 success-leg inherits PW2 + PV1-R | `p012.correction_pv1r_over_allocated_rolls_back_stays_prior_no_callback` | RAISE mdr_over_allocated, whole rollback, stays prior, no settle/callback/audit |
| AC#4 SM3 illegal benign no-op (incl. success/CT2 race) | `sm3ct.correction_illegal_sources_benign_no_op` + `sm3ct.legal_map_correction_failed_review_only` | not_correctable, zero money/callback/audit |
| AC#5 AM5 every move | folded into AC#1/#2 (`am5Holds` on the client wallet) + §8-A | balance ≥ frozen, frozen ≥ 0 |
| AC#6 audit + denorm | folded into AC#1/#2 (`auditRowShape` + `lastAdminActionCols`) | resource_type=payout, action_type=correction, actor_type=admin |
| AC#7 corrective callback (CT3) | folded into AC#1/#2 (exactly-one payout.success; failed-source coexists w/ prior payout.failed) | same payout id, last-wins |
| §8-A failed-path insufficiency (SPEC-PENDING) | `p012.correction_failed_insufficiency_fail_closed_SPEC_PENDING_8A` | fail-closed: re-freeze RAISEs wallet CHECK, stays failed, no move/callback/audit |

### PAYOUT-013 `reverse_settle` (SPEC §4.5 + §2.3) — lane3-reverse
| AC | Probe | binds |
|---|---|---|
| AC#1 happy (all coverable) + CB5 conservation | `p013.reverse_happy_recredit_clawback_residual_conservation_callback` | re-credit (PW1), per-partner full clawback, residual unwind, CB5 (2 witnesses, Δ0 satang), one corrective callback, audit+denorm, AM5 |
| AC#2 SM3 success-only benign no-op | `sm3ct.reverse_settle_illegal_sources_benign_no_op` + `sm3ct.legal_map_reverse_settle_success_only` | not_success, zero money/callback/audit |
| AC#3 per-partner shortfall (audit-only) + conservation | `p013.reverse_shortfall_audit_only_never_forced_negative` | victim UNTOUCHED, full `mdr_unwind_shortfall`, never forced-negative, CB5 still holds, txn COMMITS (PW3) |
| AC#4 AM5 every move | folded into AC#1/#3 (`am5Holds` on client + partner) | balance ≥ frozen, frozen ≥ 0; a breaching clawback ⇒ shortfall |
| AC#5 audit + queryable shortfall | folded into AC#1/#3 (`auditRowShape` + shortfall rows queryable) | action_type=reverse_settle, metadata totals |
| AC#6 corrective callback (CT3) | folded into AC#1 (one payout.failed, own event_id + explicit dedup_key, failureCode=admin_reverse_settle) | same id, NOT suppressed by prior dedup |
| §6 bare-success caveat (teeth) | `p013.reverse_bare_success_no_fanout_zero_clawback_NOT_conservation_probe` | clawed=0/residual=0 from absent fan-out — proves the conservation witness REQUIRES a real settle |

### EF gate + NOT-step-up (SPEC §3.1/§4.1/§5) — lane1-ct-efgate (both EFs)
`ctef.{correct,reverse}_405_method_not_allowed` · `_401_no_bearer` · `_401_forged_alg_none` · `_401_legacy_stub` · `_401_aal1_pre_mfa` · `_403_lacks_payout_approve` · `_400_missing_payout_id` · `_400_missing_reason` · `_not_step_up_no_challenge` (the load-bearing NOT-step-up).

### Readiness (SPEC §6) — lane0-readiness
`readiness-ct.R1` tables (10) · `R2` both EFs respond · `R3` admin_correct_payout / admin_reverse_settle_payout / mdr_clawback_fanout present · `R4` mark_success present (write_audit_log soft, implied) · `R5` §ADR-20 clock · `R6` fixtures · `R7` super_admin actor.

## §contract-cross-check (§0/§8 cross-boundary lock — HELD)
- `mark_success` + the forward MDR fan-out + `match_payout_statement` are **REUSED VERBATIM** — brew-ops confirmed md5-UNCHANGED (seal held). The correction success leg `PERFORM mark_success` and reverse_settle reconstructs from its change-log rows. The probes bind to mark_success's STATED inherited outcomes (PW2 conservation + PV1-R fail-close + exactly-one payout.success) and the WALLET-003 forward mirror — **no probe requires a change to mark_success / the forward fan-out**. None surfaced as a contract question (the slice did not re-open any slice-1/bbot seal).

## SPEC-PENDING money-rule ambiguities (surfaced — none block; the conservation rule itself is FULLY PINNED)
The CB5 reverse-conservation rule (§2.3) is **fully pinned** by the ratified text (rounding→reverse-recorded, missing-partner→mdr_skip-in-residual, shortfall→PW3 full-or-audit-only) — verified GREEN, exact to the satang. The four §8 **secondary** edges are NON-BLOCKING; each is implemented with the conservation-/AM5-safe default and probed against it:

- **[§8-A] correction failed-path client insufficiency — PROMINENT.** Not pinned: what happens if the client SPENT the released funds after a false-FAILED. The build implemented **fail-closed** (the AM5 re-freeze RAISEs `wallet_balance_gte_frozen` → whole rollback → 500, payout stays failed, never force-negative) — VERIFIED live (RAISE = `new row for relation "wallet" violates check constraint`, walletIntact, no new rows). The probe binds to this fail-closed default. **ARCHITECT to confirm fail-closed vs an audit-shortfall on the client leg** — if the latter, the §8-A probe's expectation flips.
- **[§8-C] corrective-callback dedup on repeat-success — PROMINENT (closest money-adjacent gap).** `correction` INHERITS mark_success's STATIC dedup_key `payout:<id>:payout.success`, unique in the dominant single-correction case but would COLLIDE (UNIQUE violation → fail-safe rollback) if a payout reaches success a SECOND time via re-correction (success→reverse→correct→success). mark_success is sealed (slice-1). The correction-callback probe binds ONLY to the single-correction case; a **repeat-success correction is NOT probed** (it would require a mark_success touch — architect-gated). ARCHITECT to confirm whether the rare repeat-success correction needs a corrective dedup_key.
- **[§8-B] multi-generation reconstruction (re-correction loops).** CB3/CB5 written for a single forward distribution per `reference_id`; the build nets by `reference_id` (single-generation-exact + idempotent). Phase-1 probes exercise SINGLE-generation only; a multi-generation loop is NOT probed. ARCHITECT to confirm netting is the intended reconstruction.
- **[§8-D] reverse_settle failure_code taxonomy.** `ts_payouts_failure_code_check` has no reverse code; the COLUMN is set NULL and the CALLBACK payload carries `failureCode='admin_reverse_settle'` (same latent asymmetry as `bank_maintenance`) — VERIFIED live (column NULL, payload code present). ARCHITECT may add `admin_reverse_settle`/`reversed` to the CHECK + the failed-terminal whitelist (a shared-constraint change — OUT of this slice).

## §stack-needs (delta) — SATISFIED at run time
This was the PENDING-DEPLOY gate; brew-ops deployed it (migration `20260613000010`). What the suite required and the run confirmed present on yupsev:
- EFs: `admin-payout-correct`, `admin-payout-reverse-settle` (both 401-gate live, real gotrue).
- RPCs: `admin_correct_payout(uuid,uuid,text,text,text)`, `admin_reverse_settle_payout(uuid,uuid,text,text)`, `mdr_clawback_fanout(text,uuid,text)` (WALLET-008 greenfield), `mark_success(uuid,text)` (REUSED VERBATIM, md5-unchanged), `write_audit_log` (implied), §ADR-20 clock.
- Fixtures: enable_payout client + wallet, mdr_profile + ≥1 partner + partner wallet, the `mdr_owner` residual wallet, a super_admin app_user. RBAC grant super_admin ⊇ `payout:approve` present.
- Tester slot carries `GATEWAY_ASSERTION_SIGNING_KEY` + `KID` (scope=payout GW4 keypair) — needed to STAGE payouts via the create EF (the money logic itself is then exercised via DIRECT service-role RPC, no admin JWT — SPEC §6).

## Notes / gotchas
- **Money path = DIRECT service-role RPC** (SPEC §6 split): the 012/013 money correctness is asserted via `admin_correct_payout`/`admin_reverse_settle_payout` called directly with a seeded super_admin `app_user` id; the EF lane asserts the auth gate + NOT-step-up. The super_admin aal2 bearer REACHED the handler (proven by the NOT-step-up leg → 404 for a zero-uuid). **Non-gating follow-up:** an EF→RPC→200 happy correction smoke (super_admin bearer + a real staged failed payout) would add an end-to-end EF-money witness on top of the direct-RPC money proof — not built this pass (the money ACs are fully covered by the direct-RPC legs + the EF-gate reaching the handler).
- **Footprint:** the runner restores in `finally` — `cleanupPayout` per staged payout, `teardownCtBearers` (deletes the gotrue auth users; `app_user` rows are pre-seeded substrate, left intact per the slice-4 NO-SHIM re-mint rule), `clock_reset`. The §8-A / shortfall legs drain a client / partner wallet balance; these are healed by `reset_for_test` at the next run start + per-stage `fund()` re-funding (matches the slice-1/4 pattern — no per-run wallet-balance snapshot/restore).
- **Defensive bindings** (read defensively, surfaced never invented): `audit_log` column spellings (resource_type/action_type/metadata/resource_id/actor_*) — rebound to the deployed schema (verified slice-2), robust linkage = the echoed audit_id; `last_admin_action_*` denorm (match any /last_admin_action/ column); `callback_queue.event_id`/`dedup_key`; RBAC role→perm map + per-account IP allowlist (the EF money legs would surface a miss as super_admin→403 SEED-PENDING — did NOT trigger, the seed is granted).

## Run command
```
set -a; source .secrets/slots/tester.env; set +a
bun tests/integration/payout-selfcheck.ts      # 149/149 offline meta-assertions
bun tests/integration/run-payout-ct.ts          # 54/54 GREEN on yupsev → evidence/integration-run-payout-ct-<RUN_ID>.json
```
