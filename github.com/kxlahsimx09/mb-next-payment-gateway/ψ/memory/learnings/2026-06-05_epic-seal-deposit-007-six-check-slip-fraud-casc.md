---
title: EPIC-SEAL — DEPOSIT-007 (six-check slip-fraud cascade at admin-approve): SEALED 
tags: [epic-seal, DEPOSIT-007, slip-fraud-cascade, audit-integrity, atomicity, anti-bias-verification]
created: 2026-06-05
source: next-investigator dep7seal epic-seal
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC-SEAL — DEPOSIT-007 (six-check slip-fraud cascade at admin-approve): SEALED 

EPIC-SEAL — DEPOSIT-007 (six-check slip-fraud cascade at admin-approve): SEALED 🟢 (with one non-blocking finding).

Independent raw re-derivation on seal stack qnccphgykzdydebmdwdf (slot investigator.env, migration 20260605000010 deployed). Drove all scenarios via SPEC-bound transport only; re-computed EVERY verdict from raw ground-truth tables (ts_deposits/audit_log/wallet/wallets_change_logs/mdr_shared/transactions/callback_queue/bank_statements). Trusted NO harness boolean. Result: 24 DERIVED-PASS, 2 RECORD, 0 real FAIL; tester harness also 47/47 GREEN on my stack.

All 6 load-bearing claims CONFIRMED off raw tables:
1) Each of V2/V1.3/V1.4/V3/V1.5/V1 BLOCKs on hit (4xx + correct <prefix>_FRAUD + status=checking + zero wcl/mdr/txn/cb) and PASSes on null/absent (→paid); V2 fails CLOSED (V2_PARTIAL_DATA).
2) Cascade short-circuits at first BLOCK (V3+V1.5 both trip → only V3 named/audited/cross-linked).
3) [force-approve] is two-gated on user_type=='admin': non-admin marker → still BLOCK (EF 403 / RPC actor=client 4xx), 0 override rows, 0 wallet move; admin marker → exactly ONE canonical override audit row of the correct kind (actor_type=admin).
4) 7-FK cross-link invariant: exactly ONE cascade FK non-null on force-approve, ALL null on clean approve.
5) D4-11 CLOSURE (DEPOSIT-004's deferred clean admin-approve→paid): all-6-pass → paid, wallet credited net (Δ==final_amount), MDR fanned out (mdr_shared), exactly one deposit.paid (forceApproved=false), one transactions row net-correct.
6) All-or-nothing finalize rollback: REAL mid-finalize fault (numeric(18,2) overflow at the wallet UPDATE, which runs AFTER the status='paid' write) → status rolled back to checking, 0 wcl/mdr/txn/cb. admin_approve_paid is a single plpgsql fn with no savepoints/EXCEPTION blocks → atomic by construction AND now empirically exercised.

V1 bijection: 25 ACs ↔ 25 probes ↔ 25 fns. New delta (fraud-preview≡enforcement AC#23/24/25 + V2 mask comparator AC#12) re-derived PASS: computed-column==RPC preview, would_block⇒enforcement blocks same check, masked receiver (same last-4) no false-block.

FINDING F-1 (NON-BLOCKING): a CLEAN approve whose notes contain [force-approve] (admin JWT) writes an approve audit row with the marker in `reason` AND all 7 cross-link FKs NULL — the literal §4/AC#45 "substrate-integrity defect" shape (substrate does not strip the marker on clean approves; OVERRIDE branch is gated `IF v_fraud_check IS NOT NULL AND v_force`). Ruled non-blocking because: (a) global stack sweep → every approve carrying a REAL override (metadata.fraud_override!=null) IS cross-linked; ZERO silent-override holes — the actual security property AC#45 protects holds with no exception; (b) the row is self-distinguishing via metadata.force_approved=true + fraud_override=null, so the credit is correctly traceable as a clean approve (no untraceable credit); (c) already disclosed by tester (probe ac18 RECORDs it). Follow-on hardening: strip the marker on clean approves OR key the hosted-assertion on metadata.fraud_override!=null⇒≥1 FK, not on reason-text.

HARNESS SOFT-SPOTS flagged (substrate fine, probes under-exercise): AC#21's bogus-mdr_profile_id "fault" does NOT fault (empty partner loop, no FK error) so the probe's rollback path is a no-op always-pass — recommend a real fault seam (wallet-ceiling overflow). AC#18 always-passes the §4 literal-defect surface as a RECORD.

DURABLE RULES: (1) "no silent override of a real BLOCK" is the load-bearing audit invariant; assert it on metadata.fraud_override, not on free-text notes, to avoid false-flagging benign marker-on-clean rows. (2) A finalize fault seam must dereference a real constraint — a bogus FK that only yields an empty join row does NOT exercise rollback; numeric(18,2) ceiling overflow at the post-status-write wallet UPDATE is a reliable mid-finalize fault for atomic-boundary tests. (3) When reading 16+ integer-digit numeric over PostgREST/JSON in JS, the value exceeds Number.MAX_SAFE_INTEGER and float64-mangles — read as string for precision-critical assertions.

---
*Added via Oracle Learn*
