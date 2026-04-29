---
title: Two perf indexes landed 2026-04-24 on existing query shapes that were falling ba
tags: [technical-writer, repo:mobiz-payment-gateway, current, index, perf, ts_deposits, bank-statements]
created: 2026-04-24
source: db/indexes.go:94-108@b2b5201, db/indexes.go:322-327@97a8038
project: github.com/kokarat/mobiz-payment-gateway
---

# Two perf indexes landed 2026-04-24 on existing query shapes that were falling ba

Two perf indexes landed 2026-04-24 on existing query shapes that were falling back to FETCH-heavy scans. (1) `ts_deposits` gained `{client_id:1, created_date_bkk:-1}` + sparse `{ref_code:1}` (`b2b5201` #300) — the prior `{client_id:1, created_at:-1}` didn't cover the `created_date_bkk` filter field (different field), forcing the planner onto the broader `{created_date_bkk:-1}` without the client scope when a client integrator batch-checked ref_code existence; sparse `{ref_code:1}` backs the anchored `^ref_code` branch of the shape-routed deposit search (PR #285). (2) `bank_statements` gained `{transaction_date_bkk:-1, amount:1}` (`97a8038` #301) — CS's "find a signed-amount transaction in a date window" query (`$or:[{amount:X},{amount:-X}]` + date range) was FETCHing every date-matched doc to evaluate the amount predicate because the planner picked `{transaction_date_bkk,direction}`; the new compound lets it run off the index. Both commits are index-only, no code changes.

---
*Added via Oracle Learn*
