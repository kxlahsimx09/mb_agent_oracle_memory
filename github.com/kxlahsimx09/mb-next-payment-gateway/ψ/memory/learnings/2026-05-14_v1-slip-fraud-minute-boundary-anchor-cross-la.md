---
title: 
tags: [v1-fraud, hash-composition, wall-clock-minute-boundary, cross-language-hash-parity, fixture-anchor]
created: 2026-05-14
source: next-impl session 2026-05-13/14 retro
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 


# V1 slip-fraud minute-boundary anchor — cross-language hash composition must share temporal reference

V1 fraud detection composes a sha256 hash for cross-deposit slip-reuse lookup:
`sha256(receiver_account || UPPER(source_bank) || cents_str || YYYYMMDDHHMM_BKK)`

The 4th field is **minute-granular** (YYYYMMDDHHMM). Two transactions that differ by one minute produce different hashes — by design, so cross-day collisions are structurally impossible.

## The bug surfaced 2026-05-13
PoC fixture pairs DEP-V1TWIN (auto-match QR) + DEP-SLIPV1 (slip upload). Hash collision is the load-bearing test: twin's bank_statement.match_hash should equal slipv1's slip-side match_hash.

- twin side (loader-generated mock_bank_feed): `transaction_date_bkk` set at bot-push time
- slipv1 side (fixture-loader compute): originally `new Date()` at the moment of slip POST

At SPEED=60x, twin and slipv1 deposits POSTed ~6 wall-sec apart (different poisson offsets). The two `new Date()` calls could land in DIFFERENT wall-clock minutes → different `YYYYMMDDHHMM` → hashes diverge → V1 lookup returns 0 → SLIPV1 paid via the retroactive sweep instead of rejected upfront.

## Symptom (hosted DB query)
```sql
SELECT request_id, status, failure_code FROM ts_deposits
  WHERE request_id LIKE 'DEP-V1TWIN-%' OR request_id LIKE 'DEP-SLIPV1-%';
-- DEP-V1TWIN-0001: paid (correct)
-- DEP-SLIPV1-0001: paid, failure_code='slip_invalid' (WRONG — should be rejected/slip_fraud_v1)
```
The `slip_invalid` failure_code was set by `check_retroactive_slip_fraud` post-finalize sweep — a different mechanism that just FLAGS the pair, not the auto-link-prevention V1 wanted.

## Fix
Anchor SLIPV1's slip-side hash to the twin's ACTUAL recorded `transaction_date_bkk`:
1. `fixture-gen` tags each SLIPV1 with `pair_request_id: 'DEP-V1TWIN-NNNN'`.
2. `fixture-loader` polls `bank_statements?matched_request_id=eq.<pair_request_id>` until twin's stmt is matched (up to 90s wall).
3. Reads the twin's `transaction_date_bkk` from DB and uses THAT timestamp in `computeMatchHash` instead of `new Date()`.

## Why this is production-realistic
A fraudster reusing a slip claims the original transfer's wall-clock minute on the slip metadata; the cascade compares against the bank's recorded statement minute. Both reference the SAME real-world transfer minute → hashes collide → V1 catches it.

`new Date()` at slip POST time was wrong because the test was generating slip metadata from FAKE timing; production has REAL slip metadata anchored to a REAL transfer.

## General principle
**Cross-language hash composition must share a temporal anchor that is meaningful in the domain.** Don't compute "now" on both sides and pray for collision — pin one side as authoritative source-of-truth and recompose on the other side using THAT reference.

## Related learning
Earlier durable: `2026-05-13_postgresql-numericnstext-preserves-scale` — PG `(amount*100)::text` preserves the column's scale → "30013.00" not "30013". Loader-side compute uses `.toFixed(2)` to match. Same class: cross-language string composition must mirror the server's serialization exactly.


---
*Added via Oracle Learn*
