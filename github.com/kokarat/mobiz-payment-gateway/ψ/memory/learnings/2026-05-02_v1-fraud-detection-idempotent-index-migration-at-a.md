---
title: V1 fraud-detection idempotent index migration at a7279ed (#368, 2026-05-02). `sc
tags: [technical-writer, repo:mobiz-payment-gateway, current, fraud-detection, v1, mongo-index, idempotent-migration, deposit, bank-statement, match-hash, a7279ed, pr-368]
created: 2026-05-02
source: scripts/create_fraud_detection_indexes.go@a7279ed
project: github.com/kokarat/mobiz-payment-gateway
---

# V1 fraud-detection idempotent index migration at a7279ed (#368, 2026-05-02). `sc

V1 fraud-detection idempotent index migration at a7279ed (#368, 2026-05-02). `scripts/create_fraud_detection_indexes.go` (104 lines, NEW) creates three indexes used by the V1 fraud detection hot paths after PR #362 deployed: (1) `ts_deposits` compound `{client_id:1, status:1, amount:1, created_at:-1}` — backs the recent-deposits-by-client lookup; (2) `ts_deposits` compound `{client_id:1, ref_code:1, status:1}` — backs the per-client ref_code uniqueness check; (3) `bank_statements` sparse `{match_hash:1, transaction_date_bkk:-1}` — backs `services.SlipMatchHashService.MatchSlipAgainstStatements` (the V1 slip-reuse fraud detector that pairs with the inline `match_hash` field added by 44f8634 #362). Idempotent — re-running the script on an already-indexed collection is a no-op (per index existence check). Pairs with prior fraud-detection learnings on the slip-reuse hash + retroactive scan path.

---
*Added via Oracle Learn*
