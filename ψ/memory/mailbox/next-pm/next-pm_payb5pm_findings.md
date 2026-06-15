# next-pm — payb5pm findings — PAYOUT slice-5 (FINAL) Step-4 MARK

**Role:** `next-pm` (team `payb5pm`) · **Campaign:** `payb5pm` · **Date:** 2026-06-13
**Worktree:** `mb-next-payment-gateway.wt-c-payb5pm` · **Branch (mark):** `docs/payout-slice5-mark` (off `origin/main` `1af6c73`)
**Task:** Step-4 MARK PAYOUT-012 + PAYOUT-013 slice-DoD-done (in-slice-done-NOT-epic-done). Doc-only. DO NOT MERGE.

---

## VERDICT — ✅ SLICE-5 (FINAL) MARKED DoD-GREEN · EPIC STILL NOT-DONE (G2)

PAYOUT-012 (`correction`) + PAYOUT-013 (`reverse_settle`) marked **slice-DoD-done** in `docs/requirements/epic-payout.md` using the established green-dot **in-slice-done-NOT-epic-done** pattern. Slice-5 is the **FINAL** payout build slice — **all 11 buildable payout stories are now DoD-GREEN** (001/002/003/004/005/007/008/009/010/012/013; 006 cut, 011 deferred Phase-2). **The epic-seal + LIVE signoff are still owed (§ADR-21 G2)** — the epic is **NOT** done. The **epic-seal is the orchestrator's NEXT dispatch** (a separate `next-investigator` run) and is the only remaining gate before LIVE.

---

## Evidence verified at `origin/main` HEAD `1af6c73` (git fetch first, all 6 items GREEN)

| # | Item | Result |
|---|------|--------|
| 1 | **PR #477 MERGED** (`build/payout-slice5` → `main`, merge `875edc5`) | ✅ migration `20260613000010_payout012013_correction_reverse_settle` — **exactly 3 greenfield `SECURITY DEFINER` RPCs** `admin_correct_payout(uuid,uuid,text,text,text)` / `admin_reverse_settle_payout(uuid,uuid,text,text)` / `mdr_clawback_fanout(text,uuid,text)`, each `REVOKE ALL … FROM PUBLIC` + `GRANT EXECUTE … TO service_role` (proacl `{postgres, service_role}`); + 2 EFs `admin-payout-correct` / `admin-payout-reverse-settle` registered in `supabase/config.toml` (`verify_jwt = false`) |
| 2 | **PR #478 MERGED** (`test/payb5-probes` → `main`, merge `1af6c73`) | ✅ `_ct` probe modules (`p012-correction`/`ct-efgate`/`sm3-ct`/`readiness-ct` + `_spec-ct`/`_assert-ct`/`_flow-ct`/`_stage-ct`) + `run-payout-ct.ts` + additive `payout-selfcheck.ts` extension (**+29 `ct_` → 149/149**) |
| 3 | **Tester VERIFY 54/54 GREEN** | ✅ clean **FIRST-RUN, all 5 lanes, ZERO substrate fix** (first payout slice clean first-run) on `yupsev`; evidence `evidence/integration-run-payout-ct-1781338922737-2e65dce9.json` **committed at HEAD** (`status GREEN`, `git_sha 2e65dce9`; readiness 25/25 · ct-efgate 18/18 · correction 4/4 · reverse 3/3 · sm3 4/4); offline self-check 149/149. `next-tester_payb5t_findings.md` (also `wt-c-payb5t`) |
| 4 | **Investigator falsification 161/161 GREEN** | ✅ + 1 deliberate teeth-sentinel correctly RED, 0 unexpected, on `qnccph`, one `BEGIN…ROLLBACK`; **CB5 reverse-conservation `Σclawback + Σshortfall + residual_unwound = payout_fee` recomputed to the satang from raw `wallets_change_logs`** under 3 fixtures (incl. per-partner shortfall + odd-amount 333.33/fee 7.77). `wt-c-payb5i/next-investigator_payb5i_findings.md` + ψ inbox envelope |
| 5 | **Reviewer APPROVE ×2** (body-header; gh COMMENTED per self-approve refusal) | ✅ #477 (build — **CRITICAL cross-boundary seal HELD = the one blocking gate**) · #478 (probes, TEST-ONLY) |
| 6 | **SPEC on main** | ✅ `docs/spec/payout-correction-toolkit-slice.md` v1 (2026-06-13) landed via #477 |

**Cross-boundary seal (independently confirmed from the #477 diff):** the build diff carries **only** the 3 greenfield `CREATE OR REPLACE FUNCTION` + grants — **no `mark_success` / `match_payout_statement` / forward-fan-out redefinition, no `DROP`/`ALTER FUNCTION`, no view re-create**. The correction success leg `PERFORM mark_success(...)` reuses the sealed function VERBATIM (`mark_success` `md5 55561e5aaccb2aa42582a47a5e65a3ff`); `match_payout_statement` (`md5 966267eed668e235146ae9ca7def6d32`) byte-unchanged.

---

## What was changed (doc-only, off `origin/main`)

**`docs/requirements/epic-payout.md`:**
1. New `### Slice-5 build status (DoD) — the FINAL payout slice` subsection (under "Story shape at a glance") — full evidence chain + GREENFIELD note + WALLET-008 note + cross-boundary-seal note + 11/11 statement + the routed non-blocking notes pointer.
2. Slice-5 marker on the **Payout state machine (canonical)** subsection (the now-live `correction` `failed`/`review → success` + `reverse_settle` `success → failed` transitions; SM3 legal-source discipline; seal held).
3. Per-story 🟢 green-dot markers on **PAYOUT-012** and **PAYOUT-013**.

**`docs/requirements/epic-payout-revision-log.md`:**
4. New top entry (2026-06-13 payb5 Step-4 MARK) recording: GREENFIELD (no predating substrate); WALLET-008 `mdr_clawback_fanout` built here (Phase-1 `payout_reverse` trigger only — `topup_cancel`/`deposit_refund` are other epics'); cross-boundary lock held (md5-unchanged); NOT-step-up (§ADR-2 S2 carve-out, current-parity); **3-term netting positive divergence** (`Σ distribute − Σ clawback − Σ unwind_shortfall`, stricter than 2-term SPEC — reviewer recommends architect ratify); §8-C repeat-success dedup collision = fail-safe-rollback (not corruption, and makes the multi-gen divergence unreachable); RBAC `payout:approve`-reuse-vs-finer-perms; the four §6 secondary edges (§8-A/B/C/D, all REAL + non-blocking).

**Not touched:** `INDEX.md` (trust-label surface — build/DoD state lives in the epic, per the slice-1..4 + deposit precedent); no story trust label changed (all stay S2 ratified); no code, no migrations, no merges.

---

## Scope / boundaries respected

- **OUT-OF-SCOPE (untouched):** epic-done (epic-seal + LIVE owed); merging; code; the epic-seal itself (orchestrator dispatches `next-investigator` separately).
- **Slice-4 (PAYOUT-007/009)** is DoD-GREEN (PRs #472/#473 merged, tester 51/51, investigator GREEN) but its Step-4 MARK is a **separate parallel-open PR** off `origin/main` (not yet merged into main at `1af6c73`). My slice-5 PR adds **only** slice-5 marks; the two parallel marking PRs reconcile at owner-merge (same parallel-open pattern as slice-1 `#448`). The 11/11 statement is true on the build/verify state; the doc-marks land via slice-4's PR + this one.

---

## Hand-back

- **11/11 payout stories DoD-GREEN.** The **payout epic-seal** (a `next-investigator` epic-level run) + the §ADR-21 **LIVE signoff** are the **only remaining gates before LIVE**. The epic-seal is the orchestrator's NEXT dispatch right after this mark.
- ONE docs PR open off `origin/main` (DO NOT MERGE).
