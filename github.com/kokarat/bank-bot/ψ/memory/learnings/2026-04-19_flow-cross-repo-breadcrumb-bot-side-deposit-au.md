---
title: flow cross-repo breadcrumb (bot side) — deposit-auto-match-from-statement crosse
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:deposit-auto-match-from-statement, cross-repo-sync, mobiz-payment-gateway, bank-bot, scb, ktb, statement, deposit, matcher]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@5755b9a (bot) + mobiz-payment-gateway/docs/flows/deposit-auto-match-from-statement.md@212f36c (sibling ratified via mobiz thread #17)
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — deposit-auto-match-from-statement crosse

flow cross-repo breadcrumb (bot side) — deposit-auto-match-from-statement crosses from bank-bot into mobiz-payment-gateway territory at bot steps 2, 3, 7, 8, 9, 10 (three distinct Gateway crossings in the bot-side numbering: the cursor GET at step 2-3, the statement POST at step 7-8, and the balance PUT at step 9-10). Bot owns the Playwright session to the bank portal, the statement-page navigation + row scrape, the row normalization into the shared JSON shape, the direction-aware cursor filter in core/cursor.js, and the POST to /api/v1/bot/bank-statements. Mobiz-payment-gateway owns the ingest endpoint (controllers/BotConfigController.go:494-640), the matcher pipeline (services/transactionMatcher.go:27-714), and the 30-second retry ticker (scheduler/transaction_matcher.go:22-47).

Decomposition asymmetry: mobiz's flow has three bot-owned crossings on its numbering (its steps 1, 2, 3 — scrape portal page + return rows + POST to /bot/bank-statements). This bot-side doc unpacks those three crossings into 10 bot steps inside an outer loop container with one explicit alt branch — ratio 3:10 (1:3.3). Sub-steps on the bot side: ensureLoggedIn (our step 1); cursor GET/response (our 2, 3); navigate portal SCB-UI or KTB-REST (our 4); portal returns rows (our 5); parse + normalize + direction-filter (our 6); POST statements or skip (our 7, 8); PUT balance (our 9, 10). The extra depth is the natural shape of implementor-side zoom, not a coverage gap.

Counterpart: learning_2026-04-19_flow-cross-repo-breadcrumb-deposit-auto-match-fr names the reciprocal view from the mobiz-payment-gateway side. Both ratified or ratification-pending: mobiz thread #17 closed 2026-04-19; bank-bot thread #20 opened 2026-04-19 on this pass.

Contract points the bot exposes to mobiz-payment-gateway: none direct — the bot is a client, not a service. (No inbound HTTP from mobiz to bot in this flow.)

Contract points mobiz-payment-gateway exposes to the bot: GET /api/v1/bot/bank-statements/last/:account_number returning {last_in_date_bkk, last_out_date_bkk, last_date_bkk}; POST /api/v1/bot/bank-statements accepting {account_number, bank_code, system_bank_id, transactions[]} and returning {inserted, skipped}; PUT /api/v1/bot/balance accepting {account_number, bank_code, balance, available_balance}. All three require X-Bot-Secret header. The transaction row field subset is specified in the mobiz breadcrumb body and honoured by the bot at core/api.js:173 and banks/{scb,ktb}/statement.js.

Bot W8 trace: 1cfc65ab-7964-4872-9c46-d3edb0c903f4. Mobiz W8 trace: b9e04355-1599-4bfb-b001-ac7697e9586b. Note on trace chain discipline (per §Cross-repo-sync §Trace-chain): the bank-bot intra-repo trace chain does not link into the mobiz trace in arra_trace_link because the schema is a linked list, not a DAG — the cross-repo sibling is captured in this breadcrumb's prose only.

---
*Added via Oracle Learn*
