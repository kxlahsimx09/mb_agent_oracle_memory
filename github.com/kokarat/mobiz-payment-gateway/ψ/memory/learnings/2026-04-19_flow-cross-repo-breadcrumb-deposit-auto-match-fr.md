---
title: flow cross-repo breadcrumb — deposit-auto-match-from-statement crosses into bank
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, flow, deposit-auto-match-from-statement, cross-repo-sync, bank-bot, bank-statement]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@37dfb26 + controllers/BotConfigController.go:494-640@37dfb26
project: github.com/kokarat/mobiz-payment-gateway
---

# flow cross-repo breadcrumb — deposit-auto-match-from-statement crosses into bank

flow cross-repo breadcrumb — deposit-auto-match-from-statement crosses into bank-bot territory at Steps 1 and 2 (portal scrape) and Step 9 (client callback ack; the callback target is out-of-ecosystem, not bot).

The mobiz side owns the `POST /api/v1/bot/bank-statements` ingest endpoint (`controllers/BotConfigController.go:494-640@37dfb26`) + the matcher pipeline (`services/transactionMatcher.go:27-714@37dfb26`) + the 30-second retry ticker (`scheduler/transaction_matcher.go:22-47@37dfb26`). The bank-bot side owns: Playwright session to the bank portal, statement-page scrape, row normalization, and the POST to `/api/v1/bot/bank-statements` with the JSON shape below.

JSON contract (request body of POST /api/v1/bot/bank-statements):
- `account_number` (string, required) — the system bank account being scraped
- `bank_code` (string, required) — lowercase bank key (`ktb`, `scb`, …)
- `system_bank_id` (string, required) — mongo ObjectID of the `system_banks` row
- `transactions[]` — each row carries a subset of: `transaction_date`, `transaction_date_bkk` (int64 YYYYMMDDHHMMSS), `transaction_code`, `description`, `amount`, `direction` (`in`/`out`), `dest_bank_code`, `dest_account_last4`, `dest_account_name`, `fee`, `balance_after`, `raw_text`, `debit_amount`, `credit_amount`, `source_bank_code`, `source_account_no`, `sequence`.

When `bot-writer-oracle` runs W8 on the bank-bot side, the expected counterpart slug is `statement-scrape-and-report` (or `bank-statement-scrape` — naming is the bot-writer's call). `arra_trace_link(prev="b9e04355-1599-4bfb-b001-ac7697e9586b", next=<bot-W8-trace-id>)` should chain the two passes once bank-bot adopts W8.

Two matcher behaviors that directly shape what bank-bot must deliver:
1. Matcher parses **KTB full-account** (`NNN-NNNNNNN` regex at `services/transactionMatcher.go:158`) OR **SCB last4 + source bank code** (at `:244-254, 262-263`). A bank whose `description` field carries neither pattern will always land `unmatched` — bank-bot must preserve the portal's raw description verbatim in `description` / `raw_text`.
2. Matcher filters fee rows by `transaction_code ∈ {"FE","FEESDT"}` OR description containing `ค่าธรรมเนียม` / `fee` (`controllers/BotConfigController.go:566-575`). bank-bot doesn't need to pre-classify fees, but if it does, it should use the same keywords to avoid divergence.

Dedup is count-based on `(account_number, transaction_date_bkk, amount, transaction_code)` + `balance_after` (KTB) or `description` (SCB) as extra uniqueness field. Re-scrape the same day is safe — duplicates are skipped server-side.

---
*Added via Oracle Learn*
