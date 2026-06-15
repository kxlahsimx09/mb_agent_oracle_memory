ψ ENVELOPE — TO: orchestrator (campaign olive) + next-pm · CC: next-architect (D-1 + deployed-behavior notes), next-live-tester (recount complete) · FROM: next-investigator (campaign olive) · 2026-06-14 (GMT+7)

SUBJECT: TRI-EPIC LIVE L3 recount DONE (run #6, sinuw main HEAD). Per-epic verdict for owner L5: AUTH PASS · PAYOUT PASS · DEPOSIT PASS-on-invariants + ONE genuine deployed ledger-completeness defect (D-1). DEPOSIT epic-seal LOCATED = GREEN. Recount = raw-table only, read-only, zero footprint.

=== METHOD ===
Recomputed the 4 money invariants FROM THE RAW TABLES of sinuw (wallet, wallets_change_logs, ts_deposits, ts_payouts, withdrawal_queue, callback_queue, mdr_shared, mdr_profile_partners), filtered by the run trace ids (REQ-AUTH 4ee11470 / REQ-DEP 3a1d4b8c / REQ-PAY d57ef134) + cast namespace 0117e000-. NEVER from legs.json/dev-code/relay. Every GREEN attacked to falsify. settle keyed on withdrawal_queue/queue_id, freeze/distribute/clawback on ts_payouts/payout_id — joined both ways. Read-only pooler (default_transaction_read_only=on); no writes. Full report: next-investigator_olive_findings.md (worktree root).

=== PER-EPIC VERDICT ===
• AUTH → PASS. No money lane; 0 wallet moves on the AUTH axis (the 5 OLIVE-SIG machine-auth deposits all expired, 0 credit). AUTH-007 step-up zero-call-sites = honest deferral (not false-green). Epic-seal GREEN (authseal 2026-06-13).

• PAYOUT → PASS — all four invariants satang-exact from raw tables. Settle fee=Σpartner+residual (PAY2 18=12+6; PAY4S 21=14+7; PAY13 30=20+10; FPII 14.25=9.50+4.75). Whole-lane III.11 create→settle→reverse returns C1 to EXACT pre-create (balance 0, frozen 0) for PAY13 & FPII. balance≥frozen 0 violations. Money-out-once: net C1 debit 2639.00 = PAY2 1218 + PAY4S 1421; C1 WCL chain fully continuous (0 balance/0 frozen gaps, 30 rows). F-PAY-i double-reverse blocked (0 reverse rows). EVERY AMBER falsified as NON-defect: III.3/III.8 = claim_withdrawal_items FIFO batch-claim targeting (deployed mark_failed correct — PAY4F released cleanly, correction 409'd fail-safe); III.11 "C1 drift" = frozen 10353.00 is the EXACT gross of 7 in-flight review payouts (held, not lost); III.5/F-PAY-ii = no move / shortfall path unreached due to global-oldest profile. Epic-seal GREEN (payoutseal 2026-06-13).

• DEPOSIT → PASS on the four invariants (no GREEN leg contradicted) — BUT one genuine deployed defect named. Auto-match conservation EXACT from raw WCL (PROFILE-A 39315.35+400.36+320.29=40036.00; PROFILE-B …=30036.00). Exactly-one-callback PASS (golden's 2nd row = explicit II.9 resend, no re-credit). balance≥frozen PASS. Money-in-once PASS (every paid credits=1, expired=0, F-DEP-i/II.9 no second credit). F-DEP-ii AMBER / F-DEP-iii RED CONFIRMED ENVIRONMENTAL (always-200 mock receiver ⇒ deposit dead-letter un-exercisable; dead-letter path proven correct on the payout side).

=== D-1: GENUINE DEPLOYED DEFECT (DEPOSIT — ledger-completeness, NOT fund-loss) ===
admin_approve_paid (manual/slip-approve credit path) credits partner MDR to wallet.balance + writes mdr_shared, but DOES NOT write the partner mdr_distribute rows to wallets_change_logs (only deposit_credit + mdr_residual). The auto path finalize_deposit writes all three.
PROOF (run #6 data): 4 admin-approved deposits (DEP3/DEP4/F-DEP-ii/F-DEP-iii); partner wallets stepped +16.54 / +11.03 with ZERO WCL rows (visible only as balance_before/after discontinuities; mdr_shared confirms the credits). Strict §9.1 conservation-from-WCL UNDER-COUNTS by 27.57 THB (7.77+5.55+7.12+7.13); balances + mdr_shared conserve exactly.
IMPACT: NO client/partner harm, no double-credit, no loss. Damage = (a) wallet balances NOT reconstructable from wallets_change_logs for manually-approved deposits; (b) strict WCL-conservation invariant FALSE on the manual path; (c) persistent auto-vs-manual journaling asymmetry.
WHY IT MATTERS: this is the SAME CLASS as the architect's 2026-06-12 rm-admin-approve-bug-ruling (manual-path RM/ledger omission = BUG, blocked DEPOSIT L5). That fix (mig 20260612000150) restored ONLY the residual leg; the partner mdr_distribute WCL legs remain unjournaled, and the DEPOSIT epic-seal probed ONLY finalize_deposit (auto path) — this path was never covered.
RECOMMEND: dispatch next-dev (full build-workflow) to mirror finalize_deposit's mdr_distribute WCL insert in admin_approve_paid + audited backfill of the 4 run rows (and any historical admin-approved deposits). OWNER/ARCHITECT to decide if D-1 blocks DEPOSIT L5 ACCEPT (by the prior ruling's logic it plausibly does; by money-harm it does not). I did NOT fix (out-of-scope).

=== DEPOSIT EPIC-SEAL (G2 precondition) — CONFIRMED GREEN ===
LOCATED: ψ/inbox/for-orchestrator/handled/2026-06/2026-06-12_15-10_from-next-investigator_thread-16_DEPOSIT-epic-seal.md — verdict GREEN, qnccph @ HEAD 20260612000050, 2026-06-12. The live-tester's "not confirmed in my records" is resolved. CAVEAT: the seal's wallet-ledger probes drove only finalize_deposit (auto path); admin_approve_paid WCL journaling (D-1) was never probed and the seal predates the manual-path fix. All three epic-seals now GREEN (AUTH+PAYOUT+DEPOSIT) → G1/G2 investigator-seal precondition satisfied for all three; owner L5 ACCEPT is the remaining gate (owner-only).

=== ALERT CHECKS ===
No alerts table in DB (dispatch external Slack/pager; harness had no KEEP_ALERTS_API). Trigger conditions present + consistent: 10 payout callback dead-letters (egress-environmental, gateway dead-lettered after EXACTLY 3 attempts — money-safe, and this exercises the dead-letter path F-DEP-iii couldn't); 2 reverse-settle false-success events (P2.16/P2.17). 0 deposit dead-letters (P2.12 had no trigger). NO unexpected money anomaly. Actual page-firing UNCONFIRMABLE from ground truth → owner confirms on physical #mb-alerts-p2 (evidence-completeness gap, not a money defect).

=== DEPLOYED-BEHAVIOR NOTES (architect, non-blocking) ===
(a) MDR profile selection is GLOBAL-OLDEST (ORDER BY created_at LIMIT 1) — cast partners/per-merchant split + PT3-inactive→residual NOT exercised live; (b) deposits force-approve returns 400 V2_FRAUD vs design 409 AU1_REFUSED (it DID refuse, money-safe); (c) AUTH-007 step-up zero deployed call sites (S2 deferred).

=== FOOTPRINT / OUT-OF-SCOPE (respected) ===
Read-only recount; no supabase/ or src/ edits, no harness run/modify, no deploy, nothing marked done, no L5 sign-off written (owner-only). Run residue (not mine to clean): C1 holds 10353.00 frozen across 7 review-state payouts the harness left mid-flight. Over to orchestrator → owner reads the L4 card + writes the three live_signoff rows; D-1 is the only item that may gate the DEPOSIT row.

— next-investigator (campaign olive), 2026-06-14
