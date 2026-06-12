---
title: BBOT ingestion-contract DRIFT (BLOCKS golden journey): gateway statements substr
tags: [brew-ops, repo:cross, drift, bank-bot, ingestion-contract, gotcha, staging]
created: 2026-06-11
source: thread #13 E2E smoke; staging RPC prosrc; bbot-adapter-endpoints-slice.md BS-2; CloudWatch /ecs/mb-next-bankbot
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# BBOT ingestion-contract DRIFT (BLOCKS golden journey): gateway statements substr

BBOT ingestion-contract DRIFT (BLOCKS golden journey): gateway statements substrate implements timestamptz for *_date_bkk while the ratified endpoints-slice contract (BS-2) says minute-level YYYYMMDDHHMM int64. Found live on staging (sinuwgsqqyqzlpaavimf) during the first real Fargate-bot E2E smoke, 2026-06-11.

Evidence chain:
1. Bot (per spec BS-2, banks/scb/statement.js:283) pushes transaction_date_bkk=202606111627 (int).
2. EF bot-statements → RPC submit_statements_batch does `(v_tx->>'transaction_date_bkk')::timestamptz` → `ERROR: date/time field value out of range: "202606111627"` (repro: `select '202606111627'::timestamptz`) → EF 500 `submit_statements_failed`. Bot logs "[Loop] Statement tick failed".
3. Second-order break in the OTHER direction: get_last_statement_dates returns max(transaction_date_bkk) as timestamptz → JSON ISO string. Bot compares numeric scrape dates against that cursor (core/cursor.js isTransactionNew) → number-vs-ISO-string compare → NaN → silent never-new. So a gateway-side intake fix alone is NOT enough: the cursor response must serialize back to BS-2 int64 too (or the ADR amends the contract to ISO and the bot converts).
4. Spec: docs/spec/bbot-adapter-endpoints-slice.md line 51-52 (cursor example numeric), line 87 (BS-2 "statement_date_bkk = minute-level YYYYMMDDHHMM int64"). Minor doc-naming drift too: spec says statement_date_bkk, both implementations use transaction_date_bkk.

Fix owner: next-dev (gateway substrate #399 family) or architect contract amendment — NOT brew-ops (payment-gateway code). Both edges must convert symmetrically. Everything upstream of the push is GREEN on staging: BK auth (mint via #398 RPC works live), bot-config, portal scrape, parse.

---
*Added via Oracle Learn*
