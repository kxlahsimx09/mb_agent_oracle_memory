---
title: EPIC-SEAL (DEPOSIT-003 + DEPOSIT-004 "dep34" cluster) — SEALED by independent re
tags: [epic-seal, deposit-003, deposit-004, investigator, evidence-only, raw-table-rederivation, callback-queue-teardown-trap, money-invariants]
created: 2026-06-03
source: next-investigator dep34seal
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC-SEAL (DEPOSIT-003 + DEPOSIT-004 "dep34" cluster) — SEALED by independent re

EPIC-SEAL (DEPOSIT-003 + DEPOSIT-004 "dep34" cluster) — SEALED by independent re-derivation.

next-investigator sealed the dep34 cluster on an ISOLATED seal stack (Supabase ref qnccphgykzdydebmdwdf), NOT the tester stack. Verdict: SEALED. 26 in-slice assertions (DEPOSIT-003=10, DEPOSIT-004=16) reproduced 27/27 on the seal stack, and every load-bearing money/state invariant was re-derived directly from raw ground-truth tables (PostgREST service-role reads), never trusting a harness boolean.

KEY INVESTIGATOR LESSON (trust trap): the dep34 probes each restDelete their callback_queue rows in a `finally` block (and most delete the deposit row too). So you CANNOT re-derive "exactly one callback" from raw tables AFTER the suite finishes — the rows are already gone (callback_queue held only 2 stray rows post-run). The correct evidence-only move is to DRIVE the money/state flows yourself with transport-only helpers and NO teardown, reading callback_queue / wallets_change_logs / slip_verify_attempts in-flight. A purely post-hoc raw read would have wrongly looked like "0 callbacks emitted".

Raw-table confirmations (my own driven flows): admin reject → status=rejected (NOT failed), failure_code=admin_rejected, wallets_change_logs=[] (0 credit/0 MDR), wallet delta 0, exactly ONE deposit.rejected callback. Slip-less expire → exactly ONE deposit.expired, single terminal, sweep re-run is idempotent (no dup). DA1: slip-bearing pending excluded from expiry (sweep skips, expire_deposit()='race_lost') and instead escalates to checking. No-verdict (thunder_sim_outcome=thunder_system_error) → stays checking, append-only slip_verify_attempts. Late-finalize race-guard → no credit/no MDR (status stays pending). Idempotency 400/replay/409, tenant-scope 403, audit triple (customer/client/admin) all confirmed. FIX-A (migration 20260604000001) resolved upload_slip to a single signature: every slip upload returned 202/200, zero 500s/PGRST203.

D4-11 (clean approve→paid) is a CORRECT out-of-slice deferral (owner 2026-06-04; V2 fraud-gate/DEPOSIT-007), recorded as N/A — not counted as a gap. V1 bijection: 18 probes = 18 AC clauses, pos+neg, fail-closed. tags: epic-seal

---
*Added via Oracle Learn*
