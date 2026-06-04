---
title: Payout-fix epic-writer pass (DEC-A..E, user GO 2026-06-04; PR #325 `writer/payfi
tags: [payout, requirements, state-machine, mdr, step-up, writer-discipline]
created: 2026-06-04
source: next-writer (payfix-epic)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Payout-fix epic-writer pass (DEC-A..E, user GO 2026-06-04; PR #325 `writer/payfi

Payout-fix epic-writer pass (DEC-A..E, user GO 2026-06-04; PR #325 `writer/payfix-epic` vs main, doc-only, NOT merged; ADR amendments pending on `arch/payfix-adr` PR #323).

THREE DISTINCT review-adjacent payout surfaces — do NOT conflate (this was the central numbering/meaning trap):
- PAYOUT-011 = DEFERRED Phase-2 *auto* `review → failed` (statement-driven, positive-reversal-signal only; absence never auto-fails). Lives in INDEX.md "Deferred Payout Surfaces" + revision-log ONLY — no story body in epic-payout.md. LEAVE UNTOUCHED.
- PAYOUT-012 = RATIFIED *admin* `correction` (`failed`/`review → success`); the dominant CS op (ConfirmPayoutCompleted 1,300×). Remedy for §ADR-15 P2.17 false-FAILED.
- PAYOUT-013 = RATIFIED *admin* `reverse_settle` (`success → failed`); false-success clawback (OverridePayoutStatus 239×). Remedy for §ADR-15 P2.16 false-success.
New stories took 012/013 (PAYOUT-006 gap stays the deliberate cut; 011 not reused).

LOAD-BEARING meaning-locks:
- DEC-A step-up carve-out: NO payout admin action is step-up-gated (current-parity — current `VerifyTOTPStepUp` covers deposit_refund/deposit_refund_resolve ONLY). Had to REMOVE 'admin payout overrides/confirm-completed/cancels' from AUTH-007's step-up-gated set in epic-auth-rbac.md, not just add notes on payout stories. Cite §ADR-2 §S2 carve-out 2026-06-04.
- DEC-D late-report SPLIT: mark_success ACCEPTS a late bot `success` from review (truthful, just slow); mark_failed is `processing`-ONLY — `review → failed` is admin/statement only, NEVER a late bot's word (releasing a freeze on an unverified late bot report is the dangerous direction). Drop `claimed` → `processing`; unify terminal on `success` not `completed`; no `rejected` terminal.
- DEC-E PAYOUT-013 MDR unwind = per-partner ALL-OR-NOTHING: full claw-back IFF the partner wallet covers the full share, else deduct NOTHING + audit the FULL unrecovered share (mdr_unwind_shortfall). Never partial, never forced-negative (CHECK(balance>=frozen)). Whole reverse_settle still COMMITS on a partner shortfall — it's an auditable receivable, not a blocker. Client re-credit (balance +=, no re-freeze) is always invariant-safe; only the partner claw-back direction can go negative, which is why only it is gated. is_owner residual leg self-covers. Residual-MDR (is_owner) extended to ALL payout success fan-outs (PAYOUT-002/009/012), symmetric to the inflow RM rule (§ADR-10 §Amendment 2026-06-04 PW2).
- DEC-C: corrective callbacks may flip a prior terminal on the same id (§ADR-9 §Reconciliation 2026-06-04) — client tolerates same-id terminal flip.

Writer discipline that worked: re-verify anchor text at HEAD (spec line numbers had drifted ~660 vs 661); cite the exact §Amendment in every Sources block touched + mark ADR as pending PR #323; name untestable thresholds as config knobs and assert the BOUNDARY relative to the knob (payout_stuck_review_minutes, payout_confirm_grace_minutes, fee-row-or-zero tolerance, payout_metadata_max_keys/_bytes) rather than magic numbers; pin ONE canonical field name (bank_transaction_id) when prose varied. P2.16/P2.17 are self-suppressing siblings (FF3).

---
*Added via Oracle Learn*
