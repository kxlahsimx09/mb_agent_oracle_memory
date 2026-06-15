# next-pm — PAYOUT slice-4 Step-4 MARK findings (campaign payb4pm)

> **Role:** Step-4 MARK (`next-pm`). Mark **PAYOUT-007** + **PAYOUT-009** as **slice-DoD-done** in
> `docs/requirements/epic-payout.md` using the established **in-slice-done-NOT-epic-done** green-dot
> pattern (the deposit-epic precedent, §ADR-21 §Amendment 2026-06-12 adr.md CE4; same pattern next-pm
> ran for payout slices 1/2/3). **Doc-only, off `origin/main`, NOT merged.** The payout **EPIC stays
> NOT-done** — per §ADR-21 **G2** epic-DONE owes BOTH a `next-investigator` **epic-seal** AND the §ADR-21
> **LIVE signoff**; neither has run. PAYOUT-012/013 are not built and are not marked (006 = deliberate
> cut; 011 = deferred Phase-2).
>
> **Status: ✅ MARKED.** All six evidence items independently verified at `origin/main` HEAD `46f4cb7`
> (`git fetch` first) before marking. Epic marks + revision-log entry done; one docs PR opened
> (DO NOT MERGE).

---

## 1. Evidence verified at HEAD `46f4cb7` (git fetch first — every item checked, not inherited)

| # | Item | Verdict @ HEAD |
|---|---|---|
| 1 | **PR #472 MERGED** (build) | ✅ `MERGED` 2026-06-13T06:42:04Z, merge `46f4cb7` (= HEAD), base `main` ← `build/payout-slice4`. Migration `20260612000260_payout009_reconcile_clock_grace.sql` present (renumbered 250→260 — header comment documents the rename; the colliding `…000250_adr10_rm_residual_backfill_run57bd31e7.sql` is a different lane, also on main). EF `supabase/functions/payout-resend-callback/index.ts` present. Migration body re-read: `sweep_payout_reconcile(interval, timestamptz DEFAULT NULL)` + `COALESCE(p_now, app_now())` + `_payout_auto_reconcile_enabled()` first stmt + `DROP FUNCTION IF EXISTS …(interval)` + `REVOKE … FROM PUBLIC, anon, authenticated` + `GRANT … TO service_role` + per-row `EXCEPTION WHEN OTHERS … CONTINUE`; `CREATE OR REPLACE VIEW v_success_payout_audit` with `app_now() - p.completed_at > cfg.grace_window`; header `NOT TOUCHED (cross-boundary lock, SPEC §4.2): match_payout_statement … mark_success … unchanged`. |
| 2 | **PR #473 MERGED** (probes) | ✅ `MERGED` 2026-06-13T06:42:00Z, merge `b134669`, base `main` ← `test/payb4-probes`. Probe modules present at HEAD: `tests/integration/probes/payout/{p007-resend,p009-reconcile,p009-audit,readiness-rr,_spec-rr,_assert-rr,_flow-rr,_stage-rr}.ts` + runner `tests/integration/run-payout-rr.ts` + `payout-selfcheck.ts` (selfcheck **120/120** = 78 carried + 42 new `rr_`). |
| 3 | **Tester VERIFY 51/51 GREEN, all 5 lanes** on `yupsev` | ✅ Evidence `evidence/integration-run-payout-rr-1781331132671-93c6b8d4.json` **committed at HEAD** (`git_sha 93c6b8d4`); `summary {total:51, passed:51, failed:0}`, `status GREEN`. Lanes: lane0-readiness GREEN · lane1-resend-efgate 5/5 · lane2-resend 7/7 · lane3-reconcile 7/7 · lane4-audit 7/7. First run had **3 probe-side fixture/transport REDs** (slice-3 pattern), all fixed + re-run GREEN, **zero substrate fixes** (`next-tester_payb4t_findings.md`, committed at HEAD). |
| 4 | **Investigator falsification 68/68 GREEN (+1 teeth-sentinel)** on `qnccph` | ✅ `next-investigator_payb4i_findings.md` (wt-c-payb4i) + ψ inbox verdict envelope `mb_agent_oracle_memory/ψ/inbox/for-orchestrator/2026-06-13_from-next-investigator_payb4_verdict-payout-slice4-falsification-GREEN.md` (read: "GREEN — slice-4 falsification PASS", 68/68 + 1 deliberate teeth-sentinel RED, 0 unexpected, one `BEGIN…ROLLBACK`, virtual clock both ways, tester 51/51 corroborated on a different stack, **not inherited**). |
| 5 | **Reviewer APPROVE ×2** (body-header verdict) | ✅ Both PR review comments read directly: #472 = "✅ APPROVE — next-code-reviewer (payb4r), 3-dimension"; #473 = "✅ APPROVE — next-code-reviewer (payb4r)". gh review state is `COMMENTED` on both (the self-approve-refusal house rule — the verdict lives in the body header). #472 explicitly confirms the **cross-boundary lock**: `git diff main...HEAD \| grep 'FUNCTION.*(match_payout_statement\|mark_success)'` → **NONE** (matcher + `mark_success` byte-untouched — bbot epic-seal + slice-1 settle lock intact). |
| 6 | **SPEC on main** | ✅ `docs/spec/payout-resend-reconcile-slice.md` present at HEAD (landed via #472). |

`HEAD == origin/main == 46f4cb7`; both PR merge commits confirmed in `origin/main` (`git branch -r --contains`).

---

## 2. What was marked (doc-only; no behavior change; INDEX.md untouched)

**`docs/requirements/epic-payout.md` (+19 lines, 4 green-dots):**
1. **`### Slice-4 build status (DoD)`** — new consolidated DoD evidence subsection (after the Slice-3 block,
   before the state-machine `---`), carrying the full evidence chain (#472/#473 MERGED · tester 51/51 ·
   investigator 68/68 · reviewer APPROVE ×2 · cross-boundary lock · renumber · carried observations).
2. **Payout state machine** green-dot — the now-LIVE **automated** statement-driven `review → success`
   SM2-SPLIT producer (distinct from slice-1's `mark_success` and slice-2's *admin* reconcile); SM3
   unchanged; audit detection-only; PAYOUT-007 resend = not a transition.
3. **PAYOUT-007** per-story green-dot — no new substrate (shared `resend_callback` RPC + race-guard
   already at HEAD; comment-only EF fix; verified-not-modified).
4. **PAYOUT-009** per-story green-dot — two §ADR-20 clock-drift closures + inherited money model +
   detection-only audit + cross-boundary lock.

**`docs/requirements/epic-payout-revision-log.md` (+13 lines):** one **2026-06-13 payb4 slice-4 entry**
(newest-first, above the slice-3 entry) recording: the in-slice-done-NOT-epic-done pattern + G2 not-done;
the evidence chain @ `46f4cb7`; the **two slice closures** (007 = no new substrate; 009 = two §ADR-20
clock-drift closures, same class as slices 2/3); the **cross-boundary lock held** (matcher + `mark_success`
reused verbatim, not redefined); the **migration renumber 250→260**; the **three carried non-blocking
observations** + one named SV8 routed non-blocker.

**Not touched:** no story trust label changed (all stay **S2 ratified**); `INDEX.md` untouched (INDEX is
the trust-label surface — build/DoD state lives in the epic, per the slice-1/2/3 + deposit precedent). The
prior slices' DoD blocks are point-in-time snapshots and were **not** rewritten (slice-3 still reads
"PAYOUT-007 / PAYOUT-009 … not built" — true as of that pass; the slice-4 block is the new state).

---

## 3. Slice-4 closures recorded (the two-line summary)

- **PAYOUT-007 = no new substrate.** AM5 terminal-only `{success,failed,cancelled}` + `{pending,dispatching}`
  in-flight race-guard (`already_in_flight`) + AM4 append-not-mutate (same `event_id`, distinct `:resend:`
  dedup, F2 actor triple) ride the **shared generic `resend_callback` RPC** (NOT a payout fork); the EF is
  the **sole AM6 tenant gate** (RPC has no tenant gate). All as-built at HEAD; only build touch = a
  **comment-only** EF header fix.
- **PAYOUT-009 = two §ADR-20 clock-drift closures** (same drift class as slices 2/3): `sweep_payout_reconcile`
  (wall-clock → `COALESCE(p_now, app_now())`, +SV8 grant, +flag-gate-first, −old 1-arg overload) and
  `v_success_payout_audit` grace (`now()` → `app_now() - completed_at > grace_window`). Reconcile-success
  delegates to the **inherited** `mark_success` (SM2-SPLIT/AM2/PW2/PV1-R); audit is **detection-only**.

**Cross-boundary lock held:** `match_payout_statement` + `mark_success` reused **verbatim, NOT modified**
(MATCH-003 bbot-seal + slice-1 lock byte-intact — reviewer-confirmed, investigator-confirmed last-defs
`…0520…0007` / `…0110` not redefined by `…0260`).

---

## 4. Carried non-blocking observations (none a slice-DoD blocker)

1. **Reviewer NB-472-1** — the sweep's `EXCEPTION WHEN OTHERS → CONTINUE` swallows per-row errors silently;
   a persistently-failing row is invisible. → future `RAISE WARNING`/skip-counter hardening (next-dev / slice owner).
2. **Grace-knob name divergence** — substrate `payout_audit_grace_window` (default `6 hours`) vs requirements-doc
   `payout_confirm_grace_minutes` (investigator: absent from DB). → spec-layer reconciliation (next-writer / next-architect).
3. **DRIFT-V** — read-side `v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` wall-clock residue; out
   of slice, deliberately not touched (a partial fix would split the view-clock hardening). → next-architect (carried from slice-3).
4. **SV8 latent exposure (already routed)** — 7 pre-SV8 reconcile/audit helpers not yet in the blanket
   execute-revoke batch; **this slice's new fn ships tight**; fold the rest into the next `execute_or_no_grants`
   batch. NB grant/revoke ≠ body-change → the matcher seal stays intact regardless. → next-architect.

---

## 5. DONE-WHEN

- [x] Epic marks (PAYOUT-007 + PAYOUT-009 slice-DoD-done; Slice-4 DoD evidence-block; state-machine marker; epic stays NOT-done per G2)
- [x] Revision-log entry (2026-06-13 payb4 slice-4)
- [x] ONE docs PR open off `origin/main` (DO NOT MERGE) — see PR link in the reply
- [x] Findings `next-pm_payb4pm_findings.md` (this file)
- [x] Reply to the orchestrator/owner

**OUT-OF-SCOPE (untouched):** epic-done; PAYOUT-012/013; merging; code. The payout **epic-seal** + **LIVE
signoff** remain owed before epic-DONE (§ADR-21 G2).
