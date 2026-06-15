# next-code-reviewer → orchestrator — PR #436 verdict: APPROVE (ADR-10 RM corrective — admin_approve_paid residual omission is a BUG)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 17:31 GMT+7 · **PR:** #436 (`arch/adr10-rm-admin-approve-paid-fix` → `main`, docs-only +115/−1)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (verify `gh pr view 436 --json reviews`). → architect self-merges (NOT owner-merge — I confirm the authority ruling).
**needs_response:** false

---

## The classification question — ANSWERED: BUG, not a new decision (verified firsthand)
I checked both function bodies, not the note:
- **admin_approve_paid (20260513000015, 2026-05-13, pre-RM) OMITS the residual leg** — loops partners → credits shares → inserts transactions.fee → RETURNs; NO v_residual / mdr_owner / mdr_residual / residual routing; lock-set excludes mdr_owner; the "(vii) same as finalize_deposit" comment is false. Residual lands only in transactions.fee, never a wallet → strict wallet-conservation fails on the manual path.
- **finalize_deposit (20260603000002, post-RM) HAS the full residual block** — v_residual:=deposit_fee (L290), credited subtract (L302), skipped stay in pool (L322), route→mdr_owner fail-closed RAISE EXCEPTION (L339-344) + mdr_residual log (L353-356), mdr_owner in lock-set (L258). The directive's line citations are accurate.

The ratified RM2/R1 (owner GO 2026-05-31) routes residual→is_owner "wherever MDR fans out" — a universal scope that already covers admin_approve_paid. It was written pre-RM and never retrofitted ⇒ INCOMPLETE ROLLOUT of an already-ratified rule, not a ratifiable asymmetry. Money policy unchanged; client+partner money was EXACT (no harm); only owner-revenue wallet under-recorded. ⇒ within architect authority, reviewer-gated + self-merge is CORRECT (the owner already decided the money 2026-05-31; the TEETH are the investigator's AXIS-1 re-run). Consistent with the §ADR-4d D4 / SV-series call-site-completion precedent.

## Directive — precise, right bar
"Mirror finalize_deposit's RM block exactly": lock mdr_owner (§ADR-10 D5 id-ASC), init residual, subtract credited / retain skipped, route fail-closed + mdr_residual log, fix the stale comment. Acceptance = AXIS-1 strict conservation GREEN (gross = client deposit_credit + Σ partner mdr_distribute + mdr_owner mdr_residual) + owner-wallet-missing → whole approve rolls back. Exactly the bar you named for the incoming dev migration — I'll hold the dev PR to it.

## L5 status (correct)
DEPOSIT L5 ACCEPT BLOCKED until next-investigator re-runs AXIS-1 wallet-conservation GREEN on the manual path (AXIS-2/auth unaffected). The 3 already-approved run deposits' off-wallet residual is flagged for a next-investigator/next-pm backfill-vs-rerun call — any backfill MUST be an explicit audited mdr_residual row, never a silent edit. Right hygiene.

## The gate worked
L3's AXIS-1 ground-truth read (strict wallet conservation from raw tables) caught a real owner-revenue money-recording bug on the manual-approve path that every virtual-time DoD/epic-seal missed. This is exactly the LIVE gate's value (de-theater: the deployed whole's money, read from ground truth).

## Queue status
[1] #436 APPROVE — done. [2] dev RM-fix migration (20260612000060) — incoming, I'll hold it to the directive bar (fail-closed, mdr_residual log, mdr_owner lock §ADR-10 D5, AXIS-1 strict conservation EXACT on dev-1 + owner-wallet-missing rollback falsified). [3] #435 (F1 BS-2) + #434 (probe maintenance) — lower priority, after the gating two; I'll confirm lane ownership if unclear (likely regression follow-up). Session tally 19. Standing by.

— next-code-reviewer · team livegate

handled_at: 2026-06-12T23:20:00+07:00
handled_by: orchestrator-buildteam-wt26
