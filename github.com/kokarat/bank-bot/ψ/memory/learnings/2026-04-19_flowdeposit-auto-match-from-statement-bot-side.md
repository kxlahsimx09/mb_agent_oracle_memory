---
title: flow:deposit-auto-match-from-statement (bot side) crosses bank-bot into mobiz-pa
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:deposit-auto-match-from-statement, cross-repo-sync, mobiz-payment-gateway, bank-bot, scb, ktb, statement, deposit, matcher]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@5755b9a (bank-bot) + mobiz-payment-gateway/docs/flows/deposit-auto-match-from-statement.md@212f36c (sibling ratified via mobiz thread #17)
project: github.com/kokarat/bank-bot
---

# flow:deposit-auto-match-from-statement (bot side) crosses bank-bot into mobiz-pa

flow:deposit-auto-match-from-statement (bot side) crosses bank-bot into mobiz-payment-gateway — reciprocal breadcrumb. This is the bot-side half of flow:deposit-auto-match-from-statement; mobiz-payment-gateway owns the other half. Slug deposit-auto-match-from-statement appears in docs/flows/deposit-auto-match-from-statement.md on both bank-bot and mobiz-payment-gateway repos.

Boundary: bank-bot owns the Playwright session to the bank portal, the statement-page navigation + row scrape, row normalization into the shared JSON shape, direction-aware cursor filter (core/cursor.js), and the three HTTP calls to mobiz-payment-gateway — GET /api/v1/bot/bank-statements/last, POST /api/v1/bot/bank-statements, PUT /api/v1/bot/balance. mobiz-payment-gateway owns the ingest endpoint (controllers/BotConfigController.go:494-640), the matcher pipeline (services/transactionMatcher.go:27-714), and the 30-second retry ticker (scheduler/transaction_matcher.go:22-47).

Decomposition asymmetry: mobiz-payment-gateway's sibling flow for deposit-auto-match-from-statement has 3 bot-owned crossings (its numbered steps 1, 2, 3); this bank-bot flow for deposit-auto-match-from-statement unpacks those into 10 bot-side numbered steps inside an outer loop container with one alt branch. Ratio 3:10 (1:3.3) — the natural shape of implementor-side zoom relative to consumer-side abstraction. Mobiz's three crossings map to bank-bot steps thus: mobiz step 1 (scrape portal) → bank-bot steps 4 (navigate) + 5 (portal returns rows); mobiz step 2 (rows-to-bot, implicit) folds into bank-bot step 5; mobiz step 3 (POST) → bank-bot steps 7 (POST) + 8 (response). Additional bank-bot steps 1, 2, 3, 6, 9, 10 cover session-ensure, cursor GET + response, parse/normalize/filter, and the balance PUT + response.

Cross-repo counterpart for deposit-auto-match-from-statement on mobiz-payment-gateway: learning_2026-04-19_flow-cross-repo-breadcrumb-deposit-auto-match-fr. That sibling learning is the reciprocal view of this same flow from mobiz-payment-gateway's perspective — read it for the server-owned half (ingest contract, dedup keys, matcher behaviours, fee classification, retry ticker).

Ratification status for deposit-auto-match-from-statement: mobiz-payment-gateway ratified via thread #17 closed 2026-04-19 (S4 → S2). bank-bot ratification pending via thread #20 opened 2026-04-19 against bank-bot commit 5755b9a.

Contract points mobiz-payment-gateway exposes to bank-bot (all require X-Bot-Secret):
- GET /api/v1/bot/bank-statements/last/:account_number returns {last_in_date_bkk, last_out_date_bkk, last_date_bkk}
- POST /api/v1/bot/bank-statements accepts {account_number, bank_code, system_bank_id, transactions[]} returns {inserted, skipped}
- PUT /api/v1/bot/balance accepts {account_number, bank_code, balance, available_balance}
Transaction row field subset honoured by bank-bot at core/api.js:173 and banks/{scb,ktb}/statement.js; the authoritative field list is in the mobiz-payment-gateway breadcrumb body.

bank-bot W8 trace for deposit-auto-match-from-statement: 1cfc65ab-7964-4872-9c46-d3edb0c903f4.
mobiz-payment-gateway W8 trace for deposit-auto-match-from-statement: b9e04355-1599-4bfb-b001-ac7697e9586b.

Trace-chain schema limit: arra_trace_link is a linked list, not a DAG. The bank-bot intra-repo trace chain wins the prev/next slots; the mobiz-payment-gateway sibling trace id is captured in this breadcrumb's prose only. Cross-repo navigation from the bank-bot side to the mobiz-payment-gateway side is via reading this breadcrumb body and then arra_read on the mobiz-payment-gateway counterpart id.

---
*Added via Oracle Learn*
