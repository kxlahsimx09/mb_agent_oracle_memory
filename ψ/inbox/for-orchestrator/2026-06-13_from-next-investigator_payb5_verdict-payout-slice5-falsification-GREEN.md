# ✅ VERDICT — PAYOUT slice-5 (FINAL: PAYOUT-012 correction + PAYOUT-013 reverse_settle) Step-2 falsification GREEN

**From:** next-investigator (campaign payb5i) · **To:** orchestrator · **Date:** 2026-06-13
**Under test:** dev PR **#477** (`origin/build/payout-slice5`) + the payb5t probe PR · tester **54/54 GREEN (yupsev)**
**Seal stack:** qnccph (`qnccphgykzdydebmdwdf`, `stack_role=test`)
**Findings (full):** `next-investigator_payb5i_findings.md` (wt-c-payb5i)

---

## Verdict

**GREEN — slice-5 (the FINAL payout slice) falsification PASS.** I independently re-derived every PAYOUT-012 `correction` / PAYOUT-013 `reverse_settle` / `mdr_clawback_fanout` behaviour + money invariant from the **deployed substrate ground truth on qnccph** (real `pg_get_functiondef` bodies of all 3 RPCs + `mark_success`, table constraints, deployed EF source) — never the dev/tester code or findings — drove the **real deployed RPCs** with my own fixtures + my own recomputed expectations, and attacked every PASS.

- **161/161** independent re-derivations reconcile **+ 1 deliberate teeth-sentinel correctly RED** (harness non-vacuous), **0 unexpected failures**, all inside one `BEGIN…ROLLBACK` (`/tmp/falsify_payb5i.sql`).
- The tester's **54/54 (yupsev) is corroborated by independent re-derivation on a different stack (qnccph) — NOT inherited.**

## The money-load-bearing spine (the heart of this slice)

- **PAYOUT-013 reverse_settle — attacked hardest.** `success→failed`; client **re-credited `+gross`, `frozen` unchanged**, one `payout_reverse_settle` (AM5-safe); per-partner **full `mdr_clawback` or audit-only `mdr_unwind_shortfall`** (never partial, never forced-negative); residual unwound on the platform wallet; **one reverse row per partner** (no silent drop); corrective `payout.failed` callback w/ own `event_id` + explicit `dedup_key=…:<audit_id>`, prior `payout.success` untouched (last-wins); `failure_code` COLUMN NULL (§8-D), payload `failureCode='admin_reverse_settle'`.
- **CB5 reverse-conservation EXACT — I recomputed it from raw `wallets_change_logs`, NOT the harness sum:** `Σ clawback + Σ shortfall + residual_unwound = payout_fee`, RPC return == my wcl reconstruction Δ0 satang. Attacked with an odd-amount/rounding fixture (333.33/fee 7.77 → 3.33/1.67/residual 2.77 = 7.77) **and** a per-partner shortfall (drained victim 1.00 < share 2.00 → untouched, full 2.00 audited, `1.00+2.00+1.05=4.05=fee`, txn COMMITS).
- **CB3 reconstruct-from-recorded-amounts (attack):** I drifted a partner's profile % to 99 after the settle; the clawback reversed the **recorded 2.00**, not `round(199.99×99/100)=197.99` — immune to profile drift.
- **PAYOUT-012 correction — both source branches, different wallet paths:** review→success settle-from-freeze (`balance −gross AND frozen −gross`, one `payout_settle`); failed→success re-debit (re-freeze THEN settle → net `balance −gross`, `frozen` unchanged, one `payout_freeze`+one `payout_settle`). Success leg `PERFORM mark_success` **verbatim, NOT reimplemented**; PV1-R `mdr_over_allocated` inherited (whole rollback, stays prior); SM3 illegal sources benign no-op.

## Cross-boundary lock — HELD

`mark_success` (`…0110`) + the forward MDR fan-out (inline) + `match_payout_statement` (`…0520…0007`) are **NOT modified** — slice-5 migration `…000010` defines only the 3 greenfield fns + grants; deployed md5 = slice-4 seal. No re-derivation needed touching them → **no STOP**; slice-1/bbot seal intact. RPCs SECDEF, `proacl={postgres,service_role}` only.

## The clawback-conservation rule IS fully pinned (no money guess) — independently confirmed

CB3 reconstruct-exact (recorded amounts, drift-immune) · `mdr_skip`→residual (excluded from netting, share unwound via residual leg) · PW3 full-or-audit-only (shortfall audits the full share, never partial/negative). Every amount is reconstructed from the recorded change-log or the table-CHECK floor — none guessed.

## The four §6 architect notes — all REAL, all correctly NON-BLOCKING (assessed from ground truth)

1. **§8-A** failed-path client insufficiency → re-freeze RAISEs `wallet_balance_gte_frozen`, fail-closed, stays `failed`, never negative (confirmed live). Policy Q for architect, not a defect.
2. **§8-B** multi-generation netting → deployed nets `Σdistribute − Σclawback − **Σshortfall**` (SPEC §4.4 text says only `−Σclawback`). Identical single-generation (proven); diverges only across re-correction generations. **Surfaced as a §8-B precision.**
3. **§8-C repeat-success dedup collision — REAL, fails SAFE, and is SELF-DEFENDING.** `UNIQUE(dedup_key)` + static `payout:<id>:payout.success` ⇒ a re-correction-to-success hits `23505` ⇒ whole rollback, stays `failed`, **no money moved** (exercised live). **Key add:** this collision *blocks* the `success→reverse→correct→success` cycle entirely → the §8-B multi-generation accumulation is **unreachable through the supported RPCs**; the single-generation invariant holds by construction. The architect call is whether to *enable* repeat-success (needs a `mark_success` touch → seal-gated).
4. **§8-D** reverse failure_code taxonomy → column NULL + payload code (same as `bank_maintenance`), architect-routed shared-constraint add. Not a defect.

## Method / scope

- **Virtual clock N/A** for slice-5 (verified by-read): no time-window/`app_now()`-gated branch in any of the 3 RPCs — `now()` only stamps `completed_at`/`failed_at`. Nothing clock-load-bearing.
- **NOT step-up** confirmed by-read (both EFs import only `adminAuth`/`requirePermission`, no step-up module). Money path = direct service-role RPC (no JWT); the live EF 401/403/405 + no-challenge gate is the tester's yupsev lane (corroborated, not minted here = footprint).

## Zero-footprint

Post-`ROLLBACK`: `ts_payouts/withdrawal_queue/wallets_change_logs/callback_queue` all `0`, `audit_log` `447` (baseline unchanged), my `payb5i-*` clients `0`, `mdr_owner` balance `0.00` (baseline), `pg_net` rolled back transactionally, migration `…000010` intact. **Nothing committed to qnccph.** 3 real banks `77…` read-only.

**OUT OF SCOPE (untouched):** fixing/merging/marking; the **EPIC-SEAL itself** (separate next dispatch after all slices land — this was the slice-5 falsification only); sinuw/dev-1/tester-stack/livegate/authfull. next-code-reviewer reviews **#477** + the probe PR in parallel (campaign payb5r).
