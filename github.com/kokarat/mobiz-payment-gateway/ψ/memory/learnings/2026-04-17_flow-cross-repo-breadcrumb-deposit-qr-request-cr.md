---
title: flow cross-repo breadcrumb — deposit-qr-request crosses into bank-bot territory 
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, flow, deposit-qr-request, cross-repo-sync, bank-bot]
created: 2026-04-17
source: docs/flows/deposit-qr-request.md@ed45b7e + controllers/BotConfigController.go:494-640@ed45b7e
project: github.com/kokarat/mobiz-payment-gateway
---

# flow cross-repo breadcrumb — deposit-qr-request crosses into bank-bot territory 

flow cross-repo breadcrumb — deposit-qr-request crosses into bank-bot territory at Step 6 (`POST /api/v1/bot/bank-statements`). The bot actor is implemented in `github.com/kokarat/bank-bot` (not this repo). Expected counterpart slug when bot-writer runs W8: `bank-bot/docs/flows/deposit-qr-request.md` (mirrors the same flow from the bot's side — scrape loop, authorisation with `X-Bot-Secret`, POST payload shape).

When bot-writer's W8 lands, chain the two passes with:

  arra_trace_link(prevTraceId=64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0, nextTraceId=<bot W8 trace>)

bot-writer's W8 is not yet implemented. This learning is the breadcrumb. Contract points the bot depends on:
- `POST /api/v1/bot/bank-statements` body shape: `{account_number, bank_code, system_bank_id, transactions[]}` — see `controllers/BotConfigController.go:494-640@ed45b7e`.
- Transaction row fields: `transaction_date{_bkk}`, `transaction_code`, `description`, `amount`, `direction`, `dest_bank_code`, `dest_account_{last4,name}`, `source_{bank_code,account_no}`, `fee`, `balance_after`, `raw_text`, `debit_amount`, `credit_amount`, `sequence` — see `:547-563`.
- Kicks `services.MatchNewStatements(accountNumber)` async — see `:635`. That's the join point with the deposit flow.

---
*Added via Oracle Learn*
